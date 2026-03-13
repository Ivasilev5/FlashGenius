import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../storage/secure_storage.dart';
import 'app_router.dart';

/// Checks token and redirects to Home or Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final storage = SecureStorage();
    final hasToken = await storage.hasTokens();
    if (!mounted) return;
    if (hasToken) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style, size: 80, color: Colors.indigo),
            SizedBox(height: 24),
            Text('FlashCard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
