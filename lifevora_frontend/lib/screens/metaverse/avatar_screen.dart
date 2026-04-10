import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  String _selectedAccessory = 'none';

  final List<Map<String, String>> _accessories = [
    {'id': 'none', 'name': 'Aucun', 'emoji': '❌'},
    {'id': 'hat', 'name': 'Casquette', 'emoji': '🧢'},
    {'id': 'medal', 'name': 'Médaille', 'emoji': '🥇'},
    {'id': 'fire', 'name': 'Feu', 'emoji': '🔥'},
    {'id': 'star', 'name': 'Étoile', 'emoji': '⭐'},
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final ap = context.watch<ActivityProvider>();

    final progress = user != null && user.goalMinutesPerWeek > 0
        ? (ap.totalWeekMinutes / user.goalMinutesPerWeek).clamp(0.0, 1.0)
        : 0.0;

    final isHappy = progress >= 0.5;
    final avatarEmoji = isHappy ? '😄' : '😐';
    final avatarColor = isHappy ? AppColors.secondary : AppColors.primary;
    final avatarMsg = isHappy
        ? 'Super! Tu es à ${(progress * 100).toInt()}% de ton objectif! 🎉'
        : 'Continue tes efforts! Encore ${((1 - progress) * (user?.goalMinutesPerWeek ?? 150)).toInt()} min pour atteindre l\'objectif!';

    final accessoryEmoji = _accessories.firstWhere((a) => a['id'] == _selectedAccessory)['emoji']!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildAvatarZone(avatarEmoji, avatarColor, accessoryEmoji, isHappy, user?.name ?? '')
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 24),
              _buildStatusMessage(avatarMsg, isHappy)
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 24),
              _buildProgressSection(progress, ap, user?.goalMinutesPerWeek ?? 150)
                  .animate()
                  .fadeIn(delay: 500.ms),
              const SizedBox(height: 24),
              _buildAccessories().animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 24),
              _buildMetaverseStats(ap).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mon Avatar',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Espace Métaverse 🌐',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '3D bientôt',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarZone(
    String emoji,
    Color color,
    String accessory,
    bool isHappy,
    String name,
  ) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _bounceController.value),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background decorations
            Positioned(
              top: 20,
              right: 20,
              child: Text(
                '✨',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.yellow.withOpacity(0.6),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 30,
              child: Text(
                '⭐',
                style: TextStyle(fontSize: 16, color: Colors.amber.withOpacity(0.5)),
              ),
            ),
            // Avatar body
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Accessory
                if (accessory != '❌')
                  Text(accessory, style: const TextStyle(fontSize: 36)),
                // Avatar circle
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHappy ? '🏆 Objectif en cours!' : '💪 En progression',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage(String msg, bool isHappy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHappy
            ? AppColors.success.withOpacity(0.08)
            : AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHappy
              ? AppColors.success.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(isHappy ? '🎉' : '💡', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isHappy ? AppColors.success : AppColors.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(double progress, ActivityProvider ap, int goal) {
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
                'XP cette semaine',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()} / 100 XP',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.success : AppColors.primary,
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _xpStat('⚡', '${ap.totalWeekMinutes}', 'min actif'),
              _xpStat('🔥', '${ap.totalMonthSessions}', 'séances/mois'),
              _xpStat('🎯', '${goal}', 'objectif/sem'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _xpStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAccessories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accessoires Avatar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _accessories.length,
            itemBuilder: (context, i) {
              final acc = _accessories[i];
              final isSelected = _selectedAccessory == acc['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedAccessory = acc['id']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade200,
                        width: 2,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(acc['emoji']!, style: const TextStyle(fontSize: 24)),
                        Text(
                          acc['name']!,
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetaverseStats(ActivityProvider ap) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌐 Stats Métaverse',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metaStat('🏆', 'Niveau', '${(ap.activities.length / 5).floor() + 1}'),
              _metaStat('💎', 'Gemmes', '${ap.totalWeekMinutes * 2}'),
              _metaStat('⚔️', 'Rang', ap.activities.length >= 10 ? 'Or' : 'Bronze'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaStat(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}