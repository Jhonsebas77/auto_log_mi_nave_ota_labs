part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Se muestra mientras AuthController restaura la sesión persistida al
/// arrancar la app (estado AuthStatus.unknown).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const BlueprintScaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('VEHICLE_SYSTEM_V1.0', style: AppTextStyles.headlineLarge),
          SizedBox(height: 24),
          CircularProgressIndicator(color: BlueprintColors.accentOrange),
        ],
      ),
    ),
  );
}
