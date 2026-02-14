import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/debouncer.dart';
import '../core/constants.dart';
import '../models/entry.dart';
import 'entries_provider.dart';

final editorProvider =
    NotifierProvider<EditorNotifier, EditorState>(EditorNotifier.new);

class EditorState {
  final Entry? entry;
  final bool isDirty;
  final bool isSaving;
  final Set<String> manualTags;
  final String? manualJournal;
  final String? inlineJournal;

  const EditorState({
    this.entry,
    this.isDirty = false,
    this.isSaving = false,
    this.manualTags = const {},
    this.manualJournal,
    this.inlineJournal,
  });

  String? get effectiveJournal => inlineJournal ?? manualJournal;

  EditorState copyWith({
    Entry? entry,
    bool? isDirty,
    bool? isSaving,
    Set<String>? manualTags,
    String? manualJournal,
    String? inlineJournal,
    bool clearManualJournal = false,
    bool clearInlineJournal = false,
  }) {
    return EditorState(
      entry: entry ?? this.entry,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      manualTags: manualTags ?? this.manualTags,
      manualJournal:
          clearManualJournal ? null : (manualJournal ?? this.manualJournal),
      inlineJournal:
          clearInlineJournal ? null : (inlineJournal ?? this.inlineJournal),
    );
  }
}

class EditorNotifier extends Notifier<EditorState> {
  static final _inlineTagPattern = RegExp(r'(?:^|\s)#(\w+)');
  static final _inlineJournalPattern =
      RegExp(r'(?:^|\s)(?:~\[([^\]]+)\]|~(\w+))');

  final _debouncer = Debouncer(delay: Constants.autoSaveDelay);

  @override
  EditorState build() {
    ref.onDispose(() {
      _debouncer.cancel();
    });
    return const EditorState();
  }

  static Set<String> extractInlineTags(String body) {
    return _inlineTagPattern
        .allMatches(body)
        .map((m) => m.group(1)!)
        .toSet();
  }

  /// Extract inline journal from body text. Last match wins.
  static String? extractInlineJournal(String body) {
    String? journal;
    for (final match in _inlineJournalPattern.allMatches(body)) {
      journal = match.group(1) ?? match.group(2);
    }
    return journal;
  }

  List<String> _mergeTags(Set<String> manual, Set<String> inline) {
    return {...manual, ...inline}.toList();
  }

  void loadEntry(Entry entry) {
    final inlineTags = extractInlineTags(entry.body);
    final manualTags = entry.tags.toSet().difference(inlineTags);
    final inlineJournal = extractInlineJournal(entry.body);
    // If the stored journal matches inline, it came from inline.
    // Otherwise it's a manual selection.
    final String? manualJournal;
    if (entry.journal != null && entry.journal != inlineJournal) {
      manualJournal = entry.journal;
    } else {
      manualJournal = null;
    }
    state = EditorState(
      entry: entry,
      manualTags: manualTags,
      manualJournal: manualJournal,
      inlineJournal: inlineJournal,
    );
  }

  void createNew({String? defaultJournal}) {
    final now = DateTime.now();
    state = EditorState(
      entry: Entry(
        title: '',
        date: now,
        createdAt: now,
        updatedAt: now,
        journal: defaultJournal,
      ),
      manualJournal: defaultJournal,
    );
  }

  void markDirty() {
    state = state.copyWith(isDirty: true);
  }

  void updateTitle(String title) {
    if (state.entry == null) return;
    state = state.copyWith(
      entry: state.entry!.copyWith(title: title),
      isDirty: true,
    );
    _scheduleAutoSave();
  }

  void updateBody(String body) {
    if (state.entry == null) return;
    final inlineTags = extractInlineTags(body);
    final merged = _mergeTags(state.manualTags, inlineTags);
    final inlineJournal = extractInlineJournal(body);
    final effectiveJournal = inlineJournal ?? state.manualJournal;
    final e = state.entry!;
    state = EditorState(
      entry: Entry(
        filePath: e.filePath,
        title: e.title,
        date: e.date,
        time: e.time,
        tags: merged,
        mood: e.mood,
        journal: effectiveJournal,
        location: e.location,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        customProperties: e.customProperties,
        body: body,
        hasConflict: e.hasConflict,
      ),
      isDirty: true,
      manualTags: state.manualTags,
      manualJournal: state.manualJournal,
      inlineJournal: inlineJournal,
    );
    _scheduleAutoSave();
  }

  void updateTags(List<String> tags) {
    if (state.entry == null) return;
    final manualTags = tags.toSet();
    final inlineTags = extractInlineTags(state.entry!.body);
    final merged = _mergeTags(manualTags, inlineTags);
    state = state.copyWith(
      entry: state.entry!.copyWith(tags: merged),
      manualTags: manualTags,
      isDirty: true,
    );
    _scheduleAutoSave();
  }

  void updateMood(String? mood) {
    if (state.entry == null) return;
    state = state.copyWith(
      entry: state.entry!.copyWith(mood: mood),
      isDirty: true,
    );
    _scheduleAutoSave();
  }

  void updateLocation(String? location) {
    if (state.entry == null) return;
    state = state.copyWith(
      entry: state.entry!.copyWith(location: location),
      isDirty: true,
    );
    _scheduleAutoSave();
  }

  void updateJournal(String? journal) {
    if (state.entry == null) return;
    final effective = state.inlineJournal ?? journal;
    final e = state.entry!;
    state = EditorState(
      entry: Entry(
        filePath: e.filePath,
        title: e.title,
        date: e.date,
        time: e.time,
        tags: e.tags,
        mood: e.mood,
        journal: effective,
        location: e.location,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        customProperties: e.customProperties,
        body: e.body,
        hasConflict: e.hasConflict,
      ),
      isDirty: true,
      manualTags: state.manualTags,
      manualJournal: journal,
      inlineJournal: state.inlineJournal,
    );
    _scheduleAutoSave();
  }

  void updateTime(String? time) {
    if (state.entry == null) return;
    state = state.copyWith(
      entry: state.entry!.copyWith(time: time),
      isDirty: true,
    );
    _scheduleAutoSave();
  }

  void updateCustomProperty(String key, dynamic value) {
    if (state.entry == null) return;
    final props = Map<String, dynamic>.from(state.entry!.customProperties);
    props[key] = value;
    state = state.copyWith(
      entry: state.entry!.copyWith(customProperties: props),
      isDirty: true,
    );
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _debouncer.call(() => save());
  }

  Future<void> save() async {
    if (state.entry == null || !state.isDirty) return;

    state = state.copyWith(isSaving: true);
    try {
      final filePath =
          await ref.read(entriesProvider.notifier).saveEntry(state.entry!);
      state = state.copyWith(
        entry: state.entry!.copyWith(filePath: filePath),
        isDirty: false,
        isSaving: false,
      );
    } catch (_) {
      state = state.copyWith(isSaving: false);
    }
  }

  void clear() {
    _debouncer.cancel();
    state = const EditorState();
  }
}
