const { cloneVoice } = require('../services/elevenlabsService');
const admin = require('firebase-admin');

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

module.exports = { handleVoiceClone };
