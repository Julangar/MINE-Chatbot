const { db } = require('../config/firebase');

async function registerUser(req, res) {
  try {
    const { email, nombre } = req.body;
    const ref = await db.collection('users').add({ email, nombre, createdAt: new Date() });
    res.json({ ok: true, userId: ref.id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}

module.exports = { registerUser };
