const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');
const { buildSystemPrompt } = require('../utils/generatePrompt');
const openaiService = require('../services/openaiService');
const elevenlabsService = require('../services/elevenlabsService');
const didService = require('../services/didService');


// Encriptación para las conversaciones. Usamos AES-256-CBC con una clave
// secreta almacenada en variables de entorno para proteger el contenido de
// las conversaciones en Firebase. La función encryptText devuelve el IV y
// el texto cifrado separados por dos puntos. La función decryptText invierte
// el proceso. Para compatibilidad con registros antiguos no cifrados, la
// función maybeDecrypt intentará descifrar sólo si el texto contiene el
// separador ':' y fallará de forma silenciosa.
const crypto = require('crypto');
const {CONV_SECRET, ENC_ALGORITHM} = require('../config'); // 64 hex (32 bytes)

function encryptText(plain) {
  if (!plain) return plain;
  const iv = crypto.randomBytes(16);
  const key = Buffer.from(CONV_SECRET, 'hex');
  const cipher = crypto.createCipheriv(ENC_ALGORITHM, key, iv);
  let encrypted = cipher.update(String(plain), 'utf8', 'hex');
  encrypted += cipher.final('hex');
  return iv.toString('hex') + ':' + encrypted;
}

function decryptText(ciphered) {
  const [ivHex, encryptedData] = ciphered.split(':');
  const iv = Buffer.from(ivHex, 'hex');
  const key = Buffer.from(CONV_SECRET, 'hex');
  const decipher = crypto.createDecipheriv(ENC_ALGORITHM, key, iv);
  let decrypted = decipher.update(encryptedData, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
}

function maybeDecrypt(text) {
  if (typeof text !== 'string') return text;
  if (!text.includes(':')) return text;
  try {
    return decryptText(text);
  } catch (e) {
    return text;
  }
}

// Generates an initial greeting for a user and stores it in the conversation
// history. This function remains unchanged from the original implementation
// except for the addition of conversation storage so that subsequent messages
// include the greeting in the context.

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


async function generateGreeting(req, res) {
  const { userId, avatarType, userLanguage } = req.body;

  if (!userId || !avatarType || !userLanguage) {
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
    const prompt = buildSystemPrompt(personality, userLanguage);

    const greeting = await openaiService.getChatResponse([
      { role: 'system', content: prompt }, 
      { role: 'user', 
        content: 'Presentate y saluda de forma amable al usuario.' }
    ]);
    const cleanGreeting = stripSsmlTags(greeting);

    // Store the greeting in the conversations collection so that it can be
    // replayed later. We use a fixed document id ("greeting") so that the
    // greeting can be updated without creating multiple records.
    await admin.firestore()
      .collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .doc('messages')
      .set({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        userMessage: encryptText('Presentate y saluda de forma amable al usuario.'),
        avatarResponse: encryptText(cleanGreeting)
      });
    
      res.json({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        isUser: true,
        text: 'Saludo de inicio con el avatar',
        response: cleanGreeting
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
      if (data.userMessage) {
        messages.push({ role: 'user', content: maybeDecrypt(data.userMessage) });
      }
      if (data.avatarResponseClean) {
        messages.push({ role: 'assistant', content: maybeDecrypt(data.avatarResponseClean) });
      }
    });
    messages.push({ role: 'user', content: message });
    
    // Request a completion from the OpenAI service
    const gptResponse = await openaiService.getChatResponse(messages);
    const cleanResponse = stripSsmlTags(gptResponse);

    // Persist the conversation
    await db.collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        userMessage: encryptText(message),
        avatarResponse: encryptText(gptResponse),
        avatarResponseClean: encryptText(cleanResponse)
      });

    return res.json({ response: cleanResponse });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al generar respuesta del avatar.' });
  }
}

