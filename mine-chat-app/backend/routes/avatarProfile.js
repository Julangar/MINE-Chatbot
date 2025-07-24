
const express = require('express');
const router = express.Router();
const {
  getAvatarProfile,
  updateAvatarProfile,
  deleteAvatarProfile
} = require('../controllers/avatarProfileController');

router.get('/:userId/:avatarType', getAvatarProfile);
router.put('/:userId/:avatarType', updateAvatarProfile);
router.delete('/:userId/:avatarType', deleteAvatarProfile);

module.exports = router;
