import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  DateTime now = DateTime(2026, 1, 1);

  group('NotificationReconciler.reconcileAll', () {
    test(
      'notificationsEnabled: false -> cancela todo y no agenda nada',
      () async {
        FakeNotificationService notificationService = FakeNotificationService();
        FakeLegalDocumentRepository repository = FakeLegalDocumentRepository(
          seed: <LegalDocument>[
            fakeLegalDocument(
              id: 'd1',
              expirationDate: now.add(const Duration(days: 40)),
            ),
          ],
        );
        NotificationReconciler reconciler = NotificationReconciler(
          notificationService: notificationService,
          legalDocumentRepository: repository,
        );

        await reconciler.reconcileAll(now: now, notificationsEnabled: false);

        expect(notificationService.cancelAllCount, 1);
        expect(notificationService.scheduled, isEmpty);
      },
    );

    test(
      'notificationsEnabled: true -> agenda los recordatorios de cada '
      'documento',
      () async {
        FakeNotificationService notificationService = FakeNotificationService();
        FakeLegalDocumentRepository repository = FakeLegalDocumentRepository(
          seed: <LegalDocument>[
            fakeLegalDocument(
              id: 'd1',
              expirationDate: now.add(const Duration(days: 40)),
            ),
            fakeLegalDocument(
              id: 'd2',
              expirationDate: now.add(const Duration(days: 40)),
            ),
          ],
        );
        NotificationReconciler reconciler = NotificationReconciler(
          notificationService: notificationService,
          legalDocumentRepository: repository,
        );

        await reconciler.reconcileAll(now: now, notificationsEnabled: true);

        expect(notificationService.cancelAllCount, 1);
        // 4 offsets (30/15/7/1) por documento, y todos caen antes de un
        // vencimiento a 40 días.
        expect(notificationService.scheduled, hasLength(8));
      },
    );

    test(
      'corridas concurrentes se serializan y gana la más reciente',
      () async {
        FakeNotificationService notificationService = FakeNotificationService();
        FakeLegalDocumentRepository repository = FakeLegalDocumentRepository(
          seed: <LegalDocument>[
            fakeLegalDocument(
              id: 'd1',
              expirationDate: now.add(const Duration(days: 40)),
            ),
          ],
        );
        NotificationReconciler reconciler = NotificationReconciler(
          notificationService: notificationService,
          legalDocumentRepository: repository,
        );

        // Arranque (activadas) y, sin esperar, el toggle en Settings
        // (desactivadas): al final no debe quedar nada agendado.
        await Future.wait(<Future<void>>[
          reconciler.reconcileAll(now: now, notificationsEnabled: true),
          reconciler.reconcileAll(now: now, notificationsEnabled: false),
        ]);

        expect(notificationService.cancelAllCount, 2);
        expect(
          notificationService.calls.last,
          'cancelAll',
          reason: 'la última operación debe ser el cancelAll del toggle',
        );
      },
    );
  });

  test(
    'rescheduleForDocument cancela antes de agendar',
    () async {
      FakeNotificationService notificationService = FakeNotificationService();
      FakeLegalDocumentRepository repository = FakeLegalDocumentRepository();
      NotificationReconciler reconciler = NotificationReconciler(
        notificationService: notificationService,
        legalDocumentRepository: repository,
      );
      LegalDocument document = fakeLegalDocument(
        id: 'd1',
        expirationDate: now.add(const Duration(days: 40)),
      );

      await reconciler.rescheduleForDocument(document, now: now);

      // 4 cancel (uno por offset) seguidos de 4 scheduleAt.
      expect(notificationService.calls, hasLength(8));
      expect(
        notificationService.calls.sublist(0, 4),
        everyElement(startsWith('cancel:')),
      );
      expect(
        notificationService.calls.sublist(4),
        everyElement(startsWith('scheduleAt:')),
      );
    },
  );

  test(
    'documento que vence en 10 días solo agenda los offsets 7 y 1',
    () async {
      FakeNotificationService notificationService = FakeNotificationService();
      FakeLegalDocumentRepository repository = FakeLegalDocumentRepository(
        seed: <LegalDocument>[
          fakeLegalDocument(
            id: 'd1',
            expirationDate: now.add(const Duration(days: 10)),
          ),
        ],
      );
      NotificationReconciler reconciler = NotificationReconciler(
        notificationService: notificationService,
        legalDocumentRepository: repository,
      );

      await reconciler.reconcileAll(now: now, notificationsEnabled: true);

      expect(notificationService.scheduled, hasLength(2));
      List<DateTime> fireAtDays = notificationService.scheduled
          .map((ScheduledReminder r) => r.fireAt)
          .toList();
      expect(fireAtDays, contains(now.add(const Duration(days: 3))));
      expect(fireAtDays, contains(now.add(const Duration(days: 9))));
    },
  );
}
