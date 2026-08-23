part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Mirrors the `vehicles` table in claude/tech_spec.md.
///
/// `color`, `photoUrl` y `nickname` no existen en el schema real de
/// tech_spec.md — son una extensión de la capa mock/UI. Si se agrega
/// Supabase después, hay que sumar estas columnas a la tabla `vehicles` real.
class Vehicle {
  const Vehicle({
    required this.id,
    required this.userId,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.year,
    required this.fuelType,
    required this.currentOdometer,
    required this.createdAt,
    required this.color,
    this.photoUrl,
    this.nickname,
  });
  final String id;
  final String userId;
  final String licensePlate;
  final String brand;
  final String model;
  final int year;
  final FuelType fuelType;
  final int currentOdometer;
  final DateTime createdAt;
  final String color;
  final String? photoUrl;

  /// Apodo opcional puesto por el usuario (ej. "La Nave"). Si es nulo o
  /// vacío, [displayName] usa marca/modelo/año.
  final String? nickname;

  Vehicle copyWith({
    String? id,
    String? userId,
    String? licensePlate,
    String? brand,
    String? model,
    int? year,
    FuelType? fuelType,
    int? currentOdometer,
    DateTime? createdAt,
    String? color,
    String? photoUrl,
    String? nickname,
  }) => Vehicle(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    licensePlate: licensePlate ?? this.licensePlate,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    year: year ?? this.year,
    fuelType: fuelType ?? this.fuelType,
    currentOdometer: currentOdometer ?? this.currentOdometer,
    createdAt: createdAt ?? this.createdAt,
    color: color ?? this.color,
    photoUrl: photoUrl ?? this.photoUrl,
    nickname: nickname ?? this.nickname,
  );

  String get displayName => (nickname == null || nickname!.trim().isEmpty)
      ? '$brand $model $year'
      : nickname!.trim();
}
