import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:ishara/core/theme/theme.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/features/home/pages/home.dart';
import 'package:ishara/features/home/pages/settings.dart';
import '../cubit/avatar_cubit.dart';
import '../cubit/avatar_state.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_textFieldFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void onSendText(String text, AvatarCubit cubit) {
    cubit.translateText(text);
  }

  @override
  void dispose() {
    _textFieldFocusNode.removeListener(_onFocusChanged);
    _textFieldFocusNode.dispose();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return BlocProvider(
      create: (_) => AvatarCubit(),
      child: Builder(
        builder: (context) {
          final cubit = context.read<AvatarCubit>();

          return BlocListener<AvatarCubit, AvatarState>(
            listener: (context, state) {
              if (state is AvatarTranslating) {
                sendToUnity(
                  'Avatar',
                  'ReceiveGloss',
                  '{"gloss": "${state.gloss}"}',
                );
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: AppColors.cardBackground,
              body: BlocBuilder<AvatarCubit, AvatarState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      // Header
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
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                            child: Row(
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
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.home_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Live Chat',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          fontFamily: 'Fraunces',
                                          color: Colors.white,
                                          fontSize: 32,
                                        ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
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
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: keyboardHeight,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),

                              // Avatar Box
                              Container(
                                width: double.infinity,
                                height: screenWidth - 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    width: 1.2,
                                  ),
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    children: [
                                      const EmbedUnity(),
                                      if (state is AvatarLoading)
                                        Container(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                                SizedBox(height: 12),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (state is AvatarError)
                                        Container(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.error_outline,
                                                    color: Colors.red,
                                                    size: 40,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    state.message,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              // Text Input Box
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 6,
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.cardBackground,
                                        border: Border.all(
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                          width: 1.2,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _controller,
                                        focusNode: _textFieldFocusNode,
                                        enabled: state is! AvatarLoading,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Type',
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .headlineLarge
                                              ?.copyWith(
                                                color: Colors.grey,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 24,
                                              ),
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(
                                              color: Colors.black,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        maxLines: null,
                                        minLines: 3,
                                      ),
                                    ),
                                    const Positioned(
                                      top: -8,
                                      right: -8,
                                      child: Text(
                                        '✦',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      bottom: -8,
                                      left: -8,
                                      child: Text(
                                        '✦',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Bar
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 32,
                          left: 40,
                          right: 40,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientEnd,
                              AppColors.gradientMiddle,
                              AppColors.gradientStart,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.reply,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                            GestureDetector(
                              onTap: state is AvatarLoading
                                  ? null
                                  : () {
                                      final text = _controller.text.trim();
                                      if (text.isNotEmpty) {
                                        onSendText(text, cubit);
                                      }
                                    },
                              child: Icon(
                                Icons.send,
                                color: state is AvatarLoading
                                    ? Colors.white38
                                    : Colors.white,
                                size: 38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
