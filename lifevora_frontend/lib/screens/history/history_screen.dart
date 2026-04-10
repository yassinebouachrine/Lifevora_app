import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/activity_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/activity_card.dart';
import '../add_activity/add_activity_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();

  // ✅ Filtres UI (affichage) - gardés en français
  final List<String> _filters = [
    'Tout', 'Course', 'Marche', 'Vélo', 'Yoga', 'Natation', 'Musculation'
  ];

  // ✅ Mapping filtre UI → type API (pour filtrage local)
  static const Map<String, String> _filterToApiType = {
    'Tout': 'Tout',
    'Course': 'course',
    'Marche': 'marche',
    'Vélo': 'velo',
    'Yoga': 'yoga',
    'Natation': 'natation',
    'Musculation': 'musculation',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Refresh depuis API
  Future<void> _onRefresh() async {
    final userId = context.read<UserProvider>().user?.id ?? '';
    if (userId.isNotEmpty) {
      await context.read<ActivityProvider>().forceSync(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            const SizedBox(height: 8),
            _buildSearchBar(ap),
            _buildFilterChips(ap),
            _buildCount(ap),
            Expanded(
              child: ap.isLoading
                  // ✅ Loader initial
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : ap.filteredActivities.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          // ✅ Pull-to-refresh
                          onRefresh: _onRefresh,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: ap.filteredActivities.length,
                            itemBuilder: (context, i) {
                              final activity = ap.filteredActivities[i];
                              return ActivityCard(
                                activity: activity,
                                onDelete: () =>
                                    _deleteActivity(context, activity.id),
                                onEdit: () =>
                                    _editActivity(context, activity.id),
                              )
                                  .animate(
                                    delay: Duration(milliseconds: i * 50),
                                  )
                                  .fadeIn()
                                  .slideX(begin: 0.1, end: 0);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Historique',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          // ✅ Bouton refresh
          GestureDetector(
            onTap: _onRefresh,
            child: Container(
              width: 40,
              height: 40,
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
                Icons.sort_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ActivityProvider ap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: ap.setSearchQuery,
          decoration: const InputDecoration(
            hintText: 'Rechercher une activité...',
            hintStyle: TextStyle(
              color: AppColors.textHint,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textHint,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ActivityProvider ap) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final filter = _filters[i];
          // ✅ Comparer avec le filtre API stocké dans le provider
          final apiType = _filterToApiType[filter] ?? filter;
          final isSelected = ap.filterType == apiType;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              // ✅ Envoyer le type API au provider
              onTap: () => ap.setFilter(apiType),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
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
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCount(ActivityProvider ap) {
    final count = ap.filteredActivities.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count activité${count > 1 ? 's' : ''} — trié par date ↓',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          // ✅ Indicateur sync
          if (ap.isSyncing) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('🏃', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text(
            'Aucune activité trouvée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Commencez à ajouter vos séances!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteActivity(BuildContext context, String id) async {
    final userId = context.read<UserProvider>().user?.id ?? '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer cette activité?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final result = await context
          .read<ActivityProvider>()
          .deleteActivity(id, userId);

      // ✅ Afficher message de confirmation
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true
                  ? '✅ Activité supprimée'
                  : '❌ ${result['message'] ?? 'Erreur'}',
            ),
            backgroundColor: result['success'] == true
                ? AppColors.success
                : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _editActivity(BuildContext context, String id) {
    final activity = context
        .read<ActivityProvider>()
        .activities
        .firstWhere((a) => a.id == id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddActivityScreen(editActivity: activity),
      ),
    ).then((_) {
      // ✅ Refresh après retour de l'édition
      _onRefresh();
    });
  }
}