const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const path = require('path');
const mime = require('mime-types')
const fs = require('fs')
const multer = require('multer');

router.post('/generate-greeting', chatController.generateGreeting);
router.post('/send-message', chatController.sendMessage);
router.post('/send-audio', chatController.sendAudio);
router.post('/send-video', chatController.sendVideo);
router.post('/send-voice', chatController.sendVoice);
router.get('/history', chatController.getConversationHistory);

module.exports = router;
