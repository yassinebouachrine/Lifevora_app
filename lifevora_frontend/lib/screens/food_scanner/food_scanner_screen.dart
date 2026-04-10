import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/coach_session_model.dart';

class FoodScannerScreen extends StatefulWidget {
  final bool showBackButton;
  const FoodScannerScreen({super.key, this.showBackButton = false});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  File? _imageFile;
  bool _isAnalyzing = false;
  FoodScanResult? _result;
  final _picker = ImagePicker();

  // ✅ isDark via context dans build
  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  final List<FoodScanResult> _demoFoods = [
    FoodScanResult(foodName: 'Poulet grillé', calories: 165, proteins: 31, carbs: 0, fats: 3.6),
    FoodScanResult(foodName: 'Salade César', calories: 480, proteins: 18, carbs: 24, fats: 36),
    FoodScanResult(foodName: 'Pâtes bolognaise', calories: 520, proteins: 25, carbs: 68, fats: 15),
    FoodScanResult(foodName: 'Saumon grillé', calories: 208, proteins: 29, carbs: 0, fats: 10),
    FoodScanResult(foodName: 'Pizza Margherita', calories: 740, proteins: 28, carbs: 82, fats: 30),
    FoodScanResult(foodName: 'Avocat toast', calories: 320, proteins: 8, carbs: 30, fats: 22),
    FoodScanResult(foodName: 'Bol de quinoa', calories: 380, proteins: 14, carbs: 52, fats: 10),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(isDark),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildInfoBanner(isDark)
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 20),
                  _buildImageZone(isDark)
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(begin: const Offset(0.95, 0.95)),
                  const SizedBox(height: 20),
                  _buildActionButtons(isDark)
                      .animate()
                      .fadeIn(delay: 300.ms),
                  if (_isAnalyzing) ...[
                    const SizedBox(height: 32),
                    _buildAnalyzing(isDark).animate().fadeIn(),
                  ],
                  if (_result != null && !_isAnalyzing) ...[
                    const SizedBox(height: 24),
                    _buildResult(isDark)
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                  if (_result == null && !_isAnalyzing) ...[
                    const SizedBox(height: 32),
                    _buildRecentScans(isDark)
                        .animate()
                        .fadeIn(delay: 400.ms),
                  ],
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────
  Widget _buildAppBar(bool isDark) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          children: [
            if (widget.showBackButton) ...[
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanner de plat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    'Analyse nutritionnelle IA',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedBrain,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'IA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info Banner ────────────────────────────────────────────────
  Widget _buildInfoBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedRestaurant01,
                color: AppColors.secondary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analyse nutritionnelle IA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Calories, protéines, glucides et lipides en 2 secondes!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Zone image ─────────────────────────────────────────────────
  Widget _buildImageZone(bool isDark) {
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 230,
        decoration: BoxDecoration(
          color: _imageFile != null ? Colors.transparent : surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _imageFile != null
                ? AppColors.secondary
                : const Color(0x4D4F46E5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_imageFile!, fit: BoxFit.cover),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12, right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _imageFile = null;
                          _result = null;
                        }),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 12, left: 16,
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCamera01,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Photo prête pour analyse',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCamera01,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Photographiez votre plat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ou appuyez sur Caméra / Galerie ci-dessous',
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────
  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _singleActionBtn(
            icon: HugeIcons.strokeRoundedCamera01,
            label: 'Caméra',
            color: AppColors.primary,
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _singleActionBtn(
            icon: HugeIcons.strokeRoundedImage01,
            label: 'Galerie',
            color: AppColors.accentPurple,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _singleActionBtn(
            icon: HugeIcons.strokeRoundedSearch01,
            label: 'Analyser',
            color: AppColors.secondary,
            onTap: _imageFile != null ? _analyzeImage : null,
          ),
        ),
      ],
    );
  }

  // ✅ Renommé en _singleActionBtn pour éviter le doublon
  Widget _singleActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              HugeIcon(icon: icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Analyzing ──────────────────────────────────────────────────
  Widget _buildAnalyzing(bool isDark) {
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(28),
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
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70, height: 70,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.secondary,
                  ),
                  backgroundColor:
                      AppColors.secondary.withValues(alpha: 0.15),
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedBrain,
                color: AppColors.secondary,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Analyse en cours...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notre IA identifie le plat et calcule\nles valeurs nutritionnelles',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _analyzeStep(
            HugeIcons.strokeRoundedSearch01,
            'Identification du plat',
            true,
            isDark,
          ),
          const SizedBox(height: 8),
          _analyzeStep(
            HugeIcons.strokeRoundedCalculator01,
            'Calcul des nutriments',
            false,
            isDark,
          ),
          const SizedBox(height: 8),
          _analyzeStep(
            HugeIcons.strokeRoundedChart01,
            'Génération du rapport',
            false,
            isDark,
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 2.seconds,
          color: Colors.white.withValues(alpha: 0.2),
        );
  }

