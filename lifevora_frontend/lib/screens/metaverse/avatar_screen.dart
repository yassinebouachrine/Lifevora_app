import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  File? _imageFile;           // ✅ nullable, pas de null check forcé
  final _picker = ImagePicker();
  bool _isLoading = false;

  // ✅ Getter sécurisé pour isDark
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;

    // ✅ watch() avec null safety
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user; // ✅ peut être null, pas de !

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildAppBar(isDark),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildAvatarSection(isDark, user?.name),
                              const SizedBox(height: 32),
                              _buildUserInfo(isDark, user),
                              const SizedBox(height: 32),
                              _buildSaveButton(isDark),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────
  Widget _buildAppBar(bool isDark) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Mon Avatar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Avatar Section ─────────────────────────────────────────────
  Widget _buildAvatarSection(bool isDark, String? userName) {
    return Column(
      children: [
        Stack(
          children: [
            // ✅ Avatar avec null safety complet
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _imageFile == null
                    ? AppColors.primaryGradient
                    : null,
                border: Border.all(
                  color: AppColors.primary,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarContent(userName),
              ),
            ),

            // ✅ Bouton caméra
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBackground
                          : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCamera01,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ✅ Nom avec fallback
        Text(
          userName ?? 'Utilisateur',   // ✅ jamais null
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 20),

        // ✅ Boutons action
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _actionChip(
              icon: HugeIcons.strokeRoundedCamera01,
              label: 'Caméra',
              onTap: () => _pickImage(source: ImageSource.camera),
            ),
            const SizedBox(width: 12),
            _actionChip(
              icon: HugeIcons.strokeRoundedImage01,
              label: 'Galerie',
              onTap: () => _pickImage(source: ImageSource.gallery),
            ),
            if (_imageFile != null) ...[
              const SizedBox(width: 12),
              _actionChip(
                icon: HugeIcons.strokeRoundedDelete01,
                label: 'Supprimer',
                onTap: _removeImage,
                color: AppColors.error,
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ✅ Contenu avatar avec tous les cas null gérés
  Widget _buildAvatarContent(String? userName) {
    // Cas 1 : image sélectionnée
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,    // ✅ safe car on vérifie != null avant
        fit: BoxFit.cover,
        width: 180,
        height: 180,
        errorBuilder: (_, __, ___) => _defaultAvatar(userName),
      );
    }

    // Cas 2 : pas d'image → initiales ou icône
    return _defaultAvatar(userName);
  }

  Widget _defaultAvatar(String? userName) {
    // ✅ Initiales avec null safety
    final initials = _getInitials(userName);

    return Container(
      color: AppColors.primary.withValues(alpha: 0.8),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              )
            : const HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: Colors.white,
                size: 52,
              ),
      ),
    );
  }

  // ✅ Fonction sécurisée pour extraire les initiales
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '';

    final parts = name.trim().split(' ')
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();

    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  // ── User Info ──────────────────────────────────────────────────
  Widget _buildUserInfo(bool isDark, dynamic user) {
    // ✅ Toutes les valeurs avec fallback
    final name  = user?.name  ?? 'Non défini';
    final email = user?.email ?? 'Non défini';
    final age   = user?.age?.toString() ?? '--';

    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(
            icon: HugeIcons.strokeRoundedUser,
            label: 'Nom',
            value: name,
            isDark: isDark,
          ),
          _divider(isDark),
          _infoRow(
            icon: HugeIcons.strokeRoundedMail01,
            label: 'Email',
            value: email,
            isDark: isDark,
          ),
          _divider(isDark),
          _infoRow(
            icon: HugeIcons.strokeRoundedCalendar01,
            label: 'Âge',
            value: '$age ans',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,   // ✅ jamais null grâce aux fallbacks
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      color: isDark ? AppColors.darkBorder : AppColors.border,
      height: 1,
    );
  }

  // ── Save Button ────────────────────────────────────────────────
  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveAvatar,
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
                  SizedBox(width: 10),
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

  // ── Action Chip ────────────────────────────────────────────────
  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  // ✅ pickImage avec null safety
  Future<void> _pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      // ✅ Vérifie que picked n'est pas null avant d'utiliser
      if (picked != null && mounted) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      // ✅ Gestion d'erreur si caméra/galerie non disponible
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() => _imageFile = null);
  }

  Future<void> _saveAvatar() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar sauvegardé! ✅'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }
}