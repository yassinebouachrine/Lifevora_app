import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import 'storage_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildProgressIndicator(1),
              const Spacer(flex: 2),
              _buildIcon().animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
              const Spacer(),
              const Text(
                'Rappels d\'entraînement 🔔',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              const Text(
                'Autorise les notifications pour recevoir tes rappels d\'entraînement quotidiens et rester motivé(e).',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 32),
              _buildAuthorizeButton(context)
                  .animate()
                  .fadeIn(delay: 500.ms),
              const Spacer(flex: 2),
              _buildContinueButton(context)
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .slideY(begin: 0.5, end: 0),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _navigate(context),
                child: const Text(
                  'Passer',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int activeIndex) {
    return Row(
      children: List.generate(4, (i) {
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: i <= activeIndex ? AppColors.primary : AppColors.primaryLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('🔔', style: TextStyle(fontSize: 48)),
      ),
    );
  }

  Widget _buildAuthorizeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          backgroundColor: AppColors.primary.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Autoriser l\'accès',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: () => _navigate(context),
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
          children: const [
            Text('Continuer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const StorageScreen()));
  }
}