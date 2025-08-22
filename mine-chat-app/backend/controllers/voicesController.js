const { cloneVoice } = require('../services/elevenlabsService');
const admin = require('firebase-admin');
const admin = require('firebase-admin');
const fetch = require('node-fetch');

// Utilidad para mapear voces de ElevenLabs a un payload ligero para el cliente
function mapVoice(v) {
  return {
    voiceId: v.voice_id,
    name: v.name,
    // v.labels puede traer "gender", "accent", "age", "use case", etc.
    labels: v.labels || {},
    // si la voz tiene sample(s):
    previewUrl: v.preview_url || null, // algunas APIs la exponen
    language: v.labels?.language?.toLowerCase() || null,
  };
}


async function handleVoiceClone(req, res) {
  const { userId, avatarType, audioUrl } = req.body;

  if (!userId || !avatarType || !audioUrl) {
    return res.status(400).json({ error: 'Faltan campos requeridos: userId, avatarType y audioUrl.' });
  }

  try {
    const db = admin.firestore();

    const voiceId = await cloneVoice(userId, audioUrl);

    const docRef = db.collection('avatars').doc(userId).collection(avatarType).doc('profile');

    await docRef.set(
      { elevenlabs_voice_id: voiceId },
      { merge: true }
    );

    return res.json({ success: true, voiceId });
  } catch (err) {
    console.error('Error en handleVoiceClone:', err);
    return res.status(500).json({ error: 'Error al clonar la voz.' });
  }
}

async function listVoices(req, res) {
  try {
    const { lang, limit = 50 } = req.query;
    const apiKey = process.env.ELEVENLABS_API_KEY;
    // Endpoint típico (puede variar según versión)
    const r = await fetch('https://api.elevenlabs.io/v2/voices', {
      headers: { 'xi-api-key': apiKey }
    });
    if (!r.ok) return res.status(500).json({ error: 'No se pudo obtener voces' });
    const data = await r.json();

    let voices = (data.voices || []).map(mapVoice);

    if (lang) {
      const lx = lang.toLowerCase();
      voices = voices.filter(v => (v.language || '').startsWith(lx) || v.labels?.language?.toLowerCase()?.startsWith(lx));
    }
    voices = voices.slice(0, Number(limit));

    return res.json({ voices });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error listando voces' });
  }
}

async function ttsPreview(req, res) {
  try {
    const { voiceId, text = 'Hola, soy tu nuevo avatar. ¿Cómo te puedo ayudar hoy?' } = req.body;
    if (!voiceId) return res.status(400).json({ error: 'voiceId requerido' });

    const apiKey = process.env.ELEVENLABS_API_KEY;
    const r = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`, {
      method: 'POST',
      headers: {
        'xi-api-key': apiKey,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        text,
        model_id: 'eleven_multilingual_v2', // ajusta al modelo que uses
        voice_settings: {
          stability: 0.5, similarity_boost: 0.6 // knobs opcionales
        }
      })
    });

    if (!r.ok) {
      const t = await r.text();
      return res.status(500).json({ error: 'TTS error', detail: t });
    }

    // Opción A: devolver como base64 (rápido, sin subir a Storage)
    const arrayBuf = await r.arrayBuffer();
    const b64 = Buffer.from(arrayBuf).toString('base64');
    return res.json({ mime: 'audio/mpeg', base64: b64 });

    // Opción B (recomendada): sube a Storage y devuelve URL firmada.
    // ...
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error generando preview' });
  }
}

module.exports = { handleVoiceClone, ttsPreview, listVoices };
