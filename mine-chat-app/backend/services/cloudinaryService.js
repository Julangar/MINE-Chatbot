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
  const image = await cloudinary.uploader.upload(filePath, {
    resource_type: 'image',
    folder: `${folder}/${userId}/${avatarType}/images`,
    format: 'jpeg' // Forzar formato si lo necesitas
  });
  return image.secure_url;
};

// Función para subir audio
const uploadAudio = async (filePath, userId, avatarType, folder = 'avatars') => {
  const audio = await cloudinary.uploader.upload(filePath, {
    resource_type: 'video', // ¡Audio va como 'video' en Cloudinary!
    folder: `${folder}/${userId}/${avatarType}/temp/clonedAudios`,
    format: 'mp3' // Forzar formato si lo necesitas
  });
  return audio.secure_url;
};

// Función para subir video
const uploadVideo = async (filePath, userId, avatarType, folder = 'avatars') => {
  const video = await cloudinary.uploader.upload(filePath, {
    resource_type: 'video',
    folder: `${folder}/${userId}/${avatarType}/videos`,
    format: 'mp4'
  });
  return video.secure_url;
};

// Convierte un Buffer en un flujo legible. Esto evita crear archivos temporales
// en disco y permite subir directamente el audio a Cloudinary.
const { Readable } = require('stream');

function bufferToStream(buffer) {
  const stream = new Readable();
  stream.push(buffer);
  stream.push(null);
  return stream;
}

/**
 * Sube audio a Cloudinary a partir de un Buffer. Esto es útil cuando recibes
 * la respuesta de una API (por ejemplo, ElevenLabs) como array de bytes y
 * quieres evitar escribir archivos temporales en el disco.
 *
 * @param {Buffer} buffer - Datos binarios del audio.
 * @param {string} userId - ID del usuario para estructurar la carpeta.
 * @param {string} avatarType - Tipo de avatar para estructurar la carpeta.
 * @param {string} folder - Carpeta base en Cloudinary (por defecto 'avatars').
 * @returns {Promise<string>} URL segura del archivo cargado.
 */
const uploadAudioBuffer = async (buffer, userId, avatarType, folder = 'avatars') => {
  return new Promise((resolve, reject) => {
    const uploadOptions = {
      resource_type: 'video', // Cloudinary trata audio como 'video'
      folder: `${folder}/${userId}/${avatarType}/temp/clonedAudios`,
      format: 'mp3'
    };
    const uploadStream = cloudinary.uploader.upload_stream(uploadOptions, (error, result) => {
      if (error) return reject(error);
      return resolve(result.secure_url);
    });
    // Convertir el buffer en un stream y enviarlo a Cloudinary
    bufferToStream(buffer).pipe(uploadStream);
  });
};


// Función para subir audio base
const uploadAudioBase = async (filePath, userId, avatarType, folder = 'avatars') => {
  const audio = await cloudinary.uploader.upload(filePath, {
    resource_type: 'video', // ¡Audio va como 'video' en Cloudinary!
    folder: `${folder}/${userId}/${avatarType}/audios`,
    format: 'mp3' // Forzar formato si lo necesitas
  });
  return audio.secure_url;
};

// Puedes agregar más funciones para borrar, obtener, etc.

module.exports = {
  uploadImage,
  uploadAudio,
  uploadVideo,
  uploadAudioBase,
  uploadAudioBuffer,
  cloudinary // por si necesitas acceder directo
};
