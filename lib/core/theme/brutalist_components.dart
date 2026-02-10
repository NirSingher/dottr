import 'package:flutter/material.dart';
import 'dottr_theme.dart';

class BrutalistCard extends StatefulWidget {
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
  State<BrutalistCard> createState() => _BrutalistCardState();
}

class _BrutalistCardState extends State<BrutalistCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final cardColor = widget.color ?? theme.colorScheme.surface;
    final interactive = widget.onTap != null;
    final pressed = interactive && _hovered;

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
      onExit: interactive ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: widget.padding ?? const EdgeInsets.all(16),
          transform: pressed
              ? Matrix4.translationValues(
                  DottrTheme.shadowOffset - 1, DottrTheme.shadowOffset - 1, 0)
              : Matrix4.identity(),
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
                offset: Offset(
                  pressed ? 1 : DottrTheme.shadowOffset,
                  pressed ? 1 : DottrTheme.shadowOffset,
                ),
                blurRadius: 0,
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class BrutalistButton extends StatefulWidget {
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
  State<BrutalistButton> createState() => _BrutalistButtonState();
}

class _BrutalistButtonState extends State<BrutalistButton> {
  bool _hovered = false;
  static const double _shadow = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final bgColor = widget.color ?? theme.colorScheme.secondary;
    final interactive = widget.onPressed != null;
    final pressed = interactive && _hovered;

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
      onExit: interactive ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 12 : 20,
            vertical: widget.compact ? 8 : 12,
          ),
          transform: pressed
              ? Matrix4.translationValues(_shadow - 1, _shadow - 1, 0)
              : Matrix4.identity(),
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
                offset: Offset(pressed ? 1 : _shadow, pressed ? 1 : _shadow),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: widget.compact ? 16 : 20, color: theme.colorScheme.onSecondary),
                SizedBox(width: widget.compact ? 6 : 8),
              ],
              Text(
                widget.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: widget.compact ? 13 : 15,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrutalistChip extends StatefulWidget {
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
  State<BrutalistChip> createState() => _BrutalistChipState();
}

class _BrutalistChipState extends State<BrutalistChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interactive = widget.onTap != null;
    final pressed = interactive && _hovered;
    final baseColor = widget.color ?? theme.colorScheme.surface;
    final bgColor = pressed
        ? Color.alphaBlend(
            theme.colorScheme.onSurface.withAlpha(20), baseColor)
        : baseColor;

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
      onExit: interactive ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: theme.colorScheme.outline,
              width: pressed ? DottrTheme.borderWidth : 1.5,
            ),
            borderRadius: BorderRadius.circular(DottrTheme.cardRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: theme.textTheme.labelMedium,
              ),
              if (widget.onDelete != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onDelete,
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
