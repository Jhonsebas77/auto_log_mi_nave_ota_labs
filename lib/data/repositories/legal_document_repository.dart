part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories;

abstract class LegalDocumentRepository {
  Future<List<LegalDocument>> getByVehicle(String vehicleId);
  Future<LegalDocument> create(LegalDocument document);
  Future<LegalDocument> update(LegalDocument document);
  Future<void> delete(String id);

  /// Todos los documentos de todos los vehículos (para reconciliar
  /// notificaciones al iniciar la app).
  Future<List<LegalDocument>> getAll();
}
