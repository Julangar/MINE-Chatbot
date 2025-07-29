
// Estructura preliminar para usar Sora de OpenAI (aún no disponible públicamente)
const { Configuration, OpenAIApi } = require('openai');

// Esta configuración solo funcionará cuando OpenAI habilite el endpoint de video
const configuration = new Configuration({
  apiKey: process.env.OPENAI_API_KEY,
});

const openai = new OpenAIApi(configuration);

/**
 * Genera un video con Sora a partir de un prompt de texto.
 * @param {string} prompt - Descripción del video a generar
 * @param {number} duration - Duración en segundos (ej. 10)
 * @returns {Promise<string>} - URL del video generado (cuando esté disponible)
 */
async function generateSoraVideo(prompt, duration = 10) {
  try {
    // Nota: Esto es un ejemplo imaginario, no funciona aún.
    const response = await openai.video.create({
      prompt,
      duration,
      resolution: "720p", // u "1080p" si lo permiten
      model: "sora-alpha",
    });

    return response.data?.video_url;
  } catch (err) {
    console.error("Error al generar video con Sora:", err.message);
    return null;
  }
}

module.exports = { generateSoraVideo };
