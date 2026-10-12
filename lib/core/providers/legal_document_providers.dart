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
    await _ref
        .read(notificationReconcilerProvider)
        .rescheduleForDocument(created, now: DateTime.now());
  }

  Future<void> update(LegalDocument document) async {
    LegalDocument updated = await _ref
        .read(legalDocumentRepositoryProvider)
        .update(document);
    _ref.invalidate(legalDocumentsProvider(document.vehicleId));
    await _ref
        .read(notificationReconcilerProvider)
        .rescheduleForDocument(updated, now: DateTime.now());
  }

  Future<void> delete(LegalDocument document) async {
    await _ref.read(legalDocumentRepositoryProvider).delete(document.id);
    _ref.invalidate(legalDocumentsProvider(document.vehicleId));
    await _ref.read(notificationReconcilerProvider).cancelForDocument(document);
  }
}

final Provider<LegalDocumentActions> legalDocumentActionsProvider =
    Provider<LegalDocumentActions>(LegalDocumentActions.new);
