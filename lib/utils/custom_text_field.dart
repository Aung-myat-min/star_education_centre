import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? minLines;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool readonly;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.minLines,
    this.maxLines,
    this.validator,
    this.readonly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readonly, // No need for force unwrapping (!)
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: readonly ? null : const OutlineInputBorder(),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.blueGrey) // Prefix icon
            : null,
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.blueGrey) // Suffix icon
            : null,
      ),
      minLines: minLines,
      maxLines: maxLines ?? 1, // Default to single-line text field
      validator: validator,
      obscureText: obscureText, // No need for force unwrapping (!)
    );
  }
}
