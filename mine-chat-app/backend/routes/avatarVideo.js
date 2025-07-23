
const express = require('express');
const router = express.Router();
const {
  generateAvatarVideoController,
  checkAvatarVideoStatus
} = require('../controllers/avatarVideoController');

router.post('/generate-video', generateAvatarVideoController);
router.get('/video-status/:talkId', checkAvatarVideoStatus);

module.exports = router;
