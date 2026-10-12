import 'package:auto_log_mi_nave_ota_labs/core/enums/enums.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LegalDocument doc(String id, DocumentType type, DateTime expiration) =>
      LegalDocument(
        id: id,
        vehicleId: 'v1',
        documentType: type,
        expirationDate: expiration,
      );

  test('con un SOAT renovado devuelve el de vencimiento más lejano, sin '
      'importar el orden de entrada', () {
    LegalDocument oldSoat = doc('old', DocumentType.soat, DateTime(2025, 3));
    LegalDocument newSoat = doc('new', DocumentType.soat, DateTime(2026, 3));
    LegalDocument rtm = doc('rtm', DocumentType.rtm, DateTime(2026, 1));

    // Orden del repositorio: vencimiento ascendente.
    expect(
      latestDocumentByType(<LegalDocument>[oldSoat, rtm, newSoat]),
      <DocumentType, LegalDocument>{
        DocumentType.soat: newSoat,
        DocumentType.rtm: rtm,
      },
    );
    expect(
      latestDocumentByType(<LegalDocument>[
        newSoat,
        oldSoat,
      ])[DocumentType.soat],
      newSoat,
    );
  });

  test('sin documentos devuelve un mapa vacío', () {
    expect(latestDocumentByType(const <LegalDocument>[]), isEmpty);
  });
}
