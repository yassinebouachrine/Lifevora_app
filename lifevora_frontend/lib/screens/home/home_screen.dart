import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../history/history_screen.dart';
import '../add_activity/add_activity_screen.dart';
import '../profile/profile_screen.dart';
import '../metaverse/ar_avatar/avatar_ar_screen.dart';
import '../food_scanner/food_scanner_screen.dart';
import '../smart_coach/coach_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().user?.id ?? '';
      if (userId.isNotEmpty) {
        context.read<ActivityProvider>().loadActivities(userId);
      }
    });
  }

  bool get _isGuest {
    final user = context.read<UserProvider>().user;
    return user?.id.startsWith('guest_') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final isGuest = user?.id.startsWith('guest_') ?? false;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeContent(),                                    // 0
          isGuest ? _guestScreen() : const HistoryScreen(),      // 1
          isGuest ? _guestScreen() : const CoachScreen(),        // 2
          const SizedBox(),                                       // 3 FAB
          isGuest ? _guestScreen() : const FoodScannerScreen(),  // 4
          isGuest ? _guestScreen() : const AvatarArScreen(),     // 5
          isGuest ? _guestScreen() : const ProfileScreen(),      // 6
        ],
      ),
      bottomNavigationBar: LifevoraBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            if (isGuest) {
              _showGuestDialog(context);
            } else {
              _showAddActivity();
            }
          } else if (isGuest && index != 0) {
            _showGuestDialog(context);
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }

  // Écran vide (ne sera jamais affiché car dialog s'ouvre avant)
  Widget _guestScreen() => const SizedBox();

  void _showAddActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddActivityScreen()),
    );
  }

  void _showGuestDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => GuestDialog(
        onLogin: () {
          Navigator.pop(dialogContext);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        },
        onRegister: () {
          Navigator.pop(dialogContext);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
            (_) => false,
          );
        },
        onLater: () => Navigator.pop(dialogContext),
      ),
    );
  }
}

// ── Guest Dialog ───────────────────────────────────────────────
class GuestDialog extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onLater;

  const GuestDialog({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Connexion requise',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez un compte pour accéder à toutes les fonctionnalités de Lifevora.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Features
            _featureItem(
              HugeIcons.strokeRoundedTime01,
              'Historique de vos activités',
              isDark,
            ),
            _featureItem(
              HugeIcons.strokeRoundedBrain,
              'AI Coach personnalisé',
              isDark,
            ),
            _featureItem(
              HugeIcons.strokeRoundedCamera01,
              'Scanner nutritionnel',
              isDark,
            ),
            _featureItem(
              HugeIcons.strokeRoundedUserCircle,
              'Avatar Metaverse',
              isDark,
            ),
            const SizedBox(height: 24),
            // Bouton S'inscrire
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Bouton Se connecter
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: onLogin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onLater,
              child: Text(
                'Plus tard',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}