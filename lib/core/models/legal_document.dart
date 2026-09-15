part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Mirrors the `legal_documents` table in claude/tech_spec.md (más
/// `document_number`, agregado después — ver
/// `supabase/sql/0004_legal_documents.sql`).
class LegalDocument {
  const LegalDocument({
    required this.id,
    required this.vehicleId,
    required this.documentType,
    required this.expirationDate,
    this.issueDate,
    this.cost,
    this.entityName,
    this.documentUrl,
    this.notes,
    this.documentNumber,
  });

  /// Arma un [LegalDocument] a partir de una fila de la tabla
  /// `legal_documents` de Supabase (columnas `snake_case`). Ver
  /// `supabase/sql/0004_legal_documents.sql`.
  factory LegalDocument.fromJson(Map<String, dynamic> json) => LegalDocument(
    id: json['id'] as String,
    vehicleId: json['vehicle_id'] as String,
    documentType: DocumentTypeSql.fromSqlValue(json['document_type'] as String),
    issueDate: json['issue_date'] == null
        ? null
        : DateTime.parse(json['issue_date'] as String),
    expirationDate: DateTime.parse(json['expiration_date'] as String),
    cost: (json['cost'] as num?)?.toDouble(),
    entityName: json['entity_name'] as String?,
    documentUrl: json['document_url'] as String?,
    notes: json['notes'] as String?,
    documentNumber: json['document_number'] as String?,
  );
  final String id;
  final String vehicleId;
  final DocumentType documentType;
  final DateTime? issueDate;
  final DateTime expirationDate;
  final double? cost;
  final String? entityName;
  final String? documentUrl;
  final String? notes;
  final String? documentNumber;

  LegalDocument copyWith({
    String? id,
    String? vehicleId,
    DocumentType? documentType,
    DateTime? issueDate,
    DateTime? expirationDate,
    double? cost,
    String? entityName,
    String? documentUrl,
    String? notes,
    String? documentNumber,
  }) => LegalDocument(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    documentType: documentType ?? this.documentType,
    issueDate: issueDate ?? this.issueDate,
    expirationDate: expirationDate ?? this.expirationDate,
    cost: cost ?? this.cost,
    entityName: entityName ?? this.entityName,
    documentUrl: documentUrl ?? this.documentUrl,
    notes: notes ?? this.notes,
    documentNumber: documentNumber ?? this.documentNumber,
  );

  /// Representación completa de la fila (columnas `snake_case`), usada tal
  /// cual en `create` — no hay ninguna columna controlada por la DB que
  /// haya que quitar antes de un insert/update (a diferencia de
  /// `Vehicle.toJson`).
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'vehicle_id': vehicleId,
    'document_type': documentType.sqlValue,
    'issue_date': issueDate?.toIso8601String(),
    'expiration_date': expirationDate.toIso8601String(),
    'cost': cost,
    'entity_name': entityName,
    'document_url': documentUrl,
    'notes': notes,
    'document_number': documentNumber,
  };
}
