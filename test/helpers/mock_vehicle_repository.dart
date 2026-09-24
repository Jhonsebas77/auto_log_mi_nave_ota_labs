import 'package:auto_log_mi_nave_ota_labs/core/data/repositories/repositories.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/utils/utils.dart';

/// Fixture de test: implementación en memoria de [VehicleRepository]. Vive en
/// `test/helpers/` porque solo la usa `mock_repositories_test.dart`; no hay
/// referencias en `lib/`.
class MockVehicleRepository implements VehicleRepository {
  MockVehicleRepository({List<Vehicle>? seed})
    : _vehicles = <Vehicle>[...?seed];

  final List<Vehicle> _vehicles;

  Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Vehicle>> getByUser(String userId) async {
    await _delay();
    return _vehicles
        .where((Vehicle v) => v.userId == userId)
        .toList(growable: false);
  }

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    await _delay();
    Vehicle withId = vehicle.id.isEmpty
        ? vehicle.copyWith(id: generateId())
        : vehicle;
    _vehicles.add(withId);
    return withId;
  }

  @override
  Future<Vehicle> update(Vehicle vehicle) async {
    await _delay();
    int index = _vehicles.indexWhere((Vehicle v) => v.id == vehicle.id);
    if (index == -1) throw StateError('Vehicle ${vehicle.id} not found');
    _vehicles[index] = vehicle;
    return vehicle;
  }

  @override
  Future<void> delete(String id) async {
    await _delay();
    _vehicles.removeWhere((Vehicle v) => v.id == id);
  }

  @override
  Future<Vehicle> bumpOdometerIfHigher(String vehicleId, int odometer) async {
    await _delay();
    int index = _vehicles.indexWhere((Vehicle v) => v.id == vehicleId);
    if (index == -1) throw StateError('Vehicle $vehicleId not found');
    Vehicle current = _vehicles[index];
    if (odometer > current.currentOdometer) {
      Vehicle updated = current.copyWith(currentOdometer: odometer);
      _vehicles[index] = updated;
      return updated;
    }
    return current;
  }
}
