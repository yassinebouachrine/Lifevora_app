import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 1
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Step 2
  final _ageController = TextEditingController(text: '25');
  final _goalController = TextEditingController(text: '150');
  String _selectedGoalType = 'Perdre du poids';

  // Step 3 (Summary)
  bool _isLoading = false;

  final List<String> _goalTypes = [
    'Perdre du poids',
    'Prendre de la masse',
    'Rester en forme',
    'Courir un marathon',
    'Stress & bien-être',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_currentPage > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentPage--);
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Étape ${_currentPage + 1} / 3',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: i <= _currentPage
                    ? AppColors.primary
                    : const Color(0x264F46E5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── PAGE 1 : Identifiants ──────────────────────────────────────
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Créer votre compte 🚀',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 6),
          const Text(
            'Rejoignez des milliers d\'utilisateurs actifs!',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 36),

          // Champs
          _label('Prénom *'),
          const SizedBox(height: 8),
          _inputField(
            controller: _nameController,
            hint: 'Ex: Amina',
            icon: Icons.person_outline_rounded,
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),

          const SizedBox(height: 20),
          _label('Email *'),
          const SizedBox(height: 8),
          _inputField(
            controller: _emailController,
            hint: 'votre@email.com',
            icon: Icons.email_outlined,
            type: TextInputType.emailAddress,
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),

          const SizedBox(height: 20),
          _label('Mot de passe *'),
          const SizedBox(height: 8),
          _passwordInputField()
              .animate()
              .fadeIn(delay: 500.ms)
              .slideX(begin: -0.2, end: 0),

          const SizedBox(height: 36),
          _nextButton(
            label: 'Continuer',
            onTap: _validatePage1,
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Déjà un compte? ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PAGE 2 : Profil ───────────────────────────────────────────
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Votre profil 💪',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.2, end: 0),
          const SizedBox(height: 6),
          const Text(
            'Personnalisez votre expérience fitness.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),

          // Avatar preview
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(
                begin: const Offset(0.7, 0.7),
              ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Âge'),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: _ageController,
                      hint: '25',
                      icon: Icons.cake_outlined,
                      type: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Objectif (min/sem)'),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: _goalController,
                      hint: '150',
                      icon: Icons.timer_outlined,
                      type: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 24),
          _label('Objectif principal'),
          const SizedBox(height: 12),
          _buildGoalSelector()
              .animate()
              .fadeIn(delay: 400.ms),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x0F4F46E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'L\'OMS recommande 150 min/semaine d\'activité modérée.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 36),
          _nextButton(
            label: 'Voir le résumé',
            onTap: _validatePage2,
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildGoalSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _goalTypes.map((goal) {
        final isSelected = _selectedGoalType == goal;
        return GestureDetector(
          onTap: () => setState(() => _selectedGoalType = goal),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              goal,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── PAGE 3 : Résumé & Confirmation ───────────────────────────
  Widget _buildPage3() {
    final name = _nameController.text.isEmpty
        ? 'Utilisateur'
        : _nameController.text;
    final email = _emailController.text;
    final age = _ageController.text;
    final goal = _goalController.text;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Tout est prêt! 🎉',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 6),
          const Text(
            'Vérifiez vos informations avant de commencer.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),

          // Card résumé
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                _summaryRow('🎂', 'Âge', '$age ans'),
                const SizedBox(height: 12),
                _summaryRow(
                  '🎯',
                  'Objectif hebdo',
                  '$goal min/semaine',
                ),
                const SizedBox(height: 12),
                _summaryRow('💡', 'But principal', _selectedGoalType),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).scale(
                begin: const Offset(0.95, 0.95),
              ),

          const SizedBox(height: 24),

          // Features highlights
          _buildFeaturesList()
              .animate()
              .fadeIn(delay: 500.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 36),
          _buildStartButton()
              .animate()
              .fadeIn(delay: 700.ms)
              .slideY(begin: 0.4, end: 0),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _summaryRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': '🤖', 'title': 'AI Coach', 'desc': 'Conseils personnalisés'},
      {'icon': '📸', 'title': 'Food Scanner', 'desc': 'Analyse nutritionnelle'},
      {'icon': '🌐', 'title': 'Metaverse', 'desc': 'Avatar évolutif'},
      {'icon': '📊', 'title': 'Statistiques', 'desc': 'Suivi de progression'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ce qui vous attend 🚀',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0x1A4F46E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        f['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f['title']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        f['desc']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Commencer Lifevora',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('🎉', style: TextStyle(fontSize: 20)),
                ],
              ),
      ),
    );
  }

  // ── Widgets helper ────────────────────────────────────────────

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? type,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _passwordInputField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.textHint,
          size: 20,
        ),
        suffixIcon: GestureDetector(
          onTap: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textHint,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _nextButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Validation & Navigation ───────────────────────────────────

  void _validatePage1() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre prénom');
      return;
    }
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      _showError('Veuillez entrer un email valide');
      return;
    }
    // ✅ Minimum 6 caractères (validation backend)
    if (_passwordController.text.length < 6) {
      _showError('Mot de passe trop court (min. 6 caractères)');
      return;
    }
    _nextPage();
  }

  void _validatePage2() {
    _nextPage();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);

    try {
      // ✅ Appel API réel
      final result = await context.read<UserProvider>().register(
        name: _nameController.text.trim().isEmpty
            ? 'Utilisateur'
            : _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        age: int.tryParse(_ageController.text) ?? 25,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final user = context.read<UserProvider>().user;

        // ✅ Envoyer les données de profil (onboarding)
        if (user != null) {
          await context.read<UserProvider>().completeOnboarding(
            age: int.tryParse(_ageController.text) ?? 25,
            goalMinutesPerWeek: int.tryParse(_goalController.text) ?? 150,
          );

          await context.read<ActivityProvider>().loadActivities(user.id);
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        }
      } else {
        setState(() => _isLoading = false);
        _showError(result['message'] ?? 'Erreur lors de la création du compte');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Impossible de joindre le serveur');
      }
    }
  }
}