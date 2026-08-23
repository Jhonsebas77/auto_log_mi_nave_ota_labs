part of com.auto_log_mi_nave_ota_labs.app.core.models;

class DocumentOcrResult {
  const DocumentOcrResult({
    required this.entityName,
    required this.expirationDate,
  });
  final String entityName;
  final DateTime expirationDate;
}
