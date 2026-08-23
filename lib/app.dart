import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/theme/theme.dart';
import 'ui/views/views.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: 'Mi Nave',
    debugShowCheckedModeBanner: false,
    theme: appTheme,
    darkTheme: appDarkTheme,
    themeMode: ThemeMode.system,
    home: const AuthGate(),
  );
}
