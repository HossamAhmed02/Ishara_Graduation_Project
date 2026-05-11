import 'package:flutter/material.dart';

class HelpButton extends StatelessWidget {
  final List<String> animations;
  final Function(List<String>) onTranslate;

  const HelpButton({
    super.key,
    required this.animations,
    required this.onTranslate,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = (screenWidth * 0.08).clamp(15.0, 17.0);

    return GestureDetector(
      onTap: () => onTranslate(animations),
      child: Image.asset(
        'assets/images/question.png',
        width: imageSize,
        height: imageSize,
      ),
    );
  }
}
