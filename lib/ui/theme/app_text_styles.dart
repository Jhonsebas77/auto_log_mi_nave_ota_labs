part of com.auto_log_mi_nave_ota_labs.app.ui.theme;

/// Estilos de texto estáticos, accesibles sin `Theme.of(context)` (ej.
/// `AppTextStyles.bodySmall`). Son la fuente única de verdad para
/// `appTheme`/`appDarkTheme`.textTheme (ver app_theme.dart): igual que en
/// app_track_ota_labs/lib/ui/theme.dart, no fijan color — así heredan el que
/// corresponda del `ColorScheme` del tema activo (claro u oscuro).
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'JetBrainsMono';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.bold,
  );

  /// No está en el archivo de referencia (que solo llega a headlineMedium);
  /// se agrega para el wordmark de marca (splash_screen.dart), que ya usaba
  /// este rol.
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  /// No está en el archivo de referencia; se agrega porque varias vistas ya
  /// la usaban (settings, historial de combustible, mantenimiento).
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4,
  );

  /// No está en el archivo de referencia; es el rol más usado en este
  /// proyecto (labels, subtítulos, metadatos).
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.3,
  );

  /// No está en el archivo de referencia; usado por el bottom nav bar.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  /// No está en el archivo de referencia; usado por badges/etiquetas chicas.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
  );
}
