import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/avatar_state.dart';

/// Animated mood indicator badge that displays the current avatar
/// emotional state with an icon and label.
class MoodIndicator extends StatelessWidget {
  final AvatarState state;

  const MoodIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = _moodColor(state.mood);
    final icon = _moodIcon(state.mood);
    final label = _moodLabel(state.mood);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated emoji
          Text(
            icon,
            style: const TextStyle(fontSize: 22),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 800.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.15, 1.15),
                end: const Offset(1, 1),
                duration: 800.ms,
              ),
          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Avatar Mood',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Mood dot indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.5, end: 1.0, duration: 1200.ms),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.1, end: 0);
  }

  Color _moodColor(AvatarMood mood) {
    switch (mood) {
      case AvatarMood.happy:
        return const Color(0xFF10B981);
      case AvatarMood.neutral:
        return const Color(0xFF4F46E5);
      case AvatarMood.sad:
        return const Color(0xFFF59E0B);
    }
  }

  String _moodIcon(AvatarMood mood) {
    switch (mood) {
      case AvatarMood.happy:
        return '🎉';
      case AvatarMood.neutral:
        return '💪';
      case AvatarMood.sad:
        return '🔥';
    }
  }

  String _moodLabel(AvatarMood mood) {
    switch (mood) {
      case AvatarMood.happy:
        return 'Happy';
      case AvatarMood.neutral:
        return 'Neutral';
      case AvatarMood.sad:
        return 'Sad';
    }
  }
}
