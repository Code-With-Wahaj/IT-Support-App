import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/responsive_utils.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomTextButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    return TextButton(
      onPressed: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: isDesktop ? 13.5 : 14.sp.clamp(12.0, 14.0),
          fontWeight: FontWeight.w500,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}