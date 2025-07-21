
const { getChatResponse } = require('../services/openaiService');
const admin = require('firebase-admin');
const db = admin.firestore();

async function sendMessage(req, res) {
  const { userId, avatarType, message } = req.body;

  if (!userId || !avatarType || !message) {
    return res.status(400).json({ error: 'Faltan campos requeridos.' });
  }

  try {
    // Obtener datos del avatar desde Firestore
    const docRef = db.collection(userId).doc(avatarType);
    const docSnap = await docRef.get();

    if (!docSnap.exists) {
      return res.status(404).json({ error: 'Avatar no encontrado.' });
    }

    const avatarData = docSnap.data();
    const { personality } = avatarData;

    const promptSistema = 
    `Eres un clon personalizado. Tu estilo es: \${personality.speakingStyle}
    Tus intereses son: \${personality.interests?.join(', ')}
    Frases comunes: \${personality.commonPhrases?.join(', ')}
    Rasgos:
    - Extroversión: \${personality.traits.extroversion}
    - Amabilidad: \${personality.traits.agreeableness}
    - Responsabilidad: \${personality.traits.conscientiousness}

    Responde como si fueras esa persona real, siendo natural, coherente y emocionalmente cercano.`;

    const messages = [
      { role: 'system', content: promptSistema },
      { role: 'user', content: message }
    ];

    const reply = await getChatResponse(messages);

    // Opcional: guardar mensaje y respuesta en Firestore (colección: conversations)
    const convoRef = db.collection('conversations').doc();
    await convoRef.set({
      userId,
      avatarType,
      createdAt: new Date().toISOString(),
      messages: [
        { isUser: true, text: message, timestamp: new Date().toISOString() },
        { isUser: false, text: reply, timestamp: new Date().toISOString() }
      ]
    });

    res.json({ response: reply });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error procesando el mensaje.' });
  }
}

module.exports = { sendMessage };
