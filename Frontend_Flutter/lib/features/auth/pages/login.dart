import 'package:flutter/material.dart';
import 'package:ishara/core/theme/theme.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/core/widgets/custom_textfield.dart';
import 'package:ishara/core/widgets/primary_button.dart';
import 'package:ishara/features/home/pages/home.dart';
import 'package:ishara/features/auth/pages/create_account.dart';
import 'package:ishara/features/auth/pages/forgot_password.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/features/auth/cubit/login_cubit.dart';
import 'package:ishara/features/auth/cubit/login_state.dart';
import 'package:ishara/features/auth/data/models/login_request.dart';
import 'package:ishara/core/widgets/help_button.dart';
import 'package:o3d/o3d.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final O3DController o3dController = O3DController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // ✅ رقم session عشان نمنع تداخل الحركات
  int _animationSessionId = 0;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);
  }

  // ✅ لما يدوس على حقل الإيميل يشغل حركة email
  void _onEmailFocusChange() {
    if (_emailFocusNode.hasFocus) {
      _playAnimationSequence(['email']);
    }
  }

  // ✅ لما يدوس على حقل الباسورد يشغل حركة password
  void _onPasswordFocusChange() {
    if (_passwordFocusNode.hasFocus) {
      _playAnimationSequence(['password']);
    }
  }

  // ✅ دالة مركزية بتشغل الحركات ورا بعض وبعدين ترجع idle
  Future<void> _playAnimationSequence(List<String> animations) async {
    // ✅ كل ضغطة جديدة بترفع الـ session وتلغي أي حركة قديمة
    _animationSessionId++;
    final int currentSession = _animationSessionId;

    for (final String anim in animations) {
      if (!mounted || currentSession != _animationSessionId) return;

      // ✅ شغل الحركة عن طريق الـ controller مباشرة
      o3dController.animationName = anim;

      // ✅ استنى 2 ثانية (طول كل حركة) قبل ما تشغل الجاية
      await Future.delayed(const Duration(seconds: 2));
    }

    // ✅ بعد ما تخلص كل الحركات ارجع لـ idle
    if (mounted && currentSession == _animationSessionId) {
      o3dController.animationName = 'idle';
    }
  }

  // ✅ دالة جديدة لإيقاف الحركات فوراً قبل الانتقال لصفحة تانية
  void _stopAnimations() {
    _animationSessionId++; // كنسل أي حركات متأجلة
    o3dController.animationName = 'idle'; // ارجع لوضع الثبات
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.removeListener(_onPasswordFocusChange);
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // ✅ إيقاف الأفاتار قبل الانتقال للـ Home
            _stopAnimations();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          } else if (state is LoginFailure) {
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
            body: Container(
              decoration: AppTheme.gradientBackground,
              child: SafeArea(
                bottom: false,
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 16.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.04,
                                  ),
                                  Center(
                                    child: Transform.translate(
                                      offset: Offset(
                                        0,
                                        -MediaQuery.of(context).size.height *
                                            0.03,
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.70,
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.70,
                                            constraints: const BoxConstraints(
                                              maxWidth: 300,
                                              maxHeight: 300,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withValues(
                                                    alpha: 0.25,
                                                  ),
                                                  Colors.white.withValues(
                                                    alpha: 0.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: O3D(
                                                controller: o3dController,
                                                src:
                                                    'assets/models/all_signs.glb',
                                                autoPlay: true,
                                                animationName: 'idle',
                                                cameraTarget: CameraTarget(
                                                  0,
                                                  1.2,
                                                  0,
                                                ),
                                                cameraOrbit: CameraOrbit(
                                                  0,
                                                  75,
                                                  10,
                                                ),
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -35,
                                            child: Text(
                                              'ISHARA',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge
                                                  ?.copyWith(
                                                    fontSize: 60,
                                                    fontFamily: 'Fraunces',
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    hintText: 'Email',
                                    prefixIcon: Icons.person,
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                  ),
                                  const SizedBox(height: 18),
                                  CustomTextField(
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock,
                                    isPassword: true,
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (val) {
                                            setState(
                                              () => _rememberMe = val ?? false,
                                            );
                                          },
                                          side: const BorderSide(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          activeColor: Colors.white,
                                          checkColor: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Remember me',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      HelpButton(
                                        animations: const ['remember', 'me'],
                                        onTranslate: _playAnimationSequence,
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.29,
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              minHeight: 220,
                              maxHeight: 300,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(AppConstants.borderRadius),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // ✅ إيقاف الأفاتار قبل الانتقال
                                          _stopAnimations();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ForgotPasswordScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: Color(0xFF5D7382),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      HelpButton(
                                        animations: const [
                                          'forgot',
                                          'password',
                                        ],
                                        onTranslate: _playAnimationSequence,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    HelpButton(
                                      animations: const ['login'],
                                      onTranslate: _playAnimationSequence,
                                    ),
                                    const SizedBox(height: 6),
                                    state is LoginLoading
                                        ? const CircularProgressIndicator()
                                        : PrimaryButton(
                                            text: 'Login',
                                            onPressed: () {
                                              context.read<LoginCubit>().login(
                                                LoginRequest(
                                                  email: _emailController.text
                                                      .trim(),
                                                  password:
                                                      _passwordController.text,
                                                ),
                                              );
                                            },
                                          ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      'or',
                                      style: TextStyle(
                                        color: Color(0xFF5D7382),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    HelpButton(
                                      animations: const ['create', 'account'],
                                      onTranslate: _playAnimationSequence,
                                    ),
                                    const SizedBox(height: 6),
                                    PrimaryButton(
                                      text: 'Create an account',
                                      backgroundColor:
                                          AppColors.buttonSecondary,
                                      textColor: AppColors.textPrimary,
                                      onPressed: () {
                                        // ✅ إيقاف الأفاتار قبل الانتقال
                                        _stopAnimations();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const CreateAccountScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 28),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
