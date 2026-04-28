import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/coach_session_model.dart';

class CoachService {
  // ⚠️ Change cette IP selon ton réseau
  static const String _baseUrl = 'http://192.168.3.51:3000/api/coach';

  /// Récupère le token JWT stocké
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Envoie un message au coach IA via le backend
  Future<String> sendMessage({
    required String message,
    required List<CoachMessage> conversationHistory,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('Non authentifié. Veuillez vous connecter.');
      }

      // Convertir l'historique pour l'API
      final historyJson = conversationHistory
          .map((msg) => {
                'content': msg.content,
                'isUser': msg.isUser,
              })
          .toList();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'message': message,
              'conversationHistory': historyJson,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception(
              '⏱️ Le coach met trop de temps à répondre. Réessaie!',
            ),
          );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data']['response'] as String;
      } else {
        final errorMsg = data['message'] ?? 'Erreur inconnue';
        throw Exception(errorMsg);
      }
    } on http.ClientException {
      throw Exception(
        '📡 Impossible de contacter le serveur. Vérifie ta connexion.',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Vérifie si le service coach est disponible
  Future<bool> isCoachAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      
      final data = jsonDecode(response.body);
      return response.statusCode == 200 && data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}