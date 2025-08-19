const OpenAI = require('openai');
const { openaiKey } = require('../config');
const fs = require('fs')
const path = require('path');
const mime = require('mime-types');

if (!openaiKey) {
  throw new Error("Missing OpenAI API key. Please set it in config.js");
}

const openai = new OpenAI({ apiKey: openaiKey });

async function transcribeAudio(filePath, language) {

  let usablePath = filePath;
  const hasExt = Boolean(path.extname(filePath));
  const file = fs.createReadStream(filePath);
  console.log('Starting audio transcription...', file);
  if (!hasExt) {
    const guessed = 'm4a';
    const tempPath = `${filePath}.${guessed}`;
    try { fs.renameSync(filePath, tempPath); usablePath = tempPath; } catch (_) {}
  }
  try {
    // Whisper
    const file = fs.createReadStream(usablePath);
    const resp = await openai.audio.transcriptions.create({
      file,
      model: 'whisper-1',
      language
    });
    return resp.text?.trim() || '';
  } catch (err) {
    console.error('Error in transcribeAudio:', err.message);
    throw new Error('Transcription failed');
  } finally {
    if (usablePath !== filePath) {
      fs.unlinkSync(usablePath);
    }
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
