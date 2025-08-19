const admin = require('firebase-admin');
const dayjs = require('dayjs');
const { generateEngagementNudge } = require('../services/openaiService');
const { sendPushToUser } = require('../services/notificationService');

async function runEngagementSweep(inactivityHours = 24) {
  const db = admin.firestore();
  const cutoff = dayjs().subtract(inactivityHours, 'hour').toDate();

  // Encuentra usuarios con conversacion diaria no actualizada
  const usersSnap = await db.collection('conversations_daily').get();

  for (const userDoc of usersSnap.docs) {
    const userId = userDoc.id;
    const avatarTypesSnap = await db.collection('conversations_daily').doc(userId).listCollections();

    for (const avatarCol of avatarTypesSnap) {
      // Busca el doc más reciente
      const lastDaySnap = await avatarCol.orderBy('day', 'desc').limit(1).get();
      if (lastDaySnap.empty) continue;

      const last = lastDaySnap.docs[0].data();
      const updatedAt = last.updatedAt?.toDate?.() || new Date(0);
      if (updatedAt > cutoff) continue; // aún activo

      // Contexto: últimos 1-3 mensajes
      const msgs = (last.messages || []).slice(-3).map(m => ({
        u: '***',
        a: '***',
      }));
      const nudge = await generateEngagementNudge({
        recent: msgs, // puedes desencriptar si quieres personalización más fina
        avatarType: avatarCol.id,
      }, 'es');

      await sendPushToUser(userId, {
        title: 'Tu avatar',
        body: nudge,
        data: { screen: 'chat', avatarType: avatarCol.id },
      });
    }
  }
}

module.exports = { runEngagementSweep };
