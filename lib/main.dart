import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const VijayaGreenApp());
}

class VijayaGreenApp extends StatelessWidget {
  const VijayaGreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VijayaGreen',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        scaffoldBackgroundColor: const Color(0xFFF6FAF6),
      ),
      home: const LoginScreen(),
    );
  }
}
