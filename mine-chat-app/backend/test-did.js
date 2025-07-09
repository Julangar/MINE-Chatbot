require('dotenv').config();
const axios = require('axios');

async function test() {
  try {
    const response = await axios.get('https://api.d-id.com/talks', {
      headers: { Authorization: `Bearer ${process.env.DID_API_KEY}` }
    });
    console.log("Conexión exitosa con D-ID (puedes ver un listado o error de autorización si tu cuenta es nueva):");
    console.log(response.data);
  } catch (err) {
    console.log("Respuesta de D-ID:", err.response ? err.response.data : err.message);
  }
}

test();
