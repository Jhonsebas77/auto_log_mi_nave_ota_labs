part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories.supabase;

class SupabaseMaintenanceRepository implements MaintenanceRepository {
  /// Ver el comentario equivalente en `SupabaseVehicleRepository`: todas las
  /// tablas de la app viven en el schema `auto_log`, no en `public` — debe
  /// estar en la lista de "Exposed schemas" del proyecto (ya debería estarlo
  /// desde la migración de vehicles). Ver `supabase/sql/0008_maintenances.sql`.
  SupabaseQuerySchema get _schema =>
      Supabase.instance.client.schema('auto_log');

  @override
  Future<List<MaintenanceRecord>> getByVehicle(String vehicleId) async {
    // El orden descendente por fecha (más reciente primero) es el mismo que
    // ya garantiza MockMaintenanceRepository.getByVehicle (`b.date.compareTo
    // (a.date)`). `ascending` hay que pasarlo explícito: en postgrest-dart
    // 2.x el default de `.order()` es `ascending: false` (descendente), pero
    // depender de ese default silencioso invertiría el orden en cuanto
    // cambie la versión del paquete — igual que documenta el comentario
    // equivalente en `SupabaseFuelLogRepository`.
    List<Map<String, dynamic>> rows = await _schema
        .from('maintenances')
        .select()
        .eq('vehicle_id', vehicleId)
        .order('date', ascending: false);
    return rows.map(MaintenanceRecord.fromJson).toList(growable: false);
  }

  @override
  Future<MaintenanceRecord> create(MaintenanceRecord record) async {
    // Igual que FuelLog.toJson/LegalDocument.toJson,
    // MaintenanceRecord.toJson() no tiene ninguna columna controlada por la
    // DB que haya que remover (no hay updated_at/trigger en `maintenances`)
    // — se manda tal cual.
    Map<String, dynamic> row = await _schema
        .from('maintenances')
        .insert(record.toJson())
        .select()
        .single();
    return MaintenanceRecord.fromJson(row);
  }

  @override
  Future<void> delete(String id) async {
    await _schema.from('maintenances').delete().eq('id', id);
  }
}
