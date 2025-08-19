const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const path = require('path');
const mime = require('mime-types')
const fs = require('fs')
const multer = require('multer');
// Asegura la carpeta
const UPLOAD_DIR = path.join(process.cwd(), 'uploads', 'audio');
fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, UPLOAD_DIR),
  filename: (_req, file, cb) => {
    // Deriva extensión preferiblemente del mimetype
    const ext =
      mime.extension(file.mimetype) ||
      path.extname(file.originalname).replace('.', '') ||
      'm4a';
    const safeBase =
      path.basename(file.originalname || 'voice', path.extname(file.originalname || ''));
    cb(null, `${Date.now()}_${safeBase}.${ext}`);
  },
});

const fileFilter = (_req, file, cb) => {
  const ok = [
    'audio/m4a', 'audio/mp4', 'audio/aac', 'audio/mpeg',
    'audio/wav', 'audio/ogg', 'audio/webm', 'audio/x-m4a',
  ].includes(file.mimetype);
  cb(ok ? null : new Error('Formato de audio no soportado'), ok);
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB por seguridad
});

router.post('/generate-greeting', chatController.generateGreeting);
router.post('/send-message', chatController.sendMessage);
router.post('/send-audio', chatController.sendAudio);
router.post('/send-video', chatController.sendVideo);
router.post('/send-voice', upload.single('audio'), chatController.sendVoice);
router.get('/history', chatController.getConversationHistory);

module.exports = router;
