import 'package:flutter/material.dart';
import 'package:ishara/core/constants/constants.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isDarkContext;
  final TextEditingController? controller;

  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.isDarkContext = false,
    this.controller,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isDarkContext
        ? AppColors.textPrimary
        : Colors.white;
    final Color iconColor = widget.isDarkContext
        ? AppColors.textSecondary
        : Colors.white70;
    final Color borderColor = widget.isDarkContext
        ? const Color(0xFF325656)
        : Colors.white;

    return Container(
      constraints: const BoxConstraints(minHeight: 48, maxHeight: 52),
      height: MediaQuery.of(context).size.height * 0.06,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.isPassword ? _obscureText : false,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: iconColor, fontWeight: FontWeight.w400),
          prefixIcon: Icon(widget.prefixIcon, color: iconColor),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: iconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.fieldBorderRadius),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.fieldBorderRadius),
            borderSide: BorderSide(color: textColor, width: 2.0),
          ),
        ),
      ),
    );
  }
}
