const OpenAI = require('openai');
const { openaiKey } = require('../config');
const fs = require('fs')

if (!openaiKey) {
  throw new Error("Missing OpenAI API key. Please set it in config.js");
}

const openai = new OpenAI({ apiKey: openaiKey });

async function transcribeAudio(filePath, language) {
  try {
    const file = fs.createReadStream(filePath);
    // Whisper
    const resp = await openai.audio.transcriptions.create({
      file,
      model: 'whisper-1',
      language
    });
    return resp.text?.trim() || '';
  } catch (err) {
    console.error('Error in transcribeAudio:', err.message);
    throw new Error('Transcription failed');
  }
}

async function getChatResponse(messages, model = "gpt-4.1") {
  try {
    const response = await openai.chat.completions.create({
      model,
      messages
    });

    return response.choices[0]?.message?.content || '[OpenAI response missing]';
  } catch (error) {
    console.error('Error in getChatResponse:', error.message);
    throw new Error('Error while getting response from OpenAI');
  }
}

module.exports = { getChatResponse , transcribeAudio};
