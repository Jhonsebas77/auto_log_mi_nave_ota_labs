part of com.auto_log_mi_nave_ota_labs.app.services;

/// Id determinístico por (documento, offset): estable entre reprogramaciones
/// del mismo documento, lo que hace seguro cancelar-por-id.
///
/// Usa FNV-1a (32 bits) en vez de `String.hashCode`: Dart no garantiza que
/// `hashCode` sea igual entre ejecuciones ni plataformas, y un id distinto
/// tras reiniciar la app haría que cancelar-por-id no encontrara los
/// recordatorios ya agendados.
int reminderIdFor(String documentId, int offsetDays) {
  int hash = 0x811C9DC5;
  for (int unit in '$documentId:$offsetDays'.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}

/// Genera los recordatorios de un documento, filtrando cualquier fecha ya
/// pasada respecto a [now] (p. ej. al editar un documento que vence en 10
/// días, solo se agendan los offsets de 7 y 1 día, no el de 30/15).
List<ScheduledReminder> planRemindersForDocument(
  LegalDocument document, {
  required DateTime now,
  List<int> offsetsDays = kDocumentReminderOffsetsDays,
}) {
  List<ScheduledReminder> reminders = <ScheduledReminder>[];
  for (int offset in offsetsDays) {
    DateTime fireAt = document.expirationDate.subtract(Duration(days: offset));
    if (fireAt.isAfter(now)) {
      reminders.add(
        ScheduledReminder(
          id: reminderIdFor(document.id, offset),
          fireAt: fireAt,
          title: '${document.documentType.label} vence en $offset días',
          body:
              'Vence el ${document.expirationDate.day}/${document.expirationDate.month}/${document.expirationDate.year}.',
        ),
      );
    }
  }
  return reminders;
}
