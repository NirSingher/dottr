import 'package:flutter/material.dart';
import 'dottl_theme.dart';

class BrutalistCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onTap;

  const BrutalistCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final cardColor = color ?? theme.colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(
            color: theme.colorScheme.outline,
            width: DottrTheme.borderWidth,
          ),
          borderRadius: BorderRadius.circular(DottrTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              offset: const Offset(
                DottrTheme.shadowOffset,
                DottrTheme.shadowOffset,
              ),
              blurRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class BrutalistButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;
  final bool compact;

  const BrutalistButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final bgColor = color ?? theme.colorScheme.secondary;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 20,
          vertical: compact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: theme.colorScheme.outline,
            width: DottrTheme.borderWidth,
          ),
          borderRadius: BorderRadius.circular(DottrTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 16 : 20, color: theme.colorScheme.onSecondary),
              SizedBox(width: compact ? 6 : 8),
            ],
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: compact ? 13 : 15,
                color: theme.colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrutalistChip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BrutalistChip({
    super.key,
    required this.label,
    this.color,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color ?? theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(DottrTheme.cardRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium,
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BrutalistTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final int? maxLines;
  final bool monospace;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  const BrutalistTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.monospace = false,
    this.onChanged,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          textInputAction: textInputAction,
          style: monospace
              ? theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                )
              : theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ),
      ],
    );
  }
}

class BrutalistFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const BrutalistFAB({
    super.key,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon, size: 28),
    );
  }
}

class SyncStatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const SyncStatusDot({
    super.key,
    required this.color,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
    );
  }
}
