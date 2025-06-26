import 'package:flutter/material.dart';

class ProfileDropdown extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final List<String> options;
  final IconData? icon;
  final bool isEditing;
  final String? Function(String?)? validator;

  const ProfileDropdown({
    super.key,
    required this.controller,
    required this.label,
    required this.options,
    this.icon,
    required this.isEditing,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: !isEditing,
          fillColor: Colors.grey[200],
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: isEditing
            ? (String? newValue) {
          if (newValue != null) {
            controller.text = newValue;
          }
        }
            : null,
        validator: validator,
      ),
    );
  }
}