const { getFirestore, getStorage } = require('firebase-admin');

exports.createAvatar = async (userId, type, avatarName, personality) => {
  const db = getFirestore();
  const ref = db.collection(`${userId}`).doc(); // Ej: love_avatars
  await ref.set({
    userId, avatarName, personality, createdAt: new Date(),
  });
  return ref.id;
};

exports.saveAvatarPhotos = async (avatarId, photos) => {
  // Implementa lógica para subir a Storage y guardar URL en Firestore
};

exports.saveAvatarAudio = async (avatarId, audio) => {
  // Implementa lógica para subir audio a Storage y guardar URL en Firestore
};
