const admin = require('firebase-admin');
const { buildSystemPrompt } = require('../utils/generatePrompt');
const openaiService = require('../services/openaiService');
const elevenlabsService = require('../services/elevenlabsService');
const didService = require('../services/didService');
const firebaseService = require('../services/firebaseService');

// Generates an initial greeting for a user and stores it in the conversation
// history. This function remains unchanged from the original implementation
// except for the addition of conversation storage so that subsequent messages
// include the greeting in the context.
async function generateGreeting(req, res) {
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

    const greeting = await openaiService.getChatResponse([
      { role: 'system', content: prompt },
      { role: 'user', content: 'Presentate y saluda de forma amable al usuario.' }
    ]);

    // Store the greeting in the conversations collection so that it can be
    // replayed later. We use a fixed document id ("greeting") so that the
    // greeting can be updated without creating multiple records.
    await admin.firestore()
      .collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .doc('greeting')
      .set({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        userMessage: 'Presentate y saluda de forma amable al usuario.',
        avatarResponse: greeting
      });

    res.json({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isUser: true,
      text: 'Saludo de inicio con el avatar',
      response: greeting
    });
  } catch (err) {
    console.error('Error al generar saludo:', err);
    res.status(500).json({ error: 'Error al generar saludo' });
  }
};

// Handles a text chat message. This function reconstructs the previous
// conversation (up to 20 exchanges) so that the OpenAI model has context and
// stores the new exchange for future turns.
async function sendMessage(req, res) {
  const { userId, avatarType, message, userLanguage } = req.body;

  // Basic validation of required fields
  if (!userId || !avatarType || !message || !userLanguage) {
    return res.status(400).json({ error: 'Faltan parámetros requeridos.' });
  }

  try {
    const db = admin.firestore();
    // Load the personality for this avatar
    const personalityRef = db.collection('avatars').doc(userId).collection(avatarType).doc('personality');
    const personalitySnap = await personalityRef.get();
    if (!personalitySnap.exists) {
      return res.status(404).json({ error: 'Avatar no encontrado.' });
    }
    const personality = personalitySnap.data();
    const systemPrompt = buildSystemPrompt(personality, userLanguage);

    // Build the conversation history: system prompt -> historical pairs -> current message
    const messages = [];
    messages.push({ role: 'system', content: systemPrompt });
    const historySnap = await db.collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .orderBy('timestamp')
      .limit(20)
      .get();
    historySnap.forEach(doc => {
      const data = doc.data();
      if (data.userMessage) messages.push({ role: 'user', content: data.userMessage });
      if (data.avatarResponse) messages.push({ role: 'assistant', content: data.avatarResponse });
    });
    messages.push({ role: 'user', content: message });

    // Request a completion from the OpenAI service
    const gptResponse = await openaiService.getChatResponse(messages);

    // Persist the conversation
    await db.collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        userMessage: message,
        avatarResponse: gptResponse
      });

    return res.json({ response: gptResponse });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al generar respuesta del avatar.' });
  }
}

// Responds with synthesized speech using the cloned voice of the avatar. This
// endpoint behaves similarly to sendMessage but additionally generates an MP3
// using ElevenLabs and returns its URL. The conversation is saved with the
// audioUrl for later reference.
async function sendAudio(req, res) {
  const { userId, avatarType, message, userLanguage } = req.body;

  if (!userId || !avatarType || !message || !userLanguage) {
    return res.status(400).json({ error: 'Faltan parámetros requeridos.' });
  }

  try {
    const db = admin.firestore();
    const personalityRef = db.collection('avatars').doc(userId).collection(avatarType).doc('personality');
    const personalitySnap = await personalityRef.get();
    if (!personalitySnap.exists) {
      return res.status(404).json({ error: 'Avatar no encontrado.' });
    }
    const personality = personalitySnap.data();
    const systemPrompt = buildSystemPrompt(personality, userLanguage);

    // Rebuild conversation history
    const messages = [];
    messages.push({ role: 'system', content: systemPrompt });
    const historySnap = await db.collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .orderBy('timestamp')
      .limit(20)
      .get();
    historySnap.forEach(doc => {
      const data = doc.data();
      if (data.userMessage) messages.push({ role: 'user', content: data.userMessage });
      if (data.avatarResponse) messages.push({ role: 'assistant', content: data.avatarResponse });
    });
    messages.push({ role: 'user', content: message });

    const gptResponse = await openaiService.getChatResponse(messages);

    // Retrieve voiceId
    const voiceSnap = await db.collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('audio')
      .get();
    const voiceId = voiceSnap.exists ? voiceSnap.data().voiceId : null;
    if (!voiceId) {
      return res.status(400).json({ error: 'No se ha clonado una voz para este avatar.' });
    }

    // Generate speech from the GPT response
    const audioUrl = await elevenlabsService.generateSpeechFromClonedVoice(
      gptResponse,
      userId,
      avatarType,
      voiceId
    );

    // Save the conversation with audio reference
    await db.collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        userMessage: message,
        avatarResponse: gptResponse,
        audioUrl: audioUrl
      });

    return res.json({ response: gptResponse, audioUrl });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al generar la respuesta de audio.' });
  }
}

