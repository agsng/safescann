import 'package:flutter/material.dart';

class DropdownInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final List<String> options;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool enabled; // To control interaction based on _isEditing

  const DropdownInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.options,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IgnorePointer(
        ignoring: !enabled, // Disable interaction if not enabled
        child: DropdownButtonFormField<String>(
          value: options.contains(controller.text) ? controller.text : null,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[200], // Adjust fill color based on enabled state
          ),
          hint: Text('Select $labelText'),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: enabled ? (String? newValue) {
            if (newValue != null) {
              controller.text = newValue;
            }
          } : null,
          validator: validator,
        ),
      ),
    );
  }
}
