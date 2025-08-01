const admin = require('firebase-admin');
const { db } = require('../config/firebase');

async function registerUser(req, res) {
  try {
    const { email, nombre, language = 'en' } = req.body;

    if (!email || !nombre) {
      return res.status(400).json({ error: 'Faltan campos requeridos: email y nombre.' });
    }

    const newUser = {
      email,
      nombre,
      language,
      avatarActive: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    };

    const ref = await db.collection('users').add(newUser);

    res.json({ ok: true, userId: ref.id });
  } catch (err) {
    console.error('Error al registrar usuario:', err);
    res.status(500).json({ error: 'Error interno al registrar el usuario.' });
  }
}

module.exports = { registerUser };
