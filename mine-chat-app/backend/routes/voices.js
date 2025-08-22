const express = require('express');
const router = express.Router();
const { handleVoiceClone, listVoices, ttsPreview  } = require('../controllers/voiceController');

router.post('/clone', handleVoiceClone);
router.get('/', listVoices);            // /api/voices
router.post('/preview', ttsPreview);  

module.exports = router;
