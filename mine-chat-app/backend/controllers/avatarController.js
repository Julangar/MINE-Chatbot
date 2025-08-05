// controllers/avatarController.js
const admin = require('firebase-admin');
const { buildSystemPrompt } = require('../utils/generatePrompt');
const firebaseService = require('../services/firebaseService');
const openaiService = require('../services/openaiService');
const elevenlabsService = require('../services/elevenlabsService');
const didService = require('../services/didService');

// 1. Clonar voz
exports.cloneVoice = async (req, res) => {
  const { audioUrl, userId, avatarType } = req.body;

  if (!audioUrl || !userId || !avatarType) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  try {
    const voiceId = await elevenlabsService.cloneVoice(audioUrl);

    const ref = admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('audio');

    await ref.set({ voiceId });

    res.json({ success: true, voiceId });
  } catch (err) {
    console.error('Error al clonar voz:', err);
    res.status(500).json({ error: 'Error al clonar voz' });
  }
};

// 2. Generar saludo
exports.generateGreeting = async (req, res) => {
  const { userId, avatarType, language } = req.body;

  if (!userId || !avatarType || !language) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  try {
    const docRef = admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('personality');
    const snap = await docRef.get();
    if (!snap.exists) return res.status(404).json({ error: 'Avatar no encontrado' });

    const personality = snap.data();
    const prompt = buildSystemPrompt(personality, language);

    const greeting = await openaiService.getChatResponse([{ role: 'system', content: prompt }, { role: 'user', content: 'Presentate y saluda al usuario con calidez.' }]);

    await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('greeting')
      .set({ message: greeting });

    res.json({ message: greeting });
  } catch (err) {
    console.error('Error al generar saludo:', err);
    res.status(500).json({ error: 'Error al generar saludo' });
  }
};

// 3. Generar audio del saludo
exports.generateVoiceFromText = async (req, res) => {
  const { userId, avatarType } = req.body;

  if (!userId || !avatarType) {
    return res.status(400).json({ error: 'Faltan campos requeridos(user/avatarType)' });
  }

  try {
    const greetingSnap = await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('greeting')
      .get();
    console.log('Greeting Snap: ', greetingSnap.data());
    const audioSnap = await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('audio')
      .get();
      console.log('Audio Snap: ', audioSnap.data());

    if (!greetingSnap.exists || !audioSnap.exists) {
      return res.status(404).json({ error: 'Faltan saludo o voz clonada' });
    }

    const text = greetingSnap.data().message;
    const voiceId = audioSnap.data().voiceId;

    const audioUrl = await elevenlabsService.generateSpeechFromClonedVoice(text, userId, avatarType, voiceId);

    await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('audioClone')
      .set({ audioUrl });

    res.json({ voiceUrl: audioUrl });
  } catch (err) {
    console.error('Error al generar voz:', err);
    res.status(500).json({ error: 'Error al generar voz del saludo' });
  }
};

// 4. Generar video
exports.generateAvatarVideo = async (req, res) => {
  const { userId, avatarType, language } = req.body;

  if (!userId || !avatarType || !language) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  try {
    const docRef = admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('personality');
    const snap = await docRef.get();
    
    if (!snap.exists) return res.status(404).json({ error: 'Avatar no encontrado' });

    const data = snap.data();
    const imageUrl = firebaseService.getPublicUrl(data.imageUrl);

    const audioSnap = await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('audioClone')
      .get();

    const voice= audioSnap.data()?.audioUrl;
    const voiceUrl = firebaseService.getPublicUrl(voice);

    const greetingSnap = await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('greeting')
      .get();
    console.log('Greeting Snap: ', greetingSnap.data());

    const voiceSnap = await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('audio')
      .get();
      console.log('Audio Snap: ', voiceSnap.data());
    const voiceId = voiceSnap.data().voiceId;

    const videoResp = await didService.generateAvatarVideo({
      source_image_url: imageUrl,
      //voice_url: voiceUrl,
      text: greetingSnap.data()?.message,
      voice_id: voiceId
    });

    const videoUrl = videoResp?.result_url;

    await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('video')
      .set({ videoUrl });

    res.json({ success: true, videoUrl });
  } catch (err) {
    console.error('Error al generar video:', err);
    res.status(500).json({ error: 'Error al generar video del avatar' });
  }
};
