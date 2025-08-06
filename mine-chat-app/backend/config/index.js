require('dotenv').config();

module.exports = {
  openaiKey: process.env.OPENAI_API_KEY,
  elevenlabsKey: process.env.ELEVENLABS_API_KEY,
  didApiKey: process.env.DID_API_KEY,
  firebaseBucket: process.env.FIREBASE_BUCKET,
  CLOUDINARY_URL: process.env.CLOUDINARY_URL,
  CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME,
  CLOUDINARY_API_KEY: process.env.CLOUDINARY_API_KEY,
  CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET,
};