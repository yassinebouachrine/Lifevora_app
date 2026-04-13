import 'package:flutter/foundation.dart';
import '../models/avatar_state.dart';
import '../services/progress_service.dart';

/// Manages the avatar's emotional state and notifies listeners when
/// the mood changes. Acts as the bridge between activity data and
/// the 3D rendering layer.
class AvatarStateManager extends ChangeNotifier {
  AvatarState _state = AvatarState.fromProgress(0);
  int _weeklyGoalMinutes = ProgressService.defaultWeeklyGoalMinutes;
  bool _isInitialized = false;

  AvatarState get state => _state;
  int get weeklyGoalMinutes => _weeklyGoalMinutes;
  bool get isInitialized => _isInitialized;

  /// Initialize with saved goal preference.
  Future<void> initialize() async {
    _weeklyGoalMinutes = await ProgressService.loadWeeklyGoal();
    _isInitialized = true;
    notifyListeners();
  }

  /// Update the avatar state based on current week's total activity minutes.
  /// This should be called whenever activity data changes.
  void updateFromActivityMinutes(int totalWeekMinutes) {
    final progress = ProgressService.calculateWeeklyProgress(
      totalWeekMinutes: totalWeekMinutes,
      weeklyGoalMinutes: _weeklyGoalMinutes,
    );

    final newState = AvatarState.fromProgress(progress);

    // Only notify if mood actually changed (avoid unnecessary redraws)
    final moodChanged = newState.mood != _state.mood;
    _state = newState;

    if (moodChanged) {
      debugPrint('AvatarStateManager: mood → ${newState.moodString} '
          '(${progress.toStringAsFixed(1)}%)');
    }

    notifyListeners();
  }

  /// Update the weekly goal and recalculate.
  Future<void> setWeeklyGoal(int minutes, int currentWeekMinutes) async {
    _weeklyGoalMinutes = minutes;
    await ProgressService.saveWeeklyGoal(minutes);
    updateFromActivityMinutes(currentWeekMinutes);
  }
}
