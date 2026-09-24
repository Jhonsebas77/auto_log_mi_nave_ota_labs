import 'package:auto_log_mi_nave_ota_labs/core/enums/enums.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  DateTime now = DateTime(2026, 1, 15);

  group('documentStatusLevel', () {
    test('vencido ayer -> danger', () {
      LegalDocument document = fakeLegalDocument(
        expirationDate: now.subtract(const Duration(days: 1)),
      );
      expect(documentStatusLevel(document, now), TrafficLightLevel.danger);
    });

    test('vence hoy (0 días) -> warning', () {
      LegalDocument document = fakeLegalDocument(expirationDate: now);
      expect(documentStatusLevel(document, now), TrafficLightLevel.warning);
    });

    test('vence en 15 días -> warning', () {
      LegalDocument document = fakeLegalDocument(
        expirationDate: now.add(const Duration(days: 15)),
      );
      expect(documentStatusLevel(document, now), TrafficLightLevel.warning);
    });

    test('vence en 16 días -> ok', () {
      LegalDocument document = fakeLegalDocument(
        expirationDate: now.add(const Duration(days: 16)),
      );
      expect(documentStatusLevel(document, now), TrafficLightLevel.ok);
    });
  });

  group('worstStatusLevel', () {
    LegalDocument okDoc = fakeLegalDocument(
      id: 'ok',
      expirationDate: now.add(const Duration(days: 30)),
    );
    LegalDocument warningDoc = fakeLegalDocument(
      id: 'warning',
      expirationDate: now.add(const Duration(days: 10)),
    );
    LegalDocument dangerDoc = fakeLegalDocument(
      id: 'danger',
      expirationDate: now.subtract(const Duration(days: 1)),
    );

    test('lista vacía -> ok', () {
      expect(
        worstStatusLevel(const <LegalDocument>[], now),
        TrafficLightLevel.ok,
      );
    });

    test('solo ok -> ok', () {
      expect(
        worstStatusLevel(<LegalDocument>[okDoc], now),
        TrafficLightLevel.ok,
      );
    });

    test('ok + warning -> warning', () {
      expect(
        worstStatusLevel(<LegalDocument>[okDoc, warningDoc], now),
        TrafficLightLevel.warning,
      );
    });

    test('warning + danger -> danger', () {
      expect(
        worstStatusLevel(<LegalDocument>[warningDoc, dangerDoc], now),
        TrafficLightLevel.danger,
      );
    });

    test('el mismo set en orden invertido da el mismo resultado', () {
      List<LegalDocument> ordered = <LegalDocument>[
        okDoc,
        warningDoc,
        dangerDoc,
      ];
      List<LegalDocument> reversed = ordered.reversed.toList();
      expect(
        worstStatusLevel(reversed, now),
        worstStatusLevel(ordered, now),
      );
      expect(worstStatusLevel(reversed, now), TrafficLightLevel.danger);
    });
  });
}
