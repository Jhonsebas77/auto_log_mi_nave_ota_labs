import 'package:auto_log_mi_nave_ota_labs/core/constants/constants.dart';
import 'package:auto_log_mi_nave_ota_labs/core/enums/enums.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

MaintenanceRecord _record({required String category, required int odometer}) =>
    MaintenanceRecord(
      id: 'id-$category-$odometer',
      vehicleId: 'v1',
      serviceType: MaintenanceServiceType.preventivo,
      category: category,
      date: DateTime(2026, 1, 1),
      odometer: odometer,
      totalCost: 10000,
    );

void main() {
  group('calculateLifespans', () {
    test('sin registros, progreso se calcula desde odómetro 0', () {
      List<LifespanStatus> result = calculateLifespans(
        records: const <MaintenanceRecord>[],
        currentOdometer: 2500,
      );
      LifespanStatus oil = result.firstWhere(
        (LifespanStatus s) => s.category == MaintenanceLifespanCategory.oil,
      );
      expect(oil.progress, 2500 / kOilChangeIntervalKm);
    });

    test(
      'encuentra el registro más reciente por categoría vía palabra clave',
      () {
        List<MaintenanceRecord> records = <MaintenanceRecord>[
          _record(category: 'Cambio de aceite', odometer: 10000),
          _record(category: 'Cambio de aceite', odometer: 15000),
          _record(category: 'Rotación de llantas', odometer: 5000),
        ];
        List<LifespanStatus> result = calculateLifespans(
          records: records,
          currentOdometer: 17500,
        );
        LifespanStatus oil = result.firstWhere(
          (LifespanStatus s) => s.category == MaintenanceLifespanCategory.oil,
        );
        LifespanStatus tires = result.firstWhere(
          (LifespanStatus s) => s.category == MaintenanceLifespanCategory.tires,
        );
        expect(oil.lastServiceOdometer, 15000);
        expect(oil.progress, (17500 - 15000) / kOilChangeIntervalKm);
        expect(tires.lastServiceOdometer, 5000);
      },
    );

    test(
      'categoría sin match queda en el bucket "otro" (progress desde 0)',
      () {
        List<MaintenanceRecord> records = <MaintenanceRecord>[
          _record(category: 'Alineación general', odometer: 8000),
        ];
        List<LifespanStatus> result = calculateLifespans(
          records: records,
          currentOdometer: 9000,
        );
        for (LifespanStatus s in result) {
          expect(s.lastServiceOdometer, 0);
        }
      },
    );

    test('progreso >= 1.0 indica vencido', () {
      List<MaintenanceRecord> records = <MaintenanceRecord>[
        _record(category: 'Cambio de aceite', odometer: 0),
      ];
      List<LifespanStatus> result = calculateLifespans(
        records: records,
        currentOdometer: kOilChangeIntervalKm + 1,
      );
      LifespanStatus oil = result.firstWhere(
        (LifespanStatus s) => s.category == MaintenanceLifespanCategory.oil,
      );
      expect(oil.progress, greaterThan(1.0));
    });
  });
}
