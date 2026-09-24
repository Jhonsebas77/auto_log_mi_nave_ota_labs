import 'package:auto_log_mi_nave_ota_labs/core/data/repositories/repositories.dart';
import 'package:auto_log_mi_nave_ota_labs/core/enums/enums.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/services/services.dart';

/// Fakes usados en widget tests para evitar tocar plugins nativos
/// (flutter_local_notifications) que no tienen implementación de plataforma
/// disponible en el entorno de test.
///
/// También registra cada llamada (en orden) en [calls], [scheduled] y
/// [cancelledIds] para que los tests de `NotificationReconciler` puedan
/// verificar qué se agendó/canceló y en qué orden.
class FakeNotificationService implements NotificationService {
  final List<String> calls = <String>[];
  final List<ScheduledReminder> scheduled = <ScheduledReminder>[];
  final List<int> cancelledIds = <int>[];
  int cancelAllCount = 0;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleAt(ScheduledReminder reminder) async {
    calls.add('scheduleAt:${reminder.id}');
    scheduled.add(reminder);
  }

  @override
  Future<void> cancel(int id) async {
    calls.add('cancel:$id');
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    calls.add('cancelAll');
    cancelAllCount++;
  }
}

/// Fixture de test: implementación en memoria de [LegalDocumentRepository].
/// Vive acá (junto a los demás fakes) porque hoy solo la usan tests de
/// unidad de `NotificationReconciler`.
class FakeLegalDocumentRepository implements LegalDocumentRepository {
  FakeLegalDocumentRepository({List<LegalDocument>? seed})
    : _documents = <LegalDocument>[...?seed];

  final List<LegalDocument> _documents;

  @override
  Future<List<LegalDocument>> getByVehicle(String vehicleId) async =>
      _documents
          .where((LegalDocument d) => d.vehicleId == vehicleId)
          .toList(growable: false);

  @override
  Future<LegalDocument> create(LegalDocument document) async {
    _documents.add(document);
    return document;
  }

  @override
  Future<LegalDocument> update(LegalDocument document) async {
    int index = _documents.indexWhere((LegalDocument d) => d.id == document.id);
    if (index == -1) throw StateError('LegalDocument ${document.id} not found');
    _documents[index] = document;
    return document;
  }

  @override
  Future<void> delete(String id) async {
    _documents.removeWhere((LegalDocument d) => d.id == id);
  }

  @override
  Future<List<LegalDocument>> getAll() async =>
      _documents.toList(growable: false);
}

/// Construye un [LegalDocument] con valores por defecto razonables, para no
/// repetir los campos requeridos en cada test.
LegalDocument fakeLegalDocument({
  required DateTime expirationDate,
  String id = 'doc-1',
  String vehicleId = 'v1',
  DocumentType documentType = DocumentType.soat,
  DateTime? issueDate,
  double? cost,
  String? entityName,
  String? documentUrl,
  String? notes,
  String? documentNumber,
}) => LegalDocument(
  id: id,
  vehicleId: vehicleId,
  documentType: documentType,
  expirationDate: expirationDate,
  issueDate: issueDate,
  cost: cost,
  entityName: entityName,
  documentUrl: documentUrl,
  notes: notes,
  documentNumber: documentNumber,
);
