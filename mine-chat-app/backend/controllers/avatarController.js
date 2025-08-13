// controllers/avatarController.js
const admin = require('firebase-admin');
const { buildSystemPrompt } = require('../utils/generatePrompt');
const firebaseService = require('../services/firebaseService');
const openaiService = require('../services/openaiService');
const elevenlabsService = require('../services/elevenlabsService');
const didService = require('../services/didService');
const { uploadImage, uploadAudio } = require('../services/cloudinaryService');
const https = require('https');
const FormData = require('form-data');
const fs = require('fs');
const os = require('os');
const path = require('path');
// Controlador para manejar las operaciones relacionadas con los avatares

// Elimina etiquetas SSML (<break>, <emphasis>, etc.) pero mantiene los emojis.
function stripSsmlTags(text) {
  if (!text || typeof text !== 'string') return text;
  return text.replace(/<[^>]+>/g, '');
}

// Elimina emojis (rangos Unicode habituales).
function removeEmojis(text) {
  if (!text || typeof text !== 'string') return text;
  return text.replace(/[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E6}-\u{1F1FF}\u{2700}-\u{27BF}\u{1FA70}-\u{1FAFF}]/gu, '');
}

exports.uploadImageToCloudinary = async (req, res) => {
  const { filePath, userId, avatarType } = req.body;

  if (!filePath || !userId || !avatarType) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  try {
    const imageUrl = await uploadImage(filePath, userId, avatarType);
    res.json({ success: true, imageUrl });
  } catch (err) {
    console.error('Error al subir imagen a Cloudinary:', err);
    res.status(500).json({ error: 'Error al subir imagen a Cloudinary' });
  }
};

exports.uploadAudioToCloudinary = async (req, res) => {
  const { filePath, userId, avatarType } = req.body;

  if (!filePath || !userId || !avatarType) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  try {
    const audioUrl = await uploadAudio(filePath, userId, avatarType);
    res.json({ success: true, audioUrl });
  } catch (err) {
    console.error('Error al subir audio a Cloudinary:', err);
    res.status(500).json({ error: 'Error al subir audio a Cloudinary' });
  }
};

exports.uploadVideoToCloudinary = async (req, res) => {
  const { filePath, userId, avatarType } = req.body;

  if (!filePath || !userId || !avatarType) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  try {
    const audioUrl = await uploadVideo(filePath, userId, avatarType);
    res.json({ success: true, audioUrl });
  } catch (err) {
    console.error('Error al subir audio a Cloudinary:', err);
    res.status(500).json({ error: 'Error al subir audio a Cloudinary' });
  }
};


