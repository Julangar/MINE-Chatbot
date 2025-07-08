const OpenAI = require('openai');
const { openaiKey } = require('../config');

const openai = new OpenAI({ apiKey: openaiKey });

async function getChatResponse(messages) {
  const response = await openai.chat.completions.create({
    model: "gpt-4",
    messages
  });
  return response.choices[0].message.content;
}

module.exports = { getChatResponse };
