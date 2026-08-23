import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

FuelLog _log({
  required DateTime date,
  required int odometer,
  required double gallons,
  required double totalCost,
  bool isFullTank = true,
}) => FuelLog(
  id: 'id-$odometer',
  vehicleId: 'v1',
  date: date,
  odometer: odometer,
  gallons: gallons,
  totalCost: totalCost,
  isFullTank: isFullTank,
);

void main() {
  group('calculateFuelMetrics', () {
    test('lista vacía retorna FuelMetrics.empty', () {
      FuelMetrics metrics = calculateFuelMetrics(<FuelLog>[]);
      expect(metrics.curve, isEmpty);
      expect(metrics.averageKmPerGallon, isNull);
      expect(metrics.costPerKm, isNull);
      expect(metrics.totalSpent, 0);
    });

    test(
      'un solo tanqueo no genera curva pero sí costo/km si hay distancia previa nula',
      () {
        List<FuelLog> logs = <FuelLog>[
          _log(
            date: DateTime(2026, 1, 1),
            odometer: 1000,
            gallons: 10,
            totalCost: 100000,
          ),
        ];
        FuelMetrics metrics = calculateFuelMetrics(logs);
        expect(metrics.curve, isEmpty);
        expect(metrics.averageKmPerGallon, isNull);
        expect(metrics.totalSpent, 100000);
      },
    );

    test('curva km/gal solo usa pares consecutivos de tanque lleno', () {
      List<FuelLog> logs = <FuelLog>[
        _log(
          date: DateTime(2026, 1, 1),
          odometer: 1000,
          gallons: 10,
          totalCost: 100000,
        ),
        _log(
          date: DateTime(2026, 1, 10),
          odometer: 1200,
          gallons: 5,
          totalCost: 50000,
          isFullTank: false,
        ),
        _log(
          date: DateTime(2026, 1, 20),
          odometer: 1500,
          gallons: 10,
          totalCost: 110000,
        ),
      ];
      FuelMetrics metrics = calculateFuelMetrics(logs);
      // Solo el par (1000 full) -> (1500 full) cuenta: 500 km / 10 gal = 50 km/gal.
      expect(metrics.curve, hasLength(1));
      expect(metrics.curve.first.kmPerGallon, 50);
      expect(metrics.averageKmPerGallon, 50);
    });

    test('costo/km usa todo el historial incluyendo tanqueos parciales', () {
      List<FuelLog> logs = <FuelLog>[
        _log(
          date: DateTime(2026, 1, 1),
          odometer: 1000,
          gallons: 10,
          totalCost: 100000,
        ),
        _log(
          date: DateTime(2026, 1, 10),
          odometer: 1200,
          gallons: 5,
          totalCost: 50000,
          isFullTank: false,
        ),
      ];
      FuelMetrics metrics = calculateFuelMetrics(logs);
      // distancia total 200 km, gasto total 150000 -> 750/km
      expect(metrics.costPerKm, 750);
      expect(metrics.totalSpent, 150000);
    });
  });
}
