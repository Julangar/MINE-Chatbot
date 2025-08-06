// services/cloudinaryService.js
const cloudinary = require('cloudinary').v2;
const config = require('../config'); // Aquí importas tus env

cloudinary.config({
  cloud_name: config.CLOUDINARY_CLOUD_NAME,
  api_key: config.CLOUDINARY_API_KEY,
  api_secret: config.CLOUDINARY_API_SECRET,
  secure: true
});

// Función para subir imagen
const uploadImage = async (filePath, userId, avatarType, folder = 'avatars') => {
  return cloudinary.uploader.upload(filePath, {
    resource_type: 'image',
    folder: `${folder}/${userId}/${avatarType}/images`,
    format: 'jpeg' // Forzar formato si lo necesitas
  });
};

// Función para subir audio
const uploadAudio = async (filePath, userId, avatarType, folder = 'avatars') => {
  return cloudinary.uploader.upload(filePath, {
    resource_type: 'video', // ¡Audio va como 'video' en Cloudinary!
    folder: `${folder}/${userId}/${avatarType}/clonedAudios`,
    format: 'mp3' // Forzar formato si lo necesitas
  });
};

// Puedes agregar más funciones para borrar, obtener, etc.

module.exports = {
  uploadImage,
  uploadAudio,
  cloudinary // por si necesitas acceder directo
};
