part of com.auto_log_mi_nave_ota_labs.app.core.utils;

/// Nivel de semáforo de un documento según días restantes hasta el
/// vencimiento (o ya vencido).
TrafficLightLevel documentStatusLevel(LegalDocument document, DateTime now) {
  int days = document.expirationDate
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  if (days < 0) return TrafficLightLevel.danger;
  if (days <= 15) return TrafficLightLevel.warning;
  return TrafficLightLevel.ok;
}

/// Peor nivel entre un conjunto de documentos (usado por el Dashboard para
/// el semáforo SOAT/RTM resumido).
TrafficLightLevel worstStatusLevel(
  List<LegalDocument> documents,
  DateTime now,
) {
  TrafficLightLevel worst = TrafficLightLevel.ok;
  for (LegalDocument doc in documents) {
    TrafficLightLevel level = documentStatusLevel(doc, now);
    if (level == TrafficLightLevel.danger) return TrafficLightLevel.danger;
    if (level == TrafficLightLevel.warning) worst = TrafficLightLevel.warning;
  }
  return worst;
}

/// Documento vigente de cada tipo: el de vencimiento más lejano. Al renovar
/// (p. ej. un SOAT nuevo) el anterior puede seguir registrado, y como el
/// repositorio los devuelve por vencimiento ascendente, tomar el primero de
/// cada tipo mostraba el vencido.
Map<DocumentType, LegalDocument> latestDocumentByType(
  List<LegalDocument> documents,
) {
  Map<DocumentType, LegalDocument> latest = <DocumentType, LegalDocument>{};
  for (LegalDocument document in documents) {
    LegalDocument? current = latest[document.documentType];
    if (current == null ||
        document.expirationDate.isAfter(current.expirationDate)) {
      latest[document.documentType] = document;
    }
  }
  return latest;
}
