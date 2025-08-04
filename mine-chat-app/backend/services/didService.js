const axios = require('axios');
const { didApiKey } = require('../config');

const api = axios.create({
  baseURL: 'https://api.d-id.com',
  headers: { Authorization: `Bearer ${didApiKey}` }
});


async function generateAvatarVideo({ source_image_url, voice_url, language }) {
  if (!source_image_url || !voice_url) {
    throw new Error('Faltan parámetros requeridos para generar el video');
  }

  try {
    const response = await api.post('/talks', {
      source_url: source_image_url,
      script: {
        type: 'audio',
        audio_url: voice_url,
        subtitles: false
      },
      config: {
        fluent: true,
        pad_audio: 0.2
      }
    });

    return response.data; // Este objeto contiene el `id` (talkId) y otros campos como `status_url`
  } catch (error) {
    console.error('❌ Error en generateAvatarVideo:', error.response?.data || error.message);
    throw new Error('Error al generar video con D-ID');
  }
}

async function getVideoStatus(talkId) {
  try {
    const response = await api.get(`/talks/${talkId}`);
    return response.data;
  } catch (error) {
    console.error('❌ Error en getVideoStatus:', error.response?.data || error.message);
    throw new Error('Error al consultar el estado del video');
  }
}

module.exports = { generateAvatarVideo, getVideoStatus };
// This file defines the D-ID service for generating avatar videos.
// It uses the D-ID API to create a video from a script and an avatar image.