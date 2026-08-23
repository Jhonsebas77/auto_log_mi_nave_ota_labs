part of com.auto_log_mi_nave_ota_labs.app.core.models;

class VehicleOcrResult {
  const VehicleOcrResult({
    required this.licensePlate,
    required this.brand,
    required this.model,
  });
  final String licensePlate;
  final String brand;
  final String model;
}
