const axios = require('axios');
const { didApiKey } = require('../config');

const api = axios.create({
  baseURL: 'https://api.d-id.com',
  headers: { Authorization: `Bearer ${didApiKey}` }
});

async function generateAvatarVideo({ script, source_image_url, voice_url }) {
  const response = await api.post('/talks', {
    script: {
      type: 'audio',  // Puedes usar 'text' si solo tienes texto
      audio_url: voice_url, // O usa { type: 'text', input: script } si no tienes audio
      subtitles: false
    },
    source_url: source_image_url // URL pública de la imagen avatar
  });

  // response.data.id => ID del video generado
  return response.data;
}

async function getVideoStatus(talkId) {
  const response = await api.get(`/talks/${talkId}`);
  return response.data;
}

module.exports = { generateAvatarVideo, getVideoStatus };
// This file defines the D-ID service for generating avatar videos.
// It uses the D-ID API to create a video from a script and an avatar image.