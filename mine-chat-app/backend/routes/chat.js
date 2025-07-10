const express = require('express');
const { chatWithBot } = require('../controllers/chatController');
const router = express.Router();

router.post('/message', chatWithBot);

module.exports = router;
// This route handles chat messages sent to the bot.