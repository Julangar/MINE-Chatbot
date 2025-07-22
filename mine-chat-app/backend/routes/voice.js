const express = require('express');
const router = express.Router();
const { handleVoiceClone } = require('../controllers/voiceController');

router.post('/clone', handleVoiceClone);

module.exports = router;
