import 'package:flutter/material.dart';
import 'package:ishara/core/theme/theme.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/core/widgets/custom_textfield.dart';
import 'package:ishara/core/widgets/primary_button.dart';
import 'package:ishara/features/auth/pages/otp_for_signup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/features/auth/cubit/register_cubit.dart';
import 'package:ishara/features/auth/cubit/register_state.dart';
import 'package:ishara/features/auth/data/models/register_request.dart';
import 'package:ishara/core/widgets/help_button.dart';
import 'package:o3d/o3d.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypePasswordController = TextEditingController();
  final O3DController o3dController = O3DController();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _retypePasswordFocusNode = FocusNode();

  int _animationSessionId = 0;

  @override
  void initState() {
    super.initState();
    _firstNameFocusNode.addListener(() {
      if (_firstNameFocusNode.hasFocus) {
        _playAnimationSequence(['first name']);
      }
    });
    _lastNameFocusNode.addListener(() {
      if (_lastNameFocusNode.hasFocus) {
        _playAnimationSequence(['last name']);
      }
    });
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _playAnimationSequence(['email']);
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _playAnimationSequence(['password']);
      }
    });
    _retypePasswordFocusNode.addListener(() {
      if (_retypePasswordFocusNode.hasFocus) {
        _playAnimationSequence(['retype', 'password']);
      }
    });
  }

  Future<void> _playAnimationSequence(List<String> animations) async {
    _animationSessionId++;

    final int currentSession = _animationSessionId;

    for (final String anim in animations) {
      if (!mounted || currentSession != _animationSessionId) return;

      o3dController.animationName = anim;

      await Future.delayed(const Duration(seconds: 3));
    }

    if (mounted && currentSession == _animationSessionId) {
      o3dController.animationName = 'idle';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _retypePasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(),

      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) =>
                    OtpForSignupScreen(email: _emailController.text.trim()),
                transitionsBuilder: (_, animation, _, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.cardBackground,
            body: Column(
              children: [
                // Top Gradient Header
                Container(
                  width: double.infinity,
                  decoration: AppTheme.gradientBackground.copyWith(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14.0,
                                    bottom: 22.0,
                                    top: 40.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Let\'s',
                                        style: GoogleFonts.poppins(
                                          fontSize: 35,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300,
                                          height: 1.3,
                                        ),
                                      ),
                                      Text(
                                        'Create\nYour\nAccount',
                                        style: GoogleFonts.poppins(
                                          fontSize: 37,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                height: 220,
                                child: O3D(
                                  controller: o3dController,
                                  src: 'assets/models/all_signs.glb',
                                  autoPlay: true,
                                  animationName: 'idle',
                                  cameraTarget: CameraTarget(0, 1.2, 0),
                                  cameraOrbit: CameraOrbit(0, 75, 10),
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

                // Bottom Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 26,
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          hintText: 'First Name',
                          prefixIcon: Icons.person,
                          isDarkContext: true,
                          controller: _firstNameController,
                          focusNode: _firstNameFocusNode,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'Last Name',
                          prefixIcon: Icons.person,
                          isDarkContext: true,
                          controller: _lastNameController,
                          focusNode: _lastNameFocusNode,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'Email Address',
                          prefixIcon: Icons.email_outlined,
                          isDarkContext: true,
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'Password',
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          isDarkContext: true,
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'Retype Password',
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          isDarkContext: true,
                          controller: _retypePasswordController,
                          focusNode: _retypePasswordFocusNode,
                        ),
                        const SizedBox(height: 16),

                        HelpButton(
                          animations: const ["login"],
                          onTranslate: _playAnimationSequence,
                        ),
                        const SizedBox(height: 8),

                        state is RegisterLoading
                            ? const Center(child: CircularProgressIndicator())
                            : PrimaryButton(
                                text: 'Sign Up',
                                onPressed: () {
                                  if (_passwordController.text !=
                                      _retypePasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Passwords do not match'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  context.read<RegisterCubit>().register(
                                    RegisterRequest(
                                      firstName: _firstNameController.text
                                          .trim(),
                                      lastName: _lastNameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Have an account? ',
                              style: TextStyle(
                                color: Color(0xFF5D7382),
                                fontSize: 13,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Color(0xFF325656),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
