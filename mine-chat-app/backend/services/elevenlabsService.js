
const axios = require('axios');
const fs = require('fs');
const path = require('path');
const { elevenlabsKey } = require('../config');
const { bucket } = require('../config/firebase');

const api = axios.create({
  baseURL: 'https://api.elevenlabs.io/v1',
  headers: { 'xi-api-key': elevenlabsKey }
});

// Clona una voz desde un archivo público de Firebase Storage
async function cloneVoice(userId, audioUrl) {
  const response = await api.post('/voices/add', {
    name: `voice-${userId}`,
    description: 'Voice cloned from user sample',
    files: [audioUrl]
  });

  return response.data.voice_id;
}

// Convierte texto a voz con un voice_id (sintetiza y guarda en Firebase Storage)
async function textToSpeech(text, userId, voiceId = 'EXAVITQu4vr4xnSDxMaL') {
  const url = `/text-to-speech/${voiceId}`;
  const response = await api.post(url,
    {
      text,
      model_id: 'eleven_multilingual_v2',
      voice_settings: {
        stability: 0.5,
        similarity_boost: 0.75
      }
    },
    { responseType: 'arraybuffer' }
  );

  // Guarda el audio en Firebase Storage
  const fileName = `voices/${userId}-${Date.now()}.mp3`;
  const tempPath = path.join(__dirname, fileName);
  fs.writeFileSync(tempPath, response.data);

  await bucket.upload(tempPath, { destination: fileName, public: true });

  fs.unlinkSync(tempPath); // eliminar archivo temporal

  const file = bucket.file(fileName);
  const [urlSigned] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 1000 * 60 * 60 // 1 hora
  });

  return urlSigned;
}

module.exports = { cloneVoice, textToSpeech };
