import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Delay for branding display
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Listen to auth state to redirect after auth check
    ref.listenManual(authProvider, (prev, next) {
      if (!mounted) return;
      if (next.status == AuthStatus.authenticated) {
        final role = next.user?.role;
        if (role == 'ARTISAN') {
          context.go('/artisan-dashboard');
        } else {
          context.go('/home');
        }
      } else if (next.status == AuthStatus.unauthenticated) {
        context.go('/login');
      }
    });

    // The authProvider initialization triggers _checkAuth internally
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'الميقف',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Elmokef',
              style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
