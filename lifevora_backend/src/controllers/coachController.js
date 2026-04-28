const {
  sendMessageToCoach,
  checkCoachHealth: geminiHealthCheck,
} = require('../services/geminiService');

const chatWithCoach = async (req, res) => {
  try {
    const { message, conversationHistory = [] } = req.body;

    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Le message est requis',
      });
    }

    const limitedHistory = conversationHistory.slice(-20);

    const aiResponse = await sendMessageToCoach(message.trim(), limitedHistory);

    return res.status(200).json({
      success: true,
      data: {
        response: aiResponse,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    console.error('❌ Erreur coach controller:', error.message);
    return res.status(500).json({
      success: false,
      message: error.message || 'Erreur interne du serveur',
    });
  }
};

const checkCoachHealth = async (req, res) => {
  try {
    const testResponse = await geminiHealthCheck();

    return res.status(200).json({
      success: true,
      message: '🤖 Coach IA opérationnel',
      geminiStatus: 'connected',
      model: 'gemini-2.5-flash',
      testResponse: testResponse.trim(),
    });
  } catch (error) {
    return res.status(503).json({
      success: false,
      message: 'Coach IA indisponible',
      error: error.message,
    });
  }
};

module.exports = {
  chatWithCoach,
  checkCoachHealth,
};