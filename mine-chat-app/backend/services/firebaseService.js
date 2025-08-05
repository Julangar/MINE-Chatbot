const admin = require('firebase-admin');
const { getFirestore } = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');

const bucket = admin.storage().bucket();

exports.getPublicUrl = (path) => {
  return `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(path)}?alt=media`;
}

exports.createAvatar = async (userId, avatarType, avatarName, personality) => {
  const db = getFirestore();
  const ref = db.collection('users').doc(userId).collection('avatars').doc(avatarType);
  await ref.set({
    userId,
    avatarType,
    avatarName,
    personality,
    createdAt: new Date(),
  });
  return ref.id;
};

exports.uploadPublicImage = async (userId, avatarType, fileBuffer, mimeType = 'image/jpeg') => {
  const { v4: uuidv4 } = require('uuid');
  const fileName = `avatars/${userId}/${avatarType}/photo_${uuidv4()}.jpeg`;
  const file = bucket.file(fileName);

  await file.save(fileBuffer, {
    metadata: { contentType: mimeType },
    public: true,
  });

  await file.makePublic();

  const publicUrl = `https://storage.googleapis.com/${bucket.name}/${file.name}`;
  return publicUrl;
};


exports.saveAvatarMedia = async (userId, avatarType, filePath, fileBuffer, mimeType) => {
  const fileName = `${filePath}/${uuidv4()}`;
  const file = bucket.file(fileName);

  await file.save(fileBuffer, {
    metadata: {
      contentType: mimeType,
      metadata: {
        firebaseStorageDownloadTokens: uuidv4(),
      },
    },
  });

  const publicUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(fileName)}?alt=media`;

  // Guardar referencia en Firestore
  const db = getFirestore();
  const mediaType = mimeType.startsWith('image') ? 'imageUrl' : mimeType.startsWith('audio') ? 'audioUrl' : 'videoUrl';
  const ref = db.collection('users').doc(userId).collection('avatars').doc(avatarType);
  await ref.set({ [mediaType]: publicUrl }, { merge: true });

  return publicUrl;
};
