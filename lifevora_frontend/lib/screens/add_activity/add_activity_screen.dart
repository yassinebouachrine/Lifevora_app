import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/activity_model.dart';
import '../../providers/activity_provider.dart';
import '../../providers/user_provider.dart';

class AddActivityScreen extends StatefulWidget {
  final ActivityModel? editActivity;
  const AddActivityScreen({super.key, this.editActivity});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  String _selectedType = 'Course';
  int _duration = 30;
  String _intensity = 'Modéré';
  String _note = '';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _activities = const [
    {'name': 'Course', 'icon': '⚡', 'color': Color(0xFFF59E0B)},
    {'name': 'Marche', 'icon': '👣', 'color': Color(0xFF10B981)},
    {'name': 'Vélo', 'icon': '🚴', 'color': Color(0xFF3B82F6)},
    {'name': 'Yoga', 'icon': '🍃', 'color': Color(0xFF8B5CF6)},
    {'name': 'Natation', 'icon': '🌊', 'color': Color(0xFF06B6D4)},
    {'name': 'Musculation', 'icon': '💪', 'color': Color(0xFFEF4444)},
  ];

  final List<Map<String, dynamic>> _intensities = const [
    {'name': 'Faible', 'color': Color(0xFF10B981), 'emoji': '😌'},
    {'name': 'Modéré', 'color': Color(0xFFF59E0B), 'emoji': '😊'},
    {'name': 'Élevé', 'color': Color(0xFFEF4444), 'emoji': '🔥'},
  ];

  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    if (widget.editActivity != null) {
      final ea = widget.editActivity!;
      _selectedType = ea.type;
      _duration = ea.durationMin;
      _intensity = ea.intensity;
      _note = ea.note ?? '';
      _selectedDate = DateTime.parse(ea.dateISO);
    }
    _noteController = TextEditingController(text: _note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

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
        title: Text(
          widget.editActivity != null
              ? 'Modifier activité'
              : 'Ajouter activité',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('TYPE D\'ACTIVITÉ'),
            const SizedBox(height: 14),
            _buildActivityGrid()
                .animate()
                .fadeIn(delay: 100.ms),
            const SizedBox(height: 28),
            _buildSectionTitle('DURÉE (MINUTES)'),
            const SizedBox(height: 14),
            _buildDurationPicker()
                .animate()
                .fadeIn(delay: 200.ms),
            const SizedBox(height: 28),
            _buildSectionTitle('DATE'),
            const SizedBox(height: 14),
            _buildDatePicker()
                .animate()
                .fadeIn(delay: 300.ms),
            const SizedBox(height: 28),
            _buildSectionTitle('INTENSITÉ'),
            const SizedBox(height: 14),
            _buildIntensityPicker()
                .animate()
                .fadeIn(delay: 400.ms),
            const SizedBox(height: 28),
            _buildSectionTitle('NOTE (OPTIONNEL)'),
            const SizedBox(height: 14),
            _buildNoteField()
                .animate()
                .fadeIn(delay: 500.ms),
            const SizedBox(height: 36),
            _buildSaveButton()
                .animate()
                .fadeIn(delay: 600.ms)
                .slideY(begin: 0.5, end: 0),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildActivityGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _activities.length,
      itemBuilder: (context, i) {
        final act = _activities[i];
        final isSelected = _selectedType == act['name'];
        final color = act['color'] as Color;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = act['name'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? color : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? color.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  act['icon'] as String,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  act['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDurationPicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _durationBtn(Icons.remove_rounded, () {
                setState(() => _duration = (_duration - 5).clamp(5, 180));
              }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_duration',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      'min',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              _durationBtn(Icons.add_rounded, () {
                setState(() => _duration = (_duration + 5).clamp(5, 180));
              }),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: const Color(0x264F46E5),
              thumbColor: AppColors.primary,
              overlayColor: const Color(0x264F46E5),
            ),
            child: Slider(
              value: _duration.toDouble(),
              min: 5,
              max: 180,
              divisions: 35,
              onChanged: (v) => setState(() => _duration = v.toInt()),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
              Text(
                '180 min',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _durationBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 22),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day.toString().padLeft(2, '0')}/'
              '${_selectedDate.month.toString().padLeft(2, '0')}/'
              '${_selectedDate.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensityPicker() {
    return Row(
      children: _intensities.map((intensity) {
        final isSelected = _intensity == intensity['name'];
        final color = intensity['color'] as Color;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _intensity = intensity['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? color : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? color.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      intensity['emoji'] as String,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      intensity['name'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _noteController,
        onChanged: (v) => _note = v,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: '"Felt good!", "Belle session"...',
          hintStyle: TextStyle(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          widget.editActivity != null
              ? 'Mettre à jour'
              : 'Enregistrer l\'activité',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final userId = context.read<UserProvider>().user?.id ?? '';
    final ap = context.read<ActivityProvider>();

    final activity = ActivityModel(
      id: widget.editActivity?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: _selectedType,
      durationMin: _duration,
      intensity: _intensity,
      dateISO: _selectedDate.toIso8601String().split('T').first,
      note: _note.isNotEmpty ? _note : null,
    );

    if (widget.editActivity != null) {
      await ap.updateActivity(activity);
    } else {
      await ap.addActivity(activity);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editActivity != null
                ? 'Activité mise à jour!'
                : 'Activité ajoutée!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }
}