import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:ishara/core/theme/theme.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/core/services/token_service.dart';
import 'package:ishara/features/auth/pages/login.dart';
import 'package:ishara/features/home/pages/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Avatar entrance animation
  late AnimationController _avatarController;
  late Animation<double> _avatarFade;
  late Animation<double> _avatarScale;
  late Animation<Offset> _avatarSlide;

  // Floating idle animation (subtle up/down)
  late AnimationController _floatController;
  late Animation<double> _floatOffset;

  // Text letter-by-letter animation
  late AnimationController _lettersController;
  late AnimationController _glowController;

  final String _logoText = 'ISHARA';
  final List<Animation<double>> _letterAnimations = [];
  late Animation<double> _glowAnimation;

  // Global screen fade-out before navigation
  late AnimationController _fadeOutController;
  late Animation<double> _fadeOutAnimation;

  // Total splash duration
  static const Duration _splashDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initAnimations();

    // Fade-out then navigate
    Timer(_splashDuration - const Duration(milliseconds: 400), () {
      if (mounted) _fadeOutController.forward();
    });
    Timer(_splashDuration, _navigateToNextScreen);
  }

  // Animation init
  void _initAnimations() {
    // Avatar entrance: fade + scale up + slide from bottom
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _avatarFade = CurvedAnimation(
      parent: _avatarController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _avatarScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _avatarController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _avatarSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _avatarController,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Subtle floating idle loop after entrance
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat(reverse: true);

    _floatOffset = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Letter stagger
    _lettersController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    for (int i = 0; i < _logoText.length; i++) {
      final start = i / _logoText.length * 0.6;
      final end = start + 0.4;
      _letterAnimations.add(
        CurvedAnimation(
          parent: _lettersController,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    }

    // Glow pulse
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Screen fade-out
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeOutAnimation = CurvedAnimation(
      parent: _fadeOutController,
      curve: Curves.easeIn,
    );

    // Sequence: avatar entrance first, then letters appear
    _avatarController.forward();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _lettersController.forward();
    });
  }

  // Navigation
  Future<void> _navigateToNextScreen() async {
    final isLoggedIn = await TokenService.isLoggedIn();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) =>
              isLoggedIn ? const HomeScreen() : const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _floatController.dispose();
    _lettersController.dispose();
    _glowController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _fadeOutAnimation,
      builder: (context, child) =>
          Opacity(opacity: 1.0 - _fadeOutAnimation.value, child: child),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.gradientBackground,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radial glow halo behind avatar
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (_, _) => Container(
                  width: size.width * 0.80,
                  height: size.width * 0.80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.textYellow.withValues(
                          alpha: 0.07 * _glowAnimation.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar image: entrance + continuous float
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _avatarController,
                      _floatController,
                    ]),
                    builder: (_, _) {
                      return FadeTransition(
                        opacity: _avatarFade,
                        child: SlideTransition(
                          position: _avatarSlide,
                          child: Transform.translate(
                            offset: Offset(0, _floatOffset.value),
                            child: Transform.scale(
                              scale: _avatarScale.value,
                              child: SizedBox(
                                width: size.width * 0.35,
                                height: size.height * 0.25,
                                child: Image.asset(
                                  'assets/images/avatar2.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 6),

                  // ISHARA letters
                  AnimatedBuilder(
                    animation: _lettersController,
                    builder: (_, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_logoText.length, (i) {
                          final value = _letterAnimations[i].value;
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (_, _) => Text(
                                  _logoText[i],
                                  style: TextStyle(
                                    fontFamily: 'Fraunces',
                                    fontSize: 62,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 8,
                                    color: AppColors.textYellow,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.textYellow.withValues(
                                          alpha: 0.5 * _glowAnimation.value,
                                        ),
                                        blurRadius: 20,
                                      ),
                                      Shadow(
                                        color: AppColors.textYellow.withValues(
                                          alpha: 0.2 * _glowAnimation.value,
                                        ),
                                        blurRadius: 50,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
