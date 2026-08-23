part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Mirrors the `legal_documents` table in claude/tech_spec.md.
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
  });
  final String id;
  final String vehicleId;
  final DocumentType documentType;
  final DateTime? issueDate;
  final DateTime expirationDate;
  final double? cost;
  final String? entityName;
  final String? documentUrl;
  final String? notes;

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
  );
}
