import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final Color textcolor;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    required this.controller,
    this.prefixIcon,
    this.textcolor = Colors.white,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool hide = true;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final labelSize = isDesktop ? 14.0 : 15.sp.clamp(13.0, 15.0);
    final inputSize = isDesktop ? 14.5 : 15.sp.clamp(13.5, 15.5);
    final hintSize = isDesktop ? 14.0 : 15.sp.clamp(13.0, 15.0);
    final iconSize = isDesktop ? 20.0 : 18.sp.clamp(18.0, 22.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: widget.textcolor,
          ),
        ),
        SizedBox(height: isDesktop ? 8.0 : 1.h.clamp(6.0, 10.0)),

        // TextField
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? hide : false,
          validator: widget.validator ??
              (v) => (v == null || v.isEmpty) ? "Required" : null,
          style: TextStyle(fontSize: inputSize, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: hintSize,
              color: AppTheme.textSecondary,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: isDesktop ? 14.0 : 1.8.h.clamp(12.0, 16.0),
              horizontal: isDesktop ? 14.0 : 3.w.clamp(12.0, 16.0),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon,
                    color: AppTheme.textSecondary, size: iconSize)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      hide ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textSecondary,
                      size: iconSize,
                    ),
                    onPressed: () => setState(() => hide = !hide),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.grey.shade300, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.errorColor, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.errorColor, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
