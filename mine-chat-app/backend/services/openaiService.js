const OpenAI = require('openai');
const { openaiKey } = require('../config');
const fs = require('fs')
const path = require('path');
const mime = require('mime-types');

if (!openaiKey) {
  throw new Error("Missing OpenAI API key. Please set it in config.js");
}

const openai = new OpenAI({ apiKey: openaiKey });

// ==== Util: estimación de “tokens” por caracteres (aprox) ====
const CHAR_PER_TOKEN = 4; // aproximación segura
function approxTokensFromChars(str = '') {
  return Math.ceil((str?.length || 0) / CHAR_PER_TOKEN);
}

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

async function summarizeTurns(turns, language) {
  // turns = [{u: '...', a: '...'}, ...]
  const messages = [
    { role: 'system', content:
`Eres un asistente que resume una conversación en ${language}.
Objetivo: comprimir manteniendo hechos, preferencias, estilo y contexto útil.
Devuelve 1) "resumen_dia": resumen compacto (<= 350 palabras)
y 2) "memorias": viñetas con hechos estables a largo plazo (<= 10 bullets).` },
    { role: 'user', content:
`Convierte estos turnos en un resumen-día y memorias.
TURNOS:
${turns.map((t,i)=>`[${i+1}] U: ${t.u}\nA: ${t.a}`).join('\n')}` }
  ];
  const resp = await openai.chat.completions.create({
    model: 'gpt-4.1',
    messages,
  });
  return resp.choices[0]?.message?.content ?? '';
}

async function generateEngagementNudge(context, language) {
  // context: últimos mensajes del usuario, intereses, speakingStyle, etc.
  const messages = [
    { role: 'system', content:
`Eres un redactor de notificaciones push concisas en ${language}.
Tono: coherente con el estilo del avatar, positivo, personalizado.
Longitud máxima: 120 caracteres. Incluye una pregunta abierta cuando sea natural.` },
    { role: 'user', content:
`Genera 1 notificación breve para invitar a retomar la conversación.
Contexto:
${JSON.stringify(context)}` }
  ];
  const resp = await openai.chat.completions.create({
    model: 'gpt-4.1',
    messages,
  });
  return resp.choices[0]?.message?.content ?? '¿Seguimos nuestra conversación?';
}

module.exports = { getChatResponse , transcribeAudio, summarizeTurns, generateEngagementNudge };
