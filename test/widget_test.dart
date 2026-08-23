import 'package:auto_log_mi_nave_ota_labs/app.dart';
import 'package:auto_log_mi_nave_ota_labs/core/services/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/fakes.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Supabase persiste la sesión con shared_preferences por debajo; en test
    // no hay implementación de plataforma real, así que se mockea vacía.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // Credenciales dummy: alcanza para que el SDK arranque localmente (sin
    // sesión persistida) sin pegarle a un backend real. El login real contra
    // Supabase se prueba manualmente (ver plan), no en este widget test.
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      publishableKey: 'test-publishable-key',
    );
  });

  testWidgets('Sin sesión de Supabase, la app arranca en Login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          notificationServiceProvider.overrideWithValue(
            FakeNotificationService(),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('AUTHENTICATE'), findsOneWidget);
  });
}
