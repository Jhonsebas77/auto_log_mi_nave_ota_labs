part of com.auto_log_mi_nave_ota_labs.app.ui.theme;

/// Tema unificado, portado 1:1 (estructura + colores) de
/// app_track_ota_labs/lib/ui/theme.dart. `BlueprintColors` se mantiene aparte
/// para los widgets que siguen pintando el look "Engineering Blueprint"
/// directo (login, grids, corchetes, etc. — no dependen de ThemeData); este
/// archivo es el que alimenta `ThemeData`/`MaterialApp` (botones, tabs,
/// inputs, cards, snackbars, textTheme...).
const Color primaryColor = Color(0xFF3B82F6);
const Color primaryDarkColor = Color.fromARGB(255, 46, 109, 210);
const Color secondaryColor = Color(0xFF64748B);
const Color secondaryDarkColor = Color.fromRGBO(77, 208, 225, 1);
const Color tertiaryColor = Color.fromRGBO(218, 153, 33, 1);
const Color tertiaryDarkColor = Color.fromRGBO(255, 203, 80, 1);
const Color lightErrorColor = Color.fromRGBO(184, 52, 90, 1);
const Color darkErrorColor = Color.fromRGBO(239, 107, 129, 1);

// --- LIGHT THEME ---
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: AppTextStyles.fontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    tertiary: tertiaryColor,
    error: lightErrorColor,
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      textStyle: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    labelStyle: const TextStyle(
      color: primaryColor,
      fontFamily: AppTextStyles.fontFamily,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade300),
    ),
  ),
);

// --- DARK THEME ---
final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: AppTextStyles.fontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryDarkColor,
    secondary: secondaryDarkColor,
    tertiary: tertiaryDarkColor,
    error: darkErrorColor,
    brightness: Brightness.dark,
  ),
  textTheme: const TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    foregroundColor: Colors.white,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: secondaryColor,
      textStyle: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: secondaryColor, width: 2),
    ),
    labelStyle: TextStyle(
      color: Colors.grey.shade300,
      fontFamily: AppTextStyles.fontFamily,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    color: Colors.grey[850],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade800),
    ),
  ),
);
