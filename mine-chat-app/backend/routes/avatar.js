const express = require('express');
const router = express.Router();
const avatarController = require('../controllers/avatarController');
const { uploadPhotos, uploadAudio } = require('../middlewares/uploadMiddleware');

// Crear avatar con datos básicos
router.post('/create', avatarController.createAvatar);

// Subir multimedia al avatar
router.post('/:avatarId/upload-photos', uploadPhotos.array('photos'), avatarController.uploadPhotos);
router.post('/:avatarId/upload-voice', uploadAudio.single('voice'), avatarController.uploadVoice);

// Generar saludo y contenido del avatar
router.post('/generate-greeting', avatarController.generateGreeting);
router.post('/generate-voice', avatarController.generateVoiceFromText);
router.post('/generate-video', avatarController.generateSpeechFromClonedVoice);

module.exports = router;
