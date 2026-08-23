part of com.auto_log_mi_nave_ota_labs.app.services;

const String _channelId = 'document_reminders';
const String _channelName = 'Vencimientos de documentos';
const String _channelDescription =
    'Recordatorios de vencimiento de SOAT, RTM, impuestos y otros documentos.';

/// No existe un paquete `flutter_local_notifications_web`: el plugin no
/// tiene implementación de plataforma en el navegador (ni `initialize`, ni
/// notificaciones programadas). Todas las operaciones son no-op en web para
/// que la app funcione ahí sin recordatorios, en vez de lanzar
/// MissingPluginException/UnsupportedError.
class FlutterLocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    if (kIsWeb) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinInit =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
      ),
    );
  }

  @override
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    bool? androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    bool? iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  @override
  Future<void> scheduleAt(ScheduledReminder reminder) async {
    if (kIsWeb) return;
    await _plugin.zonedSchedule(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body,
      scheduledDate: tz.TZDateTime.from(reminder.fireAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
        ),
      ),
      // No requiere precisión al minuto y evita el permiso de alarma exacta.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
