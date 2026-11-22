import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const StashAStoryApp());

class StashAStoryApp extends StatelessWidget {
  const StashAStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stash A Story',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorSchemeSeed: const Color(0xFF228B22),
      ),
      home: const SplashScreen(),
    );
  }
}
