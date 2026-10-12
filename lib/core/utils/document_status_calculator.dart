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

/// Documentos de una tab de Garaje Legal, separados en vigentes (uno por
/// tipo) e historial (los reemplazados al renovar).
class GarageDocumentGroup {
  const GarageDocumentGroup({
    required this.current,
    required this.history,
    required this.missingTypes,
  });

  /// Vigente de cada tipo, del más urgente (vencido o más próximo a vencer)
  /// al más lejano.
  final List<LegalDocument> current;

  /// Documentos reemplazados por uno más reciente del mismo tipo, del más
  /// reciente al más antiguo.
  final List<LegalDocument> history;

  /// Tipos de la tab sin ningún documento registrado.
  final List<DocumentType> missingTypes;

  bool get isEmpty => current.isEmpty && history.isEmpty;

  /// Peor nivel de los vigentes (el historial no alerta: ya fue renovado);
  /// `null` si la tab no tiene vigentes.
  TrafficLightLevel? level(DateTime now) =>
      current.isEmpty ? null : worstStatusLevel(current, now);

  @override
  bool operator ==(Object other) =>
      other is GarageDocumentGroup &&
      listEquals(other.current, current) &&
      listEquals(other.history, history) &&
      listEquals(other.missingTypes, missingTypes);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(current),
    Object.hashAll(history),
    Object.hashAll(missingTypes),
  );
}

/// Agrupa [documents] para la tab [group] de Garaje Legal (ver
/// [GarageDocumentGroup]).
GarageDocumentGroup garageDocumentGroup(
  List<LegalDocument> documents,
  GarageTabGroup group,
) {
  List<LegalDocument> inGroup = documents
      .where((LegalDocument d) => d.documentType.garageTabGroup == group)
      .toList(growable: false);
  Map<DocumentType, LegalDocument> latest = latestDocumentByType(inGroup);
  Set<String> currentIds = <String>{
    for (final LegalDocument d in latest.values) d.id,
  };
  return GarageDocumentGroup(
    current: latest.values.toList()
      ..sort(
        (LegalDocument a, LegalDocument b) =>
            a.expirationDate.compareTo(b.expirationDate),
      ),
    history:
        inGroup.where((LegalDocument d) => !currentIds.contains(d.id)).toList()
          ..sort(
            (LegalDocument a, LegalDocument b) =>
                b.expirationDate.compareTo(a.expirationDate),
          ),
    missingTypes: group.documentTypes
        .where((DocumentType t) => !latest.containsKey(t))
        .toList(growable: false),
  );
}
