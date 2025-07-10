const express = require('express');
const { createAvatarVideo, getAvatarVideo } = require('../controllers/avatarController');
const router = express.Router();

router.post('/generate', createAvatarVideo);
router.get('/:talkId', getAvatarVideo);

module.exports = router;
// This file defines the avatar routes for the Express application.