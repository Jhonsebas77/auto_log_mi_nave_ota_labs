part of com.auto_log_mi_nave_ota_labs.app.core.models;

class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.fireAt,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime fireAt;
  final String title;
  final String body;
}
