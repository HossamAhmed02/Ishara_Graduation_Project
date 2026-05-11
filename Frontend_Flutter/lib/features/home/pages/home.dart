import 'package:flutter/material.dart';
import 'package:ishara/core/theme/theme.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/core/widgets/help_button.dart';
import 'package:ishara/features/home/pages/starting_chat.dart';
import 'package:ishara/features/home/pages/settings.dart';
import 'package:ishara/features/messaging/pages/chat_list_screen.dart';
import 'package:o3d/o3d.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/features/messaging/cubit/chat_list_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            width: double.infinity,
            decoration: AppTheme.gradientBackground.copyWith(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              _navigateWithAvatarPause(const SettingsScreen()),
                          child: Container(
                            padding: const EdgeInsets.all(4),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Your\nhands\ntell\nstories ,\nthe\nworld\nneeds to\nhear',
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
                        SizedBox(
                          width: 210,
                          height: 280,
                          child: O3D(
                            controller: _o3dController,
                            src: 'assets/models/all_signs.glb',
                            autoPlay: true,
                            animationName: 'idle',
                            cameraTarget: CameraTarget(0, 1.2, 0),
                            cameraOrbit: CameraOrbit(0, 75, 200),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ],
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      HelpButton(
                        animations: const ['live', 'chat'],
                        onTranslate: _playAnimationSequence,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildNavCard(
                    context: context,
                    title: 'live chat',
                    imagePath: 'assets/images/group.png',
                    onTap: () =>
                        _navigateWithAvatarPause(const StartingChatScreen()),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      HelpButton(
                        animations: const ['texring'],
                        onTranslate: _playAnimationSequence,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildNavCard(
                    context: context,
                    title: 'Messaging',
                    imagePath: 'assets/images/messaging.png',
                    onTap: () {
                      try {
                        _o3dController.pause();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => ChatListCubit(),
                              child: const ChatListScreen(),
                            ),
                          ),
                        ).then((_) => _o3dController.play());
                      } catch (e) {
                        debugPrint('Navigation error: $e');
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.buttonPrimary, width: 1.5),
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
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontFamily: 'Fraunces',
                color: AppColors.buttonPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Image.asset(imagePath, height: 65, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
