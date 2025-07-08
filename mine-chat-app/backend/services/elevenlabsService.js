const axios = require('axios');
const { elevenlabsKey } = require('../config');

const api = axios.create({
  baseURL: 'https://api.elevenlabs.io/v1',
  headers: { 'xi-api-key': elevenlabsKey }
});

async function listVoices() {
  const response = await api.get('/voices');
  return response.data;
}

module.exports = { listVoices };
