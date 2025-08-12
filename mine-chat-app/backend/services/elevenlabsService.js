const axios = require('axios');
const admin = require('firebase-admin');
const { uploadAudioBuffer } = require('../services/cloudinaryService');
const https = require('https');
const FormData = require('form-data');
const fs = require('fs');
const os = require('os');
const { createWriteStream } = require('fs');
const path = require('path');
const { elevenlabsKey } = require('../config');
const { bucket } = require('../config/firebase');
const firebaseService = require('./firebaseService');
const { v4: uuidv4 } = require('uuid');

const api = axios.create({
  baseURL: 'https://api.elevenlabs.io/v1',
  headers: { 'xi-api-key': elevenlabsKey }
});



async function cloneVoice(audioUrl, name) {
  try {
    const tempPath = path.join(os.tmpdir(), `${name}_${Date.now()}.mp3`);
    await firebaseService.downloadAudio(audioUrl, tempPath);

    const formData = new FormData();
    formData.append('name', `${name}_${Date.now()}`);
    formData.append('description', 'Voice cloned from user sample');
    formData.append('files', fs.createReadStream(tempPath));

    const response = await axios.post('https://api.elevenlabs.io/v1/voices/add', formData, {
      headers: {
        ...formData.getHeaders(),
        'xi-api-key': elevenlabsKey,
      }
    });

    return response.data.voice_id;
  } catch (err) {
    console.error('❌ Error en cloneVoice:', err.response?.data || err.message);
    throw new Error('Error al clonar voz');
  }
}

async function textToSpeech(text, userId, voiceId) {
  const url = `/text-to-speech/${voiceId}`;
  const response = await api.post(url,
    {
      text,
      model_id: 'eleven_multilingual_v2',
      voice_settings: {
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

async function generateSpeechFromClonedVoice(text, userId, avatarType, voiceId) {
  try {
    const response = await api.post(
      `/text-to-speech/${voiceId}`,
      {
        text,
        model_id: 'eleven_multilingual_v2',
        voice_settings: {
          stability: 0.25,
          similarity_boost: 0.95,
          style: 0.3,
          use_speaker_boost: true
        }
      },
      { responseType: 'arraybuffer' }
    );


    const buffer = Buffer.from(response.data, 'binary');

    // Subir directamente a Cloudinary sin guardar en disco. Cloudinary trata
    // los archivos de audio como 'video', por lo que reutilizamos la función
    // uploadAudioBuffer definida en cloudinaryService. La función devuelve
    // la URL segura del audio.
    const url = await uploadAudioBuffer(buffer, userId, avatarType);
    return url;
  } catch (error) {
    console.error('❌ Error en generateSpeechFromClonedVoice:', error?.response?.data || error.message);
    throw new Error('Error al generar y subir el audio con voz clonada');
  }
}

/*
  // 1. Guardar archivo temporalmente en el sistema local
  const tempDir = os.tmpdir();
  const filename = `audio_${uuidv4()}.mp3`;
  const tempPath = path.join(tempDir, filename);
    fs.writeFileSync(tempPath, buffer);

    // 2. Definir ruta en Firebase Storage
    const destinationPath = `avatars/${userId}/${avatarType}/audioClon/${filename}`;

    const bucket = admin.storage().bucket();

    // 3. Subir archivo
    await bucket.upload(tempPath, {
      destination: destinationPath,
      contentType: 'audio/mpeg',
    });

    // 4. Eliminar archivo temporal
    fs.unlinkSync(tempPath);

    // 5. Obtener URL pública
    const file = bucket.file(destinationPath);
    const [url] = await file.getSignedUrl({
      action: 'read',
      expires: Date.now() + 1000 * 60 * 60 * 24 * 7, // 7 días
    });

    return url;
  } catch (error) {
    console.error('❌ Error en generateSpeechFromClonedVoice:', error?.response?.data || error.message);
    throw new Error('Error al generar y subir el audio con voz clonada');
  }
}*/


module.exports = {
  cloneVoice,
  textToSpeech,
  generateSpeechFromClonedVoice
};
