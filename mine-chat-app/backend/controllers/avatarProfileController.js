
const admin = require('firebase-admin');
const { bucket } = require('../config/firebase');

async function getAvatarProfile(req, res) {
  const { userId, avatarType } = req.params;
  if (!userId || !avatarType) {
    return res.status(400).json({ error: 'Faltan parámetros requeridos.' });
  }

  try {
    //const docRef = admin.firestore().collection(userId).doc(avatarType);
    const docRef = admin.firestore().collection('avatars').doc(userId).collection('types').doc(avatarType);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Perfil no encontrado.' });
    }

    res.json(doc.data());
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener el perfil.' });
  }
}

async function updateAvatarProfile(req, res) {
  const { userId, avatarType } = req.params;
  const updateData = req.body;

  if (!userId || !avatarType || !updateData) {
    return res.status(400).json({ error: 'Faltan datos.' });
  }

  try {
    const docRef = admin.firestore().collection(userId).doc(avatarType);
    await docRef.update(updateData);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar el perfil.' });
  }
}

async function deleteAvatarProfile(req, res) {
  const { userId, avatarType } = req.params;

  if (!userId || !avatarType) {
    return res.status(400).json({ error: 'Faltan parámetros requeridos.' });
  }

  try {
    const docRef = admin.firestore().collection(userId).doc(avatarType);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Perfil no encontrado.' });
    }

    const data = doc.data();

    const filesToDelete = [];

    if (data.voice_sample) filesToDelete.push(data.voice_sample);
    if (data.photos) {
      for (const photo of data.photos) {
        if (photo.url) filesToDelete.push(photo.url);
      }
    }

    if (data.did_video_url) filesToDelete.push(data.did_video_url);

    for (const url of filesToDelete) {
      const filePath = decodeURIComponent(new URL(url).pathname.replace(/^\//, '').split('/o/')[1].split('?')[0]);
      await bucket.file(filePath).delete().catch(err => {
        console.warn('No se pudo eliminar:', filePath, err.message);
      });
    }

    await docRef.delete();
    res.json({ success: true, deleted: avatarType });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al eliminar el perfil.' });
  }
}

module.exports = {
  getAvatarProfile,
  updateAvatarProfile,
  deleteAvatarProfile
};
