import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const AdaptiveTextExampleApp());

class AdaptiveTextExampleApp extends StatelessWidget {
  const AdaptiveTextExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'adaptive_text Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
      ),
      home: const HomeScreen(),
    );
  }
}
