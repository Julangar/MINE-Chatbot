const axios = require('axios');
const { didApiKey } = require('../config');

const api = axios.create({
  baseURL: 'https://api.d-id.com',
  headers: { Authorization: `Bearer ${didApiKey}` }
});

async function generateTalk({ script, imageUrl }) {
  const response = await api.post('/talks', {
    script: { type: 'text', input: script },
    source_url: imageUrl
  });
  return response.data;
}

module.exports = { generateTalk };
