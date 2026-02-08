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

  const EditorState({
    this.entry,
    this.isDirty = false,
    this.isSaving = false,
  });

  EditorState copyWith({
    Entry? entry,
    bool? isDirty,
    bool? isSaving,
  }) {
    return EditorState(
      entry: entry ?? this.entry,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class EditorNotifier extends Notifier<EditorState> {
  final _debouncer = Debouncer(delay: Constants.autoSaveDelay);

  @override
  EditorState build() {
    ref.onDispose(() {
      _debouncer.cancel();
    });
    return const EditorState();
  }

  void loadEntry(Entry entry) {
    state = EditorState(entry: entry);
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
    state = state.copyWith(
      entry: state.entry!.copyWith(body: body),
      isDirty: true,
    );
    _scheduleAutoSave();
  }

  void updateTags(List<String> tags) {
    if (state.entry == null) return;
    state = state.copyWith(
      entry: state.entry!.copyWith(tags: tags),
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
