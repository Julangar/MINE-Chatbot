const { textToSpeech } = require('../services/elevenlabsService');

async function generateVoice(req, res) {
  try {
    const { text, userId } = req.body;
    if (!text || !userId) return res.status(400).json({ error: 'Faltan campos requeridos' });

    const url = await textToSpeech(text, userId);
    res.json({ audioUrl: url });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}

module.exports = { generateVoice };
// This file defines the voiceController which handles requests for generating voice audio from text.
// It uses the ElevenLabs service to convert text to speech and returns the URL of the generated audio file.
// The controller expects a POST request with 'text' and 'userId' in the body