import 'package:auto_log_mi_nave_ota_labs/core/data/repositories/repositories.dart';
import 'package:auto_log_mi_nave_ota_labs/core/enums/enums.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/providers/providers.dart';
import 'package:auto_log_mi_nave_ota_labs/ui/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simula que la tabla `maintenances` todavía no existe en Supabase.
class _UnavailableMaintenanceRepository implements MaintenanceRepository {
  int getByVehicleCalls = 0;

  @override
  Future<List<MaintenanceRecord>> getByVehicle(String vehicleId) async {
    getByVehicleCalls++;
    throw Exception('relation "auto_log.maintenances" does not exist');
  }

  @override
  Future<MaintenanceRecord> create(MaintenanceRecord record) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

/// Evita que `VehiclesNotifier.build()` toque Supabase/auth.
class _FakeVehiclesNotifier extends VehiclesNotifier {
  _FakeVehiclesNotifier(this._vehicle);
  final Vehicle _vehicle;

  @override
  Future<List<Vehicle>> build() async => <Vehicle>[_vehicle];
}

void main() {
  Vehicle vehicle = Vehicle(
    id: 'v1',
    userId: 'user-1',
    licensePlate: 'ABC123',
    brand: 'Mazda',
    model: 'CX-5',
    year: 2021,
    fuelType: FuelType.gasolinaCorriente,
    currentOdometer: 1000,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    color: 'Rojo',
  );

  testWidgets(
    'Taller muestra un estado de "no disponible" (sin FAB) cuando falla la '
    'carga de mantenimientos, y "Reintentar" vuelve a consultar',
    (WidgetTester tester) async {
      _UnavailableMaintenanceRepository repository =
          _UnavailableMaintenanceRepository();

      await tester.pumpWidget(
        ProviderScope(
          // `Override` no es parte de la API pública de riverpod 3.x.
          // ignore: always_specify_types
          overrides: [
            maintenanceRepositoryProvider.overrideWithValue(repository),
            selectedVehicleProvider.overrideWithValue(vehicle),
            vehiclesProvider.overrideWith(() => _FakeVehiclesNotifier(vehicle)),
          ],
          child: const MaterialApp(home: MaintenanceScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('El taller aún no está disponible.'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(
        repository.getByVehicleCalls,
        1,
        reason: 'sin reintentos automáticos',
      );

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(repository.getByVehicleCalls, 2);
      expect(find.text('El taller aún no está disponible.'), findsOneWidget);
    },
  );

  testWidgets(
    'Acciones oculta "Registrar Mantenimiento" mientras el módulo no está '
    'disponible, y lo muestra cuando sí',
    (WidgetTester tester) async {
      Future<void> pumpQuickActions(MaintenanceRepository repository) async {
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            // ignore: always_specify_types
            overrides: [
              maintenanceRepositoryProvider.overrideWithValue(repository),
              selectedVehicleProvider.overrideWithValue(vehicle),
              vehiclesProvider.overrideWith(
                () => _FakeVehiclesNotifier(vehicle),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: QuickActionsScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpQuickActions(_UnavailableMaintenanceRepository());
      expect(find.text('Registrar Tanqueo'), findsOneWidget);
      expect(find.text('Registrar Documento'), findsOneWidget);
      expect(find.text('Registrar Mantenimiento'), findsNothing);

      await pumpQuickActions(_AvailableMaintenanceRepository());
      expect(find.text('Registrar Mantenimiento'), findsOneWidget);
    },
  );
}

class _AvailableMaintenanceRepository implements MaintenanceRepository {
  @override
  Future<List<MaintenanceRecord>> getByVehicle(String vehicleId) async =>
      const <MaintenanceRecord>[];

  @override
  Future<MaintenanceRecord> create(MaintenanceRecord record) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}
