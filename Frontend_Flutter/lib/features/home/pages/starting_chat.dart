import 'package:flutter/material.dart';
import 'package:ishara/core/theme/theme.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/core/widgets/help_button.dart';
import 'package:ishara/features/home/pages/home.dart';
import 'package:ishara/features/home/pages/settings.dart';
import 'package:ishara/features/live_chat/pages/live_chat.dart';
import 'package:ishara/features/avatar/pages/avatar_screen.dart';
import 'package:o3d/o3d.dart';

class StartingChatScreen extends StatefulWidget {
  const StartingChatScreen({super.key});

  @override
  State<StartingChatScreen> createState() => _StartingChatScreenState();
}

class _StartingChatScreenState extends State<StartingChatScreen> {
  final O3DController _o3dController = O3DController();

  Future<void> _navigateWithAvatarPause(Widget screen) async {
    _o3dController.pause();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _o3dController.play();
  }

  void _playAnimationSequence(List<String> animations) async {
    for (String anim in animations) {
      _o3dController.animationName = anim;
      _o3dController.play();
      await Future.delayed(const Duration(seconds: 2));
    }
    _o3dController.animationName = 'idle';
    _o3dController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Column(
        children: [
          Container(
            height: 380,
            width: double.infinity,
            decoration: AppTheme.gradientBackground.copyWith(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.home_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _navigateWithAvatarPause(const SettingsScreen()),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 240,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Communication\nhas\nno limits -\nand\nneither\ndo you.',
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      fontFamily: 'Fraunces',
                                      color: Colors.white,
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: -10,
                            bottom: 0,
                            child: SizedBox(
                              width: 200,
                              child: O3D(
                                controller: _o3dController,
                                src: 'assets/models/all_signs.glb',
                                autoPlay: true,
                                animationName: 'idle',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      HelpButton(
                        animations: const ['avatar'],
                        onTranslate: _playAnimationSequence,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _navigateWithAvatarPause(const AvatarScreen()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        border: Border.all(
                          color: AppColors.buttonPrimary,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Avatar',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontFamily: 'Fraunces',
                                  color: AppColors.buttonPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/avatar.jpeg',
                              height: 65,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      HelpButton(
                        animations: const ['camera'],
                        onTranslate: _playAnimationSequence,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () =>
                        _navigateWithAvatarPause(const LiveChatScreen()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        border: Border.all(
                          color: AppColors.buttonPrimary,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Camera',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontFamily: 'Fraunces',
                                  color: AppColors.buttonPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Image.asset(
                            'assets/images/videoCamera.png',
                            height: 65,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
