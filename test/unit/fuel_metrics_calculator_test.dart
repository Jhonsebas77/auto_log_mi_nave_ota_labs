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
      // Solo el par (1000 full) -> (1500 full) genera punto; el parcial del
      // medio no abre ni cierra un tramo.
      expect(metrics.curve, hasLength(1));
      expect(metrics.curve.first.date, DateTime(2026, 1, 20));
    });

    test(
      'km/gal divide por todos los galones del tramo, incluidos los parciales',
      () {
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
            date: DateTime(2026, 1, 15),
            odometer: 1350,
            gallons: 3,
            totalCost: 30000,
            isFullTank: false,
          ),
          _log(
            date: DateTime(2026, 1, 20),
            odometer: 1540,
            gallons: 4,
            totalCost: 40000,
          ),
        ];
        FuelMetrics metrics = calculateFuelMetrics(logs);
        // 540 km / (5 + 3 + 4) gal = 45 km/gal. Con solo los galones del
        // lleno que cierra daría 540 / 4 = 135 (el bug).
        expect(metrics.curve, hasLength(1));
        expect(metrics.curve.first.kmPerGallon, 45);
        expect(metrics.averageKmPerGallon, 45);
      },
    );

    test('los galones del primer lleno no cuentan para el tramo siguiente', () {
      List<FuelLog> logs = <FuelLog>[
        _log(
          date: DateTime(2026, 1, 1),
          odometer: 1000,
          gallons: 10,
          totalCost: 100000,
        ),
        _log(
          date: DateTime(2026, 1, 10),
          odometer: 1400,
          gallons: 10,
          totalCost: 100000,
        ),
        _log(
          date: DateTime(2026, 1, 15),
          odometer: 1600,
          gallons: 2,
          totalCost: 20000,
          isFullTank: false,
        ),
        _log(
          date: DateTime(2026, 1, 20),
          odometer: 1900,
          gallons: 8,
          totalCost: 80000,
        ),
      ];
      FuelMetrics metrics = calculateFuelMetrics(logs);
      // Tramo 1: 400 km / 10 gal = 40. Tramo 2: 500 km / (2 + 8) gal = 50
      // (el acumulado se reinicia en cada lleno).
      expect(metrics.curve.map((FuelMetricsPoint p) => p.kmPerGallon), <double>[
        40,
        50,
      ]);
      expect(metrics.averageKmPerGallon, 45);
    });

    test('parciales antes del primer lleno se ignoran en la curva', () {
      List<FuelLog> logs = <FuelLog>[
        _log(
          date: DateTime(2026, 1, 1),
          odometer: 900,
          gallons: 3,
          totalCost: 30000,
          isFullTank: false,
        ),
        _log(
          date: DateTime(2026, 1, 5),
          odometer: 1000,
          gallons: 10,
          totalCost: 100000,
        ),
        _log(
          date: DateTime(2026, 1, 20),
          odometer: 1400,
          gallons: 10,
          totalCost: 100000,
        ),
      ];
      FuelMetrics metrics = calculateFuelMetrics(logs);
      // 400 km / 10 gal = 40: los 3 gal previos al primer lleno no tienen
      // un punto de partida conocido.
      expect(metrics.curve, hasLength(1));
      expect(metrics.curve.first.kmPerGallon, 40);
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

    test('currentMonthSpent solo suma los tanqueos del mes de referencia', () {
      List<FuelLog> logs = <FuelLog>[
        _log(
          date: DateTime(2026, 1, 15),
          odometer: 1000,
          gallons: 10,
          totalCost: 100000,
        ),
        _log(
          date: DateTime(2026, 2, 5),
          odometer: 1100,
          gallons: 5,
          totalCost: 60000,
        ),
        _log(
          date: DateTime(2026, 2, 20),
          odometer: 1200,
          gallons: 5,
          totalCost: 45000,
        ),
      ];
      FuelMetrics metrics = calculateFuelMetrics(
        logs,
        now: DateTime(2026, 2, 28),
      );
      expect(metrics.currentMonthSpent, 105000);
    });

    test('cuenta tanqueos (totales y del mes) y la distancia recorrida', () {
      List<FuelLog> logs = <FuelLog>[
        _log(
          date: DateTime(2026, 1, 15),
          odometer: 1000,
          gallons: 10,
          totalCost: 100000,
        ),
        _log(
          date: DateTime(2026, 2, 5),
          odometer: 1100,
          gallons: 5,
          totalCost: 60000,
          isFullTank: false,
        ),
        _log(
          date: DateTime(2026, 2, 20),
          odometer: 1350,
          gallons: 5,
          totalCost: 45000,
        ),
      ];
      FuelMetrics metrics = calculateFuelMetrics(
        logs,
        now: DateTime(2026, 2, 28),
      );
      expect(metrics.fillCount, 3);
      expect(metrics.currentMonthFillCount, 2);
      expect(metrics.totalDistanceKm, 350);
    });

    test('distancia negativa (Odómetro mal cargado) se reporta como 0', () {
      List<FuelLog> logs = <FuelLog>[
        _log(
          date: DateTime(2026, 1, 1),
          odometer: 2000,
          gallons: 10,
          totalCost: 100000,
        ),
        _log(
          date: DateTime(2026, 1, 10),
          odometer: 1500,
          gallons: 10,
          totalCost: 100000,
        ),
      ];
      FuelMetrics metrics = calculateFuelMetrics(logs);
      expect(metrics.totalDistanceKm, 0);
      expect(metrics.costPerKm, isNull);
    });
  });
}
