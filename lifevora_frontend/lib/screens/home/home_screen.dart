import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../history/history_screen.dart';
import '../add_activity/add_activity_screen.dart';
import '../profile/profile_screen.dart';
import '../metaverse/avatar_screen.dart';
import 'home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().user?.id ?? '';
      if (userId.isNotEmpty) {
        context.read<ActivityProvider>().loadActivities(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeContent(),
          HistoryScreen(),
          SizedBox(),
          AvatarScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: LifevoraBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _showAddActivity();
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }

  void _showAddActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddActivityScreen()),
    );
  }
}