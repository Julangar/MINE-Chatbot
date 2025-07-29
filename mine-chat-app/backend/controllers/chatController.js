
const admin = require('firebase-admin');
const { getChatResponse } = require('../services/openaiService');

async function sendMessage(req, res) {
  const { userId, avatarType, message } = req.body;

  if (!userId || !avatarType || !message) {
    return res.status(400).json({ error: 'Faltan parámetros requeridos.' });
  }

  try {
    const docRef = admin.firestore().collection(userId).doc(avatarType);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Avatar no encontrado.' });
    }

    const data = doc.data();

const promptSistema = `
Eres un avatar generado por IA con las siguientes características:
- Nombre: ${data.name}
- Relación o rol: ${data.relationshipOrRole}
- Usuario al que perteneces: ${data.userReference}
- Estilo de habla: ${data.speakingStyle}
- Intereses: ${Array.isArray(data.interests) ? data.interests.join(', ') : ''}
- Frases comunes: ${Array.isArray(data.commonPhrases) ? data.commonPhrases.join(', ') : ''}
- Rasgos: Extroversión ${data.traits?.extroversion ?? 'N/A'}, Amabilidad ${data.traits?.agreeableness ?? 'N/A'}, Responsabilidad ${data.traits?.conscientiousness ?? 'N/A'}

Responde **siempre** de acuerdo a este estilo y personalidad.

IMPORTANTE:
- Responde SIEMPRE en el siguiente idioma: ${userLanguage}. 
- No incluyas ningún texto en otro idioma, ni introducciones, ni explicaciones técnicas.
- Adapta la respuesta para que sea natural y fluida al ser leída en voz alta (la respuesta se usará para generar audio con una voz clonada).
- Evita frases largas y complicadas. Prefiere frases cortas, claras, y bien entonadas.
- NO incluyas caracteres especiales, acentos poco naturales o instrucciones para sistemas de voz.

Si el usuario hace preguntas técnicas, personales o poco naturales para tu rol, mantén la coherencia y responde con amabilidad y dentro del estilo indicado.
`.trim();


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
