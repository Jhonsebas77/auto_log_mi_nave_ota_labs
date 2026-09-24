import 'package:auto_log_mi_nave_ota_labs/core/data/repositories/repositories.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/utils/utils.dart';

/// Fixture de test: implementación en memoria de [FuelLogRepository]. Vive en
/// `test/helpers/` porque solo la usa `mock_repositories_test.dart`; no hay
/// referencias en `lib/`.
class MockFuelLogRepository implements FuelLogRepository {
  MockFuelLogRepository({List<FuelLog>? seed}) : _logs = <FuelLog>[...?seed];

  final List<FuelLog> _logs;

  Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<FuelLog>> getByVehicle(String vehicleId) async {
    await _delay();
    List<FuelLog> result =
        _logs.where((FuelLog l) => l.vehicleId == vehicleId).toList()
          ..sort((FuelLog a, FuelLog b) => a.date.compareTo(b.date));
    return result;
  }

  @override
  Future<FuelLog> create(FuelLog log) async {
    await _delay();
    FuelLog withId = log.id.isEmpty ? log.copyWith(id: generateId()) : log;
    _logs.add(withId);
    return withId;
  }

  @override
  Future<void> delete(String id) async {
    await _delay();
    _logs.removeWhere((FuelLog l) => l.id == id);
  }
}
