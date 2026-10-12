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

  test('separa el vigente de cada tipo del historial de renovaciones', () {
    LegalDocument oldSoat = doc('old', DocumentType.soat, DateTime(2025, 3));
    LegalDocument olderSoat = doc('older', DocumentType.soat, DateTime(2024));
    LegalDocument newSoat = doc('new', DocumentType.soat, DateTime(2026, 3));
    LegalDocument rtm = doc('rtm', DocumentType.rtm, DateTime(2026, 1));

    // Orden del repositorio: vencimiento ascendente.
    GarageDocumentGroup group = garageDocumentGroup(<LegalDocument>[
      olderSoat,
      oldSoat,
      rtm,
      newSoat,
    ], GarageTabGroup.vehiculo);

    // Vigentes del más urgente al más lejano; historial del más reciente al
    // más antiguo.
    expect(group.current, <LegalDocument>[rtm, newSoat]);
    expect(group.history, <LegalDocument>[oldSoat, olderSoat]);
    expect(group.missingTypes, <DocumentType>[
      DocumentType.polizaTodoRiesgo,
      DocumentType.extintor,
    ]);
  });

  test('solo incluye los tipos de la tab', () {
    LegalDocument soat = doc('soat', DocumentType.soat, DateTime(2026));
    LegalDocument license = doc(
      'lic',
      DocumentType.licenciaConduccion,
      DateTime(2030),
    );

    GarageDocumentGroup group = garageDocumentGroup(<LegalDocument>[
      soat,
      license,
    ], GarageTabGroup.conductor);

    expect(group.current, <LegalDocument>[license]);
    expect(group.history, isEmpty);
    expect(group.missingTypes, isEmpty);
  });

  test('el nivel ignora el historial y es null sin vigentes', () {
    DateTime now = DateTime(2026, 6, 1);
    LegalDocument expiredOld = doc('old', DocumentType.soat, DateTime(2025));
    LegalDocument current = doc('new', DocumentType.soat, DateTime(2027));

    expect(
      garageDocumentGroup(<LegalDocument>[
        expiredOld,
        current,
      ], GarageTabGroup.vehiculo).level(now),
      TrafficLightLevel.ok,
    );
    expect(
      garageDocumentGroup(
        const <LegalDocument>[],
        GarageTabGroup.impuestos,
      ).level(now),
      isNull,
    );
  });

  test('cada tipo de documento pertenece a exactamente una tab', () {
    expect(
      <DocumentType>[
        for (final GarageTabGroup g in GarageTabGroup.values)
          ...g.documentTypes,
      ]..sort((DocumentType a, DocumentType b) => a.index - b.index),
      DocumentType.values,
    );
  });
}
