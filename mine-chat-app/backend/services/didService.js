const axios = require('axios');
const { didApiKey , elevenlabsKey} = require('../config');


const api = axios.create({
  baseURL: 'https://api.d-id.com',
  headers: { authorization: `Basic ${didApiKey}`,
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'x-api-key-external': JSON.stringify({ elevenlabs: elevenlabsKey }),
  }
});

async function uploadImage(image) {
  try {
    const response = await api.post('/images', image);
    return response.data;
  } catch (error) {
    const message = extractErrorMessage(error);
    console.error('❌ Error en uploadImage:', message);
    throw new Error('Error al subir imagen');
  }
}

async function generateAvatarVideo({ source_image_url, voice_id, text }) {
  if (!source_image_url || !voice_id || !text) {
    throw new Error('Faltan parámetros requeridos para generar el video');
  }
  const payload = {
    source_url: source_image_url,
    script: {
      type: 'text',
      input: text,
      subtitles: false,
      provider: {
        type: 'elevenlabs',
        voice_id: voice_id
      }
    },
    config: {
      fluent: false
    }
  };

  try {
    const response = await api.post('/talks', payload);
    return response.data; // Contiene talkId, status_url, etc.
  } catch (error) {
    const message = extractErrorMessage(error);
    console.error('❌ Error en generateAvatarVideo:', message);
    throw new Error('Error al generar video con D-ID');
  }
}

// Consultar estado del video
async function getVideoStatus(talkId) {
  try {
    const response = await api.get(`/talks/${talkId}`);
    return response.data;
  } catch (error) {
    const message = extractErrorMessage(error);
    console.error('❌ Error en getVideoStatus:', message);
    throw new Error('Error al consultar el estado del video');
  }
}

// 🔍 Utilidad para obtener mensaje de error legible
function extractErrorMessage(error) {
  if (error.response?.data) {
    try {
      return JSON.stringify(error.response.data, null, 2);
    } catch (_) {
      return '[Error al serializar error.response.data]';
    }
  } else if (error.message) {
    return error.message;
  } else {
    return 'Error desconocido';
  }
}

module.exports = { generateAvatarVideo, getVideoStatus, uploadImage };
// This file defines the D-ID service for generating avatar videos.
// It uses the D-ID API to create a video from a script and an avatar image.