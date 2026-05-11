import 'package:flutter/material.dart';
import 'package:ishara/core/theme/theme.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/core/widgets/custom_textfield.dart';
import 'package:ishara/features/auth/pages/reset_successful.dart';
import 'package:ishara/core/widgets/primary_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/features/auth/cubit/reset_password_cubit.dart';
import 'package:ishara/features/auth/cubit/reset_password_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordCubit(),
      child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ResetSuccessfulScreen()),
              (route) => false,
            );
          } else if (state is ResetPasswordFailure) {
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
                        vertical: 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.textPrimary,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Center(
                              child: Text(
                                'Reset your Password',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      color: AppColors.buttonPrimary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      height: 1.2,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Enter a new password to access your account.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),

                            const Text(
                              'New Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              hintText: 'Enter a strong password',
                              prefixIcon: Icons.lock,
                              isPassword: true,
                              controller: _newPasswordController,
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              'Confirm Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock,
                              isPassword: true,
                              controller: _confirmPasswordController,
                            ),

                            const SizedBox(height: 48),

                            state is ResetPasswordLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : PrimaryButton(
                                    text: 'Reset Password',
                                    backgroundColor: AppColors.buttonSecondary,
                                    textColor: AppColors.textPrimary,
                                    onPressed: () {
                                      context
                                          .read<ResetPasswordCubit>()
                                          .resetPassword(
                                            email: widget.email,
                                            newPassword:
                                                _newPasswordController.text,
                                            confirmPassword:
                                                _confirmPasswordController.text,
                                            resetToken: widget.resetToken,
                                          );
                                    },
                                  ),
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
