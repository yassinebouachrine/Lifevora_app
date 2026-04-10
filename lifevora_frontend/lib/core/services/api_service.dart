import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️ ADAPTER SELON ENVIRONNEMENT:
  // Android Emulator  → http://10.0.2.2:3000
  // iOS Simulator     → http://localhost:3000
  // Appareil physique → http://192.168.X.X:3000 (votre IP locale)
  static const String _baseUrl = 'http://192.168.100.11:3000/api';
  static const String _tokenKey = 'auth_token';
  static const Duration _timeout = Duration(seconds: 15);

  // ============================================================
  // TOKEN MANAGEMENT
  // ============================================================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // HEADERS
  // ============================================================
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ============================================================
  // HTTP HELPERS
  // ============================================================
  static Future<Map<String, dynamic>> _get(String path,
      {bool auth = true}) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl$path'), headers: await _headers(auth: auth))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      return _networkError();
    } on HttpException {
      return _networkError();
    } catch (e) {
      return {'success': false, 'message': 'Erreur: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      return _networkError();
    } catch (e) {
      return {'success': false, 'message': 'Erreur: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl$path'),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      return _networkError();
    } catch (e) {
      return {'success': false, 'message': 'Erreur: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> _delete(String path,
      {bool auth = true}) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl$path'),
            headers: await _headers(auth: auth),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      return _networkError();
    } catch (e) {
      return {'success': false, 'message': 'Erreur: ${e.toString()}'};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de parsing: ${response.statusCode}'
      };
    }
  }

  static Map<String, dynamic> _networkError() {
    return {
      'success': false,
      'message': 'Impossible de joindre le serveur. Vérifiez votre connexion.'
    };
  }

  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================

  /// Inscription - Body: { name, email, password, age? }
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    int age = 25,
  }) async {
    final result = await _post(
      '/auth/register',
      {'name': name, 'email': email, 'password': password, 'age': age},
      auth: false,
    );
    if (result['success'] == true) {
      await saveToken(result['data']['token']);
    }
    return result;
  }

  /// Connexion - Body: { email, password }
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _post(
      '/auth/login',
      {'email': email, 'password': password},
      auth: false,
    );
    if (result['success'] == true) {
      await saveToken(result['data']['token']);
    }
    return result;
  }

  /// Utilisateur courant
  static Future<Map<String, dynamic>> getMe() async {
    return await _get('/auth/me');
  }

  /// Déconnexion
  static Future<void> logout() async {
    try {
      await _post('/auth/logout', {});
    } finally {
      await clearToken();
    }
  }

  /// Mot de passe oublié
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _post('/auth/forgot-password', {'email': email}, auth: false);
  }

  // ============================================================
  // ACTIVITIES ENDPOINTS
  // ============================================================

  /// Liste des activités
  /// [type] : 'tout', 'course', 'marche', 'velo', 'yoga', 'natation', 'musculation'
  static Future<Map<String, dynamic>> getActivities({
    String? type,
    int page = 1,
    int limit = 50,
    String sort = 'date_iso',
    String order = 'DESC',
    String? search,
  }) async {
    final params = StringBuffer('/activities?page=$page&limit=$limit&sort=$sort&order=$order');
    if (type != null && type != 'tout') params.write('&type=$type');
    if (search != null && search.isNotEmpty) params.write('&search=${Uri.encodeComponent(search)}');
    return await _get(params.toString());
  }

  /// Détail d'une activité
  static Future<Map<String, dynamic>> getActivityById(String id) async {
    return await _get('/activities/$id');
  }

  /// Créer une activité
  /// Champs: type, durationMin, intensity, dateISO, note?
  static Future<Map<String, dynamic>> createActivity({
    required String type,
    required int durationMin,
    required String intensity,
    required String dateISO,
    String? note,
  }) async {
    return await _post('/activities', {
      'type': type,
      'durationMin': durationMin,
      'intensity': intensity,
      'dateISO': dateISO,
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  /// Modifier une activité
  static Future<Map<String, dynamic>> updateActivity({
    required String id,
    String? type,
    int? durationMin,
    String? intensity,
    String? dateISO,
    String? note,
  }) async {
    final body = <String, dynamic>{};
    if (type != null) body['type'] = type;
    if (durationMin != null) body['durationMin'] = durationMin;
    if (intensity != null) body['intensity'] = intensity;
    if (dateISO != null) body['dateISO'] = dateISO;
    if (note != null) body['note'] = note;
    return await _put('/activities/$id', body);
  }

  /// Supprimer une activité
  static Future<Map<String, dynamic>> deleteActivity(String id) async {
    return await _delete('/activities/$id');
  }

  // ============================================================
  // STATS ENDPOINTS
  // ============================================================

  /// Stats du dashboard (home screen)
  static Future<Map<String, dynamic>> getDashboardStats() async {
    return await _get('/stats/dashboard');
  }

  /// Stats hebdomadaires
  static Future<Map<String, dynamic>> getWeeklyStats({int weeks = 4}) async {
    return await _get('/stats/weekly?weeks=$weeks');
  }

  // ============================================================
  // PROFILE ENDPOINTS
  // ============================================================

  /// Récupérer profil complet
  static Future<Map<String, dynamic>> getProfile() async {
    return await _get('/profile');
  }

  /// Mettre à jour profil
  /// Champs possibles: name, age, goalMinutesPerWeek, avatarState,
  ///                   gender, weight, height, fitnessGoal,
  ///                   activityLevel, notificationsEnabled, themeMode
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    return await _put('/profile', data);
  }

  /// Terminer l'onboarding
  static Future<Map<String, dynamic>> completeOnboarding({
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? fitnessGoal,
    String? activityLevel,
    int goalMinutesPerWeek = 150,
  }) async {
    return await _post('/profile/complete-onboarding', {
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (fitnessGoal != null) 'fitnessGoal': fitnessGoal,
      if (activityLevel != null) 'activityLevel': activityLevel,
      'goalMinutesPerWeek': goalMinutesPerWeek,
    });
  }

  /// Changer le mot de passe
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _put('/profile/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}