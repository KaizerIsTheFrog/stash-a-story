import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stash_a_story/screens/dashboard_screen.dart';
import 'package:stash_a_story/services/api_service.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color _titleGreen = Color(0xFF2F6139);

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2)); // let the logo show
    final result = await ApiService.profile();
    if (!mounted) return;
    final loggedIn = result['success'] == true;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => loggedIn ? const DashboardScreen() : const LoginScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo.png', width: 220),
              const SizedBox(height: 24),
              const Text(
                'Stash A Story',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: _titleGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
