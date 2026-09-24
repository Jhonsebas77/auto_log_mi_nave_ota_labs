import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/constants.dart';
import 'core/services/services.dart';

const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  if (_supabaseUrl.isEmpty ||
      _supabasePublishableKey.isEmpty ||
      hardcodedEmail.isEmpty) {
    throw StateError(
      'Faltan las credenciales de Supabase. Corre la app con '
      '--dart-define=SUPABASE_URL=... '
      '--dart-define=SUPABASE_PUBLISHABLE_KEY=... '
      '--dart-define=AUTH_EMAIL=... '
      '(o --dart-define-from-file=config/dart_defines.local.json).',
    );
  }
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );

  ProviderContainer container = ProviderContainer();
  await container.read(notificationServiceProvider).init();

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
