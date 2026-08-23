part of com.auto_log_mi_nave_ota_labs.app.services;

abstract class NotificationService {
  Future<void> init();
  Future<bool> requestPermissions();
  Future<void> scheduleAt(ScheduledReminder reminder);
  Future<void> cancel(int id);
  Future<void> cancelAll();
}
