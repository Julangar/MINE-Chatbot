const axios = require('axios');
const fs = require('fs');
const path = require('path');
const { elevenlabsKey } = require('../config');
const { bucket } = require('../config/firebase');

const api = axios.create({
  baseURL: 'https://api.elevenlabs.io/v1',
  headers: { 'xi-api-key': elevenlabsKey }
});

// Cambia "voice_id" por el de tu voz (puedes obtenerlo con listVoices)
async function textToSpeech(text, userId) {
  const voice_id = 'EXAVITQu4vr4xnSDxMaL'; // usa tu voz o deja la por defecto
  //const url = `/text-to-speech/${voice_id}`;
  const response = await api.post(url,
    { text, model_id: 'eleven_multilingual_v2', voice_settings: { stability: 0.5, similarity_boost: 0.75 } },
    { responseType: 'arraybuffer' }
  );

  // Guarda el audio en Firebase Storage
  const fileName = `voices/${userId}-${Date.now()}.mp3`;
  const tempPath = path.join(__dirname, fileName);
  fs.writeFileSync(tempPath, response.data);

  await bucket.upload(tempPath, { destination: fileName, public: true });

  // Elimina archivo temporal
  fs.unlinkSync(tempPath);

  // Obtén la URL pública del archivo subido
  const file = bucket.file(fileName);
  const [url] = await file.getSignedUrl({ action: 'read', expires: Date.now() + 1000 * 60 * 60 }); // 1 hora
  return url;
}

module.exports = { textToSpeech };
