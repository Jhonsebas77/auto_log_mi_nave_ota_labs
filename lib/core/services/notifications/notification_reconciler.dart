part of com.auto_log_mi_nave_ota_labs.app.services;

/// Orquesta el agendado/cancelación de recordatorios. Punto único de
/// disparo desde: crear/editar/eliminar documento, inicio de la app
/// (reconciliación completa) y el toggle de notificaciones en Settings.
class NotificationReconciler {
  NotificationReconciler({
    required NotificationService notificationService,
    required LegalDocumentRepository legalDocumentRepository,
  }) : _notificationService = notificationService,
       _legalDocumentRepository = legalDocumentRepository;

  final NotificationService _notificationService;
  final LegalDocumentRepository _legalDocumentRepository;

  Future<void> rescheduleForDocument(
    LegalDocument document, {
    required DateTime now,
  }) async {
    await _cancelExisting(document);
    List<ScheduledReminder> reminders = planRemindersForDocument(
      document,
      now: now,
    );
    for (ScheduledReminder reminder in reminders) {
      await _notificationService.scheduleAt(reminder);
    }
  }

  Future<void> cancelForDocument(LegalDocument document) =>
      _cancelExisting(document);

  Future<void> _cancelExisting(LegalDocument document) async {
    for (int offset in const <int>[30, 15, 7, 1]) {
      await _notificationService.cancel(reminderIdFor(document.id, offset));
    }
  }

  /// Cancela todo y reprograma desde cero a partir de los documentos
  /// existentes en el repositorio mock. Se ejecuta al iniciar la app (tras
  /// login) y cuando se reactiva el toggle de notificaciones en Settings.
  Future<void> reconcileAll({
    required DateTime now,
    required bool notificationsEnabled,
  }) async {
    await _notificationService.cancelAll();
    if (!notificationsEnabled) return;
    List<LegalDocument> documents = await _legalDocumentRepository.getAll();
    for (LegalDocument document in documents) {
      List<ScheduledReminder> reminders = planRemindersForDocument(
        document,
        now: now,
      );
      for (ScheduledReminder reminder in reminders) {
        await _notificationService.scheduleAt(reminder);
      }
    }
  }
}
