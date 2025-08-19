const admin = require('firebase-admin');

async function sendPushToUser(userId, payload) {
  const db = admin.firestore();
  const col = db.collection('users').doc(userId).collection('fcmTokens');
  const snap = await col.get();
  const tokens = [];
  snap.forEach(d => tokens.push(d.id));
  if (!tokens.length) return { successCount: 0, failureCount: 0 };

  const message = {
    tokens,
    notification: {
      title: payload.title || 'Tu avatar te espera',
      body: payload.body || '¿Continuamos la conversación?',
    },
    data: payload.data || {},
  };

  return admin.messaging().sendEachForMulticast(message);
}

module.exports = { sendPushToUser };
