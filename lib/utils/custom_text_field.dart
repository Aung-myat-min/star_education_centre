import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? minLines;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool? readonly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.minLines,
    this.maxLines,
    this.validator,
    this.readonly = false,
  });


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readonly!,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: readonly == true ? null : const OutlineInputBorder(),
      ),
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
