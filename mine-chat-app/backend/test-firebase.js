require('dotenv').config();
const admin = require('firebase-admin');
const serviceAccount = require('./config/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: process.env.FIREBASE_BUCKET
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

async function test() {
  // Escribir un documento de prueba
  const ref = await db.collection('test-collection').add({ saludo: "Hola Firebase", ts: new Date() });
  console.log('Documento creado:', ref.id);

  // Listar archivos (si tienes alguno en Storage)
  const [files] = await bucket.getFiles();
  console.log('Archivos en el bucket:', files.map(f => f.name));
}

test();
