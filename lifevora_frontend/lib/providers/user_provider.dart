import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;
  bool _isDarkMode = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    
    if (userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUser(UserModel user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  Future<void> updateAvatarState(String state) async {
    if (_user != null) {
      _user = _user!.copyWith(avatarState: state);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toJson()));
      notifyListeners();
    }
  }
}