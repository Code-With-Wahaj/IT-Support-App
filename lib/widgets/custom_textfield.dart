import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final Color textcolor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    required this.controller,
    this.prefixIcon,
    this.textcolor = Colors.white,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool hide = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: widget.textcolor,
          ),
        ),
        SizedBox(height: 1.h),

        // TextField
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? hide : false,
          validator: (v) => v!.isEmpty ? "Required" : null,
          style: TextStyle(fontSize: 16.sp, color: AppTheme.textPrimary),

          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textSecondary,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 1.8.h,
              horizontal: 3.w,
            ),

            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppTheme.textSecondary, size: 18.sp)
                : null,

            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                hide ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textSecondary,
                size: 18.sp,
              ),
              onPressed: () => setState(() => hide = !hide),
            )
                : null,

            filled: true,
            fillColor: Colors.white, // light card style

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5.sp),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2.sp),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide(color: AppTheme.errorColor, width: 2.sp),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide(color: AppTheme.errorColor, width: 2.sp),
            ),
          ),
        ),
      ],
    );
  }
}
