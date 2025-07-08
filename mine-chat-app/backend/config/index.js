require('dotenv').config();

module.exports = {
  openaiKey: process.env.OPENAI_API_KEY,
  elevenlabsKey: process.env.ELEVENLABS_API_KEY,
  didApiKey: process.env.DID_API_KEY,
  firebaseBucket: process.env.FIREBASE_BUCKET
};
