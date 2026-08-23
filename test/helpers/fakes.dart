import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/services/services.dart';

/// Fakes usados en widget tests para evitar tocar plugins nativos
/// (flutter_local_notifications) que no tienen implementación de plataforma
/// disponible en el entorno de test.
class FakeNotificationService implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleAt(ScheduledReminder reminder) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}
}
