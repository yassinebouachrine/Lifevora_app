import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';
import '../core/services/api_service.dart';

class ActivityProvider extends ChangeNotifier {
  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String _filterType = 'Tout';
  String _searchQuery = '';
  String? _errorMessage;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String get filterType => _filterType;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  // ============================================================
  // FILTERED ACTIVITIES (inchangé - logique locale)
  // ============================================================
List<ActivityModel> get filteredActivities {
  List<ActivityModel> result = List.from(_activities);

  // ✅ 'Tout' = pas de filtre, sinon filtrer par type API
  if (_filterType != 'Tout') {
    result = result.where((a) => a.type == _filterType).toList();
  }

  if (_searchQuery.isNotEmpty) {
    result = result
        .where((a) =>
            a.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (a.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();
  }

  result.sort((a, b) => b.dateISO.compareTo(a.dateISO));
  return result;
}

  // ============================================================
  // STATS (calculs locaux inchangés)
  // ============================================================
  int get totalWeekMinutes {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _activities
        .where((a) {
          final date = DateTime.parse(a.dateISO);
          return date.isAfter(weekStart.subtract(const Duration(days: 1)));
        })
        .fold(0, (sum, a) => sum + a.durationMin);
  }

  int get totalMonthMinutes {
    final now = DateTime.now();
    return _activities
        .where((a) {
          final date = DateTime.parse(a.dateISO);
          return date.month == now.month && date.year == now.year;
        })
        .fold(0, (sum, a) => sum + a.durationMin);
  }

  int get totalMonthSessions {
    final now = DateTime.now();
    return _activities
        .where((a) {
          final date = DateTime.parse(a.dateISO);
          return date.month == now.month && date.year == now.year;
        })
        .length;
  }

  double get avgDuration {
    if (_activities.isEmpty) return 0;
    final total = _activities.fold(0, (sum, a) => sum + a.durationMin);
    return total / _activities.length;
  }

  List<double> get last7DaysData {
    final now = DateTime.now();
    List<double> data = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayActivities = _activities.where((a) {
        final date = DateTime.parse(a.dateISO);
        return date.year == day.year &&
            date.month == day.month &&
            date.day == day.day;
      });
      data[i] = dayActivities.fold(0.0, (sum, a) => sum + a.durationMin);
    }

    return data;
  }

  ActivityModel? get lastActivity {
    if (_activities.isEmpty) return null;
    final sorted = List<ActivityModel>.from(_activities)
      ..sort((a, b) => b.dateISO.compareTo(a.dateISO));
    return sorted.first;
  }

  // ============================================================
  // LOAD ACTIVITIES
  // Stratégie: cache local d'abord → puis sync API
  // ============================================================
  Future<void> loadActivities(String userId) async {
    _isLoading = true;
    notifyListeners();

    // 1. Charger depuis le cache local (rapide)
    await _loadFromLocal(userId);

    _isLoading = false;
    notifyListeners();

    // 2. Synchroniser avec l'API en arrière-plan
    await _syncFromApi(userId);
  }

  /// Charger depuis SharedPreferences
  Future<void> _loadFromLocal(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = prefs.getString('activities_$userId');

      if (activitiesJson != null) {
        final List<dynamic> decoded = jsonDecode(activitiesJson);
        _activities = decoded.map((e) => ActivityModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Erreur _loadFromLocal: $e');
    }
  }

  /// Synchroniser depuis l'API et mettre à jour le cache
  Future<void> _syncFromApi(String userId) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final result = await ApiService.getActivities(limit: 100);

      if (result['success'] == true) {
        final List<dynamic> rawList = result['data']['activities'] ?? [];
        _activities = rawList.map((e) => ActivityModel.fromJson(e)).toList();
        await _saveToLocal(userId);
      }
    } catch (e) {
      debugPrint('Erreur _syncFromApi: $e');
      // Pas d'erreur visible si le cache local est déjà chargé
    }

    _isSyncing = false;
    notifyListeners();
  }

