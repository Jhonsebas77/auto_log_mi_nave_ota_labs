part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories.supabase;

class SupabaseFuelLogRepository implements FuelLogRepository {
  /// Ver el comentario equivalente en `SupabaseVehicleRepository`: todas las
  /// tablas de la app viven en el schema `auto_log`, no en `public` — debe
  /// estar en la lista de "Exposed schemas" del proyecto (ya debería estarlo
  /// desde la migración de vehicles). Ver `supabase/sql/0003_fuel_logs.sql`.
  SupabaseQuerySchema get _schema => Supabase.instance.client.schema(
    'auto_log',
  );

  @override
  Future<List<FuelLog>> getByVehicle(String vehicleId) async {
    // El orden ascendente por fecha es requerido: calculateFuelMetrics()
    // asume esta ordenación para calcular km/gal entre pares consecutivos
    // de tanque lleno (mismo comportamiento que ya garantiza
    // MockFuelLogRepository.getByVehicle).
    List<Map<String, dynamic>> rows = await _schema
        .from('fuel_logs')
        .select()
        .eq('vehicle_id', vehicleId)
        .order('date');
    return rows.map(FuelLog.fromJson).toList(growable: false);
  }

  @override
  Future<FuelLog> create(FuelLog log) async {
    // A diferencia de Vehicle.toJson, FuelLog.toJson() no tiene ninguna
    // columna controlada por la DB que haya que remover (no hay
    // updated_at/trigger en fuel_logs) — se manda tal cual.
    Map<String, dynamic> row = await _schema
        .from('fuel_logs')
        .insert(log.toJson())
        .select()
        .single();
    return FuelLog.fromJson(row);
  }

  @override
  Future<void> delete(String id) async {
    await _schema.from('fuel_logs').delete().eq('id', id);
  }
}
