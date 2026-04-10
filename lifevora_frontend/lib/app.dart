import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/services/api_service.dart';
import 'models/user_model.dart';
import 'providers/user_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/auth_gate_screen.dart';
import 'screens/home/home_screen.dart';

class LifevoraApp extends StatelessWidget {
  const LifevoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Lifevora',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          home: const AppRouter(),
        );
      },
    );
  }
}

// ============================================================
// AppRouter - Gère le démarrage et la vérification de session
// ============================================================
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  // Statuts possibles du router
  _RouterStatus _status = _RouterStatus.checking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  // ============================================================
  // Logique d'initialisation complète
  // ============================================================
  Future<void> _initializeApp() async {
    try {
      // ── Étape 1: Charger le cache local d'abord (rapide) ──
      await context.read<UserProvider>().loadUser();

      // ── Étape 2: Vérifier si un token API existe ──
      final hasToken = await ApiService.hasToken();

      if (!hasToken) {
        // Pas de token → vérifier si user invité en cache
        final cachedUser = context.read<UserProvider>().user;

        if (cachedUser != null && _isGuestUser(cachedUser)) {
          // User invité en cache → aller directement en Home
          if (!mounted) return;
          await context
              .read<ActivityProvider>()
              .loadActivities(cachedUser.id);
          _setStatus(_RouterStatus.authenticated);
        } else {
          // Aucun user → écran d'accueil
          _setStatus(_RouterStatus.unauthenticated);
        }
        return;
      }

      // ── Étape 3: Token trouvé → valider avec l'API ──
      final result = await ApiService.getMe();

      if (!mounted) return;

      if (result['success'] == true) {
        // ✅ Token valide → restaurer l'utilisateur depuis API
        final userData = result['data']['user'];
        final user = UserModel.fromJson(userData);

        await context.read<UserProvider>().saveUser(user);
        if (!mounted) return;

        // Charger les activités (cache local d'abord + sync API)
        await context.read<ActivityProvider>().loadActivities(user.id);
        if (!mounted) return;

        _setStatus(_RouterStatus.authenticated);
      } else {
        // ❌ Token invalide/expiré → clear et déconnecter
        await ApiService.clearToken();
        if (!mounted) return;

        await context.read<UserProvider>().logout();
        _setStatus(_RouterStatus.unauthenticated);
      }
    } catch (e) {
      // ── Erreur réseau → mode hors-ligne ──
      debugPrint('Erreur _initializeApp: $e');

      if (!mounted) return;

      final cachedUser = context.read<UserProvider>().user;

      if (cachedUser != null) {
        // Cache disponible → Home en mode hors-ligne
        await context
            .read<ActivityProvider>()
            .loadActivities(cachedUser.id);
        if (!mounted) return;
        _setStatus(_RouterStatus.authenticated);
      } else {
        // Aucun cache → écran d'accueil
        _setStatus(_RouterStatus.unauthenticated);
      }
    }
  }

  // Vérifier si c'est un utilisateur invité (pas de token API)
  bool _isGuestUser(UserModel user) {
    return user.id.startsWith('guest_');
  }

  void _setStatus(_RouterStatus status) {
    if (mounted) setState(() => _status = status);
  }

  // ============================================================
  // Build selon le statut
  // ============================================================
  @override
  Widget build(BuildContext context) {
    switch (_status) {
      // ── Chargement ──
      case _RouterStatus.checking:
        return _buildSplashScreen();

      // ── Connecté ──
      case _RouterStatus.authenticated:
        return const HomeScreen();

      // ── Non connecté ──
      case _RouterStatus.unauthenticated:
        return const AuthGateScreen();
    }
  }

  // ============================================================
  // Splash Screen pendant la vérification
  // ============================================================
  Widget _buildSplashScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F1A)
          : const Color(0xFFF8F7FF),
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
                    blurRadius: 28,
                    offset: Offset(0, 10),
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
                      gradient: LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nom de l'app
            const Text(
              'Lifevora',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4F46E5),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Fitness & Well-Being',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF8B8FA8)
                    : const Color(0xFF64748B),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 48),

            // Indicateur de chargement
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Color(0xFF4F46E5),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement...',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF8B8FA8)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Enum des statuts du router
// ============================================================
enum _RouterStatus {
  checking,       // Vérification en cours
  authenticated,  // Connecté → HomeScreen
  unauthenticated, // Non connecté → AuthGateScreen
}