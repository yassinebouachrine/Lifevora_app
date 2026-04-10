// lib/widgets/activity_card.dart
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/activity_model.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onDelete,
    this.onEdit,
  });

  static const Map<String, String> _icons = {
    'Course': '⚡',
    'Marche': '👣',
    'Vélo': '🚴',
    'Yoga': '🍃',
    'Natation': '🌊',
    'Musculation': '💪',
  };

  static const Map<String, Color> _intensityColors = {
    'Faible': AppColors.success,
    'Modéré': AppColors.warning,
    'Élevé': AppColors.error,
  };

  String _formatDate(String dateISO) {
    try {
      final date = DateTime.parse(dateISO);
      const months = [
        'jan.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
      ];
      const days = [
        'lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'
      ];
      return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return dateISO;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _icons[activity.type] ?? '🏃';
    final color = AppColors.activityColors[activity.type] ?? AppColors.primary;
    final intensityColor =
        _intensityColors[activity.intensity] ?? AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${activity.durationMin} min',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                    Text(
                      _formatDate(activity.dateISO),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (activity.intensity.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: intensityColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activity.intensity,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: intensityColor,
                          ),
                        ),
                      ),
                      if (activity.note != null &&
                          activity.note!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '"${activity.note}"',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null || onEdit != null)
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (value) {
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'Supprimer',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}