part of com.auto_log_mi_nave_ota_labs.app.core.providers;

const Logger _legalDocumentsLog = Logger('LegalDocumentProviders');

// ignore: always_specify_types
final legalDocumentsProvider = FutureProvider.autoDispose
    .family<List<LegalDocument>, String>((Ref ref, String vehicleId) async {
      try {
        return await ref
            .watch(legalDocumentRepositoryProvider)
            .getByVehicle(vehicleId);
      } catch (e) {
        _legalDocumentsLog.error('legalDocumentsProvider($vehicleId): $e');
        rethrow;
      }
    });

class LegalDocumentActions {
  LegalDocumentActions(this._ref);
  final Ref _ref;

  Future<void> create(LegalDocument document) async {
    LegalDocument created = await _ref
        .read(legalDocumentRepositoryProvider)
        .create(document);
    _ref.invalidate(legalDocumentsProvider(document.vehicleId));
    await _rescheduleReminders(created);
  }

  Future<void> update(LegalDocument document) async {
    LegalDocument updated = await _ref
        .read(legalDocumentRepositoryProvider)
        .update(document);
    _ref.invalidate(legalDocumentsProvider(document.vehicleId));
    await _rescheduleReminders(updated);
  }

  Future<void> delete(LegalDocument document) async {
    await _ref.read(legalDocumentRepositoryProvider).delete(document.id);
    _ref.invalidate(legalDocumentsProvider(document.vehicleId));
    // El documento ya se borró: si cancelar sus recordatorios falla, no se
    // propaga para que la UI no lo reporte como "no se pudo eliminar".
    try {
      await _ref
          .read(notificationReconcilerProvider)
          .cancelForDocument(document);
    } catch (e) {
      _legalDocumentsLog.error('cancelForDocument(${document.id}): $e');
    }
  }

  /// El documento ya se guardó: si reprogramar sus recordatorios falla, no se
  /// propaga para que la UI no lo reporte como "no se pudo guardar" (y el
  /// usuario no lo registre dos veces).
  Future<void> _rescheduleReminders(LegalDocument document) async {
    try {
      await _ref
          .read(notificationReconcilerProvider)
          .rescheduleForDocument(document, now: DateTime.now());
    } catch (e) {
      _legalDocumentsLog.error('rescheduleForDocument(${document.id}): $e');
    }
  }
}

final Provider<LegalDocumentActions> legalDocumentActionsProvider =
    Provider<LegalDocumentActions>(LegalDocumentActions.new);
