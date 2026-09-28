part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories.supabase;

class SupabaseLegalDocumentRepository implements LegalDocumentRepository {
  /// Ver el comentario equivalente en `SupabaseVehicleRepository`: todas las
  /// tablas de la app viven en el schema `auto_log`, no en `public`. Ver
  /// `supabase/sql/0004_legal_documents.sql`.
  SupabaseQuerySchema get _schema =>
      Supabase.instance.client.schema('auto_log');

  @override
  Future<List<LegalDocument>> getByVehicle(String vehicleId) async {
    List<Map<String, dynamic>> rows = await _schema
        .from('legal_documents')
        .select()
        .eq('vehicle_id', vehicleId)
        .order('expiration_date', ascending: true);
    return rows.map(LegalDocument.fromJson).toList(growable: false);
  }

  @override
  Future<List<LegalDocument>> getAll() async {
    // Sin filtro por vehicle_id: RLS ya limita las filas devueltas a los
    // vehículos del usuario autenticado (ver policy
    // legal_documents_select_own en supabase/sql/0004_legal_documents.sql).
    // Solo las columnas que usa la reconciliación de notificaciones (y las
    // obligatorias de `LegalDocument.fromJson`); el resto llega `null`.
    List<Map<String, dynamic>> rows = await _schema
        .from('legal_documents')
        .select('id, vehicle_id, document_type, expiration_date');
    return rows.map(LegalDocument.fromJson).toList(growable: false);
  }

  @override
  Future<LegalDocument> create(LegalDocument document) async {
    Map<String, dynamic> row = await _schema
        .from('legal_documents')
        .insert(document.toJson())
        .select()
        .single();
    return LegalDocument.fromJson(row);
  }

  @override
  Future<LegalDocument> update(LegalDocument document) async {
    Map<String, dynamic> row = await _schema
        .from('legal_documents')
        .update(document.toJson())
        .eq('id', document.id)
        .select()
        .single();
    return LegalDocument.fromJson(row);
  }

  @override
  Future<void> delete(String id) async {
    await _schema.from('legal_documents').delete().eq('id', id);
  }
}
