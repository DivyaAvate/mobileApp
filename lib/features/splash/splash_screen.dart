import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double>   _fade;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: const Interval(0, 0.6)));
    _scale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: Curves.elasticOut));

    _anim.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for animation + auth check
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.isLoggedIn) {
      if (authState.isGymOwner) {
        context.go('/gym-owner');
      } else {
        context.go('/home');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, _) => FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo Icon ────────────────────────────
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.accentGreen.withValues(alpha: 0.3),
                        width: 1.5),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.accentGreen,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── App Name ─────────────────────────────
                  const Text('GymBuddy AI',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32, fontWeight: FontWeight.w700,
                      letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  const Text('Your trainer in your pocket',
                    style: TextStyle(
                      color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 48),

                  // ── Loading indicator ────────────────────
                  SizedBox(
                    width: 32, height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.accentGreen.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}