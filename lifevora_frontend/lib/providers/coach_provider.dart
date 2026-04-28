import 'package:flutter/foundation.dart';
import '../models/coach_session_model.dart';
import '../core/services/coach_service.dart';

class CoachProvider extends ChangeNotifier {
  final List<CoachMessage> _messages = [];
  bool _isTyping = false;
  bool _hasError = false;
  String _errorMessage = '';

  final CoachService _coachService = CoachService();

  // ─── Getters ───────────────────────────────────────────────
  List<CoachMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // ─── Initialisation ────────────────────────────────────────
  void initConversation() {
    if (_messages.isEmpty) {
      _addBotMessage(
        'Bonjour! 👋 Je suis ton coach IA Lifevora propulsé par Gemini. '
        'Comment puis-je t\'aider aujourd\'hui?\n\n'
        'Je peux t\'aider avec :\n'
        '🏋️ Entraînements et exercices\n'
        '🥗 Nutrition et alimentation\n'
        '😴 Récupération et sommeil\n'
        '💪 Motivation et objectifs',
      );
    }
  }

  // ─── Envoyer un message ────────────────────────────────────
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _hasError = false;
    _errorMessage = '';

    final userMsg = CoachMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    try {
      // ─── FIX : exclure le message de bienvenue (index 0, isUser=false) ───
      // et le message actuel (dernier élément)
      final history = _messages
          .sublist(0, _messages.length - 1) // Exclure message actuel
          .where((msg) => msg.isUser || _messages.indexOf(msg) > 0) // Exclure bienvenue
          .toList();

      // Plus simple : filtrer uniquement les vrais échanges
      // (ignorer le 1er message bot de bienvenue)
      final filteredHistory = _messages
          .sublist(0, _messages.length - 1)
          .skip(1) // ← Skip le message de bienvenue du bot (index 0)
          .toList();

      final aiResponse = await _coachService.sendMessage(
        message: content.trim(),
        conversationHistory: filteredHistory,
      );

      _addBotMessage(aiResponse);
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _addBotMessage(
        '😔 Oups! Je rencontre un problème technique.\n'
        '$_errorMessage\n\n'
        'Réessaie dans quelques secondes!',
      );
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // ─── Réessayer le dernier message ─────────────────────────
  Future<void> retryLastMessage() async {
    // Trouver le dernier message utilisateur
    final lastUserMsg = _messages.lastWhere(
      (m) => m.isUser,
      orElse: () => throw Exception('Aucun message à réessayer'),
    );

    // Supprimer le message d'erreur du bot si présent
    if (_messages.last.isUser == false) {
      _messages.removeLast();
    }

    // Réessayer
    await sendMessage(lastUserMsg.content);
  }

  // ─── Effacer la conversation ───────────────────────────────
  void clearConversation() {
    _messages.clear();
    _hasError = false;
    _errorMessage = '';
    initConversation();
  }

  // ─── Helpers privés ────────────────────────────────────────
  void _addBotMessage(String content, {bool isError = false}) {
    final aiMsg = CoachMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_bot',
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMsg);
    notifyListeners();
  }
}