const { generateAvatarVideo, getVideoStatus } = require('../services/didService');
const admin = require('firebase-admin');

async function generateAvatarVideoController(req, res) {
  const { userId, avatarType, language } = req.body;

  if (!userId || !avatarType) {
    return res.status(400).json({ error: 'Faltan campos requeridos.' });
  }

  try {
    const db = admin.firestore();
    const docRef = db.collection('avatars').doc(`${userId}_${avatarType}`);
    const docSnap = await docRef.get();

    if (!docSnap.exists) {
      return res.status(404).json({ error: 'Avatar no encontrado.' });
    }

    const data = docSnap.data();
    const imageUrl = data.photos?.[0]?.url;
    const voiceUrl = data.voice_sample;

    if (!imageUrl || !voiceUrl) {
      return res.status(400).json({ error: 'Faltan imagen o audio del avatar.' });
    }

    const videoResp = await generateAvatarVideo({
      source_image_url: imageUrl,
      voice_url: voiceUrl,
      language
    });

    const talkId = videoResp.id;

    await docRef.update({ did_talk_id: talkId });

    res.json({ success: true, talkId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al generar el video del avatar' });
  }
}

async function checkAvatarVideoStatus(req, res) {
  const { talkId } = req.params;

  if (!talkId) {
    return res.status(400).json({ error: 'Falta el ID del video.' });
  }

  try {
    const status = await getVideoStatus(talkId);

    if (status.result_url) {
      return res.json({ ready: true, videoUrl: status.result_url });
    } else {
      return res.json({ ready: false, status });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al consultar el estado del video.' });
  }
}

module.exports = { generateAvatarVideoController, checkAvatarVideoStatus };
