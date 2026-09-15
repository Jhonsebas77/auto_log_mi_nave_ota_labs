part of com.auto_log_mi_nave_ota_labs.app.core.providers;

// ignore: always_specify_types
final legalDocumentsProvider =
    FutureProvider.family<List<LegalDocument>, String>(
      (Ref ref, String vehicleId) =>
          ref.watch(legalDocumentRepositoryProvider).getByVehicle(vehicleId),
    );

// ignore: always_specify_types
final documentStatusProvider = Provider.family<TrafficLightLevel, String>((
  Ref ref,
  String vehicleId,
) {
  List<LegalDocument> documents =
      ref.watch(legalDocumentsProvider(vehicleId)).value ??
      const <LegalDocument>[];
  return worstStatusLevel(documents, DateTime.now());
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
