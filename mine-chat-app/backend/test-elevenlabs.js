require('dotenv').config();
const axios = require('axios');

async function test() {
  const response = await axios.get('https://api.elevenlabs.io/v1/voices', {
    headers: { 'xi-api-key': process.env.ELEVENLABS_API_KEY }
  });
  console.log(response.data);
}

test();
