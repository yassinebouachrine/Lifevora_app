import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';
import '../onboarding/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final ap = context.watch<ActivityProvider>();

    if (user == null) return const SizedBox();

    final progress = user.goalMinutesPerWeek > 0
        ? (ap.totalWeekMinutes / user.goalMinutesPerWeek).clamp(0.0, 1.0)
        : 0.0;

    final badges = _getBadges(ap.activities.length, ap.totalMonthSessions);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 20),
              _buildProfileCard(user).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),
              _buildStatsRow(ap).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 20),
              _buildWeeklyGoal(ap, user.goalMinutesPerWeek, progress).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 20),
              _buildBadges(badges).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 20),
              _buildLogoutBtn(context).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          ),
        ),
        const Expanded(
          child: Text(
            'Mon Profil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.edit_rounded, color: AppColors.textSecondary, size: 18),
        ),
      ],
    );
  }

  Widget _buildProfileCard(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.age} ans',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎯', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'Objectif : ${user.goalMinutesPerWeek} min / semaine',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ActivityProvider ap) {
    return Row(
      children: [
        _statItem('📅', '${ap.totalWeekMinutes}min', 'Cette semaine', AppColors.primary),
        const SizedBox(width: 12),
        _statItem('⏱', '${ap.avgDuration.toInt()}min', 'Moy. durée', AppColors.secondary),
        const SizedBox(width: 12),
        _statItem('🎯', '${ap.activities.length}', 'Séances', AppColors.accentPurple),
      ],
    );
  }

  Widget _statItem(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGoal(ActivityProvider ap, int goal, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Objectif hebdomadaire',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${ap.totalWeekMinutes} / $goal min · ${ap.totalMonthMinutes} min ce mois',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getBadges(int total, int monthly) {
    return [
      {'emoji': '🏃', 'name': 'Première séance', 'unlocked': total >= 1},
      {'emoji': '🔥', '5 séances réalisées': '5 séances réalisées', 'name': '5 séances réalisées', 'unlocked': total >= 5},
      {'emoji': '🏆', 'name': '10 séances réalisées', 'unlocked': total >= 10},
      {'emoji': '⚡', 'name': 'Objectif mensuel atteint', 'unlocked': monthly >= 4},
    ];
  }

 Widget _buildBadges(List<Map<String, dynamic>> badges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('🏅', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text(
              'Badges',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...badges.map((badge) {    // <- SANS .toList()
          final unlocked = badge['unlocked'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0x1410B981)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unlocked
                    ? const Color(0x4D10B981)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Text(badge['emoji'] as String,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Text(
                  badge['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: unlocked ? AppColors.secondary : AppColors.textHint,
                  ),
                ),
                const Spacer(),
                if (unlocked)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.secondary, size: 20)
                else
                  const Icon(Icons.lock_outline_rounded,
                      color: AppColors.textHint, size: 18),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLogoutBtn(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () async {
          await context.read<UserProvider>().logout();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (_) => false,
            );
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'Se déconnecter',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}