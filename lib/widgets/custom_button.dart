import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isPrimary;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 48.0 : 7.h.clamp(46.0, 52.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppTheme.primaryColor
              : AppTheme.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: isDesktop ? 15.0 : 16.sp.clamp(14.0, 16.0),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