  // ============================================================
  // ADD ACTIVITY → local immédiat + API en arrière-plan
  // ============================================================
  Future<Map<String, dynamic>> addActivity(ActivityModel activity) async {
    // 1. Ajouter localement immédiatement (UX fluide)
    _activities.add(activity);
    await _saveToLocal(activity.userId);
    notifyListeners();

    // 2. Envoyer à l'API
    try {
      final result = await ApiService.createActivity(
        type: activity.type,
        durationMin: activity.durationMin,
        intensity: activity.intensity,
        dateISO: activity.dateISO,
        note: activity.note,
      );

      if (result['success'] == true) {
        // Remplacer l'activité locale par celle du serveur (avec vrai ID)
        final serverActivity =
            ActivityModel.fromJson(result['data']['activity']);

        final index = _activities.indexOf(activity);
        if (index != -1) {
          _activities[index] = serverActivity;
        } else {
          // Remplacer par ID local
          final idxById = _activities.indexWhere((a) => a.id == activity.id);
          if (idxById != -1) _activities[idxById] = serverActivity;
        }

        await _saveToLocal(serverActivity.userId);
        notifyListeners();
        return result;
      } else {
        // Rollback si erreur API
        _activities.removeWhere((a) => a.id == activity.id);
        await _saveToLocal(activity.userId);
        notifyListeners();
        _errorMessage = result['message'];
        return result;
      }
    } catch (e) {
      debugPrint('Erreur addActivity API: $e');
      // Garder en local si pas de réseau (sera synced plus tard)
      return {'success': true, 'message': 'Sauvegardé localement'};
    }
  }

  // ============================================================
  // UPDATE ACTIVITY → local + API
  // ============================================================
  Future<Map<String, dynamic>> updateActivity(ActivityModel activity) async {
    // Update local
    final index = _activities.indexWhere((a) => a.id == activity.id);
    final oldActivity = index != -1 ? _activities[index] : null;

    if (index != -1) {
      _activities[index] = activity;
      await _saveToLocal(activity.userId);
      notifyListeners();
    }

    // Update API
    try {
      final result = await ApiService.updateActivity(
        id: activity.id,
        type: activity.type,
        durationMin: activity.durationMin,
        intensity: activity.intensity,
        dateISO: activity.dateISO,
        note: activity.note,
      );

      if (result['success'] != true) {
        // Rollback
        if (oldActivity != null && index != -1) {
          _activities[index] = oldActivity;
          await _saveToLocal(activity.userId);
          notifyListeners();
        }
        _errorMessage = result['message'];
      }

      return result;
    } catch (e) {
      debugPrint('Erreur updateActivity API: $e');
      return {'success': true, 'message': 'Mis à jour localement'};
    }
  }

  // ============================================================
  // DELETE ACTIVITY → local + API
  // ============================================================
  Future<Map<String, dynamic>> deleteActivity(
      String activityId, String userId) async {
    // Backup pour rollback
    final backup = _activities.firstWhere(
      (a) => a.id == activityId,
      orElse: () => ActivityModel(
        id: '', userId: '', type: '', durationMin: 0,
        intensity: '', dateISO: '',
      ),
    );

    // Supprimer localement
    _activities.removeWhere((a) => a.id == activityId);
    await _saveToLocal(userId);
    notifyListeners();

    // Supprimer via API
    try {
      final result = await ApiService.deleteActivity(activityId);

      if (result['success'] != true) {
        // Rollback
        if (backup.id.isNotEmpty) {
          _activities.add(backup);
          await _saveToLocal(userId);
          notifyListeners();
        }
        _errorMessage = result['message'];
        return result;
      }

      return result;
    } catch (e) {
      debugPrint('Erreur deleteActivity API: $e');
      return {'success': true, 'message': 'Supprimé localement'};
    }
  }

  // ============================================================
  // FORCE SYNC depuis l'API
  // ============================================================
  Future<void> forceSync(String userId) async {
    await _syncFromApi(userId);
  }

  // ============================================================
  // CLEAR (à la déconnexion)
  // ============================================================
  Future<void> clearActivities(String userId) async {
    _activities = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('activities_$userId');
    notifyListeners();
  }

  // ============================================================
  // FILTER & SEARCH (inchangé)
  // ============================================================
  void setFilter(String filter) {
    _filterType = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // HELPERS PRIVÉS
  // ============================================================
  Future<void> _saveToLocal(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_activities.map((a) => a.toJson()).toList());
      await prefs.setString('activities_$userId', encoded);
    } catch (e) {
      debugPrint('Erreur _saveToLocal: $e');
    }
  }
}