  Widget _analyzeStep(
    IconData icon,
    String label,
    bool active,
    bool isDark,
  ) {
    return Row(
      children: [
        HugeIcon(
          icon: icon,
          color: active
              ? AppColors.primary
              : (isDark ? AppColors.darkTextHint : AppColors.textHint),
          size: 16,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: active
                ? AppColors.primary
                : (isDark ? AppColors.darkTextHint : AppColors.textHint),
            fontWeight:
                active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        if (active)
          const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )
        else
          HugeIcon(
            icon: HugeIcons.strokeRoundedCircle,
            color: isDark ? AppColors.darkTextHint : AppColors.textHint,
            size: 16,
          ),
      ],
    );
  }

  // ── Result ─────────────────────────────────────────────────────
  Widget _buildResult(bool isDark) {
    final r = _result!;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                    color: AppColors.success,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Analyse complète',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() {
                _result = null;
                _imageFile = null;
              }),
              child: const Text(
                'Nouvelle scan',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: isDark ? 0.2 : 0.07),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedRestaurant01,
                        color: AppColors.secondary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.foodName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Portion estimée : 1 assiette',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _caloriesBadge(r.calories),
              const SizedBox(height: 20),
              Text(
                'Macronutriments',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _nutrientCard('🥩', 'Protéines', r.proteins, 'g', AppColors.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: _nutrientCard('🍞', 'Glucides', r.carbs, 'g', AppColors.accent)),
                  const SizedBox(width: 10),
                  Expanded(child: _nutrientCard('🥑', 'Lipides', r.fats, 'g', AppColors.secondary)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Répartition',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildNutrientBars(r),
              const SizedBox(height: 20),
              _buildHealthTip(r),
            ],
          ),
        ),
      ],
    );
  }

  Widget _caloriesBadge(double calories) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedFire,
                    color: Colors.white70,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Calories totales',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const Text(
                'Pour une portion',
                style: TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${calories.toInt()}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'kcal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutrientCard(
    String emoji, String name, double value, String unit, Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientBars(FoodScanResult r) {
    final total = r.proteins + r.carbs + r.fats;
    if (total == 0) return const SizedBox();
    return Column(
      children: [
        _barItem('Protéines', r.proteins, total, AppColors.primary),
        const SizedBox(height: 10),
        _barItem('Glucides', r.carbs, total, AppColors.accent),
        const SizedBox(height: 10),
        _barItem('Lipides', r.fats, total, AppColors.secondary),
      ],
    );
  }

  Widget _barItem(String label, double value, double total, Color color) {
    final ratio = total > 0 ? value / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            '${(ratio * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTip(FoodScanResult r) {
    String tip;
    IconData icon;
    Color color;
    if (r.proteins > 25) {
      tip = 'Excellent apport en protéines! Idéal après l\'entraînement.';
      icon = HugeIcons.strokeRoundedDumbbell01;
      color = AppColors.success;
    } else if (r.calories > 600) {
      tip = 'Repas calorique. Pensez à une activité physique après.';
      icon = HugeIcons.strokeRoundedAlert01;
      color = AppColors.warning;
    } else {
      tip = 'Repas équilibré! Continuez comme ça.';
      icon = HugeIcons.strokeRoundedCheckmarkCircle01;
      color = AppColors.success;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Scans ───────────────────────────────────────────────
  Widget _buildRecentScans(bool isDark) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;

    final recents = [
      {'food': 'Poulet grillé', 'cal': '165', 'time': 'Hier, 12:30'},
      {'food': 'Salade César',  'cal': '480', 'time': 'Lun, 13:00'},
      {'food': 'Saumon grillé', 'cal': '208', 'time': 'Dim, 19:45'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Scans récents',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const Text(
              'Voir tout',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...recents.map((item) => _recentScanCard(item, surfaceColor, textPrimary, isDark)),
      ],
    );
  }

  Widget _recentScanCard(
    Map<String, String> item,
    Color surfaceColor,
    Color textPrimary,
    bool isDark,
  ) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedRestaurant01,
                color: AppColors.secondary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['food']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                Text(
                  item['time']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x1A4F46E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item['cal']} kcal',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _result = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 2));
    final demoResult =
        _demoFoods[DateTime.now().millisecond % _demoFoods.length];
    setState(() {
      _isAnalyzing = false;
      _result = demoResult;
    });
  }
}