// Responds with a talking avatar video generated from the GPT response. This
// endpoint generates speech first and then uses D‑ID to produce a video
// synchronized with the avatar image. The resulting audio and video URLs are
// included in the response and saved in the conversation record.
async function sendVideo(req, res) {
  const { userId, avatarType, message, userLanguage } = req.body;

  if (!userId || !avatarType || !message || !userLanguage) {
    return res.status(400).json({ error: 'Faltan parámetros requeridos.' });
  }

  try {
    const db = admin.firestore();
    const personalityRef = db.collection('avatars').doc(userId).collection(avatarType).doc('personality');
    const personalitySnap = await personalityRef.get();
    if (!personalitySnap.exists) {
      return res.status(404).json({ error: 'Avatar no encontrado.' });
    }
    const personality = personalitySnap.data();
    const systemPrompt = buildSystemPrompt(personality, userLanguage);

    // Build history
    const messages = [];
    messages.push({ role: 'system', content: systemPrompt });
    const historySnap = await db.collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .orderBy('timestamp')
      .limit(20)
      .get();
    historySnap.forEach(doc => {
      const data = doc.data();
      if (data.userMessage) messages.push({ role: 'user', content: data.userMessage });
      if (data.avatarResponse) messages.push({ role: 'assistant', content: data.avatarResponse });
    });
    messages.push({ role: 'user', content: message });

    const gptResponse = await openaiService.getChatResponse(messages);

    // Retrieve image path and convert to URL
    const imagePath = personality.imageUrl;
    if (!imagePath) {
      return res.status(400).json({ error: 'No se ha configurado una imagen para este avatar.' });
    }
    const imageUrl = firebaseService.getPublicUrl(imagePath);

    // Retrieve voiceId
    const voiceSnap = await db.collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('audio')
      .get();
    const voiceId = voiceSnap.exists ? voiceSnap.data().voiceId : null;
    if (!voiceId) {
      return res.status(400).json({ error: 'No se ha clonado una voz para este avatar.' });
    }

    // Generate audio
    const audioUrl = await elevenlabsService.generateSpeechFromClonedVoice(
      gptResponse,
      userId,
      avatarType,
      voiceId
    );

    // Create video from image and audio
    const videoResp = await didService.generateAvatarVideoWithAudio({
      source_image_url: imageUrl,
      audio_url: audioUrl
    });
    const talkId = videoResp?.id;
    if (!talkId) {
      return res.status(500).json({ error: 'No se pudo generar el video.' });
    }
    const videoUrl = await didService.waitForVideoResult(talkId);
    if (!videoUrl) {
      return res.status(500).json({ error: 'El video no estuvo listo a tiempo.' });
    }

    // Save conversation
    await db.collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        userMessage: message,
        avatarResponse: gptResponse,
        audioUrl,
        videoUrl
      });

    return res.json({ response: gptResponse, audioUrl, videoUrl });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al generar la respuesta en video.' });
  }
}

module.exports = {
  generateGreeting,
  sendMessage,
  sendAudio,
  sendVideo
};