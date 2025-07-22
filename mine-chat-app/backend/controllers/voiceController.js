
const { cloneVoice } = require('../services/elevenlabsService');

async function handleVoiceClone(req, res) {
  const { userId, avatarType, audioUrl } = req.body;

  if (!userId || !avatarType || !audioUrl) {
    return res.status(400).json({ error: 'Faltan campos requeridos.' });
  }

  try {
    const admin = require('firebase-admin');
    const db = admin.firestore();

    const voiceId = await cloneVoice(userId, audioUrl);
    await db.collection(userId).doc(avatarType).update({ elevenlabs_voice_id: voiceId });

    res.json({ success: true, voiceId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al clonar la voz' });
  }
}

module.exports = { handleVoiceClone };
