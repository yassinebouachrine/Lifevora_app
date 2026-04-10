import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/services/api_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;
  bool _isDarkMode = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  // ============================================================
  // LOAD USER (depuis cache local au démarrage)
  // ============================================================
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final isDark = prefs.getBool('isDarkMode') ?? false;
      _isDarkMode = isDark;

      if (userJson != null) {
        _user = UserModel.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      debugPrint('Erreur loadUser local: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // REGISTER → API + cache local
  // ============================================================
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    int age = 25,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.register(
        name: name,
        email: email,
        password: password,
        age: age,
      );

      if (result['success'] == true) {
        final userData = result['data']['user'];
        final user = UserModel.fromJson(userData);
        await _saveUserLocal(user);
        _user = user;
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Erreur lors de l\'inscription';
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Erreur de connexion au serveur';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  // ============================================================
  // LOGIN → API + cache local
  // ============================================================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        final userData = result['data']['user'];
        final user = UserModel.fromJson(userData);
        await _saveUserLocal(user);
        _user = user;
        _errorMessage = null;

        // Sauvegarder settings
        if (result['data']['settings'] != null) {
          final settings = result['data']['settings'];
          final prefs = await SharedPreferences.getInstance();
          if (settings['theme_mode'] == 'dark') {
            _isDarkMode = true;
            await prefs.setBool('isDarkMode', true);
          }
        }
      } else {
        _errorMessage = result['message'] ?? 'Email ou mot de passe incorrect';
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Erreur de connexion au serveur';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  // ============================================================
  // REFRESH depuis l'API (synchroniser avec serveur)
  // ============================================================
  Future<void> refreshUser() async {
    try {
      final result = await ApiService.getMe();
      if (result['success'] == true) {
        final userData = result['data']['user'];
        final user = UserModel.fromJson(userData);
        await _saveUserLocal(user);
        _user = user;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur refreshUser: $e');
    }
  }

  // ============================================================
  // SAVE USER (local uniquement)
  // ============================================================
  Future<void> saveUser(UserModel user) async {
    _user = user;
    await _saveUserLocal(user);
    notifyListeners();
  }

  // ============================================================
  // UPDATE USER → API + cache local
  // ============================================================
  Future<Map<String, dynamic>> updateUser(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.updateProfile({
        'name': user.name,
        'age': user.age,
        'goalMinutesPerWeek': user.goalMinutesPerWeek,
        'avatarState': user.avatarState,
        if (user.email != null) 'email': user.email,
      });

      if (result['success'] == true) {
        _user = user;
        await _saveUserLocal(user);
      } else {
        _errorMessage = result['message'];
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  // ============================================================
  // ✅ UPDATE PROFILE (données partielles) → API + cache local
  // Utilisé par: settings_screen, edit_profile_screen
  // ============================================================
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      // ✅ Appel API
      final result = await ApiService.updateProfile(data);

      if (result['success'] == true && _user != null) {
        // ✅ Mettre à jour le cache local avec les nouvelles données
        bool needsUpdate = false;
        String? newName = _user!.name;
        int? newAge = _user!.age;
        int? newGoal = _user!.goalMinutesPerWeek;
        String? newAvatarState = _user!.avatarState;

        if (data.containsKey('name') && data['name'] != null) {
          newName = data['name'].toString();
          needsUpdate = true;
        }
        if (data.containsKey('age') && data['age'] != null) {
          newAge = data['age'] is int
              ? data['age']
              : int.tryParse(data['age'].toString()) ?? _user!.age;
          needsUpdate = true;
        }
        if (data.containsKey('goalMinutesPerWeek') &&
            data['goalMinutesPerWeek'] != null) {
          newGoal = data['goalMinutesPerWeek'] is int
              ? data['goalMinutesPerWeek']
              : int.tryParse(data['goalMinutesPerWeek'].toString()) ??
                  _user!.goalMinutesPerWeek;
          needsUpdate = true;
        }
        if (data.containsKey('avatarState') && data['avatarState'] != null) {
          newAvatarState = data['avatarState'].toString();
          needsUpdate = true;
        }

        if (needsUpdate) {
          _user = _user!.copyWith(
            name: newName,
            age: newAge,
            goalMinutesPerWeek: newGoal,
            avatarState: newAvatarState,
          );
          await _saveUserLocal(_user!);
          notifyListeners();
        }
      }

      return result;
    } catch (e) {
      debugPrint('Erreur updateProfile: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  // ============================================================
  // UPDATE AVATAR STATE → API + cache local
  // ============================================================
  Future<void> updateAvatarState(String state) async {
    if (_user == null) return;

    _user = _user!.copyWith(avatarState: state);
    await _saveUserLocal(_user!);
    notifyListeners();

    try {
      await ApiService.updateProfile({'avatarState': state});
    } catch (e) {
      debugPrint('Erreur updateAvatarState API: $e');
    }
  }

  // ============================================================
  // COMPLETE ONBOARDING → API
  // ============================================================
  Future<Map<String, dynamic>> completeOnboarding({
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? fitnessGoal,
    String? activityLevel,
    int goalMinutesPerWeek = 150,
  }) async {
    try {
      final result = await ApiService.completeOnboarding(
        age: age,
        gender: gender,
        weight: weight,
        height: height,
        fitnessGoal: fitnessGoal,
        activityLevel: activityLevel,
        goalMinutesPerWeek: goalMinutesPerWeek,
      );

      if (result['success'] == true && _user != null) {
        _user = _user!.copyWith(
          age: age ?? _user!.age,
          goalMinutesPerWeek: goalMinutesPerWeek,
        );
        await _saveUserLocal(_user!);
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  // ============================================================
  // CHANGE PASSWORD → API
  // ============================================================
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await ApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  // ============================================================
  // LOGOUT → API + clear local
  // ============================================================
  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
      debugPrint('Erreur logout API: $e');
    }

    _user = null;
    _isDarkMode = false;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('isDarkMode');

    notifyListeners();
  }

  // ============================================================
  // TOGGLE DARK MODE (local + sync API)
  // ============================================================
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveDarkMode(_isDarkMode);

    ApiService.updateProfile({
      'themeMode': _isDarkMode ? 'dark' : 'light',
    }).catchError((e) => debugPrint('Erreur sync themeMode: $e'));

    notifyListeners();
  }

  // ============================================================
  // HELPERS PRIVÉS
  // ============================================================
  Future<void> _saveUserLocal(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Erreur _saveUserLocal: $e');
    }
  }

  Future<void> _saveDarkMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', value);
    } catch (e) {
      debugPrint('Erreur _saveDarkMode: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}