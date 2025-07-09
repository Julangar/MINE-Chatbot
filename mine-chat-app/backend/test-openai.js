require('dotenv').config();
const OpenAI = require('openai');
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

async function test() {
  const response = await openai.chat.completions.create({
    model: "gpt-4.1",
    messages: [{ role: "user", content: "Hola, ¿quién eres?" }]
  });
  console.log(response.choices[0].message.content);
}

test();
