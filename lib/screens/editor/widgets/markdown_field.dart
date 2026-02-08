import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkdownField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const MarkdownField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 14,
        height: 1.7,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Write your thoughts...',
        hintStyle: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          color: theme.colorScheme.onSurface.withAlpha(80),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
