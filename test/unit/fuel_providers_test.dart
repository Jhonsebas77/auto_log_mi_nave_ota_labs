import 'package:auto_log_mi_nave_ota_labs/core/data/repositories/repositories.dart';
import 'package:auto_log_mi_nave_ota_labs/core/enums/enums.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_fuel_log_repository.dart';
import '../helpers/mock_vehicle_repository.dart';

/// Evita que `VehiclesNotifier.build()` (que hace
/// `ref.watch(authControllerProvider)`) toque `Supabase.instance`, que no
/// está inicializado en un test de unidad puro.
class _FakeAuthController extends AuthController {
  _FakeAuthController(this._state);
  final AuthState _state;

  @override
  AuthState build() => _state;
}

/// Envuelve un [VehicleRepository] real (el mock en memoria) para contar
/// cuántas veces se llama cada método — así se puede verificar que
/// `ref.invalidate(...)` de verdad dispara un rebuild (una llamada nueva),
/// no solo que no truena.
class _CountingVehicleRepository implements VehicleRepository {
  _CountingVehicleRepository(this._inner);
  final VehicleRepository _inner;
  int bumpCalls = 0;
  int getByUserCalls = 0;

  @override
  Future<List<Vehicle>> getByUser(String userId) {
    getByUserCalls++;
    return _inner.getByUser(userId);
  }

  @override
  Future<Vehicle> create(Vehicle vehicle) => _inner.create(vehicle);

  @override
  Future<Vehicle> update(Vehicle vehicle) => _inner.update(vehicle);

  @override
  Future<void> delete(String id) => _inner.delete(id);

  @override
  Future<Vehicle> bumpOdometerIfHigher(String vehicleId, int odometer) {
    bumpCalls++;
    return _inner.bumpOdometerIfHigher(vehicleId, odometer);
  }
}

class _CountingFuelLogRepository implements FuelLogRepository {
  _CountingFuelLogRepository(this._inner);
  final FuelLogRepository _inner;
  int createCalls = 0;
  int getByVehicleCalls = 0;

  @override
  Future<List<FuelLog>> getByVehicle(String vehicleId) {
    getByVehicleCalls++;
    return _inner.getByVehicle(vehicleId);
  }

  @override
  Future<FuelLog> create(FuelLog log) {
    createCalls++;
    return _inner.create(log);
  }

  @override
  Future<void> delete(String id) => _inner.delete(id);
}

void main() {
  const String userId = 'user-1';
  const String vehicleId = 'v1';

  Vehicle vehicle({int odometer = 1000}) => Vehicle(
    id: vehicleId,
    userId: userId,
    licensePlate: 'ABC123',
    brand: 'Mazda',
    model: 'CX-5',
    year: 2021,
    fuelType: FuelType.gasolinaCorriente,
    currentOdometer: odometer,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    color: 'Rojo',
  );

  FuelLog fuelLog({int odometer = 1500}) => FuelLog(
    id: '',
    vehicleId: vehicleId,
    date: DateTime(2024, 6, 1),
    odometer: odometer,
    gallons: 8.5,
    totalCost: 120000,
  );

  AuthState authenticatedState() => AuthState.authenticated(
    AppUser(
      id: userId,
      email: 'test@example.com',
      fullName: 'Test User',
      createdAt: DateTime(2024, 1, 1),
    ),
  );

  late _CountingVehicleRepository vehicleRepo;
  late _CountingFuelLogRepository fuelLogRepo;
  late ProviderContainer container;

  setUp(() {
    vehicleRepo = _CountingVehicleRepository(
      MockVehicleRepository(seed: <Vehicle>[vehicle()]),
    );
    fuelLogRepo = _CountingFuelLogRepository(MockFuelLogRepository());
    container = ProviderContainer(
      // `Override` no es parte de la API pública de riverpod 3.x (no se
      // puede importar), así que la lista no puede llevar tipo explícito.
      // ignore: always_specify_types
      overrides: [
        vehicleRepositoryProvider.overrideWithValue(vehicleRepo),
        fuelLogRepositoryProvider.overrideWithValue(fuelLogRepo),
        authControllerProvider.overrideWith(
          () => _FakeAuthController(authenticatedState()),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  test(
    'FuelLogActions.create llama bumpOdometerIfHigher, invalida '
    'fuelLogsProvider(vehicleId) y parchea vehiclesProvider sin refetch',
    () async {
      // Fuerza el primer build de ambos providers antes de crear el
      // tanqueo, para tener una línea base de cuántas veces se llamó cada
      // repositorio.
      await container.read(vehiclesProvider.future);
      await container.read(fuelLogsProvider(vehicleId).future);
      expect(vehicleRepo.getByUserCalls, 1);
      expect(fuelLogRepo.getByVehicleCalls, 1);

      await container.read(fuelLogActionsProvider).create(fuelLog());

      expect(fuelLogRepo.createCalls, 1);
      expect(vehicleRepo.bumpCalls, 1);

      // fuelLogsProvider se invalidó: leerlo otra vez dispara un rebuild
      // real (una llamada nueva al repositorio).
      await container.read(fuelLogsProvider(vehicleId).future);
      expect(fuelLogRepo.getByVehicleCalls, 2);

      // vehiclesProvider NO se vuelve a pedir: se parchea con la fila que
      // devuelve bumpOdometerIfHigher.
      List<Vehicle> vehicles = await container.read(vehiclesProvider.future);
      expect(vehicleRepo.getByUserCalls, 1);
      expect(vehicles.single.currentOdometer, 1500);
    },
  );

  test(
    'FuelLogActions.delete solo invalida fuelLogsProvider(vehicleId), '
    'no vehiclesProvider',
    () async {
      FuelLog created = await container
          .read(fuelLogRepositoryProvider)
          .create(fuelLog());
      await container.read(fuelLogsProvider(vehicleId).future);
      await container.read(vehiclesProvider.future);
      expect(fuelLogRepo.getByVehicleCalls, 1);
      expect(vehicleRepo.getByUserCalls, 1);

      await container.read(fuelLogActionsProvider).delete(created);

      await container.read(fuelLogsProvider(vehicleId).future);
      expect(fuelLogRepo.getByVehicleCalls, 2);

      // vehiclesProvider no se invalida en delete(): sigue con el valor
      // cacheado, sin una llamada nueva al repositorio.
      await container.read(vehiclesProvider.future);
      expect(vehicleRepo.getByUserCalls, 1);
    },
  );
}
