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
    await Future.wait(reminders.map(_notificationService.scheduleAt));
  }

  Future<void> cancelForDocument(LegalDocument document) =>
      _cancelExisting(document);

  Future<void> _cancelExisting(LegalDocument document) => Future.wait(
    kDocumentReminderOffsetsDays.map(
      (int offset) =>
          _notificationService.cancel(reminderIdFor(document.id, offset)),
    ),
  );

  /// Cola de reconciliaciones: cada corrida espera a que termine la
  /// anterior. Evita que dos corridas se intercalen (ej. la del arranque y
  /// un toggle en Settings), lo que podía dejar recordatorios agendados con
  /// las notificaciones desactivadas.
  Future<void> _queue = Future<void>.value();

  /// Cancela todo y reprograma desde cero a partir de los documentos
  /// existentes en el repositorio de Supabase. Se ejecuta al iniciar la app
  /// (tras login) y cuando se reactiva el toggle de notificaciones en
  /// Settings.
  Future<void> reconcileAll({
    required DateTime now,
    required bool notificationsEnabled,
  }) {
    Future<void> run = _queue
        .catchError((Object _) {})
        .then(
          (_) => _reconcileAll(
            now: now,
            notificationsEnabled: notificationsEnabled,
          ),
        );
    _queue = run;
    return run;
  }

  Future<void> _reconcileAll({
    required DateTime now,
    required bool notificationsEnabled,
  }) async {
    await _notificationService.cancelAll();
    if (!notificationsEnabled) return;
    List<LegalDocument> documents = await _legalDocumentRepository.getAll();
    await Future.wait(<Future<void>>[
      for (LegalDocument document in documents)
        for (ScheduledReminder reminder in planRemindersForDocument(
          document,
          now: now,
        ))
          _notificationService.scheduleAt(reminder),
    ]);
  }
}
