import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap; // For DOB picker
  final String? notes; // For displaying extra notes below the field

  const TextInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.notes, // Initialize new field
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            onTap: onTap,
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              filled: true,
              fillColor: readOnly ? Colors.grey[200] : Colors.white,
            ),
          ),
          if (notes != null && notes!.isNotEmpty) // Display notes if present
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 12.0),
              child: Text(
                notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
