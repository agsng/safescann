import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool readOnly;
  final TextInputType keyboardType;
  final int maxLines;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: readOnly,
          fillColor: Colors.grey[200],
        ),
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onTap: onTap,
        validator: validator,
      ),
    );
  }
}