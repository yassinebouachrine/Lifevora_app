import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _goalController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;

  bool _isLoading = false;
  bool _showPasswordSection = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController =
        TextEditingController(text: user?.age.toString() ?? '25');
    _goalController = TextEditingController(
        text: user?.goalMinutesPerWeek.toString() ?? '150');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(isDark, textPrimary),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatarSection(isDark, textPrimary)
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .scale(begin: const Offset(0.9, 0.9)),
                      const SizedBox(height: 28),

                      _buildSectionTitle('Informations personnelles', isDark),
                      const SizedBox(height: 12),
                      _buildInfoSection(isDark, surfaceColor, textPrimary)
                          .animate()
                          .fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Objectifs fitness', isDark),
                      const SizedBox(height: 12),
                      _buildGoalsSection(isDark, surfaceColor, textPrimary)
                          .animate()
                          .fadeIn(delay: 300.ms),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Sécurité', isDark),
                      const SizedBox(height: 12),
                      _buildPasswordSection(isDark, surfaceColor, textPrimary)
                          .animate()
                          .fadeIn(delay: 400.ms),
                      const SizedBox(height: 36),

                      _buildSaveButton()
                          .animate()
                          .fadeIn(delay: 500.ms)
                          .slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────
  Widget _buildAppBar(bool isDark, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
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
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Modifier le profil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar ────────────────────────────────────────────────────
  Widget _buildAvatarSection(bool isDark, Color textPrimary) {
    final user = context.watch<UserProvider>().user;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBackground
                          : AppColors.background,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCamera01,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Modifier la photo',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Avatar basé sur votre initiale',
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextHint : AppColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }

  // ── Informations personnelles ─────────────────────────────────
  Widget _buildInfoSection(
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Prénom',
            hint: 'Votre prénom',
            icon: HugeIcons.strokeRoundedUser,
            iconColor: AppColors.primary,
            isDark: isDark,
            textPrimary: textPrimary,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Prénom requis';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ageController,
            label: 'Âge',
            hint: '25',
            icon: HugeIcons.strokeRoundedCalendar01,
            iconColor: AppColors.secondary,
            isDark: isDark,
            textPrimary: textPrimary,
            keyboardType: TextInputType.number,
            validator: (v) {
              final age = int.tryParse(v ?? '');
              if (age == null || age < 10 || age > 100) {
                return 'Âge invalide (10-100)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Objectifs ─────────────────────────────────────────────────
  Widget _buildGoalsSection(
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
  ) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _goalController,
            label: 'Objectif hebdomadaire (minutes)',
            hint: '150',
            icon: HugeIcons.strokeRoundedTarget01,
            iconColor: AppColors.accentPurple,
            isDark: isDark,
            textPrimary: textPrimary,
            keyboardType: TextInputType.number,
            validator: (v) {
              final goal = int.tryParse(v ?? '');
              if (goal == null || goal < 30 || goal > 1440) {
                return 'Objectif invalide (30-1440 min)';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          // ✅ Suggestions rapides
          Row(
            children: [60, 90, 150, 210, 300].map((min) {
              final isSelected = _goalController.text == min.toString();
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _goalController.text = min.toString()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$min',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            'L\'OMS recommande 150 min/semaine',
            style: TextStyle(
              fontSize: 11,
              color: textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ── Mot de passe ──────────────────────────────────────────────
  Widget _buildPasswordSection(
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Toggle bouton
          GestureDetector(
            onTap: () =>
                setState(() => _showPasswordSection = !_showPasswordSection),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSquareLock01,
                        color: AppColors.accent,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Changer le mot de passe',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _showPasswordSection ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowDown01,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Champs mot de passe (animés)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showPasswordSection
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Divider(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          label: 'Mot de passe actuel',
                          obscure: _obscureCurrent,
                          onToggle: () => setState(
                              () => _obscureCurrent = !_obscureCurrent),
                          isDark: isDark,
                          textPrimary: textPrimary,
                        ),
                        const SizedBox(height: 14),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: 'Nouveau mot de passe',
                          obscure: _obscureNew,
                          onToggle: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          isDark: isDark,
                          textPrimary: textPrimary,
                          hint: 'Min. 6 caractères',
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  // ── Save Button ───────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
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
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sauvegarder',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── TextField réutilisable ────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Color textPrimary,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final hintColor = isDark ? AppColors.darkTextHint : AppColors.textHint;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final fillColor =
        isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8F9FA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontSize: 15, color: textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: HugeIcon(icon: icon, color: iconColor, size: 20),
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Password Field ────────────────────────────────────────────
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDark,
    required Color textPrimary,
    String? hint,
  }) {
    final hintColor = isDark ? AppColors.darkTextHint : AppColors.textHint;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final fillColor =
        isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8F9FA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(fontSize: 15, color: textPrimary),
          decoration: InputDecoration(
            hintText: hint ?? '••••••••',
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSquareLock01,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            // ✅ FIX: Utiliser Material Icons (compatible toutes versions)
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: hintColor,
                  size: 22,
                ),
              ),
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Handle Save ───────────────────────────────────────────────
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final currentUser = userProvider.user;
      if (currentUser == null) return;

      // ✅ 1. Mettre à jour profil
      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? currentUser.age,
        goalMinutesPerWeek: int.tryParse(_goalController.text) ??
            currentUser.goalMinutesPerWeek,
      );

      final profileResult = await userProvider.updateUser(updatedUser);

      if (!mounted) return;

      if (profileResult['success'] != true) {
        _showSnackBar(
          profileResult['message'] ?? 'Erreur de mise à jour',
          isError: true,
        );
        setState(() => _isLoading = false);
        return;
      }

      // ✅ 2. Changer mot de passe si renseigné
      if (_showPasswordSection &&
          _currentPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty) {
        if (_newPasswordController.text.length < 6) {
          _showSnackBar(
            'Le nouveau mot de passe doit contenir au moins 6 caractères',
            isError: true,
          );
          setState(() => _isLoading = false);
          return;
        }

        final passwordResult = await userProvider.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        if (!mounted) return;

        if (passwordResult['success'] != true) {
          _showSnackBar(
            passwordResult['message'] ?? 'Erreur mot de passe',
            isError: true,
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      // ✅ Succès
      _showSnackBar('Profil mis à jour avec succès! ✅');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur de connexion au serveur', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}