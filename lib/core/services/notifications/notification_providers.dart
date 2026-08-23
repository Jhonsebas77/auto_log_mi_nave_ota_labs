part of com.auto_log_mi_nave_ota_labs.app.services;

final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>(
      (Ref ref) => FlutterLocalNotificationService(),
    );

final Provider<NotificationReconciler> notificationReconcilerProvider =
    Provider<NotificationReconciler>(
      (Ref ref) => NotificationReconciler(
        notificationService: ref.watch(notificationServiceProvider),
        legalDocumentRepository: ref.watch(legalDocumentRepositoryProvider),
      ),
    );
