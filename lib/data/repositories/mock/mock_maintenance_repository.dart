part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories.mock;

class MockMaintenanceRepository implements MaintenanceRepository {
  MockMaintenanceRepository({List<MaintenanceRecord>? seed})
    : _records = <MaintenanceRecord>[...?seed];

  final List<MaintenanceRecord> _records;

  Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<MaintenanceRecord>> getByVehicle(String vehicleId) async {
    await _delay();
    List<MaintenanceRecord> result =
        _records
            .where((MaintenanceRecord r) => r.vehicleId == vehicleId)
            .toList()
          ..sort(
            (MaintenanceRecord a, MaintenanceRecord b) =>
                b.date.compareTo(a.date),
          );
    return result;
  }

  @override
  Future<MaintenanceRecord> create(MaintenanceRecord record) async {
    await _delay();
    MaintenanceRecord withId = record.id.isEmpty
        ? record.copyWith(id: generateId())
        : record;
    _records.add(withId);
    return withId;
  }

  @override
  Future<void> delete(String id) async {
    await _delay();
    _records.removeWhere((MaintenanceRecord r) => r.id == id);
  }
}
