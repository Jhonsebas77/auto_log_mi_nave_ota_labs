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

// --- OVERLAYS NATIVOS (diálogos, date picker, menús, bottom sheets) ---
//
// A diferencia del resto de la UI, estos widgets no viven dentro de
// `BlueprintScaffold`: son rutas/overlays propios que resuelven su fondo
// desde `ThemeData` en el momento de abrirse, y por lo tanto SÍ cambian con
// el tema del sistema si no se fijan acá. Como `AppTextStyles` ya fuerza un
// color de texto fijo (pensado para el fondo oscuro fijo de
// `BlueprintColors.background`), estos overlays necesitan también un fondo
// fijo — si no, en tema claro del sistema terminan con fondo claro
// (heredado de `ColorScheme.surface`) y texto casi blanco encima,
// ilegible. Se usa el mismo valor (`surfaceContainerLow`) que ya usan a
// mano los `AlertDialog` de borrado (ver `fuel_history_list.dart`,
// `legal_garage_screen.dart`, `odometer_quick_update_card.dart`), así que
// esos quedan visualmente igual.
final DatePickerThemeData _blueprintDatePickerTheme = DatePickerThemeData(
  backgroundColor: BlueprintColors.surfaceContainerLow,
  headerBackgroundColor: BlueprintColors.background,
  headerForegroundColor: BlueprintColors.textPrimary,
  weekdayStyle: AppTextStyles.bodySmall,
  dayStyle: AppTextStyles.bodyMedium,
  dayForegroundColor: WidgetStateProperty.resolveWith<Color?>(
    (Set<WidgetState> states) => states.contains(WidgetState.selected)
        ? BlueprintColors.onAccent
        : states.contains(WidgetState.disabled)
        ? BlueprintColors.textMuted
        : BlueprintColors.textPrimary,
  ),
  dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
    (Set<WidgetState> states) => states.contains(WidgetState.selected)
        ? BlueprintColors.accentOrange
        : null,
  ),
  todayForegroundColor: WidgetStateProperty.resolveWith<Color?>(
    (Set<WidgetState> states) => states.contains(WidgetState.selected)
        ? BlueprintColors.onAccent
        : BlueprintColors.accentOrange,
  ),
  todayBorder: const BorderSide(color: BlueprintColors.accentOrange),
  yearStyle: AppTextStyles.bodyMedium,
  yearForegroundColor: WidgetStateProperty.resolveWith<Color?>(
    (Set<WidgetState> states) => states.contains(WidgetState.selected)
        ? BlueprintColors.onAccent
        : BlueprintColors.textPrimary,
  ),
  yearBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
    (Set<WidgetState> states) => states.contains(WidgetState.selected)
        ? BlueprintColors.accentOrange
        : null,
  ),
  rangePickerBackgroundColor: BlueprintColors.surfaceContainerLow,
  dividerColor: BlueprintColors.outlineVariant,
  subHeaderForegroundColor: BlueprintColors.textPrimary,
  shape: kSharpShape,
);

const DialogThemeData _blueprintDialogTheme = DialogThemeData(
  backgroundColor: BlueprintColors.surfaceContainerLow,
  shape: kSharpShape,
);

const PopupMenuThemeData _blueprintPopupMenuTheme = PopupMenuThemeData(
  color: BlueprintColors.surfaceContainerLow,
  textStyle: AppTextStyles.bodyMedium,
  shape: kSharpShape,
);

const BottomSheetThemeData _blueprintBottomSheetTheme = BottomSheetThemeData(
  backgroundColor: BlueprintColors.surfaceContainerLow,
  shape: kSharpShape,
);

// `ListTile`/`SwitchListTile`/`CheckboxListTile` NO heredan su color de
// `textTheme` como el resto de los `Text`: su estilo por defecto es
// `textTheme.bodyLarge!.copyWith(color: colorScheme.onSurface)` (ver
// `list_tile.dart` en el SDK de Flutter) — ese `.copyWith` pisa el color fijo
// de `AppTextStyles` con el `onSurface` adaptativo del `ColorScheme`, así que
// títulos como "Fecha del tanqueo" o "Tanque lleno" (usados sin `style`
// propio en varias pantallas) volvían a quedar casi negros en tema claro.
// Se fija acá por la misma razón que el resto de los overlays de arriba.
const ListTileThemeData _blueprintListTileTheme = ListTileThemeData(
  textColor: BlueprintColors.textPrimary,
  iconColor: BlueprintColors.textMuted,
  titleTextStyle: AppTextStyles.bodyLarge,
  subtitleTextStyle: AppTextStyles.bodySmall,
);

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
  // El menú de `DropdownButton`/`DropdownButtonFormField` usa `canvasColor`
  // como fondo cuando no se pasa `dropdownColor` explícito — se fija acá
  // por la misma razón que dialogTheme/datePickerTheme (ver comentario
  // arriba): si no, en tema claro queda claro con el texto casi blanco de
  // `AppTextStyles` encima.
  canvasColor: BlueprintColors.surfaceContainerLow,
  dialogTheme: _blueprintDialogTheme,
  datePickerTheme: _blueprintDatePickerTheme,
  popupMenuTheme: _blueprintPopupMenuTheme,
  bottomSheetTheme: _blueprintBottomSheetTheme,
  listTileTheme: _blueprintListTileTheme,
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
    // Fijo en blanco (no `primaryColor`): el fondo del formulario siempre es
    // oscuro (`BlueprintColors.background`), sin importar el tema del
    // sistema, así que no hace falta (ni conviene) un color de label que
    // cambie con el tema.
    labelStyle: const TextStyle(
      color: BlueprintColors.textPrimary,
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
  canvasColor: BlueprintColors.surfaceContainerLow,
  dialogTheme: _blueprintDialogTheme,
  datePickerTheme: _blueprintDatePickerTheme,
  popupMenuTheme: _blueprintPopupMenuTheme,
  bottomSheetTheme: _blueprintBottomSheetTheme,
  listTileTheme: _blueprintListTileTheme,
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
    labelStyle: const TextStyle(
      color: BlueprintColors.textPrimary,
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
