const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // generado desde Firebase

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  //storageBucket: process.env.FIREBASE_BUCKET
});

const db = admin.firestore();
//const bucket = admin.storage().bucket();

module.exports = { admin, db, bucket };
