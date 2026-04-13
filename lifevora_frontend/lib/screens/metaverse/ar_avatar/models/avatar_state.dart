/// Represents the emotional state of the 3D avatar based on user progress.
enum AvatarMood {
  sad,     // < 40% progress
  neutral, // 40–99% progress
  happy,   // >= 100% progress
}

/// Immutable data class representing the avatar's current state.
class AvatarState {
  final AvatarMood mood;
  final double progress; // 0.0 – 100.0+
  final String label;
  final String emoji;

  const AvatarState({
    required this.mood,
    required this.progress,
    required this.label,
    required this.emoji,
  });

  /// Factory that resolves the correct state from a progress percentage.
  factory AvatarState.fromProgress(double progress) {
    if (progress >= 100.0) {
      return AvatarState(
        mood: AvatarMood.happy,
        progress: progress,
        label: 'You reached your goal 🎉',
        emoji: '🎉',
      );
    } else if (progress >= 40.0) {
      return AvatarState(
        mood: AvatarMood.neutral,
        progress: progress,
        label: 'Keep going 💪',
        emoji: '💪',
      );
    } else {
      return AvatarState(
        mood: AvatarMood.sad,
        progress: progress,
        label: "Let's get moving! 🔥",
        emoji: '🔥',
      );
    }
  }

  /// JS-compatible mood string for the Three.js scene.
  String get moodString {
    switch (mood) {
      case AvatarMood.happy:
        return 'happy';
      case AvatarMood.neutral:
        return 'neutral';
      case AvatarMood.sad:
        return 'sad';
    }
  }
}
