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

  const EditorState({
    this.entry,
    this.isDirty = false,
    this.isSaving = false,
    this.manualTags = const {},
  });

  EditorState copyWith({
    Entry? entry,
    bool? isDirty,
    bool? isSaving,
    Set<String>? manualTags,
  }) {
    return EditorState(
      entry: entry ?? this.entry,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      manualTags: manualTags ?? this.manualTags,
    );
  }
}

class EditorNotifier extends Notifier<EditorState> {
  static final _inlineTagPattern = RegExp(r'(?:^|\s)#(\w+)');

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

  List<String> _mergeTags(Set<String> manual, Set<String> inline) {
    return {...manual, ...inline}.toList();
  }

  void loadEntry(Entry entry) {
    final inlineTags = extractInlineTags(entry.body);
    final manualTags = entry.tags.toSet().difference(inlineTags);
    state = EditorState(entry: entry, manualTags: manualTags);
  }

  void createNew() {
    final now = DateTime.now();
    state = EditorState(
      entry: Entry(
        title: '',
        date: now,
        createdAt: now,
        updatedAt: now,
      ),
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
    state = state.copyWith(
      entry: state.entry!.copyWith(body: body, tags: merged),
      isDirty: true,
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
