import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthHeader extends StatelessWidget {
  final DateTime date;

  const MonthHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DateFormat('MMMM yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: theme.colorScheme.onSurface.withAlpha(150),
        ),
      ),
    );
  }
}
