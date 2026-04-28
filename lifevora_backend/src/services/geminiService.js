const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const MODEL_NAME = 'gemini-2.5-flash';

const SYSTEM_PROMPT = `
Tu es Coach Lifevora, un coach IA expert en fitness, nutrition et bien-être.

Règles :
- Tu parles uniquement en français
- Tu es motivant, bienveillant et clair
- Tu donnes des réponses courtes et utiles
- Tu utilises des emojis avec modération
- Tu restes dans le domaine : sport, nutrition, récupération, motivation
- Tu n'es pas médecin
`;

function cleanHistory(conversationHistory = []) {
  const history = conversationHistory.map((msg) => ({
    role: msg.isUser ? 'user' : 'model',
    parts: [{ text: msg.content }],
  }));

  // Gemini n'accepte pas une conversation qui commence par model
  while (history.length > 0 && history[0].role === 'model') {
    history.shift();
  }

  return history;
}

const sendMessageToCoach = async (userMessage, conversationHistory = []) => {
  try {
    const model = genAI.getGenerativeModel({
      model: MODEL_NAME,
      systemInstruction: SYSTEM_PROMPT,
    });

    const history = cleanHistory(conversationHistory);

    const chat = model.startChat({ history });
    const result = await chat.sendMessage(userMessage);
    const response = await result.response;

    return response.text();
  } catch (error) {
    console.error('❌ Erreur Gemini:', error.message);
    throw new Error("Erreur de communication avec l'IA");
  }
};

const checkCoachHealth = async () => {
  const model = genAI.getGenerativeModel({ model: MODEL_NAME });
  const result = await model.generateContent('Réponds juste OK');
  const response = await result.response;
  return response.text();
};

module.exports = {
  sendMessageToCoach,
  checkCoachHealth,
};