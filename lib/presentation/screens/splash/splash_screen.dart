import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/services/auth_service.dart';
import 'package:library_management/localization/app_localization.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      // Supabase restores the existing session before the app starts.
      context.go(AuthService().isAuthenticated ? '/home' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logos/app_logo.png',
              height: 96,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalization.tr('splash_title'),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
