import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';
import '../../core/services/api_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  bool _isChecking = true; // ✅ Vérification token au démarrage

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  // ============================================================
  // ✅ Vérifier si un token valide existe au démarrage
  // ============================================================
  Future<void> _checkExistingSession() async {
    try {
      final hasToken = await ApiService.hasToken();

      if (!hasToken) {
        // Pas de token → afficher l'écran d'accueil
        if (mounted) setState(() => _isChecking = false);
        return;
      }

      // Token existe → vérifier sa validité avec /api/auth/me
      final result = await ApiService.getMe();

      if (!mounted) return;

      if (result['success'] == true) {
        // ✅ Token valide → restaurer l'utilisateur et aller sur Home
        final userData = result['data']['user'];
        final user = UserModel.fromJson(userData);

        await context.read<UserProvider>().saveUser(user);
        if (!mounted) return;

        // Charger les activités
        await context.read<ActivityProvider>().loadActivities(user.id);
        if (!mounted) return;

        // Naviguer vers Home directement
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      } else {
        // ✅ Token invalide/expiré → clear et afficher AuthGate
        await ApiService.clearToken();
        if (mounted) setState(() => _isChecking = false);
      }
    } catch (e) {
      // ✅ Erreur réseau → vérifier si user en cache local
      debugPrint('Erreur _checkExistingSession: $e');

      if (!mounted) return;

      // Tenter de charger depuis le cache local
      await context.read<UserProvider>().loadUser();
      final cachedUser = context.read<UserProvider>().user;

      if (cachedUser != null && mounted) {
        // Cache disponible → aller en Home (mode hors-ligne)
        await context.read<ActivityProvider>().loadActivities(cachedUser.id);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        }
      } else {
        if (mounted) setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    // ✅ Splash screen pendant la vérification du token
    if (_isChecking) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x554F46E5),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedDumbbell01,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.7, 0.7)),
              const SizedBox(height: 20),
              const Text(
                'Lifevora',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 40),
              // ✅ Loader
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      );
    }

    // ✅ Écran principal AuthGate
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _ThemeToggleBtn(),
                ),
              ),
              const Spacer(flex: 2),
              _buildLogo(isDark)
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(begin: const Offset(0.6, 0.6)),
              const SizedBox(height: 28),
              _buildTitle(isDark)
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
              const Spacer(flex: 3),
              _buildButtons(context, isDark)
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.5, end: 0),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x554F46E5),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedDumbbell01,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Lifevora',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fitness & Well-Being',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(bool isDark) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      children: [
        Text(
          'Votre parcours fitness\ncommence ici',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Suivez vos activités, analysez vos repas,\net évoluez avec votre AI Coach.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _featureBadge(HugeIcons.strokeRoundedBrain, 'AI Coach'),
            _featureBadge(HugeIcons.strokeRoundedCamera01, 'Food Scan'),
            _featureBadge(
              HugeIcons.strokeRoundedGameController01,
              'Metaverse',
            ),
          ],
        ),
      ],
    );
  }

  Widget _featureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        // ✅ Créer un compte → RegisterScreen
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ✅ J'ai déjà un compte → LoginScreen
        SizedBox(
          width: double.infinity,
          height: 58,
          child: OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.primary,
                width: 1.5,
              ),
              backgroundColor: isDark
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedLogin01,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'J\'ai déjà un compte',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ✅ Continuer sans compte → HomeScreen (mode invité)
        TextButton(
          onPressed: () => _continueWithoutAccount(context),
          child: Text(
            'Continuer sans compte →',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Mode invité - pas d'API, données locales uniquement
  Future<void> _continueWithoutAccount(BuildContext context) async {
    final guestUser = UserModel(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Invité',
      age: 25,
      goalMinutesPerWeek: 150,
      email: null,
    );

    await context.read<UserProvider>().saveUser(guestUser);
    if (!context.mounted) return;

    await context.read<ActivityProvider>().loadActivities(guestUser.id);
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }
}

// ── Theme Toggle ───────────────────────────────────────────────
class _ThemeToggleBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? AppColors.primary : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isDark ? 30 : 2,
              top: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(
                    icon: isDark
                        ? HugeIcons.strokeRoundedMoon01
                        : HugeIcons.strokeRoundedSun01,
                    color: isDark ? AppColors.primary : AppColors.accent,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}