const axios = require('axios');
const { didApiKey } = require('../config');

const api = axios.create({
  baseURL: 'https://api.d-id.com',
  headers: { Authorization: `Bearer ${didApiKey}` }
});

async function generateAvatarVideo({ script, source_image_url, voice_url }) {
  const scriptPayload = voice_url
    ? { type: 'audio', audio_url: voice_url, subtitles: false }
    : { type: 'text', input: script, subtitles: false, provider: { type: 'microsoft', voice_id: 'en-US-JennyNeural' } }; // ejemplo si se usara texto

  const response = await api.post('/talks', {
    script: scriptPayload,
    source_url: source_image_url
  });

  return response.data;
}

async function getVideoStatus(talkId) {
  const response = await api.get(`/talks/${talkId}`);
  return response.data;
}

module.exports = { generateAvatarVideo, getVideoStatus };
// This file defines the D-ID service for generating avatar videos.
// It uses the D-ID API to create a video from a script and an avatar image.