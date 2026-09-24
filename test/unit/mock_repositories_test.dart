import 'package:auto_log_mi_nave_ota_labs/core/enums/enums.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_fuel_log_repository.dart';
import '../helpers/mock_vehicle_repository.dart';

Vehicle _vehicle({String id = '', int odometer = 1000}) => Vehicle(
  id: id,
  userId: 'u1',
  licensePlate: 'ABC123',
  brand: 'Mazda',
  model: 'CX-5',
  year: 2021,
  fuelType: FuelType.gasolinaCorriente,
  currentOdometer: odometer,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  color: 'Rojo',
);

void main() {
  group('MockVehicleRepository', () {
    test(
      'create() asigna id cuando viene vacío y getByUser() lo retorna',
      () async {
        MockVehicleRepository repo = MockVehicleRepository();
        Vehicle created = await repo.create(_vehicle());
        expect(created.id, isNotEmpty);
        List<Vehicle> vehicles = await repo.getByUser('u1');
        expect(vehicles, hasLength(1));
        expect(vehicles.first.id, created.id);
      },
    );

    test(
      'bumpOdometerIfHigher solo actualiza si el nuevo valor es mayor',
      () async {
        MockVehicleRepository repo = MockVehicleRepository();
        Vehicle created = await repo.create(_vehicle(odometer: 1000));
        Vehicle unchanged = await repo.bumpOdometerIfHigher(created.id, 500);
        expect(unchanged.currentOdometer, 1000);
        Vehicle updated = await repo.bumpOdometerIfHigher(created.id, 1500);
        expect(updated.currentOdometer, 1500);
      },
    );

    test('delete() remueve el vehículo', () async {
      MockVehicleRepository repo = MockVehicleRepository();
      Vehicle created = await repo.create(_vehicle());
      await repo.delete(created.id);
      expect(await repo.getByUser('u1'), isEmpty);
    });
  });

  group('MockFuelLogRepository', () {
    test('getByVehicle() retorna ordenado por fecha ascendente', () async {
      MockFuelLogRepository repo = MockFuelLogRepository();
      await repo.create(
        FuelLog(
          id: '',
          vehicleId: 'v1',
          date: DateTime(2026, 2, 1),
          odometer: 200,
          gallons: 5,
          totalCost: 50000,
        ),
      );
      await repo.create(
        FuelLog(
          id: '',
          vehicleId: 'v1',
          date: DateTime(2026, 1, 1),
          odometer: 100,
          gallons: 5,
          totalCost: 50000,
        ),
      );
      List<FuelLog> logs = await repo.getByVehicle('v1');
      expect(logs.first.odometer, 100);
      expect(logs.last.odometer, 200);
    });

    test('delete() remueve solo el tanqueo indicado', () async {
      MockFuelLogRepository repo = MockFuelLogRepository();
      FuelLog kept = await repo.create(
        FuelLog(
          id: '',
          vehicleId: 'v1',
          date: DateTime(2026, 1, 1),
          odometer: 100,
          gallons: 5,
          totalCost: 50000,
        ),
      );
      FuelLog removed = await repo.create(
        FuelLog(
          id: '',
          vehicleId: 'v1',
          date: DateTime(2026, 2, 1),
          odometer: 200,
          gallons: 5,
          totalCost: 50000,
        ),
      );
      await repo.delete(removed.id);
      List<FuelLog> logs = await repo.getByVehicle('v1');
      expect(logs, hasLength(1));
      expect(logs.single.id, kept.id);
    });
  });
}
