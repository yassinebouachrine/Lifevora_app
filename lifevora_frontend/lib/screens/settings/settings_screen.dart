import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _workoutReminder = true;
  bool _weeklyReport = false;
  bool _achievementAlerts = true;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Apparence ──
                    _buildSectionLabel('Apparence', isDark),
                    const SizedBox(height: 10),
                    _buildAppearanceSection(
                            context, isDark, surfaceColor, textPrimary)
                        .animate()
                        .fadeIn(delay: 100.ms),
                    const SizedBox(height: 24),

                    // ── Notifications ──
                    _buildSectionLabel('Notifications', isDark),
                    const SizedBox(height: 10),
                    _buildNotificationsSection(
                            isDark, surfaceColor, textPrimary)
                        .animate()
                        .fadeIn(delay: 200.ms),
                    const SizedBox(height: 24),

                    // ── Confidentialité ──
                    _buildSectionLabel('Confidentialité', isDark),
                    const SizedBox(height: 10),
                    _buildPrivacySection(
                            context, isDark, surfaceColor, textPrimary)
                        .animate()
                        .fadeIn(delay: 300.ms),
                    const SizedBox(height: 24),

                    // ── Aide & Support ──
                    _buildSectionLabel('Aide & Support', isDark),
                    const SizedBox(height: 10),
                    _buildSupportSection(
                            context, isDark, surfaceColor, textPrimary)
                        .animate()
                        .fadeIn(delay: 400.ms),
                    const SizedBox(height: 24),

                    // ── À propos ──
                    _buildAboutSection(isDark, surfaceColor, textPrimary)
                        .animate()
                        .fadeIn(delay: 500.ms),
                    const SizedBox(height: 40),
                  ],
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
            'Paramètres',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────
  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextHint : AppColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }

  // ── Apparence ─────────────────────────────────────────────────
  Widget _buildAppearanceSection(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return _buildCard(
      isDark: isDark,
      surfaceColor: surfaceColor,
      children: [
        _buildSwitchTile(
          icon: HugeIcons.strokeRoundedMoon01,
          iconColor: AppColors.accentPurple,
          title: 'Mode sombre',
          subtitle: 'Thème de l\'application',
          value: themeProvider.isDark,
          onChanged: (val) => context.read<ThemeProvider>().toggleTheme(),
          isDark: isDark,
          textPrimary: textPrimary,
        ),
      ],
    );
  }

  // ── Notifications ─────────────────────────────────────────────
  Widget _buildNotificationsSection(
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
  ) {
    return _buildCard(
      isDark: isDark,
      surfaceColor: surfaceColor,
      children: [
        _buildSwitchTile(
          icon: HugeIcons.strokeRoundedNotification01,
          iconColor: AppColors.primary,
          title: 'Notifications',
          subtitle: 'Activer toutes les notifications',
          value: _notificationsEnabled,
          onChanged: (val) {
            setState(() {
              _notificationsEnabled = val;
              if (!val) {
                _workoutReminder = false;
                _weeklyReport = false;
                _achievementAlerts = false;
              }
            });
            _saveNotificationSettings();
          },
          isDark: isDark,
          textPrimary: textPrimary,
        ),
        _buildDivider(isDark),
        _buildSwitchTile(
          icon: HugeIcons.strokeRoundedClock01,
          iconColor: AppColors.secondary,
          title: 'Rappel d\'entraînement',
          subtitle: 'Rappel quotidien à 8h00',
          value: _workoutReminder && _notificationsEnabled,
          onChanged: _notificationsEnabled
              ? (val) {
                  setState(() => _workoutReminder = val);
                  _saveNotificationSettings();
                }
              : null,
          isDark: isDark,
          textPrimary: textPrimary,
        ),
        _buildDivider(isDark),
        _buildSwitchTile(
          icon: HugeIcons.strokeRoundedChart01,
          iconColor: AppColors.accent,
          title: 'Rapport hebdomadaire',
          subtitle: 'Résumé chaque dimanche',
          value: _weeklyReport && _notificationsEnabled,
          onChanged: _notificationsEnabled
              ? (val) {
                  setState(() => _weeklyReport = val);
                  _saveNotificationSettings();
                }
              : null,
          isDark: isDark,
          textPrimary: textPrimary,
        ),
        _buildDivider(isDark),
        _buildSwitchTile(
          icon: HugeIcons.strokeRoundedAward01,
          iconColor: AppColors.accentPurple,
          title: 'Badges & Récompenses',
          subtitle: 'Alertes lors de déblocage',
          value: _achievementAlerts && _notificationsEnabled,
          onChanged: _notificationsEnabled
              ? (val) {
                  setState(() => _achievementAlerts = val);
                  _saveNotificationSettings();
                }
              : null,
          isDark: isDark,
          textPrimary: textPrimary,
        ),
      ],
    );
  }

  // ── Confidentialité ───────────────────────────────────────────
  Widget _buildPrivacySection(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
  ) {
    return _buildCard(
      isDark: isDark,
      surfaceColor: surfaceColor,
      children: [
        _buildArrowTile(
          icon: HugeIcons.strokeRoundedShield01,
          iconColor: AppColors.secondary,
          title: 'Politique de confidentialité',
          isDark: isDark,
          textPrimary: textPrimary,
          onTap: () => _showPrivacyPolicy(context, isDark),
        ),
        _buildDivider(isDark),
        _buildArrowTile(
          icon: HugeIcons.strokeRoundedFile01,
          iconColor: AppColors.primary,
          title: 'Conditions d\'utilisation',
          isDark: isDark,
          textPrimary: textPrimary,
          onTap: () => _showTermsOfService(context, isDark),
        ),
        _buildDivider(isDark),
        _buildArrowTile(
          icon: HugeIcons.strokeRoundedDelete01,
          iconColor: AppColors.error,
          title: 'Supprimer mon compte',
          titleColor: AppColors.error,
          isDark: isDark,
          textPrimary: textPrimary,
          onTap: () => _showDeleteAccountDialog(context, isDark),
        ),
      ],
    );
  }

  // ── Aide & Support ────────────────────────────────────────────
  Widget _buildSupportSection(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
  ) {
    return _buildCard(
      isDark: isDark,
      surfaceColor: surfaceColor,
      children: [
        _buildArrowTile(
          icon: HugeIcons.strokeRoundedHelpCircle,
          iconColor: AppColors.accentPurple,
          title: 'Centre d\'aide',
          isDark: isDark,
          textPrimary: textPrimary,
          onTap: () => _showHelpCenter(context, isDark),
        ),
        _buildDivider(isDark),
        _buildArrowTile(
          icon: HugeIcons.strokeRoundedMail01,
          iconColor: AppColors.primary,
          title: 'Nous contacter',
          subtitle: 'support@lifevora.com',
          isDark: isDark,
          textPrimary: textPrimary,
          onTap: () => _showContactDialog(context, isDark),
        ),
        _buildDivider(isDark),
        _buildArrowTile(
          icon: HugeIcons.strokeRoundedStar,
          iconColor: AppColors.accent,
          title: 'Noter l\'application',
          subtitle: 'Votre avis nous aide!',
          isDark: isDark,
          textPrimary: textPrimary,
          onTap: () => _showRateDialog(context, isDark),
        ),
      ],
    );
  }

  // ── À propos ──────────────────────────────────────────────────
  Widget _buildAboutSection(
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
  ) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedDumbbell01,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lifevora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              Text(
                'Fitness & Well-Being',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Widgets réutilisables ─────────────────────────────────────
  Widget _buildCard({
    required bool isDark,
    required Color surfaceColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required bool isDark,
    required Color textPrimary,
  }) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final isDisabled = onChanged == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDisabled
                  ? Colors.grey.withValues(alpha: 0.1)
                  : iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: HugeIcon(
                icon: icon,
                color: isDisabled ? Colors.grey : iconColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? Colors.grey : textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDisabled ? Colors.grey : textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    required bool isDark,
    required Color textPrimary,
    required VoidCallback onTap,
  }) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: HugeIcon(icon: icon, color: iconColor, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                ],
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 68,
      color: isDark ? AppColors.darkBorder : AppColors.border,
    );
  }

  // ── Actions ───────────────────────────────────────────────────
  Future<void> _saveNotificationSettings() async {
    final result = await context.read<UserProvider>().updateProfile({
      'notificationsEnabled': _notificationsEnabled,
    });
    if (!mounted) return;
    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur de sauvegarde'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showPrivacyPolicy(BuildContext context, bool isDark) {
    _showBottomSheet(
      context: context,
      isDark: isDark,
      title: 'Politique de confidentialité',
      icon: HugeIcons.strokeRoundedShield01,
      iconColor: AppColors.secondary,
      content: '''
Lifevora respecte votre vie privée.

📊 Données collectées :
• Informations de profil (nom, email, âge)
• Activités sportives enregistrées
• Données d\'utilisation de l\'application

🔒 Protection des données :
• Chiffrement SSL/TLS pour toutes les communications
• Mots de passe hashés (bcrypt)
• Données stockées sur des serveurs sécurisés

🚫 Nous ne partageons JAMAIS :
• Vos données personnelles avec des tiers
• Vos informations de santé
• Vos activités sans votre consentement

📧 Contact : privacy@lifevora.com
      ''',
    );
  }

  void _showTermsOfService(BuildContext context, bool isDark) {
    _showBottomSheet(
      context: context,
      isDark: isDark,
      title: 'Conditions d\'utilisation',
      icon: HugeIcons.strokeRoundedFile01,
      iconColor: AppColors.primary,
      content: '''
En utilisant Lifevora, vous acceptez :

✅ Utilisation personnelle uniquement
✅ Fournir des informations exactes
✅ Ne pas partager votre compte
✅ Respecter les autres utilisateurs

⚠️ Responsabilités :
• Consultez un médecin avant tout programme sportif
• Lifevora est un outil d\'aide, non médical
• Les conseils AI sont indicatifs uniquement

📌 Version 1.0.0 - En vigueur depuis 2024
      ''',
    );
  }

  void _showHelpCenter(BuildContext context, bool isDark) {
    _showBottomSheet(
      context: context,
      isDark: isDark,
      title: 'Centre d\'aide',
      icon: HugeIcons.strokeRoundedHelpCircle,
      iconColor: AppColors.accentPurple,
      content: '''
❓ Questions fréquentes :

🏃 Comment ajouter une activité ?
→ Appuyez sur le bouton + en bas de l\'écran

📊 Comment voir mes statistiques ?
→ Accédez à l\'onglet Accueil ou Profil

🤖 Comment utiliser l\'AI Coach ?
→ Onglet Coach dans la barre de navigation

🍎 Comment scanner un aliment ?
→ Onglet Scanner dans la barre de navigation

🎮 Qu\'est-ce que l\'Avatar Metaverse ?
→ Votre avatar évolue avec vos activités!

📧 Toujours besoin d\'aide ?
→ Contactez support@lifevora.com
      ''',
    );
  }

  void _showContactDialog(BuildContext context, bool isDark) {
    _showBottomSheet(
      context: context,
      isDark: isDark,
      title: 'Nous contacter',
      icon: HugeIcons.strokeRoundedMail01,
      iconColor: AppColors.primary,
      content: '''
Nous sommes là pour vous aider! 💪

📧 Email :
support@lifevora.com

⏰ Temps de réponse :
24-48 heures ouvrables

🌍 Disponible en :
Français, Anglais, Arabe

💬 Pour signaler un bug :
bugs@lifevora.com

📱 Réseaux sociaux :
@lifevora_app
      ''',
    );
  }

  void _showRateDialog(BuildContext context, bool isDark) {
    int selectedStars = 5;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('⭐', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Noter Lifevora',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Votre avis nous aide à améliorer l\'app!',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedStars = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        i < selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 42,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Merci pour votre $selectedStars étoile${selectedStars > 1 ? 's' : ''}! 🙏',
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Envoyer ma note',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedDelete01,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Supprimer le compte',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: textPrimary,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Annuler',
              style: TextStyle(color: textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Implémenter suppression compte via API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité bientôt disponible'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet({
    required BuildContext context,
    required bool isDark,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
  }) {
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: HugeIcon(icon: icon, color: iconColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      height: 1.7,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}