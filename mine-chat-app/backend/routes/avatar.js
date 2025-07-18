const express = require('express');
const router = express.Router();
const avatarController = require('../controllers/avatarController');
const { uploadPhotos, uploadAudio } = require('../middlewares/uploadMiddleware'); // Multer config

router.post('/create', avatarController.createAvatar);
router.post('/:avatarId/upload-photos', uploadPhotos.array('photos'), avatarController.uploadPhotos);
router.post('/:avatarId/upload-voice', uploadAudio.single('voice'), avatarController.uploadVoice);

module.exports = router;
