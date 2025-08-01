const axios = require('axios');
const fs = require('fs');
const path = require('path');
const { elevenlabsKey } = require('../config');
const { bucket } = require('../config/firebase');
const firebaseService = require('./firebaseService');
const { v4: uuidv4 } = require('uuid');

const api = axios.create({
  baseURL: 'https://api.elevenlabs.io/v1',
  headers: { 'xi-api-key': elevenlabsKey }
});

async function cloneVoice(userId, audioUrl) {
  const response = await api.post('/voices/add', {
    name: `voice-${userId}`,
    description: 'Voice cloned from user sample',
    files: [audioUrl]
  });

  return response.data.voice_id;
}

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

  const fileName = `voices/${userId}-${Date.now()}.mp3`;
  const tempPath = path.join(__dirname, fileName);
  fs.writeFileSync(tempPath, response.data);

  await bucket.upload(tempPath, { destination: fileName, public: true });
  fs.unlinkSync(tempPath);

  const file = bucket.file(fileName);
  const [urlSigned] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 1000 * 60 * 60
  });

  return urlSigned;
}

async function generateSpeechFromClonedVoice(text, userId, voiceId) {
  const response = await api.post(`/text-to-speech/${voiceId}`, {
    text,
    model_id: 'eleven_monolingual_v1'
  }, {
    responseType: 'arraybuffer'
  });

  const buffer = Buffer.from(response.data, 'binary');
  const audioUrl = await firebaseService.uploadBuffer(buffer, `voices/${userId}/${uuidv4()}.mp3`, 'audio/mpeg');
  return audioUrl;
}

module.exports = {
  cloneVoice,
  textToSpeech,
  generateSpeechFromClonedVoice
};
