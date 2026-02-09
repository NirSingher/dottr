import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/platform_path.dart';
import '../models/template.dart';
import '../services/template_service.dart';

final templateServiceProvider = Provider<TemplateService>((ref) {
  return TemplateService();
});

final templateProvider =
    AsyncNotifierProvider<TemplateNotifier, List<EntryTemplate>>(
        TemplateNotifier.new);

class TemplateNotifier extends AsyncNotifier<List<EntryTemplate>> {
  late TemplateService _templateService;

  @override
  Future<List<EntryTemplate>> build() async {
    _templateService = ref.read(templateServiceProvider);
    if (kIsWeb) return [];
    final journalPath = await getJournalBasePath();
    await _templateService.initialize(journalPath);
    return _templateService.loadTemplates();
  }

  Future<void> addTemplate(EntryTemplate template) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, template];
    await _templateService.saveTemplates(updated);
    state = AsyncData(updated);
  }

  Future<void> updateTemplate(int index, EntryTemplate template) async {
    final current = state.valueOrNull ?? [];
    final updated = List<EntryTemplate>.from(current);
    updated[index] = template;
    await _templateService.saveTemplates(updated);
    state = AsyncData(updated);
  }

  Future<void> deleteTemplate(int index) async {
    final current = state.valueOrNull ?? [];
    final updated = List<EntryTemplate>.from(current);
    updated.removeAt(index);
    await _templateService.saveTemplates(updated);
    state = AsyncData(updated);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.valueOrNull ?? [];
    final updated = List<EntryTemplate>.from(current);
    if (newIndex > oldIndex) newIndex--;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    await _templateService.saveTemplates(updated);
    state = AsyncData(updated);
  }
}
