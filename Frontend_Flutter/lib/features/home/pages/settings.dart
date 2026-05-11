import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/core/services/token_service.dart';
import 'package:ishara/features/home/cubit/profile_cubit.dart';
import 'package:ishara/features/home/cubit/profile_state.dart';
import 'package:ishara/features/home/models/profile_models.dart';
import 'package:ishara/features/auth/pages/login.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..getProfile(),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatefulWidget {
  const _SettingsBody();

  @override
  State<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<_SettingsBody>
    with TickerProviderStateMixin {
  bool _profileExpanded = false;
  bool _passwordExpanded = false;

  late final AnimationController _profileArrowController;
  late final AnimationController _passwordArrowController;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _originalFirstName = '';
  String _originalLastName = '';

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();

    _profileArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _passwordArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _profileArrowController.dispose();
    _passwordArrowController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _populateFields(ProfileResponse profile) {
    _originalFirstName = profile.firstName;
    _originalLastName = profile.lastName;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _emailController.text = profile.email;
  }

  String _initials(String fullName) {
    if (fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  bool get _anyExpanded => _profileExpanded || _passwordExpanded;

  void _toggleProfile() => setState(() {
    _profileExpanded = !_profileExpanded;
    _profileExpanded
        ? _profileArrowController.forward()
        : _profileArrowController.reverse();
  });

  void _togglePassword() => setState(() {
    _passwordExpanded = !_passwordExpanded;
    _passwordExpanded
        ? _passwordArrowController.forward()
        : _passwordArrowController.reverse();
  });

  void _onCancel() {
    setState(() {
      _firstNameController.text = _originalFirstName;
      _lastNameController.text = _originalLastName;
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _profileExpanded = false;
      _passwordExpanded = false;
      _profileArrowController.reverse();
      _passwordArrowController.reverse();
    });
  }

  // Password validation
  String? _validatePassword(String password) {
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) {
      return 'Password must contain at least one special character';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // Save
  void _onSave() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (firstName.isEmpty || lastName.isEmpty) {
      _showSnackBar('First name and last name cannot be empty', isError: true);
      return;
    }

    String? passwordToSend;
    if (_passwordExpanded && newPass.isNotEmpty) {
      if (newPass != confirm) {
        _showSnackBar('Passwords do not match', isError: true);
        return;
      }
      final passError = _validatePassword(newPass);
      if (passError != null) {
        _showSnackBar(passError, isError: true);
        return;
      }
      passwordToSend = newPass;
    }

    context.read<ProfileCubit>().updateProfile(
      UpdateProfileRequest(
        firstName: firstName,
        lastName: lastName,
        newPassword: passwordToSend,
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.buttonPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _populateFields(state.profile);
        }
        if (state is ProfileUpdateSuccess) {
          // Refresh profile card after successful save
          context.read<ProfileCubit>().getProfile();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          setState(() {
            _profileExpanded = false;
            _passwordExpanded = false;
            _profileArrowController.reverse();
            _passwordArrowController.reverse();
          });
          _showSnackBar(state.message);
        }
        if (state is ProfileUpdateError) {
          _showSnackBar(state.message, isError: true);
        }
        if (state is ProfileError) {
          _showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, state) {
        // Determine current data to show in the card
        final isCardLoading =
            state is ProfileLoading || state is ProfileInitial;
        final profile = state is ProfileLoaded
            ? state.profile
            : state is ProfileUpdateLoading
            ? null
            : state is ProfileUpdateSuccess
            ? null
            : null;

        final isSaving = state is ProfileUpdateLoading;

        return Scaffold(
          backgroundColor: AppColors.cardBackground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.reply,
                          color: AppColors.buttonPrimary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 40),
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontFamily: 'Fraunces',
                              color: AppColors.buttonPrimary,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Profile Card
                  isCardLoading
                      ? const _ProfileCardSkeleton()
                      : profile != null
                      ? _ProfileCard(
                          userName: profile.fullName,
                          userEmail: profile.email,
                          initials: _initials(profile.fullName),
                        )
                      : _ProfileCard(
                          userName: '$_originalFirstName $_originalLastName'
                              .trim(),
                          userEmail: _emailController.text,
                          initials: _initials(
                            '$_originalFirstName $_originalLastName'.trim(),
                          ),
                        ),

                  const SizedBox(height: 40),

                  //  Other Settings label
                  const Text(
                    'Other Settings',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      color: AppColors.buttonPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Scrollable area
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //  Profile Details accordion
                          _buildAccordionTile(
                            title: 'Profile Details',
                            leadingIcon: Icons.manage_accounts_outlined,
                            isExpanded: _profileExpanded,
                            arrowController: _profileArrowController,
                            onTap: _toggleProfile,
                            children: [
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'First Name',
                                controller: _firstNameController,
                              ),
                              const SizedBox(height: 14),
                              _buildTextField(
                                label: 'Last Name',
                                controller: _lastNameController,
                              ),
                              const SizedBox(height: 14),
                              _buildTextField(
                                label: 'Email',
                                controller: _emailController,
                                readOnly: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Password accordion
                          _buildAccordionTile(
                            title: 'Password',
                            leadingIcon: Icons.lock_outline,
                            isExpanded: _passwordExpanded,
                            arrowController: _passwordArrowController,
                            onTap: _togglePassword,
                            children: [
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'New Password',
                                controller: _newPasswordController,
                                obscureText: _obscureNew,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNew
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.buttonPrimary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureNew = !_obscureNew,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildTextField(
                                label: 'Confirm Password',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirm,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.buttonPrimary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                ),
                              ),
                              // Password rules hint
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  'Password must be 8+ characters and include an uppercase letter, a number, and a special character.',
                                  style: TextStyle(
                                    color: AppColors.buttonPrimary.withValues(
                                      alpha: 0.5,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          //  Cancel / Save
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _anyExpanded
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: Row(
                                      children: [
                                        // Cancel
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: isSaving
                                                ? null
                                                : _onCancel,
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: AppColors.buttonPrimary,
                                                width: 1.5,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                            ),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: AppColors.buttonPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Save
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: isSaving
                                                ? null
                                                : _onSave,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.buttonPrimary,
                                              disabledBackgroundColor: AppColors
                                                  .buttonPrimary
                                                  .withValues(alpha: 0.6),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                            ),
                                            child: isSaving
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : const Text(
                                                    'Save',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  //  Logout
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccordionTile({
    required String title,
    required IconData leadingIcon,
    required bool isExpanded,
    required AnimationController arrowController,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.buttonPrimary, width: 1.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(leadingIcon, color: AppColors.buttonPrimary, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.buttonPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: arrowController,
                  builder: (_, _) => Transform.rotate(
                    angle: arrowController.value * 1.5708, // 90 degrees
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.buttonPrimary,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(children: children),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText,
      style: TextStyle(
        color: readOnly
            ? AppColors.buttonPrimary.withValues(alpha: 0.5)
            : AppColors.buttonPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: readOnly
              ? AppColors.buttonPrimary.withValues(alpha: 0.4)
              : AppColors.buttonPrimary.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: readOnly
            ? AppColors.buttonPrimary.withValues(alpha: 0.05)
            : Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: readOnly
                ? AppColors.buttonPrimary.withValues(alpha: 0.3)
                : AppColors.buttonPrimary,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: AppColors.buttonPrimary,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.buttonPrimary.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton.icon(
        onPressed: () async {
          await TokenService.clearTokens();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout, color: Colors.red, size: 20),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
      ),
    );
  }
}

// Profile Card

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.userName,
    required this.userEmail,
    required this.initials,
  });

  final String userName;
  final String userEmail;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.buttonPrimary, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.buttonPrimary,
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.buttonPrimary.withValues(alpha: 0.08),
                    Colors.white,
                    AppColors.buttonPrimary.withValues(alpha: 0.04),
                  ],
                ),
              ),
            ),
          ),
          //  Decorative circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.buttonPrimary.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _AvatarInitials(initials: initials),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full name from API
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.buttonPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Email from API
                      if (userEmail.isNotEmpty)
                        Text(
                          userEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.buttonPrimary.withValues(
                              alpha: 0.65,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Avatar initials circle

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.buttonPrimary,
            AppColors.buttonPrimary.withValues(alpha: 0.75),
          ],
        ),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonPrimary.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// Loading skeleton
class _ProfileCardSkeleton extends StatelessWidget {
  const _ProfileCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.buttonPrimary, width: 2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.buttonPrimary,
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.buttonPrimary,
          ),
        ),
      ),
    );
  }
}
