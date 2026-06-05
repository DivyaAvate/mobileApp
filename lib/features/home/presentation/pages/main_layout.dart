import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gymbuddy_ai/core/constants/app_colors.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;
    if (location.startsWith('/workout')) {
      currentIndex = 1;
    } else if (location.startsWith('/progress')) {
      currentIndex = 2;
    } else if (location.startsWith('/coach')) {
      currentIndex = 3;
    } else if (location.startsWith('/profile') || location.startsWith('/achievements') || location.startsWith('/leaderboard')) {
      currentIndex = 4;
    } else {
      currentIndex = 0;
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.bgPrimary,
        selectedItemColor: AppColors.accentGreen,
        unselectedItemColor: AppColors.textMuted,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/workout');
              break;
            case 2:
              context.go('/progress');
              break;
            case 3:
              context.go('/coach');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Workout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Progress",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: "AI Coach",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}