import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/dottr_theme.dart';
import '../../../models/template.dart';
import '../../../providers/template_provider.dart';

Future<EntryTemplate?> showTemplatePicker(BuildContext context) async {
  return showModalBottomSheet<EntryTemplate>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _TemplatePickerSheet(),
  );
}

class _TemplatePickerSheet extends ConsumerWidget {
  const _TemplatePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final templatesAsync = ref.watch(templateProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline,
                width: DottrTheme.borderWidth,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.muted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Start from template',
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Blank'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: templatesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (templates) {
                    if (templates.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No templates yet.\nCreate one in Settings > Templates.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.muted,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        final template = templates[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TemplateCard(
                            template: template,
                            onTap: () => Navigator.pop(context, template),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final EntryTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(DottrTheme.cardRadius),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: template.color,
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(DottrTheme.cardRadius),
              ),
              child: Icon(
                template.icon,
                size: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (template.body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      template.body.split('\n').first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
