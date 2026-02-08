import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../core/constants.dart';
import '../models/property_schema.dart';
import '../services/schema_service.dart';

final schemaServiceProvider = Provider<SchemaService>((ref) {
  return SchemaService();
});

final schemaProvider =
    AsyncNotifierProvider<SchemaNotifier, List<PropertySchema>>(
        SchemaNotifier.new);

class SchemaNotifier extends AsyncNotifier<List<PropertySchema>> {
  late SchemaService _schemaService;

  @override
  Future<List<PropertySchema>> build() async {
    _schemaService = ref.read(schemaServiceProvider);
    final dir = await getApplicationDocumentsDirectory();
    final journalPath = p.join(dir.path, Constants.journalDirName);
    await _schemaService.initialize(journalPath);
    return _schemaService.loadSchemas();
  }

  Future<void> addSchema(PropertySchema schema) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, schema];
    await _schemaService.saveSchemas(updated);
    state = AsyncData(updated);
  }

  Future<void> updateSchema(int index, PropertySchema schema) async {
    final current = state.valueOrNull ?? [];
    final updated = List<PropertySchema>.from(current);
    updated[index] = schema;
    await _schemaService.saveSchemas(updated);
    state = AsyncData(updated);
  }

  Future<void> deleteSchema(int index) async {
    final current = state.valueOrNull ?? [];
    final updated = List<PropertySchema>.from(current);
    updated.removeAt(index);
    await _schemaService.saveSchemas(updated);
    state = AsyncData(updated);
  }
}
