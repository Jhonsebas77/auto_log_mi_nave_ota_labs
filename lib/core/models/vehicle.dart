part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Mirrors the `vehicles` table in Supabase (ver
/// `supabase/sql/0001_vehicles.sql`).
///
/// `color`, `photoUrl`, `nickname` y `updatedAt` no estaban en el schema
/// original de `claude/tech_spec.md` — se agregaron a la tabla real en
/// `supabase/sql/0001_vehicles.sql` para que coincida con lo que la UI ya
/// usaba en la capa mock.
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
    required this.updatedAt,
    required this.color,
    this.photoUrl,
    this.nickname,
    this.tankCapacityGallons,
  });

  /// Arma un [Vehicle] a partir de una fila de la tabla `vehicles` de
  /// Supabase (columnas `snake_case`). Ver `supabase/sql/0001_vehicles.sql`.
  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    licensePlate: json['license_plate'] as String,
    brand: json['brand'] as String,
    model: json['model'] as String,
    year: json['year'] as int,
    fuelType: FuelTypeSql.fromSqlValue(json['fuel_type'] as String),
    currentOdometer: json['current_odometer'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    color: json['color'] as String,
    photoUrl: json['photo_url'] as String?,
    nickname: json['nickname'] as String?,
    tankCapacityGallons: (json['tank_capacity_gallons'] as num?)?.toDouble(),
  );
  final String id;
  final String userId;
  final String licensePlate;
  final String brand;
  final String model;
  final int year;
  final FuelType fuelType;
  final int currentOdometer;
  final DateTime createdAt;

  /// Fecha de la última modificación de cualquier campo. La mantiene el
  /// trigger `trg_vehicles_updated_at` en Supabase — nunca se envía desde el
  /// cliente en un `update()`, ver `SupabaseVehicleRepository`.
  final DateTime updatedAt;
  final String color;
  final String? photoUrl;

  /// Apodo opcional puesto por el usuario (ej. "La Nave"). Si es nulo o
  /// vacío, [displayName] usa marca/modelo/año.
  final String? nickname;

  /// Capacidad total del tanque, en galones. Opcional — sin este dato no se
  /// puede estimar autonomía, pero el rendimiento (km/gal) sigue
  /// calculándose igual a partir del historial de tanqueos.
  final double? tankCapacityGallons;

  /// [photoUrl], [nickname] y [tankCapacityGallons] son opcionales y usan el
  /// patrón centinela (`_unset`, definido en `models.dart`): no pasarlos
  /// conserva el valor actual, pero pasarlos explícitamente como `null` sí
  /// vacía el campo. Sin esto, `campo ?? this.campo` no puede distinguir "no
  /// pasado" de "pasado como null" y esos campos quedarían imposibles de
  /// vaciar desde la app (ej. borrar el apodo de un vehículo).
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
    DateTime? updatedAt,
    String? color,
    Object? photoUrl = _unset,
    Object? nickname = _unset,
    Object? tankCapacityGallons = _unset,
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
    updatedAt: updatedAt ?? this.updatedAt,
    color: color ?? this.color,
    photoUrl: identical(photoUrl, _unset) ? this.photoUrl : photoUrl as String?,
    nickname: identical(nickname, _unset) ? this.nickname : nickname as String?,
    tankCapacityGallons: identical(tankCapacityGallons, _unset)
        ? this.tankCapacityGallons
        : tankCapacityGallons as double?,
  );

  /// Representación completa de la fila (columnas `snake_case`). El
  /// repositorio de Supabase arma el payload de escritura a partir de esto,
  /// quitando las columnas que la propia DB controla (`updated_at`).
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'user_id': userId,
    'license_plate': licensePlate,
    'brand': brand,
    'model': model,
    'year': year,
    'fuel_type': fuelType.sqlValue,
    'current_odometer': currentOdometer,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'color': color,
    'photo_url': photoUrl,
    'nickname': nickname,
    'tank_capacity_gallons': tankCapacityGallons,
  };

  String get displayName => (nickname == null || nickname!.trim().isEmpty)
      ? '$brand $model $year'
      : nickname!.trim();
}