// 1. Clonar voz
exports.cloneVoice = async (req, res) => {
  const { audioUrl, userId, avatarType } = req.body;

  if (!audioUrl || !userId || !avatarType) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  const avatarPersonality = admin.firestore()
    .collection('avatars')
    .doc(userId)
    .collection(avatarType)
    .doc('personality');

  const name = (await avatarPersonality.get()).data()?.name;
  const audioSnap = await admin.firestore()
    .collection('avatars')
    .doc(userId)
    .collection(avatarType)
    .doc('audio')
    .get();

  if (audioSnap.exists) {
      return res.status(200).json({ success: true, voiceId: audioSnap.data().voiceId });
  } else {
    try {
      const voiceId = await elevenlabsService.cloneVoice(audioUrl, name);
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
    const userName = personality.name || 'Usuario';
    const prompt = buildSystemPrompt(personality, language);

    const greeting = await openaiService.getChatResponse([
      { role: 'system', content: prompt }, 
      { role: 'user', 
        content: `Saluda de la siguiente manera: "Hola ${userName}, `+
        '<phoneme alphabet="ipa" ph="maɪn">MINE</phoneme> nos da una nueva oportunidad de estar cerca, '+
        'y esta vez para siempre. Te he extrañado y siempre estás '+
        'en mi corazón. Ahora que te tomaste el tiempo de crearme, '+
        'podremos escribirnos en chat, hablar por voz o vernos en video, '+
        'todo en línea y todo el tiempo que lo desees. '+
        'Con cada frase estaremos más cerca, porque todo queda en mi memoria, '+
        'por lo que cada segundo será más real y la conversación más cercana '+
        'a lo que esperas, sin límites. Todo lo que hablemos estará totalmente '+
        'encriptado y nadie más lo sabrá, nunca. Finalmente, '+
        'las transacciones de pago son totalmente seguras. '+
        'Si me querías cerca, acá estoy para hacer un poco mejor tu vida. '+
        'Disfrutemos este nuevo comienzo. Me has recreado, para siempre.".'}
    ]);
    const cleanGreeting = stripSsmlTags(greeting);
    const textForAudio = removeEmojis(greeting);

    await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('greeting')
      .set({ message: cleanGreeting, messageForAudio: textForAudio });

    res.json({ message: cleanGreeting });
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

    const text = greetingSnap.data().messageForAudio;
    const voiceId = audioSnap.data().voiceId;

    const audioUrl = await elevenlabsService.generateSpeechFromClonedVoice(text, userId, avatarType, voiceId);

    await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('audioClone')
      .set({ audioUrl });

    res.json({ voiceUrl: audioUrl });
    console.log('Clone audio: ', audioUrl);
  } catch (err) {
    console.error('Error al generar voz:', err);
    res.status(500).json({ error: 'Error al generar voz del saludo' });
  }
};

// 4. Generar video con texto y usando elevenlabs NO ES FUNCIONAL
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

    const voice= audioSnap.data().audioUrl;
    const voiceUrl = firebaseService.getPublicUrl(voice);

    const greetingSnap = await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('greeting')
      .get();
    const greeting = greetingSnap.data().message;

    const voiceSnap = await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('audio')
      .get();
    const voiceId = voiceSnap.data().voiceId;

    const videoResp = await didService.generateAvatarVideo({
      source_image_url: imageUrl,
      //voice_url: voiceUrl,
      text: greeting,
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

//5. Generar video con audio
exports.generateAvatarVideoWithAudio = async (req, res) => {
  const { userId, avatarType, language } = req.body;

  if (!userId || !avatarType || !language) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  try {
    // 1. Obtener imagen
    const docRef = admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('personality');
    const imageSnap = await docRef.get();
    if (!imageSnap.exists) return res.status(404).json({ error: 'Avatar no encontrado' });
    const image = imageSnap.data().imageUrl;

    // 2. Subir imagen a Cloudinary
    //const resultImage = await uploadImage(image, userId, avatarType);
    //if (!resultImage) return res.status(500).json({ error: 'Error uploading to Cloudinary (image)' });
    //const imageUrl = resultImage.secure_url;
    console.log('Image: ', image);

    // 3. Obtener audio
    const audioSnap = await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('audioClone')
      .get();
    if (!audioSnap.exists) return res.status(404).json({ error: 'Audio no encontrado' });
    const voice = audioSnap.data().audioUrl;
    //const tempPathAudio = path.join(os.tmpdir(), `audioClon_${Date.now()}.mp3`);
    //await firebaseService.downloadAudio(voice, tempPathAudio);

    // 4. Subir audio a Cloudinary
    //const resultAudio = await uploadAudio(voice, userId, avatarType);
    //if (!resultAudio) return res.status(500).json({ error: 'Error uploading to Cloudinary (audio)' });
    //const audioUrl = resultAudio.secure_url;
    console.log('Audio Cloudinary: ', voice);
    // 5. Generar video con D-ID
    const videoResp = await didService.generateAvatarVideoWithAudio({
      source_image_url: image,
      audio_url: voice,
    });
    const talkId = videoResp?.id;
    if (!talkId) {
      return res.status(500).json({ error: 'No se generó el video, id es undefined.' });
    }
    const videoUrl = await didService.waitForVideoResult(talkId);
    if (!videoUrl) {
      return res.status(500).json({ error: 'No se generó el video, videoUrl es undefined.' });
    }
    // 6. Guardar URL de video en Firestore
    await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('personality')
      .update({ videoUrl : videoUrl });
    await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('video')
      .set({ videoUrl });
    console.log('Video Clon: ', videoUrl);
    // 7. RESPUESTA ÚNICA AL FINAL
    return res.json({
      success: true,
      image,
      audio: voice,
      videoUrl
    });
  } catch (err) {
    console.error('Error al generar video:', err);
    return res.status(500).json({ error: 'Error al generar video del avatar', details: err.message });
  }
};
