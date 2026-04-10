import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';

class ActivityProvider extends ChangeNotifier {
  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String _filterType = 'Tout';
  String _searchQuery = '';

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String get filterType => _filterType;
  String get searchQuery => _searchQuery;

  List<ActivityModel> get filteredActivities {
    List<ActivityModel> result = List.from(_activities);
    
    if (_filterType != 'Tout') {
      result = result.where((a) => a.type == _filterType).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((a) =>
              a.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (a.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }
    
    result.sort((a, b) => b.dateISO.compareTo(a.dateISO));
    return result;
  }

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

  Future<void> loadActivities(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getString('activities_$userId');
    
    if (activitiesJson != null) {
      final List<dynamic> decoded = jsonDecode(activitiesJson);
      _activities = decoded.map((e) => ActivityModel.fromJson(e)).toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addActivity(ActivityModel activity) async {
    _activities.add(activity);
    await _saveActivities(activity.userId);
    notifyListeners();
  }

  Future<void> updateActivity(ActivityModel activity) async {
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
      await _saveActivities(activity.userId);
      notifyListeners();
    }
  }

  Future<void> deleteActivity(String activityId, String userId) async {
    _activities.removeWhere((a) => a.id == activityId);
    await _saveActivities(userId);
    notifyListeners();
  }

  Future<void> _saveActivities(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_activities.map((a) => a.toJson()).toList());
    await prefs.setString('activities_$userId', encoded);
  }

  void setFilter(String filter) {
    _filterType = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}