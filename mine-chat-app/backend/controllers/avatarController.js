const { generateAvatarVideo, getVideoStatus } = require('../services/didService');

async function createAvatarVideo(req, res) {
  try {
    const { script, imageUrl, voiceUrl } = req.body;
    if (!script || !imageUrl || !voiceUrl)
      return res.status(400).json({ error: 'Faltan campos requeridos' });

    const video = await generateAvatarVideo({
      script,
      source_image_url: imageUrl,
      voice_url: voiceUrl
    });

    res.json({ talkId: video.id, status: video.status });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}

// Endpoint para consultar el estado o URL final del video
async function getAvatarVideo(req, res) {
  try {
    const { talkId } = req.params;
    const video = await getVideoStatus(talkId);
    res.json(video);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}

module.exports = { createAvatarVideo, getAvatarVideo };
// This file defines the avatarController which handles requests for generating avatar videos.