part of com.auto_log_mi_nave_ota_labs.app.services;

/// Simulación del escáner OCR mencionado en design_spec.md (Registrar
/// Documento / Agregar Vehículo). No hay reconocimiento óptico real: solo
/// un delay para imitar el procesamiento y un autocompletado plausible.
class OcrSimulationService {
  Future<VehicleOcrResult> scanVehicleRegistration() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    return const VehicleOcrResult(
      licensePlate: 'ABC123',
      brand: 'Chevrolet',
      model: 'Spark GT',
    );
  }

  Future<DocumentOcrResult> scanDocument(
    DocumentType type, {
    required DateTime now,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    return DocumentOcrResult(
      entityName: switch (type) {
        DocumentType.soat => 'Seguros Mundial',
        DocumentType.rtm => 'CDA Sabaneta',
        DocumentType.impuestoVehicular => 'Gobernación de Antioquia',
        DocumentType.polizaTodoRiesgo => 'Sura',
        DocumentType.licenciaConduccion => 'RUNT',
        DocumentType.extintor => 'Ferretería El Tornillo',
      },
      expirationDate: now.add(const Duration(days: 365)),
    );
  }
}
