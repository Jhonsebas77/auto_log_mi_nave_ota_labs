part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories;

/// Único punto de swap a Supabase: cuando se conecte el backend real, solo
/// este archivo cambia (Mock*Repository -> Supabase*Repository); nada en
/// data/models ni en features/* referencia las implementaciones mock.
final Provider<SeedData> seedDataProvider = Provider<SeedData>(
  (Ref ref) => buildSeedData(DateTime.now()),
);

final Provider<VehicleRepository> vehicleRepositoryProvider =
    Provider<VehicleRepository>((Ref ref) => SupabaseVehicleRepository());

final Provider<LegalDocumentRepository> legalDocumentRepositoryProvider =
    Provider<LegalDocumentRepository>(
      (Ref ref) => SupabaseLegalDocumentRepository(),
    );

final Provider<FuelLogRepository> fuelLogRepositoryProvider =
    Provider<FuelLogRepository>((Ref ref) => SupabaseFuelLogRepository());

final Provider<MaintenanceRepository> maintenanceRepositoryProvider =
    Provider<MaintenanceRepository>((Ref ref) {
      SeedData seed = ref.watch(seedDataProvider);
      return MockMaintenanceRepository(seed: seed.maintenanceRecords);
    });
