import 'package:flutter/foundation.dart';
import '../models/coach_session_model.dart';

class CoachProvider extends ChangeNotifier {
  final List<CoachMessage> _messages = []; // final fix
  bool _isTyping = false;

  List<CoachMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  void initConversation() {
    if (_messages.isEmpty) {
      _messages.add(CoachMessage(
        id: '0',
        content:
            'Bonjour! 👋 Je suis ton coach IA Lifevora. Comment puis-je t\'aider aujourd\'hui? Je peux t\'aider avec tes entraînements, nutrition, ou te motiver!',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    final userMsg = CoachMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    final response = _generateAIResponse(content);
    final aiMsg = CoachMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMsg);
    _isTyping = false;
    notifyListeners();
  }

  String _generateAIResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('course') || msg.contains('courir')) {
      return '🏃 Super! La course est excellente pour le cardio. Je recommande de commencer par 20-30 min à rythme modéré. N\'oublie pas l\'échauffement et le retour au calme!';
    } else if (msg.contains('yoga')) {
      return '🧘 Le yoga est fantastique pour la flexibilité et la récupération! Commence par 15-20 min de yoga doux le matin.';
    } else if (msg.contains('nutrition') ||
        msg.contains('manger') ||
        msg.contains('aliment')) {
      return '🥗 Une bonne nutrition est essentielle! Essaie de: 1) Manger 5 portions de légumes/jour 2) Boire 2L d\'eau 3) Privilégier les protéines maigres.';
    } else if (msg.contains('fatigue') || msg.contains('fatigué')) {
      return '😴 La récupération est aussi importante que l\'entraînement! Assure-toi d\'avoir 7-8h de sommeil.';
    } else if (msg.contains('objectif') || msg.contains('but')) {
      return '🎯 Excellent état d\'esprit! Pour atteindre tes objectifs: 1) Sois régulier(e) 2) Augmente progressivement l\'intensité 3) Célèbre les petites victoires!';
    } else if (msg.contains('motivation')) {
      return '💪 La motivation vient de l\'action, pas le contraire! Commence petit: même 10 min par jour fait une différence.';
    } else if (msg.contains('musculation') || msg.contains('muscle')) {
      return '💪 La musculation booste le métabolisme et renforce les os! Pour débuter: 3 séances/semaine, repos entre les groupes musculaires.';
    } else {
      return '🌟 Merci pour ta question! Je suis là pour t\'accompagner dans ton parcours fitness. Tu peux me demander des conseils sur l\'entraînement, la nutrition, la récupération, ou la motivation.';
    }
  }
}