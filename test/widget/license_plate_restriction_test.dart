// Widget tests para "Pico y Placa" (Medellín): reemplazan al viejo
// test/tmp_visual/pico_y_placa_visual_check_test.dart (basado en goldens que
// fallaban siempre porque no había imágenes de referencia en el repo).
// Aquí se verifica el comportamiento real vía pumpWidget + aserciones sobre
// textos/widgets visibles, sin matchesGoldenFile.
import 'package:auto_log_mi_nave_ota_labs/core/constants/constants.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/ui/theme/theme.dart';
import 'package:auto_log_mi_nave_ota_labs/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: appDarkTheme,
  home: Scaffold(
    backgroundColor: BlueprintColors.background,
    body: SafeArea(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  ),
);

void main() {
  group('LicensePlateRestrictionCard', () {
    testWidgets(
      'muestra "No puedes circular hoy" y los datos del día restringido',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 600));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // Lunes 2026-08-17: restringe dígitos 5 y 8. Placa termina en 5.
        LicensePlateRestrictionResult result = isVehicleRestrictedToday(
          licensePlate: 'ABC125',
          today: DateTime.utc(2026, 8, 17),
        );

        await tester.pumpWidget(
          _wrap(
            LicensePlateRestrictionCard(result: result, licensePlate: 'ABC125'),
          ),
        );

        expect(find.text('No puedes circular hoy'), findsOneWidget);
        expect(
          find.text(
            'Los lunes se restringen los dígitos 5 y 8. Tu dígito es 5.',
          ),
          findsOneWidget,
        );
        expect(find.text('5:00 a.m. - 8:00 p.m.'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        // Martes restringe 1 y 4, así que el dígito 5 queda libre mañana.
        expect(find.text('Mañana'), findsOneWidget);
        expect(
          find.text('Verifica vigencia — este calendario pudo haber rotado.'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'muestra "Puedes circular hoy" cuando el dígito no está restringido',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 600));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // Lunes 2026-08-17: restringe 5 y 8. Placa termina en 3 -> libre.
        LicensePlateRestrictionResult result = isVehicleRestrictedToday(
          licensePlate: 'ABC123',
          today: DateTime.utc(2026, 8, 17),
        );

        await tester.pumpWidget(
          _wrap(
            LicensePlateRestrictionCard(result: result, licensePlate: 'ABC123'),
          ),
        );

        expect(find.text('Puedes circular hoy'), findsOneWidget);
        expect(
          find.text(
            'Los lunes se restringen los dígitos 5 y 8. Tu dígito es 3.',
          ),
          findsOneWidget,
        );
        expect(find.text('3'), findsOneWidget);
        expect(find.text('Hoy'), findsOneWidget);
      },
    );

    testWidgets('placa sin dígitos: dígito "—" y sin restricción calculada', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      LicensePlateRestrictionResult result = isVehicleRestrictedToday(
        licensePlate: 'ABC',
        today: DateTime.utc(2026, 8, 17),
      );
      expect(result.plateDigit, isNull);

      await tester.pumpWidget(
        _wrap(LicensePlateRestrictionCard(result: result, licensePlate: 'ABC')),
      );

      expect(find.text('Puedes circular hoy'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(
        find.text('Los lunes se restringen los dígitos 5 y 8.'),
        findsOneWidget,
      );
      // Sin dígito no hay nada que calcular: se asume hoy libre.
      expect(find.text('Hoy'), findsOneWidget);
    });

    testWidgets(
      'muestra el aviso de tabla desactualizada cuando el schedule está stale',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 600));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // 2027-01-04 (lunes) es posterior a effectiveTo (2026-12-31).
        DateTime staleDate = DateTime.utc(2027, 1, 4);
        LicensePlateRestrictionResult result = isVehicleRestrictedToday(
          licensePlate: 'ABC125',
          today: staleDate,
        );
        expect(result.scheduleIsStale, isTrue);

        await tester.pumpWidget(
          _wrap(
            LicensePlateRestrictionCard(result: result, licensePlate: 'ABC125'),
          ),
        );

        expect(
          find.text('Verifica vigencia — este calendario pudo haber rotado.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'muestra el nombre del día como próximo día libre cuando el dígito '
      'sigue restringido al día siguiente',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 600));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // Schedule sintético: el dígito 5 está restringido tanto lunes como
        // martes, así que el próximo día libre real es miércoles (nombre
        // del día), no "Mañana". Esto no ocurre con la tabla vigente de
        // Medellín (cada dígito cae en un solo día), pero ejerce la rama
        // `_ => weekdayLabel(day.weekday)` de `_nextFreeDayLabel`.
        LicensePlateRestrictionSchedule customSchedule =
            LicensePlateRestrictionSchedule(
              cityLabel: 'Ciudad de prueba',
              effectivePeriodLabel: 'Periodo de prueba',
              effectiveFrom: DateTime.utc(2026, 1, 1),
              effectiveTo: DateTime.utc(2026, 12, 31),
              rulesByIsoWeekday: <int, LicensePlateRestrictionDayRule>{
                DateTime.monday: const LicensePlateRestrictionDayRule(
                  dayLabel: 'Lunes',
                  restrictedLastDigits: <int>[5],
                  horarioLabel: '5:00 a.m. - 8:00 p.m.',
                ),
                DateTime.tuesday: const LicensePlateRestrictionDayRule(
                  dayLabel: 'Martes',
                  restrictedLastDigits: <int>[5],
                  horarioLabel: '5:00 a.m. - 8:00 p.m.',
                ),
                DateTime.wednesday: const LicensePlateRestrictionDayRule(
                  dayLabel: 'Miércoles',
                  restrictedLastDigits: <int>[1],
                  horarioLabel: '5:00 a.m. - 8:00 p.m.',
                ),
              },
            );

        LicensePlateRestrictionResult result = isVehicleRestrictedToday(
          licensePlate: 'ABC125',
          today: DateTime.utc(2026, 8, 17), // lunes
          schedule: customSchedule,
        );

        await tester.pumpWidget(
          _wrap(
            LicensePlateRestrictionCard(result: result, licensePlate: 'ABC125'),
          ),
        );

        expect(find.text('Miércoles'), findsOneWidget);
      },
    );

    testWidgets('fin de semana: sin regla aplicable muestra "-" en franja y el '
        'mensaje genérico', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Sábado 2026-08-22: no hay regla para fin de semana.
      LicensePlateRestrictionResult result = isVehicleRestrictedToday(
        licensePlate: 'ABC123',
        today: DateTime.utc(2026, 8, 22),
      );
      expect(result.ruleApplied, isNull);

      await tester.pumpWidget(
        _wrap(
          LicensePlateRestrictionCard(result: result, licensePlate: 'ABC123'),
        ),
      );

      expect(find.text('Puedes circular hoy'), findsOneWidget);
      expect(
        find.text('Hoy no aplica restricción de pico y placa.'),
        findsOneWidget,
      );
      expect(find.text('-'), findsOneWidget);
      expect(find.text('Hoy'), findsOneWidget);
    });

    testWidgets(
      'toca "Ver calendario del mes" y abre la hoja con el calendario '
      'completo',
      (WidgetTester tester) async {
        // La hoja abierta necesita más alto que la tarjeta sola: usa el
        // mismo tamaño de superficie que los tests de
        // LicensePlateRestrictionScheduleSheet para que no desborde.
        await tester.binding.setSurfaceSize(const Size(400, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        LicensePlateRestrictionResult result = isVehicleRestrictedToday(
          licensePlate: 'ABC125',
          today: DateTime.utc(2026, 8, 17),
        );

        await tester.pumpWidget(
          _wrap(
            LicensePlateRestrictionCard(result: result, licensePlate: 'ABC125'),
          ),
        );

        await tester.tap(find.text('Ver calendario del mes'));
        await tester.pumpAndSettle();

        expect(
          find.byType(LicensePlateRestrictionScheduleSheet),
          findsOneWidget,
        );
        expect(
          find.text('Días con restricción · Medellín y Valle de Aburrá'),
          findsOneWidget,
        );
      },
    );
  });

  group('LicensePlateRestrictionScheduleSheet', () {
    testWidgets('lista los 5 días con regla y los 2 días de fin de semana sin '
        'restricción, sin resaltar ningún día cuando plateDigit es null', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(
          LicensePlateRestrictionScheduleSheet(
            schedule: picoYPlacaMedellin2026S2,
            plateDigit: null,
          ),
        ),
      );

      expect(
        find.text('Días con restricción · Medellín y Valle de Aburrá'),
        findsOneWidget,
      );
      expect(
        find.text('Vigente 2026-2 · Segundo semestre 2026'),
        findsOneWidget,
      );

      for (String dayLabel in spanishWeekdayLabels) {
        expect(find.text(dayLabel), findsOneWidget);
      }

      expect(find.text('[5, 8] · 5:00 a.m. - 8:00 p.m.'), findsOneWidget);
      expect(find.text('[1, 4] · 5:00 a.m. - 8:00 p.m.'), findsOneWidget);
      expect(find.text('[0, 2] · 5:00 a.m. - 8:00 p.m.'), findsOneWidget);
      expect(find.text('[3, 6] · 5:00 a.m. - 8:00 p.m.'), findsOneWidget);
      expect(find.text('[7, 9] · 5:00 a.m. - 8:00 p.m.'), findsOneWidget);
      expect(find.text('Sin restricción'), findsNWidgets(2));

      expect(find.text('TU DÍA'), findsNothing);
      expect(find.byIcon(Icons.block), findsNothing);
    });

    testWidgets(
      'resalta con la insignia "TU DÍA" y el ícono de bloqueo el día del '
      'dígito de la placa del usuario',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // El dígito 9 solo cae en la regla del viernes ([7, 9]).
        await tester.pumpWidget(
          _wrap(
            LicensePlateRestrictionScheduleSheet(
              schedule: picoYPlacaMedellin2026S2,
              plateDigit: 9,
            ),
          ),
        );

        expect(find.text('TU DÍA'), findsOneWidget);
        expect(find.byIcon(Icons.block), findsOneWidget);
      },
    );
  });
}
