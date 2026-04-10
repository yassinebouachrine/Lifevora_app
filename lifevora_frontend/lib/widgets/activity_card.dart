import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
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

  static const Map<String, String> _emojis = {
    'Course'     : '⚡',
    'Marche'     : '👣',
    'Vélo'       : '🚴',
    'Yoga'       : '🍃',
    'Natation'   : '🌊',
    'Musculation': '💪',
  };

  static const Map<String, Color> _intensityColors = {
    'Faible': AppColors.success,
    'Modéré': AppColors.warning,
    'Élevé' : AppColors.error,
  };

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = [
        'jan.','févr.','mars','avr.','mai','juin',
        'juil.','août','sept.','oct.','nov.','déc.'
      ];
      const days = ['lun.','mar.','mer.','jeu.','ven.','sam.','dim.'];
      return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final emoji = _emojis[activity.type] ?? '🏃';
    final color = AppColors.activityColors[activity.type] ?? AppColors.primary;
    final intensityColor =
        _intensityColors[activity.intensity] ?? AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.type,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedClock01,
                      color: textSecondary,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.durationMin} min',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(color: textSecondary),
                    ),
                    Text(
                      _formatDate(activity.dateISO),
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
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
                          color: intensityColor.withValues(alpha: 0.12),
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
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
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
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedMoreVertical,
                color: isDark
                    ? AppColors.darkTextHint
                    : AppColors.textHint,
                size: 20,
              ),
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (v) {
                if (v == 'edit') onEdit?.call();
                if (v == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                if (onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedPencilEdit01,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Modifier',
                          style: TextStyle(color: textPrimary),
                        ),
                      ],
                    ),
                  ),
                if (onDelete != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: const [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete01,
                          color: AppColors.error,
                          size: 18,
                        ),
                        SizedBox(width: 10),
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