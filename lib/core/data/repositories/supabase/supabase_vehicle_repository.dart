part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories.supabase;

class SupabaseVehicleRepository implements VehicleRepository {
  /// Todas las tablas de la app viven en el schema `auto_log`, no en
  /// `public` — debe estar en la lista de "Exposed schemas" del proyecto
  /// (Project Settings → API), si no toda consulta falla con "The schema
  /// must be one of the following: public". Ver `supabase/sql/0001_vehicles.sql`.
  SupabaseQuerySchema get _schema => Supabase.instance.client.schema(
    'auto_log',
  );

  /// Payload de escritura: igual a [Vehicle.toJson] pero sin `updated_at`,
  /// que siempre lo controla el trigger `trg_vehicles_updated_at` en la DB
  /// (ver `supabase/sql/0001_vehicles.sql`) — nunca se envía desde el
  /// cliente, ni en `create` ni en `update`.
  Map<String, dynamic> _writablePayload(Vehicle vehicle) =>
      vehicle.toJson()..remove('updated_at');

  @override
  Future<List<Vehicle>> getByUser(String userId) async {
    List<Map<String, dynamic>> rows = await _schema
        .from('vehicles')
        .select()
        .eq('user_id', userId);
    return rows.map(Vehicle.fromJson).toList(growable: false);
  }

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    Map<String, dynamic> row = await _schema
        .from('vehicles')
        .insert(_writablePayload(vehicle))
        .select()
        .single();
    return Vehicle.fromJson(row);
  }

  @override
  Future<Vehicle> update(Vehicle vehicle) async {
    Map<String, dynamic> row = await _schema
        .from('vehicles')
        .update(_writablePayload(vehicle))
        .eq('id', vehicle.id)
        .select()
        .single();
    return Vehicle.fromJson(row);
  }

  @override
  Future<void> delete(String id) async {
    await _schema.from('vehicles').delete().eq('id', id);
  }

  @override
  Future<Vehicle> bumpOdometerIfHigher(String vehicleId, int odometer) async {
    Map<String, dynamic> currentRow = await _schema
        .from('vehicles')
        .select()
        .eq('id', vehicleId)
        .single();
    Vehicle current = Vehicle.fromJson(currentRow);
    if (odometer <= current.currentOdometer) return current;

    Map<String, dynamic> updatedRow = await _schema
        .from('vehicles')
        .update(<String, dynamic>{'current_odometer': odometer})
        .eq('id', vehicleId)
        .select()
        .single();
    return Vehicle.fromJson(updatedRow);
  }
}
