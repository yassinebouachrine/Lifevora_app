import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';
import '../auth/auth_gate_screen.dart';


import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final ap = context.watch<ActivityProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) return const SizedBox();

    final progress = user.goalMinutesPerWeek > 0
        ? (ap.totalWeekMinutes / user.goalMinutesPerWeek)
            .clamp(0.0, 1.0)
        : 0.0;

    final badges = _getBadges(ap.activities.length, ap.totalMonthSessions);

    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildAppBar(context, isDark, textPrimary),
              const SizedBox(height: 20),
              _buildProfileCard(
                context, user, isDark, surfaceColor,
                textPrimary, textSecondary,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 16),
              _buildStatsRow(
                ap, isDark, surfaceColor, textSecondary,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              _buildWeeklyGoal(
                ap, user.goalMinutesPerWeek,
                progress, isDark, surfaceColor, textPrimary, textSecondary,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),
              _buildBadges(
                badges, isDark, surfaceColor, textPrimary,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 20),
              _buildSettingsSection(
                context, isDark, surfaceColor, textPrimary, textSecondary,
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 16),
              _buildLogoutBtn(context, isDark)
                  .animate()
                  .fadeIn(delay: 600.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────
  Widget _buildAppBar(
    BuildContext context,
    bool isDark,
    Color textPrimary,
  ) {
    return Row(
      children: [
        Text(
          'Mon Profil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const Spacer(),

        // ✅ Bouton Settings
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSettings01,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // ✅ Bouton Edit Profil
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedPencilEdit01,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Profile Card ───────────────────────────────────────────────
  Widget _buildProfileCard(
    BuildContext context,
    dynamic user,
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : '?',
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          if (user.email != null && user.email!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.email!,
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${user.age} ans',
            style: TextStyle(
              fontSize: 15,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedTarget01,
                  color: AppColors.primary,
                  size: 16,
                ),
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

  // ── Stats ──────────────────────────────────────────────────────
  Widget _buildStatsRow(
    ActivityProvider ap,
    bool isDark,
    Color surfaceColor,
    Color textSecondary,
  ) {
    return Row(
      children: [
        _statItem(
          HugeIcons.strokeRoundedCalendar01,
          '${ap.totalWeekMinutes}min',
          'Cette semaine',
          AppColors.primary,
          surfaceColor,
          isDark,
        ),
        const SizedBox(width: 10),
        _statItem(
          HugeIcons.strokeRoundedClock01,
          '${ap.avgDuration.toInt()}min',
          'Moy. durée',
          AppColors.secondary,
          surfaceColor,
          isDark,
        ),
        const SizedBox(width: 10),
        _statItem(
          HugeIcons.strokeRoundedTarget01,
          '${ap.activities.length}',
          'Séances',
          AppColors.accentPurple,
          surfaceColor,
          isDark,
        ),
      ],
    );
  }

  Widget _statItem(
    IconData icon,
    String value,
    String label,
    Color color,
    Color surfaceColor,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Weekly Goal ────────────────────────────────────────────────
  Widget _buildWeeklyGoal(
    ActivityProvider ap,
    int goal,
    double progress,
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Objectif hebdomadaire',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  AppColors.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0
                    ? AppColors.secondary
                    : AppColors.primary,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${ap.totalWeekMinutes} / $goal min  •  ${ap.totalMonthMinutes} min ce mois',
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Badges ─────────────────────────────────────────────────────
List<Map<String, dynamic>> _getBadges(int total, int monthly) {
    return [
      {
        'icon': HugeIcons.strokeRoundedRunningShoes,
        'name': 'Première séance',
        'unlocked': total >= 1,
      },
      {
        'icon': HugeIcons.strokeRoundedFire,
        'name': '5 séances réalisées',
        'unlocked': total >= 5,
      },
      {
        'icon': HugeIcons.strokeRoundedAward01,  // ✅ remplace strokeRoundedTrophy
        'name': '10 séances réalisées',
        'unlocked': total >= 10,
      },
      {
        'icon': HugeIcons.strokeRoundedTarget01,
        'name': 'Objectif mensuel atteint',
        'unlocked': monthly >= 4,
      },
    ];
  }

Widget _buildBadges(
    List<Map<String, dynamic>> badges,
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedMedal01,
              color: AppColors.accent,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Badges',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...badges.map((badge) {
          final unlocked = badge['unlocked'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.secondary.withValues(alpha: 0.08)
                  : surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unlocked
                    ? AppColors.secondary.withValues(alpha: 0.3)
                    : (isDark
                        ? AppColors.darkBorder
                        : AppColors.border),
              ),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: badge['icon'] as IconData,
                  color: unlocked
                      ? AppColors.secondary
                      : (isDark
                          ? AppColors.darkTextHint
                          : AppColors.textHint),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  badge['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: unlocked
                        ? AppColors.secondary
                        : (isDark
                            ? AppColors.darkTextHint
                            : AppColors.textHint),
                  ),
                ),
                const Spacer(),
                // ✅ strokeRoundedLock01 remplacé par strokeRoundedSquareLock01
                HugeIcon(
                  icon: unlocked
                      ? HugeIcons.strokeRoundedCheckmarkCircle01
                      : HugeIcons.strokeRoundedSquareLock01,
                  color: unlocked
                      ? AppColors.secondary
                      : (isDark
                          ? AppColors.darkTextHint
                          : AppColors.textHint),
                  size: 18,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Settings Section ───────────────────────────────────────────
  Widget _buildSettingsSection(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final items = [
      {
        'icon': HugeIcons.strokeRoundedNotification01,
        'label': 'Notifications',
        'color': AppColors.primary,
        'screen': const SettingsScreen(),
      },
      {
        'icon': HugeIcons.strokeRoundedShield01,
        'label': 'Confidentialité',
        'color': AppColors.secondary,
        'screen': const SettingsScreen(),
      },
      {
        'icon': HugeIcons.strokeRoundedHelpCircle,
        'label': 'Aide & Support',
        'color': AppColors.accentPurple,
        'screen': const SettingsScreen(),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;
          final color = item['color'] as Color;

          return Column(
            children: [
              GestureDetector(
                // ✅ Naviguer vers SettingsScreen
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => item['screen'] as Widget,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: item['icon'] as IconData,
                            color: color,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const Spacer(),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 68,
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Logout ─────────────────────────────────────────────────────
  Widget _buildLogoutBtn(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () => _handleLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(
            color: AppColors.error.withValues(alpha: 0.5),
          ),
          backgroundColor: AppColors.error.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedLogout01,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Se déconnecter',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ── Remplacer _handleLogout ────────────────────────────────────
  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Se déconnecter',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Voulez-vous vraiment vous déconnecter?',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Déconnecter',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      final userId = context.read<UserProvider>().user?.id ?? '';

      // ✅ 1. Vider les activités locales
      await context.read<ActivityProvider>().clearActivities(userId);

      // ✅ 2. Logout API + clear token + clear user local
      await context.read<UserProvider>().logout();

      if (context.mounted) {
        // ✅ 3. Rediriger vers AuthGateScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGateScreen()),
          (_) => false,
        );
      }
    }
  }
}