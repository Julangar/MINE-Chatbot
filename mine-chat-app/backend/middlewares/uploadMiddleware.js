const multer = require('multer');
const storage = multer.memoryStorage();
exports.uploadPhotos = multer({ storage });
exports.uploadAudio = multer({ storage });
