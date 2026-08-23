part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Mirrors the `users` table in claude/tech_spec.md.
///
/// Deviation from tech_spec.md's DB default 'BOG': this app instance always
/// operates in Medellín, so the mock construction default here is 'MED'.
/// Do not change the real Postgres DEFAULT when Supabase is wired up later —
/// only this mock-layer default.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.createdAt,
    this.cityCode = 'MED',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: json['fullName'] as String,
    cityCode: json['cityCode'] as String? ?? 'MED',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
  final String id;
  final String email;
  final String fullName;
  final String cityCode;
  final DateTime createdAt;

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? cityCode,
    DateTime? createdAt,
  }) => AppUser(
    id: id ?? this.id,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    cityCode: cityCode ?? this.cityCode,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'email': email,
    'fullName': fullName,
    'cityCode': cityCode,
    'createdAt': createdAt.toIso8601String(),
  };
}
