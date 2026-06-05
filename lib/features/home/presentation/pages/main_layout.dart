import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  int _indexFromPath(String path) {
    if (path.startsWith('/workout')) {
      return 1;
    }
    if (path.startsWith('/progress')) {
      return 2;
    }
    if (path.startsWith('/coach')) {
      return 3;
    }
    if (path.startsWith('/profile') ||
        path.startsWith('/achievements') ||
        path.startsWith('/leaderboard')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path  = GoRouterState.of(context).uri.path;
    final index = _indexFromPath(path);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: NavigationBar(
          selectedIndex:    index,
          backgroundColor:  AppColors.bgSurface,
          indicatorColor:   AppColors.accentGreen.withValues(alpha: 0.15),
          surfaceTintColor: Colors.transparent,
          elevation:        0,
          onDestinationSelected: (i) {
            switch (i) {
              case 0: context.go('/home');     break;
              case 1: context.go('/workout');  break;
              case 2: context.go('/progress'); break;
              case 3: context.go('/coach');    break;
              case 4: context.go('/profile');  break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Workout',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart_outlined),
              selectedIcon: Icon(Icons.show_chart),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy),
              label: 'AI Coach',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}