import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/brutalist_components.dart';
import '../../core/theme/dottl_theme.dart';
import '../../providers/entries_provider.dart';
import '../../services/import/day_one_import_service.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _importing = false;
  double _progress = 0;
  DayOneImportResult? _result;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Import')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Day One import
          BrutalistCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Day One', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Import entries from a Day One JSON export (.zip). Text only — photos are not imported.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.muted,
                  ),
                ),
                const SizedBox(height: 16),
                if (_importing) ...[
                  LinearProgressIndicator(value: _progress > 0 ? _progress : null),
                  const SizedBox(height: 8),
                  Text(
                    'Importing entries...',
                    style: theme.textTheme.bodySmall,
                  ),
                ] else ...[
                  Center(
                    child: BrutalistButton(
                      label: 'Select ZIP file',
                      icon: Icons.file_upload_outlined,
                      onPressed: _pickAndImport,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (_result != null) ...[
            const SizedBox(height: 16),
            BrutalistCard(
              color: colors.green.withAlpha(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Import Complete', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _ResultRow(label: 'Total entries', value: '${_result!.total}'),
                  _ResultRow(label: 'Imported', value: '${_result!.imported}'),
                  if (_result!.skipped > 0)
                    _ResultRow(label: 'Skipped', value: '${_result!.skipped}'),
                  if (_result!.errors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_result!.errors.length} error(s)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 16),
            BrutalistCard(
              color: theme.colorScheme.error.withAlpha(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Error', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    setState(() {
      _importing = true;
      _progress = 0;
      _result = null;
      _error = null;
    });

    try {
      final service = DayOneImportService();
      final (entries, importResult) = await service.parseZip(filePath);

      // Save each entry via the entries provider
      final notifier = ref.read(entriesProvider.notifier);
      for (int i = 0; i < entries.length; i++) {
        await notifier.saveEntry(entries[i]);
        setState(() {
          _progress = (i + 1) / entries.length;
        });
      }

      setState(() {
        _result = importResult;
        _importing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _importing = false;
      });
    }
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