// Handles an audio message from the user. This function transcribes the audio
async function sendAudioMessage(req, res) {
  // Espera: multipart/form-data con campo 'audio' (multer), y en body:
  // userId, avatarType, userLanguage, audioFile
  const { userId, avatarType, audioFile, userLanguage } = req.body;
  if (!userId || !avatarType || !userLanguage || !audioFile) {
    return res.status(400).json({ error: 'Faltan parámetros o archivo de audio.' });
  }

  try {
    // 1) Transcribir con Whisper
    const userText = await transcribeAudio(audioFile, userLanguage);
    fs.unlink(audioFile, ()=>{});
    if (!userText) {
      return res.status(400).json({ error: 'No se pudo transcribir el audio.' });
    }
    if (userText.length > 320) {
      return res.status(400).json({ error: 'El mensaje transcrito excede 320 caracteres.' });
    }
    return res.json({ userText });
  } catch (err) {
    console.error('sendAudioMessage error:', err);
    return res.status(500).json({ error: 'Error al procesar mensaje de audio.' });
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
      if (data.userMessage) {
        messages.push({ role: 'user', content: maybeDecrypt(data.userMessage) });
      }
      if (data.avatarResponseClean) {
        messages.push({ role: 'assistant', content: maybeDecrypt(data.avatarResponseClean) });
      }
    });
    messages.push({ role: 'user', content: message });
    const gptResponse = await openaiService.getChatResponse(messages);
    const cleanResponse = stripSsmlTags(gptResponse);
    const textForAudio = removeEmojis(gptResponse);
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
      textForAudio,
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
        userMessage: encryptText(message),
        avatarResponse: encryptText(gptResponse),
        avatarResponseClean: encryptText(cleanResponse),
        audioUrl: audioUrl
      });

    return res.json({ response: cleanResponse, audioUrl });
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
      if (data.userMessage) {
        messages.push({ role: 'user', content: maybeDecrypt(data.userMessage) });
      }
      if (data.avatarResponseClean) {
        messages.push({ role: 'assistant', content: maybeDecrypt(data.avatarResponseClean) });
      }
    });
    messages.push({ role: 'user', content: message });

    const gptResponse = await openaiService.getChatResponse(messages);
    const cleanResponse = stripSsmlTags(gptResponse);
    const textForAudio = removeEmojis(gptResponse);
    // Retrieve image path and convert to URL
    const imagePath = personality.imageUrl;
    if (!imagePath) {
      return res.status(400).json({ error: 'No se ha configurado una imagen para este avatar.' });
    }
    const imageUrl = imagePath
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
      textForAudio,
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
        userMessage: encryptText(message),
        avatarResponse: encryptText(gptResponse),
        avatarResponseClean: encryptText(cleanResponse),
        audioUrl,
        videoUrl
      });

    return res.json({ response: cleanResponse, audioUrl, videoUrl });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al generar la respuesta en video.' });
  }
}

// Retrieves the conversation history for a given user and avatar.
// The returned data includes the decrypted user messages and avatar
// responses. Audio and video URLs are omitted because the mobile client
// should not replay them for privacy reasons. Clients can call this
// endpoint instead of reading directly from Firestore. Query parameters
// `userId` and `avatarType` must be provided.
async function getConversationHistory(req, res) {
  const { userId, avatarType } = req.query;
  if (!userId || !avatarType) {
    return res.status(400).json({ error: 'Faltan parámetros requeridos.' });
  }
  try {
    const db = admin.firestore();
    const snapshot = await db.collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .orderBy('timestamp')
      .get();
    const history = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      // Only include text fields; ignore audio/video URLs for security.
      history.push({
        userMessage: data.userMessage ? maybeDecrypt(data.userMessage) : null,
        avatarResponse: data.avatarResponseClean ? maybeDecrypt(data.avatarResponseClean) : null
      });
    });
    return res.json({ messages: history });
  } catch (err) {
    console.error('Error al obtener historial:', err);
    return res.status(500).json({ error: 'Error al obtener historial.' });
  }
}

module.exports = {
  generateGreeting,
  sendMessage,
  sendAudio,
  sendVideo,
  getConversationHistory
};
