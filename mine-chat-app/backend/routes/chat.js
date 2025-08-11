const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');

router.post('/generate-greeting', chatController.generateGreeting);
router.post('/send-message', chatController.sendMessage);
router.post('/send-audio', chatController.sendAudio);
router.post('/send-video', chatController.sendVideo);
router.get('/history', chatController.getConversationHistory);

module.exports = router;
