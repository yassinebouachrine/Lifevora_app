import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/activity_provider.dart';
import 'managers/avatar_state_manager.dart';
import 'models/avatar_state.dart';
import 'widgets/ar_avatar_webview.dart';
import 'widgets/mood_indicator.dart';
import 'widgets/progress_ring.dart';
import 'widgets/goal_editor_sheet.dart';

/// The main Avatar AR screen that combines the 3D WebView scene
/// with Flutter overlay UI showing progress, mood, and controls.
class AvatarArScreen extends StatefulWidget {
  const AvatarArScreen({super.key});

  @override
  State<AvatarArScreen> createState() => _AvatarArScreenState();
}

class _AvatarArScreenState extends State<AvatarArScreen>
    with TickerProviderStateMixin {
  late final AvatarStateManager _avatarManager;
  late final AnimationController _pulseController;
  late final AnimationController _slideController;
  bool _showControls = true;
  bool _isLoaded = false;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _avatarManager = AvatarStateManager();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _initializeAvatar();
  }

  Future<void> _initializeAvatar() async {
    await _avatarManager.initialize();

    // Initial progress sync
    if (mounted) {
      final weekMinutes = context.read<ActivityProvider>().totalWeekMinutes;
      _avatarManager.updateFromActivityMinutes(weekMinutes);

      // Poll for changes every 5 seconds (lightweight)
      _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) {
          final mins = context.read<ActivityProvider>().totalWeekMinutes;
          _avatarManager.updateFromActivityMinutes(mins);
        }
      });
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoaded = true);
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _progressTimer?.cancel();
    _avatarManager.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _isDark ? const Color(0xFF060610) : const Color(0xFF0a0a1a),
      body: SizedBox.expand(
        child: Stack(
          children: [
            // ── 3D Avatar WebView (full screen) ──
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _avatarManager,
              builder: (context, _) {
                return ArAvatarWebView(
                  progress: _avatarManager.state.progress,
                  mood: _avatarManager.state.moodString,
                );
              },
            ),
          ),

          // ── Top gradient for readability ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom gradient ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Top Bar ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildTopBar(),
            ),
          ),

          // ── Bottom HUD ──
          if (_isLoaded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: _buildBottomHud(),
              ),
            ),

          // ── Loading overlay ──
          if (!_isLoaded)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Top Bar
  // ────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Row(
      children: [
        // Back button
        _glassButton(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),

        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MY AVATAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Metaverse Fitness',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Toggle controls
        _glassButton(
          icon: _showControls
              ? HugeIcons.strokeRoundedEye
              : HugeIcons.strokeRoundedViewOffSlash,
          onTap: () => setState(() => _showControls = !_showControls),
        ),

        const SizedBox(width: 8),

        // Settings (goal editor)
        _glassButton(
          icon: HugeIcons.strokeRoundedSettings01,
          onTap: _openGoalEditor,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(begin: -0.3, end: 0);
  }

  // ────────────────────────────────────────────────────────────
  // Bottom HUD
  // ────────────────────────────────────────────────────────────
  Widget _buildBottomHud() {
    if (!_showControls) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: _avatarManager,
      builder: (context, _) {
        final state = _avatarManager.state;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mood indicator with animated badge
              MoodIndicator(state: state),
              const SizedBox(height: 16),

              // Progress card
              _buildProgressCard(state),
              const SizedBox(height: 12),

              // Quick stats row
              _buildStatsRow(),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 400.ms)
            .slideY(begin: 0.3, end: 0);
      },
    );
  }

  // ────────────────────────────────────────────────────────────
  // Progress Card
  // ────────────────────────────────────────────────────────────
  Widget _buildProgressCard(AvatarState state) {
    final moodColor = _moodColor(state.mood);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: moodColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: moodColor.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress ring
          ProgressRing(
            progress: state.progress.clamp(0, 100) / 100,
            color: moodColor,
            size: 72,
            child: Text(
              '${state.progress.clamp(0, 999).toInt()}%',
              style: TextStyle(
                color: moodColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Goal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.label,
                  style: TextStyle(
                    color: moodColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Mini progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (state.progress / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(moodColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Stats Row
  // ────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final activityProvider = context.watch<ActivityProvider>();
    final weekMinutes = activityProvider.totalWeekMinutes;
    final sessions = activityProvider.totalMonthSessions;
    final goalMinutes = _avatarManager.weeklyGoalMinutes;

    return Row(
      children: [
        Expanded(
          child: _statChip(
            icon: HugeIcons.strokeRoundedTime01,
            value: '${weekMinutes}m',
            label: 'This Week',
            color: AppColors.accentBlue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statChip(
            icon: HugeIcons.strokeRoundedTarget01,
            value: '${goalMinutes}m',
            label: 'Goal',
            color: AppColors.accentPurple,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statChip(
            icon: HugeIcons.strokeRoundedActivity01,
            value: '$sessions',
            label: 'Sessions',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          HugeIcon(icon: icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Glass Button
  // ────────────────────────────────────────────────────────────
  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: HugeIcon(icon: icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Goal Editor
  // ────────────────────────────────────────────────────────────
  void _openGoalEditor() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GoalEditorSheet(
        currentGoal: _avatarManager.weeklyGoalMinutes,
        onSave: (newGoal) {
          final weekMinutes =
              context.read<ActivityProvider>().totalWeekMinutes;
          _avatarManager.setWeeklyGoal(newGoal, weekMinutes);
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────
  Color _moodColor(AvatarMood mood) {
    switch (mood) {
      case AvatarMood.happy:
        return AppColors.secondary; // green
      case AvatarMood.neutral:
        return AppColors.primary;   // indigo
      case AvatarMood.sad:
        return AppColors.accent;    // amber
    }
  }
}
