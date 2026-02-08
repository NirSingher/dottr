import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/brutalist_components.dart';
import '../../core/theme/dottl_theme.dart';
import '../../providers/entries_provider.dart';

class ViewerScreen extends ConsumerWidget {
  final String filePath;

  const ViewerScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final fileService = ref.read(fileServiceProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/editor?path=${Uri.encodeComponent(filePath)}');
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: FutureBuilder(
        future: fileService.readEntry(filePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final entry = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meta row
                Row(
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(entry.date),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                    if (entry.time != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        entry.time!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  entry.title.isEmpty ? 'Untitled' : entry.title,
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: 12),

                // Properties
                if (entry.mood != null || entry.location != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (entry.mood != null)
                        BrutalistChip(label: entry.mood!),
                      if (entry.location != null)
                        BrutalistChip(
                          label: '📍 ${entry.location}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Tags
                if (entry.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entry.tags
                        .map((tag) => BrutalistChip(label: '#$tag'))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                const Divider(),
                const SizedBox(height: 16),

                // Rendered markdown body
                MarkdownBody(
                  data: entry.body,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                    h1: theme.textTheme.headlineLarge,
                    h2: theme.textTheme.headlineMedium,
                    h3: theme.textTheme.titleLarge,
                    code: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      backgroundColor:
                          theme.colorScheme.outlineVariant.withAlpha(50),
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(
                        DottrTheme.cardRadius,
                      ),
                    ),
                    blockquotePadding: const EdgeInsets.only(left: 16),
                    blockquoteDecoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: theme.colorScheme.secondary,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(entriesProvider.notifier).deleteEntry(filePath);
      if (context.mounted) context.pop();
    }
  }
}
