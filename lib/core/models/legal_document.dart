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

  /// [issueDate], [cost], [entityName], [documentUrl], [documentNumber] y
  /// [notes] son opcionales y se reciben envueltos en [ValueWrapper]: no
  /// pasarlos conserva el valor actual, pero pasar `const ValueWrapper(null)`
  /// sí vacía el campo. Sin esto, `campo ?? this.campo` no puede distinguir
  /// "no pasado" de "pasado como null" y esos campos quedarían imposibles de
  /// vaciar desde la app (ver `DocumentFormSection._submit`, que depende de
  /// este comportamiento).
  LegalDocument copyWith({
    String? id,
    String? vehicleId,
    DocumentType? documentType,
    DateTime? expirationDate,
    ValueWrapper<DateTime>? issueDate,
    ValueWrapper<double>? cost,
    ValueWrapper<String>? entityName,
    ValueWrapper<String>? documentUrl,
    ValueWrapper<String>? notes,
    ValueWrapper<String>? documentNumber,
  }) => LegalDocument(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    documentType: documentType ?? this.documentType,
    expirationDate: expirationDate ?? this.expirationDate,
    issueDate: issueDate == null ? this.issueDate : issueDate.value,
    cost: cost == null ? this.cost : cost.value,
    entityName: entityName == null ? this.entityName : entityName.value,
    documentUrl: documentUrl == null ? this.documentUrl : documentUrl.value,
    notes: notes == null ? this.notes : notes.value,
    documentNumber: documentNumber == null
        ? this.documentNumber
        : documentNumber.value,
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
