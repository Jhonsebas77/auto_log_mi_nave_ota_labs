part of com.auto_log_mi_nave_ota_labs.app.core.providers;

// ignore: always_specify_types
final picoYPlacaTodayProvider =
    Provider.family<LicensePlateRestrictionResult, String>(
      (Ref ref, String licensePlate) => isVehicleRestrictedToday(
        licensePlate: licensePlate,
        today: DateTime.now(),
        schedule: picoYPlacaMedellin2026S2,
      ),
    );
