import 'package:auto_log_mi_nave_ota_labs/core/enums/enums.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('planRemindersForDocument', () {
    test('agenda los 4 offsets cuando el vencimiento está muy lejos', () {
      DateTime now = DateTime(2026, 1, 1);
      LegalDocument document = LegalDocument(
        id: 'doc-1',
        vehicleId: 'v1',
        documentType: DocumentType.soat,
        expirationDate: now.add(const Duration(days: 100)),
      );
      List<ScheduledReminder> reminders = planRemindersForDocument(
        document,
        now: now,
      );
      expect(reminders, hasLength(4));
    });

    test('solo agenda offsets cuya fecha resultante es futura', () {
      DateTime now = DateTime(2026, 1, 1);
      // Vence en 10 días: offsets 30 y 15 ya quedaron en el pasado.
      LegalDocument document = LegalDocument(
        id: 'doc-2',
        vehicleId: 'v1',
        documentType: DocumentType.rtm,
        expirationDate: now.add(const Duration(days: 10)),
      );
      List<ScheduledReminder> reminders = planRemindersForDocument(
        document,
        now: now,
      );
      expect(reminders, hasLength(2));
    });

    test('documento ya vencido no agenda ningún recordatorio', () {
      DateTime now = DateTime(2026, 1, 1);
      LegalDocument document = LegalDocument(
        id: 'doc-3',
        vehicleId: 'v1',
        documentType: DocumentType.extintor,
        expirationDate: now.subtract(const Duration(days: 5)),
      );
      List<ScheduledReminder> reminders = planRemindersForDocument(
        document,
        now: now,
      );
      expect(reminders, isEmpty);
    });

    test(
      'reminderIdFor es determinístico para el mismo (documento, offset)',
      () {
        int id1 = reminderIdFor('doc-1', 30);
        int id2 = reminderIdFor('doc-1', 30);
        int id3 = reminderIdFor('doc-1', 15);
        expect(id1, id2);
        expect(id1, isNot(id3));
      },
    );

    test(
      'reminderIdFor es estable entre ejecuciones (no depende de '
      'String.hashCode)',
      () {
        // Valor fijo de FNV-1a sobre "doc-1:30": si cambia, los
        // recordatorios agendados en una versión anterior ya no se podrían
        // cancelar por id.
        expect(reminderIdFor('doc-1', 30), 1402836688);
        expect(reminderIdFor('doc-1', 30), lessThanOrEqualTo(0x7FFFFFFF));
      },
    );
  });
}
