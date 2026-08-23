part of com.auto_log_mi_nave_ota_labs.app.services;

/// Id determinístico por (documento, offset): estable entre reprogramaciones
/// del mismo documento, lo que hace seguro cancelar-por-id.
int reminderIdFor(String documentId, int offsetDays) =>
    (documentId.hashCode ^ offsetDays).abs() % 0x7FFFFFFF;

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
