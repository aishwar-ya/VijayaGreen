import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _leafController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _logoMove;

  // VijayaGreen colors
  static const Color cream = Color(0xFFF7F3E7);
  static const Color gold = Color(0xFFD4A72C);
  static const Color olive = Color(0xFF7B8F3A);

  @override
  void initState() {
    super.initState();

    // ============================================================
    // LOGO ANIMATION
    // ============================================================

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
    );

    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoMove = Tween<double>(begin: 25, end: 0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // ============================================================
    // FLOATING LEAVES
    // ============================================================

    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _logoController.forward();

    // ============================================================
    // GO TO LOGIN
    // ============================================================

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const LoginScreen();
          },
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _leafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==========================================================
      // CLEAN CREAM BACKGROUND
      // ==========================================================

      backgroundColor: cream,

      body: Stack(
        children: [
          // ========================================================
          // SUBTLE BACKGROUND GLOW
          // ========================================================

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [Colors.white.withValues(alpha: 0.45), cream],
                ),
              ),
            ),
          ),

          // ========================================================
          // DECORATIVE FLOATING LEAVES
          // ========================================================
          AnimatedBuilder(
            animation: _leafController,
            builder: (context, child) {
              final value = _leafController.value;

              return Stack(
                children: [
                  _buildLeaf(
                    left: 25,
                    top: 120 + math.sin(value * math.pi * 2) * 12,
                    size: 26,
                    opacity: 0.30,
                    rotation: -0.4,
                  ),
                  _buildLeaf(
                    right: 25,
                    top: 185 + math.sin(value * math.pi * 2 + 1) * 14,
                    size: 22,
                    opacity: 0.25,
                    rotation: 0.5,
                  ),
                  _buildLeaf(
                    left: 40,
                    bottom: 150 + math.sin(value * math.pi * 2 + 2) * 10,
                    size: 20,
                    opacity: 0.22,
                    rotation: 0.7,
                  ),
                  _buildLeaf(
                    right: 45,
                    bottom: 110 + math.sin(value * math.pi * 2 + 3) * 12,
                    size: 24,
                    opacity: 0.28,
                    rotation: -0.6,
                  ),
                ],
              );
            },
          ),

          // ========================================================
          // MAIN LOGO
          // ========================================================
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFade.value,
                  child: Transform.translate(
                    offset: Offset(0, _logoMove.value),
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  ),
                );
              },

              // IMPORTANT:
              // No Container
              // No border
              // No shadow
              // No cream box around the logo
              child: Image.asset(
                'assets/images/vijayagreen_logo.png',
                width: 360,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ========================================================
          // BOTTOM BRAND TEXT
          // ========================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 45,
            child: FadeTransition(
              opacity: _logoFade,
              child: const Column(
                children: [
                  Text(
                    'VijayaGreen',
                    style: TextStyle(
                      color: Color(0xFF24543A),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Garden Accounts Made Simple',
                    style: TextStyle(
                      color: gold,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // FLOATING LEAF
  // ==============================================================

  Widget _buildLeaf({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required double opacity,
    required double rotation,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.rotate(
        angle: rotation,
        child: Icon(
          Icons.eco,
          size: size,
          color: olive.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
