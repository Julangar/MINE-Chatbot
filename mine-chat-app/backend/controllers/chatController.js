const admin = require('firebase-admin');
const { getChatResponse } = require('../services/openaiService');
const { generatePrompt } = require('../utils/generatePrompt');

async function sendMessage(req, res) {
  const { userId, avatarType, message, userLanguage } = req.body;

  if (!userId || !avatarType || !message || !userLanguage) {
    return res.status(400).json({ error: 'Faltan parámetros requeridos.' });
  }

  try {
    const docRef = admin
      .firestore()
      .collection('avatars')
      .doc(`${userId}_${avatarType}`);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Avatar no encontrado.' });
    }

    const data = doc.data();
    const promptSistema = generatePrompt(data, userLanguage);

    const messages = [
      { role: 'system', content: promptSistema },
      { role: 'user', content: message }
    ];

    const gptResponse = await getChatResponse(messages);

    const conversationRef = admin
      .firestore()
      .collection('conversations')
      .doc(userId)
      .collection(avatarType)
      .doc();

    await conversationRef.set({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      userMessage: message,
      avatarResponse: gptResponse
    });

    res.json({ response: gptResponse });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al generar respuesta del avatar.' });
  }
}

module.exports = {
  sendMessage
};
