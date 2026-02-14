import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/brutalist_components.dart';
import '../../models/entry.dart';
import '../../models/template.dart';
import '../../providers/editor_provider.dart';
import '../../providers/entries_provider.dart';
import '../../providers/template_provider.dart';
import 'widgets/markdown_field.dart';
import 'widgets/properties_form.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String? filePath;
  final String? templateId;
  final String? defaultJournal;

  const EditorScreen({
    super.key,
    this.filePath,
    this.templateId,
    this.defaultJournal,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  bool _showProperties = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntry();
    });
  }

  Future<void> _loadEntry() async {
    final editor = ref.read(editorProvider.notifier);
    if (widget.filePath != null) {
      final fileService = ref.read(fileServiceProvider);
      final entry = await fileService.readEntry(widget.filePath!);
      editor.loadEntry(entry);
      _titleController.text = entry.title;
      _bodyController.text = entry.body;
    } else if (widget.templateId != null) {
      _applyTemplate(editor, widget.templateId!);
    } else {
      editor.createNew(defaultJournal: widget.defaultJournal);
    }
  }

  void _applyTemplate(EditorNotifier editor, String templateId) {
    final templates = ref.read(templateProvider).valueOrNull ?? [];
    final matches = templates.where((t) => t.id == templateId);
    final EntryTemplate? template = matches.isEmpty ? null : matches.first;
    if (template == null) {
      editor.createNew();
      return;
    }
    final now = DateTime.now();
    editor.loadEntry(
      Entry(
        title: '',
        date: now,
        createdAt: now,
        updatedAt: now,
        tags: template.tags,
        mood: template.mood,
        customProperties: Map.from(template.customProperties),
        body: template.body,
      ),
    );
    editor.markDirty();
    _bodyController.text = template.body;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editorState = ref.watch(editorProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(editorProvider.notifier).save();
            context.pop();
          },
        ),
        title: Text(
          widget.filePath != null ? 'Edit' : 'New Entry',
        ),
        actions: [
          if (editorState.isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (editorState.isDirty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BrutalistButton(
                label: 'Save',
                compact: true,
                onPressed: () => ref.read(editorProvider.notifier).save(),
              ),
            ),
          IconButton(
            icon: Icon(
              _showProperties
                  ? Icons.expand_less
                  : Icons.tune,
            ),
            onPressed: () {
              setState(() => _showProperties = !_showProperties);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _titleController,
              onChanged: (v) =>
                  ref.read(editorProvider.notifier).updateTitle(v),
              style: theme.textTheme.headlineMedium,
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(80),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),

          // Properties panel (collapsible)
          if (_showProperties) ...[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: PropertiesForm(),
              ),
            ),
          ],

          const Divider(height: 1),

          // Body field
          Expanded(
            child: MarkdownField(
              controller: _bodyController,
              onChanged: (v) =>
                  ref.read(editorProvider.notifier).updateBody(v),
            ),
          ),
        ],
      ),
    );
  }
}
