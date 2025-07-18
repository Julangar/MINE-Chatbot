const firebaseService = require('../services/firebaseService');

exports.createAvatar = async (req, res) => {
  try {
    const { userId, type, avatarName, personality } = req.body;
    const avatarId = await firebaseService.createAvatar(userId, type, avatarName, personality);
    res.status(201).json({ success: true, avatarId });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// Para fotos
exports.uploadPhotos = async (req, res) => {
  try {
    const { avatarId } = req.params;
    const photos = req.files;
    const urls = await firebaseService.saveAvatarPhotos(avatarId, photos);
    res.status(200).json({ success: true, urls });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// Para audio
exports.uploadVoice = async (req, res) => {
  try {
    const { avatarId } = req.params;
    const audio = req.file;
    const url = await firebaseService.saveAvatarAudio(avatarId, audio);
    res.status(200).json({ success: true, url });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
