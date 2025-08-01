const admin = require('firebase-admin');
const { uploadFileAndGetURL } = require('../services/firebaseService');
const { generateGreeting, generatePromptForVoice } = require('../utils/generatePrompt');
const elevenlabsService = require('../services/elevenlabsService');
const didService = require('../services/didService');
const { extractVoiceIdFromUrl } = require('../utils/helpers');

// [POST] /api/avatar/generate-greeting
exports.generateGreeting = async (req, res) => {
  try {
    const { data, userLanguage } = req.body;
    const prompt = generateGreeting(data, userLanguage);
    res.json({ greeting: prompt });
  } catch (error) {
    console.error('Error generating greeting:', error);
    res.status(500).json({ error: 'Error generating greeting.' });
  }
};

// [POST] /api/avatar/generate-voice
exports.generateVoiceFromText = async (req, res) => {
  try {
    const { greeting, voiceReference } = req.body;
    const voiceId = extractVoiceIdFromUrl(voiceReference);
    const voiceUrl = await elevenlabsService.speakWithVoiceId(greeting, voiceId);
    res.json({ voiceUrl });
  } catch (error) {
    console.error('Error generating voice from greeting:', error);
    res.status(500).json({ error: 'Error generating voice from greeting.' });
  }
};

// [POST] /api/avatar/generate-video
exports.generateAvatarVideo = async (req, res) => {
  try {
    const { avatarType, imageUrl, voiceUrl, userId } = req.body;

    const videoUrl = await didService.createTalkingAvatar({
      imageUrl,
      audioUrl: voiceUrl,
      userId,
      avatarType
    });

    // Guardar video en Firebase o en Firestore
    const videoDoc = admin
      .firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('video');

    await videoDoc.set({
      videoUrl,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    res.json({ videoUrl });
  } catch (error) {
    console.error('Error generating avatar video:', error);
    res.status(500).json({ error: 'Error generating avatar video.' });
  }
};
