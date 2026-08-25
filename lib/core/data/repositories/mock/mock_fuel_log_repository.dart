part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories.mock;

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
