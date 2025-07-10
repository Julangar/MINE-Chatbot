const express = require('express');
const { generateVoice } = require('../controllers/voiceController');
const router = express.Router();

router.post('/generate', generateVoice);

module.exports = router;
// This file defines the voice routes for the Express application.