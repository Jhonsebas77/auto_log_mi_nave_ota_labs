import 'package:auto_log_mi_nave_ota_labs/core/constants/constants.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isVehicleRestrictedToday', () {
    DateTime monday = DateTime.utc(2026, 8, 3);
    DateTime tuesday = DateTime.utc(2026, 8, 4);
    DateTime wednesday = DateTime.utc(2026, 8, 5);
    DateTime thursday = DateTime.utc(2026, 8, 6);
    DateTime friday = DateTime.utc(2026, 8, 7);
    DateTime saturday = DateTime.utc(2026, 8, 8);
    DateTime sunday = DateTime.utc(2026, 8, 9);

    void expectRestrictedOnlyFor(DateTime day, List<int> restrictedDigits) {
      for (int digit = 0; digit <= 9; digit++) {
        LicensePlateRestrictionResult result = isVehicleRestrictedToday(
          licensePlate: 'ABC$digit',
          today: day,
        );
        bool shouldRestrict = restrictedDigits.contains(digit);
        expect(
          result.isRestrictedToday,
          shouldRestrict,
          reason:
              'dígito $digit ${shouldRestrict ? "debería" : "no debería"} '
              'restringir ese día',
        );
      }
    }

    // Fuente de verdad: picoYPlacaMedellin2026S2 en
    // lib/core/constants/license_plate_restriction_medellin.dart. Cada día cubre
    // dos dígitos puntuales; los 5 días cubren 0..9 exactamente una vez.
    test('Lunes restringe solo los dígitos 5 y 8', () {
      expectRestrictedOnlyFor(monday, <int>[5, 8]);
    });

    test('Martes restringe solo los dígitos 1 y 4', () {
      expectRestrictedOnlyFor(tuesday, <int>[1, 4]);
    });

    test('Miércoles restringe solo los dígitos 0 y 2', () {
      expectRestrictedOnlyFor(wednesday, <int>[0, 2]);
    });

    test('Jueves restringe solo los dígitos 3 y 6', () {
      expectRestrictedOnlyFor(thursday, <int>[3, 6]);
    });

    test('Viernes restringe solo los dígitos 7 y 9', () {
      expectRestrictedOnlyFor(friday, <int>[7, 9]);
    });

    test('Fin de semana nunca restringe', () {
      for (DateTime day in <DateTime>[saturday, sunday]) {
        for (int digit = 0; digit <= 9; digit++) {
          expect(
            isVehicleRestrictedToday(
              licensePlate: 'ABC$digit',
              today: day,
            ).isRestrictedToday,
            isFalse,
          );
        }
      }
    });

    test('scheduleIsStale es true después de effectiveTo', () {
      DateTime farFuture = DateTime.utc(2027, 6, 1);
      LicensePlateRestrictionResult result = isVehicleRestrictedToday(
        licensePlate: 'ABC0',
        today: farFuture,
      );
      expect(result.scheduleIsStale, isTrue);
    });

    test('scheduleIsStale es false dentro del período vigente', () {
      LicensePlateRestrictionResult result = isVehicleRestrictedToday(
        licensePlate: 'ABC0',
        today: monday,
      );
      expect(result.scheduleIsStale, isFalse);
    });
  });
}
