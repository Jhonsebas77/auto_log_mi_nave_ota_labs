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
  /// [notes] son opcionales y usan el patrón centinela (`_unset`, definido en
  /// `models.dart`): no pasarlos conserva el valor actual, pero pasarlos
  /// explícitamente como `null` sí vacía el campo. Sin esto,
  /// `campo ?? this.campo` no puede distinguir "no pasado" de "pasado como
  /// null" y esos campos quedarían imposibles de vaciar desde la app (ver
  /// `DocumentFormSection._submit`, que depende de este comportamiento).
  LegalDocument copyWith({
    String? id,
    String? vehicleId,
    DocumentType? documentType,
    DateTime? expirationDate,
    Object? issueDate = _unset,
    Object? cost = _unset,
    Object? entityName = _unset,
    Object? documentUrl = _unset,
    Object? notes = _unset,
    Object? documentNumber = _unset,
  }) => LegalDocument(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    documentType: documentType ?? this.documentType,
    expirationDate: expirationDate ?? this.expirationDate,
    issueDate: identical(issueDate, _unset)
        ? this.issueDate
        : issueDate as DateTime?,
    cost: identical(cost, _unset) ? this.cost : cost as double?,
    entityName: identical(entityName, _unset)
        ? this.entityName
        : entityName as String?,
    documentUrl: identical(documentUrl, _unset)
        ? this.documentUrl
        : documentUrl as String?,
    notes: identical(notes, _unset) ? this.notes : notes as String?,
    documentNumber: identical(documentNumber, _unset)
        ? this.documentNumber
        : documentNumber as String?,
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
