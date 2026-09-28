import 'package:auto_log_mi_nave_ota_labs/core/providers/providers.dart';
import 'package:auto_log_mi_nave_ota_labs/ui/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Arranca con una espera activa de 3 s, como tras varios fallos seguidos.
class _LockedThrottleController extends LoginThrottleController {
  @override
  LoginThrottleState build() => LoginThrottleState(
    failures: 3,
    lockedUntil: DateTime.now().add(const Duration(seconds: 3)),
  );
}

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'Mi Nave',
      packageName: 'test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets(
    'Con una espera activa el botón de login queda deshabilitado con cuenta '
    'regresiva y se reactiva al terminar',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          // ignore: always_specify_types
          overrides: [
            loginThrottleProvider.overrideWith(_LockedThrottleController.new),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('RETRY_IN'), findsOneWidget);
      expect(find.text('AUTHENTICATE'), findsNothing);
      ElevatedButton button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);

      // Termina la espera: vuelve el botón normal.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 3)),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('AUTHENTICATE'), findsOneWidget);
      button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      // Desmonta para cancelar las animaciones en loop del login.
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
