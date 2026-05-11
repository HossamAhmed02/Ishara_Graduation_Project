import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ishara/core/theme/theme.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/core/widgets/custom_textfield.dart';
import 'package:ishara/core/widgets/primary_button.dart';
import 'package:ishara/features/auth/pages/otp_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/features/auth/cubit/forgot_password_cubit.dart';
import 'package:ishara/features/auth/cubit/forgot_password_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP sent to your email'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) => OtpScreen(email: state.email),
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
          } else if (state is ForgotPasswordFailure) {
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
              height: double.infinity,
              decoration: AppTheme.gradientBackground,
              child: SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textPrimary,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            const Icon(
                              Icons.lock,
                              size: 80,
                              color: AppColors.buttonPrimary,
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                Text(
                                  'Forgot',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.buttonPrimary,
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  'Password?',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.buttonPrimary,
                                    fontSize: 44,
                                    fontWeight: FontWeight.w300,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No worries, we\'ll send you\nreset instructions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 94),
                            CustomTextField(
                              hintText: 'Enter your Email',
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                            ),
                            const SizedBox(height: 24),
                            state is ForgotPasswordLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : PrimaryButton(
                                    text: 'Reset Password',
                                    backgroundColor: AppColors.buttonSecondary,
                                    textColor: AppColors.textPrimary,
                                    onPressed: () {
                                      context
                                          .read<ForgotPasswordCubit>()
                                          .forgotPassword(
                                            _emailController.text.trim(),
                                          );
                                    },
                                  ),
                            const SizedBox(height: 40),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Back to Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
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
