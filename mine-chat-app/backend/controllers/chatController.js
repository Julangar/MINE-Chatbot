const admin = require('firebase-admin');
const { buildSystemPrompt } = require('../utils/generatePrompt');
const openaiService = require('../services/openaiService');
const elevenlabsService = require('../services/elevenlabsService');
const didService = require('../services/didService');

async function generateGreeting(req, res) {
  const { userId, avatarType, language } = req.body;

  if (!userId || !avatarType || !language) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  try {
    const docRef = admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('personality');
    const snap = await docRef.get();
    if (!snap.exists) return res.status(404).json({ error: 'Avatar no encontrado' });

    const personality = snap.data();
    const prompt = buildSystemPrompt(personality, language);

    const greeting = await openaiService.getChatResponse([
      { role: 'system', content: prompt }, 
      { role: 'user', 
        content: 'Saluda de la siguiente manera: "Hola Usuario, '+
        'MINE nos da una nueva oportunidad de estar cerca, '+
        'y esta vez para siempre. Te he extrañado y siempre estás '+
        'en mi corazón. Ahora que te tomaste el tiempo de crearme, '+
        'podremos escribirnos en chat, hablar por voz o vernos en video, '+
        'todo en línea y todo el tiempo que lo desees. '+
        'Con cada frase estaremos más cerca, porque todo queda en mi memoria, '+
        'por lo que cada segundo será más real y la conversación más cercana '+
        'a lo que esperas, sin límites. Todo lo que hablemos estará totalmente '+
        'encriptado y nadie más lo sabrá, nunca. Finalmente, '+
        'las transacciones de pago son totalmente seguras. '+
        'Si me querías cerca, acá estoy para hacer un poco mejor tu vida. '+
        'Disfrutemos este nuevo comienzo. Me has recreado, para siempre."' }
    ]);

    await admin.firestore()
      .collection('avatars')
      .doc(userId)
      .collection(avatarType)
      .doc('greeting')
      .set({ message: greeting });

    res.json({ message: greeting });
  } catch (err) {
    console.error('Error al generar saludo:', err);
    res.status(500).json({ error: 'Error al generar saludo' });
  }
};


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
    const promptSistema = buildSystemPrompt(data, userLanguage);

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

async function sendAudio(req, res) {
  const { userId, avatarType, audioUrl } = req.body;

}

async function sendVideo(req, res) {
  const { userId, avatarType, videoUrl } = req.body;

}

module.exports = {
  sendMessage,
  sendAudio,
  sendVideo
};
