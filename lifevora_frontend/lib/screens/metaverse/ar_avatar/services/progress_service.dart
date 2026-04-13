import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for calculating weekly fitness goal progress.
/// Provides a 0–100+ percentage representing how much of the weekly
/// goal the user has completed.
class ProgressService {
  static const String _weeklyGoalKey = 'weekly_goal_minutes';
  static const int defaultWeeklyGoalMinutes = 150; // WHO recommendation

  /// Calculate weekly progress percentage from activity data.
  /// Returns 0.0 – 100.0+ (can exceed 100% if user surpasses goal).
  static double calculateWeeklyProgress({
    required int totalWeekMinutes,
    int? weeklyGoalMinutes,
  }) {
    final goal = weeklyGoalMinutes ?? defaultWeeklyGoalMinutes;
    if (goal <= 0) return 0.0;
    return (totalWeekMinutes / goal) * 100.0;
  }

  /// Load the user's custom weekly goal from local storage.
  static Future<int> loadWeeklyGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_weeklyGoalKey) ?? defaultWeeklyGoalMinutes;
    } catch (e) {
      debugPrint('ProgressService.loadWeeklyGoal error: $e');
      return defaultWeeklyGoalMinutes;
    }
  }

  /// Persist the user's custom weekly goal.
  static Future<void> saveWeeklyGoal(int minutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_weeklyGoalKey, minutes);
    } catch (e) {
      debugPrint('ProgressService.saveWeeklyGoal error: $e');
    }
  }
}
