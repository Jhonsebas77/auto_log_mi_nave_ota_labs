// TEMP file for visual verification only — not part of the real test suite.
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
  testWidgets('free today card', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 500));
    LicensePlateRestrictionResult result = isVehicleRestrictedToday(
      licensePlate: 'ABC123',
      today: DateTime.utc(2026, 8, 17), // Monday, digit 3 -> not restricted
    );
    await tester.pumpWidget(
      _wrap(
        LicensePlateRestrictionCard(result: result, licensePlate: 'ABC123'),
      ),
    );
    await expectLater(
      find.byType(LicensePlateRestrictionCard),
      matchesGoldenFile('free_today.png'),
    );
  });

  testWidgets('restricted today card', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 500));
    LicensePlateRestrictionResult result = isVehicleRestrictedToday(
      licensePlate: 'ABC0',
      today: DateTime.utc(2026, 8, 17), // Monday, digit 0 -> restricted
    );
    await tester.pumpWidget(
      _wrap(LicensePlateRestrictionCard(result: result, licensePlate: 'ABC0')),
    );
    await expectLater(
      find.byType(LicensePlateRestrictionCard),
      matchesGoldenFile('restricted_today.png'),
    );
  });

  testWidgets('schedule sheet', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 700));
    LicensePlateRestrictionResult result = isVehicleRestrictedToday(
      licensePlate: 'ABC0',
      today: DateTime.utc(2026, 8, 17),
    );
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (BuildContext context) =>
              LicensePlateRestrictionScheduleSheet(
                schedule: result.schedule,
                plateDigit: result.plateDigit,
              ),
        ),
      ),
    );
    await expectLater(
      find.byType(LicensePlateRestrictionScheduleSheet),
      matchesGoldenFile('schedule_sheet.png'),
    );
  });
}
