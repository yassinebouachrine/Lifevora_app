import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/coach_session_model.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  File? _imageFile;
  bool _isAnalyzing = false;
  FoodScanResult? _result;
  final _picker = ImagePicker();

  final List<FoodScanResult> _demoFoods = [
    FoodScanResult(
      foodName: 'Poulet grillé',
      calories: 165,
      proteins: 31,
      carbs: 0,
      fats: 3.6,
    ),
    FoodScanResult(
      foodName: 'Salade César',
      calories: 480,
      proteins: 18,
      carbs: 24,
      fats: 36,
    ),
    FoodScanResult(
      foodName: 'Pâtes bolognaise',
      calories: 520,
      proteins: 25,
      carbs: 68,
      fats: 15,
    ),
    FoodScanResult(
      foodName: 'Saumon grillé',
      calories: 208,
      proteins: 29,
      carbs: 0,
      fats: 10,
    ),
    FoodScanResult(
      foodName: 'Pizza Margherita',
      calories: 740,
      proteins: 28,
      carbs: 82,
      fats: 30,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        title: const Text(
          'Scanner de plat 📸',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildImageZone(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            if (_isAnalyzing) ...[
              const SizedBox(height: 32),
              _buildAnalyzing(),
            ],
            if (_result != null && !_isAnalyzing) ...[
              const SizedBox(height: 24),
              _buildResult(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1A10B981),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x3310B981)),
      ),
      child: const Row(
        children: [
          Text('💡', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Prenez une photo de votre plat pour analyser ses valeurs nutritionnelles instantanément!',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageZone() {
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: _imageFile != null
              ? Colors.transparent
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _imageFile != null
                ? AppColors.secondary
                : const Color(0x4D4F46E5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_imageFile!, fit: BoxFit.cover),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _imageFile = null;
                          _result = null;
                        }),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CameraIcon(),
                  SizedBox(height: 14),
                  Text(
                    'Touchez pour ajouter une photo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'JPG, PNG acceptés',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionBtn(
            icon: '📷',
            label: 'Caméra',
            color: AppColors.primary,
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionBtn(
            icon: '🖼️',
            label: 'Galerie',
            color: AppColors.accentPurple,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionBtn(
            icon: '🔍',
            label: 'Analyser',
            color: AppColors.secondary,
            onTap: _imageFile != null ? _analyzeImage : null,
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '🤖 Analyse en cours...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Identification du plat et calcul des nutriments',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms);
  }

  Widget _buildResult() {
    final r = _result!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('✅', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Analyse complète',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🍽️', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Text(
                    r.foodName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _caloriesBadge(r.calories),
              const SizedBox(height: 20),
              const Text(
                'Macronutriments',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _nutrientCard(
                      '🥩', 'Protéines', r.proteins, 'g', AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _nutrientCard(
                      '🍞', 'Glucides', r.carbs, 'g', AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _nutrientCard(
                      '🥑', 'Lipides', r.fats, 'g', AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildNutrientBars(r),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _caloriesBadge(double calories) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '🔥 Calories totales',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            '${calories.toInt()} kcal',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutrientCard(
    String emoji,
    String name,
    double value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
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
        const SizedBox(height: 8),
        _barItem('Glucides', r.carbs, total, AppColors.accent),
        const SizedBox(height: 8),
        _barItem('Lipides', r.fats, total, AppColors.secondary),
      ],
    );
  }

  Widget _barItem(
    String label,
    double value,
    double total,
    Color color,
  ) {
    final ratio = total > 0 ? value / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(ratio * 100).toInt()}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked =
        await _picker.pickImage(source: source, imageQuality: 80);
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

// Widget const séparé pour l'icône caméra
class _CameraIcon extends StatelessWidget {
  const _CameraIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0x1A4F46E5),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('📸', style: TextStyle(fontSize: 34)),
      ),
    );
  }
}