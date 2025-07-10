const { getChatResponse } = require('../services/openaiService');

async function chatWithBot(req, res) {
  try {
    const { messages } = req.body;
    const response = await getChatResponse(messages);
    res.json({ response });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}

module.exports = { chatWithBot };
// This controller handles the chat requests to the OpenAI API.