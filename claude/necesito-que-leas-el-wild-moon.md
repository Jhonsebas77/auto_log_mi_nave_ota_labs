# Plan: App de Control Vehicular "Mi Nave" (Flutter, Blueprint Design System)

## Contexto

El proyecto Flutter está en su estado inicial (app contador por defecto de `flutter create`). Existen tres specs en `claude/` que definen lo que hay que construir:

- `claude/tech_spec.md` — schema de datos objetivo (Postgres/Supabase): `users`, `vehicles`, `legal_documents`, `fuel_logs`, `maintenances`. Stack a largo plazo: `flutter_riverpod` + Supabase + `flutter_local_notifications`.
- `claude/design_spec.md` — design system "Engineering Blueprint Schematic" (fondo oscuro `#0b1623`, grid overlay, tipografía JetBrains Mono, acento naranja `#ff9f30`, verde éxito `#00ff9d`, esquinas a 0px), navegación inferior de 5 tabs, y 9 pantallas específicas.
- `claude/pico_y_placa_Medellin.md` — tabla vigente de restricción "Pico y Placa" para Medellín/Valle de Aburrá, semestre 2026-2.

El objetivo es construir la app completa en una sola pasada, pero **sin integración real a Supabase todavía**: la persistencia real de backend se difiere para una iteración futura. Esta pasada construye el 100% de la UI y la lógica de negocio (cálculos de combustible, semáforo de documentos, barras de vida útil de mantenimiento, Pico y Placa, notificaciones locales) contra un repositorio en memoria/mock, diseñado con una interfaz limpia para que conectar Supabase después sea un cambio aislado (un solo archivo de bindings), sin tocar UI ni providers.

### Decisiones ya tomadas con el usuario
1. **Backend diferido**: solo repositorios mock en memoria esta pasada, con interfaces abstractas por entidad para poder swap-ear a Supabase después.
2. **Alcance**: app completa — las 9 pantallas del design_spec + una pantalla de Login/Registro nueva (no está en el design_spec; la diseñamos con la misma estética Blueprint) + una pantalla de Settings mínima (implícita por el ícono de configuración del TopAppBar, no detallada en el spec).
3. **Pico y Placa**: siempre Medellín (no multi-ciudad). Tabla exacta de `claude/pico_y_placa_Medellin.md` hardcodeada como constante Dart, con período de vigencia explícito para detectar cuándo quedó desactualizada (rota cada 6 meses). Solo se indica si el vehículo restringe HOY o no (sin franja horaria en la lógica, sin festivos/día sin carro).
4. **Adjuntos de documentos**: selector de imagen/PDF local (mock-friendly, se guarda una ruta local, no upload real a Storage). El "scanner OCR" de las pantallas Registrar Documento y Agregar Vehículo es una simulación (delay falso + autocompletado de 1-2 campos, con aviso visible de que es simulado).
5. **Notificaciones**: `flutter_local_notifications`, recordatorios en 30/15/7/1 días antes del vencimiento de cada documento legal.
6. **Fuente JetBrains Mono**: archivos `.ttf` empaquetados como assets (yo los descargo de la fuente oficial OFL), no `google_fonts` — garantiza renderizado offline desde el primer uso, importante para una app de bitácora vehicular que debe funcionar sin señal.
7. **city_code**: el modelo mock de usuario usa `'MED'` por defecto (el tech_spec real define `'BOG'` como default del schema; esto es una desviación documentada solo en la capa mock, no un cambio al schema real).
8. **Persistencia de sesión**: el login debe sobrevivir un reinicio en frío de la app, usando `flutter_secure_storage`. Esto es una excepción puntual a "todo mock en memoria" (decisión #1): solo la sesión/usuario autenticado persiste entre reinicios; vehículos, tanqueos, documentos y mantenimientos siguen siendo mock en memoria y se resiembran en cada arranque.

---

## Stack y dependencias (`pubspec.yaml`)

```yaml
dependencies:
  flutter_riverpod: ^3.4.2      # state management (sin codegen: Notifier/AsyncNotifier a mano)
  # Navegación: Navigator 2.0 nativo (Router/RouterDelegate/RouteInformationParser
  # del SDK de Flutter) — sin go_router ni otro paquete de routing.
  flutter_local_notifications: ^22.2.0
  timezone: ^0.11.1               # requerido por zonedSchedule; tz fijo a America/Bogota
  image_picker: ^1.2.3
  file_picker: ^11.0.3
  path_provider: ^2.1.6           # copiar archivo elegido a directorio persistente de la app
  fl_chart: ^1.2.0                # curva de rendimiento Km/Gal
  intl: ^0.20.3                   # formato moneda COP y fechas es_CO
  uuid: ^4.6.0                    # ids mock equivalentes a gen_random_uuid()
  flutter_secure_storage: ^10.3.1 # persistencia segura de sesión (decisión #8)
  cupertino_icons: ^1.0.8         # ya presente

dev_dependencies:
  flutter_lints: ^6.0.0           # ya presente
```

Sin `build_runner`/codegen (ni Riverpod ni go_router): con ~14 rutas y 5 modelos no se justifica el paso de compilación extra en esta pasada. Sin `shared_preferences`/DB local para datos de dominio: consistente con "solo mock en memoria" para vehículos/tanqueos/documentos/mantenimiento — se documenta como limitación conocida (esos datos y las preferencias de settings no sobreviven un reinicio en frío) y se resuelve junto con la integración real de Supabase. La única excepción es la sesión de usuario, persistida vía `flutter_secure_storage` (ver sección "Persistencia de sesión").

`flutter_secure_storage: ^10.3.1` requiere `minSdkVersion 23` en Android — el proyecto ya usa `flutter.minSdkVersion` (por defecto `24` en Flutter 3.41.6), así que no requiere subir el mínimo manualmente.

Fuente: `assets/fonts/JetBrainsMono-{Regular,Medium,Bold,Italic}.ttf`, registrados en `flutter.fonts` como familia `JetBrainsMono`.

---

## Estructura de `lib/` (feature-first)

```
lib/
  main.dart                      # bootstrap tz, ProviderScope, runApp
  app.dart                       # MaterialApp.router + tema

  core/
    theme/                       # blueprint_colors, typography, shapes, theme
    widgets/                     # BlueprintScaffold, TopAppBar, BottomNavBar,
                                  # StatusTrafficLight, LifespanBar, KpiCard,
                                  # CountdownChip, FullTankBadge, UploadZone, OcrScanButton
    constants/                   # pico_y_placa_medellin.dart, maintenance_intervals.dart,
                                  # document_reminder_cadence.dart
    router/                      # Navigator 2.0 nativo: app_route_path.dart, app_router_delegate.dart,
                                  # app_route_information_parser.dart, route_paths.dart

  data/
    models/                      # enums.dart, user.dart, vehicle.dart, legal_document.dart,
                                  # fuel_log.dart, maintenance.dart (mapean 1:1 al schema SQL)
    repositories/                # interfaces abstractas por entidad
      mock/                      # implementaciones en memoria (únicas usadas por ahora)
      providers.dart             # Provider<XRepository> — único punto de swap a Supabase
    seed/seed_data.dart          # datos demo, calculados relativos a DateTime.now()

  services/
    notifications/               # notification_service, scheduler, providers
    ocr/ocr_simulation_service.dart
    attachments/attachment_picker_service.dart
    session/
      session_store.dart              # interfaz abstracta (save/read/clear)
      secure_session_store.dart        # impl con flutter_secure_storage
      session_providers.dart

  features/
    auth/            # login_screen, register_screen, auth_controller
    dashboard/       # vehicle_selector, odometer_quick_update, pico_y_placa_card, document_status_row
    fuel/            # fuel_metrics_screen, register_fuel_screen, performance_curve_chart, kpi_cards_row
    legal/           # legal_garage_screen, register_document_screen, expiration_countdown
    maintenance/     # maintenance_screen, register_maintenance_screen, lifespan_bar_group
    quick_actions/   # quick_actions_screen (speed-dial a los 3 formularios)
    vehicles/        # add_vehicle_screen
    settings/        # settings_screen
    shell/           # app_shell.dart (StatefulShellRoute: TopAppBar + BottomNavBar)
```

**Modelos y enums**: nombres calcan el SQL (`User`, `Vehicle`, `LegalDocument`, `FuelLog`, `Maintenance`), con enums Dart (`FuelType`, `DocumentType`, `MaintenanceServiceType`) que llevan un `sqlValue`/`fromSqlValue` igual a los `CHECK` del schema, para que una futura serialización a Supabase sea directa. Clases inmutables escritas a mano (`copyWith`/`toJson`/`fromJson`), sin `freezed`/`json_serializable`.

**Repositorios**: interfaz abstracta + CRUD/queries de dominio por entidad (`VehicleRepository`, `FuelLogRepository`, `LegalDocumentRepository`, `MaintenanceRepository`, `UserRepository`). Implementaciones mock en memoria, sembradas desde `seed_data.dart`, con delay simulado para ejercitar estados de carga reales. **Regla de arquitectura**: las features solo dependen de las interfaces + providers, nunca importan `repositories/mock` directamente — así el swap a Supabase después toca solo `data/repositories/providers.dart`.

---

## Providers Riverpod (mapa principal)

| Provider | Tipo | Uso |
|---|---|---|
| `*RepositoryProvider` (x5) | `Provider<T>` | binding a implementación mock |
| `sessionStoreProvider` | `Provider<SessionStore>` | binding a `SecureSessionStore` (flutter_secure_storage) |
| `authControllerProvider` | `NotifierProvider` | login/registro/logout mock, usuario actual, estado `unknown/unauthenticated/authenticated` (restaura sesión al iniciar) |
| `vehiclesProvider` | `AsyncNotifierProvider` | lista CRUD de vehículos del usuario |
| `selectedVehicleIdProvider` / `selectedVehicleProvider` | `Notifier` / derivado | vehículo activo entre tabs |
| `fuelLogsProvider(vehicleId)` | `AsyncNotifierProvider.family` | tanqueos por vehículo |
| `fuelMetricsProvider(vehicleId)` | derivado | KPIs + curva Km/Gal (cálculo puro) |
| `legalDocumentsProvider(vehicleId)` / `documentStatusProvider` | `AsyncNotifierProvider.family` / derivado | documentos + semáforo |
| `picoYPlacaTodayProvider(plate)` | derivado | restricción hoy + alerta de vigencia vencida |
| `maintenanceRecordsProvider(vehicleId)` / `lifespanProvider` | `AsyncNotifierProvider.family` / derivado | historial + barras de vida útil |
| `notificationSchedulerProvider` | `Provider` | agenda/cancela recordatorios locales |
| `settingsProvider` | `Notifier` | toggle notificaciones, ciudad fija |

Toda mutación sigue: llamar repositorio → `ref.invalidate` de los providers dependientes, para que Dashboard/Gasolina/Taller reflejen el cambio de inmediato.

---

## Routing (Navigator 2.0 nativo de Flutter, sin go_router)

Sin paquetes de routing de terceros. Se usa el API declarativo del SDK (`Router`, `RouterDelegate`, `RouteInformationParser`), integrado con Riverpod:

- **`AppRoutePath`** (`core/router/app_route_path.dart`): value type inmutable que representa el estado de navegación completo — `AppRoutePath.login()`, `AppRoutePath.register()`, `AppRoutePath.authenticated(tabIndex, pushedRoute)`, donde `pushedRoute` es un enum/sealed opcional (`SettingsRoute`, `AddVehicleRoute`, `RegisterFuelRoute`, `RegisterDocumentRoute({DocumentType? prefilledType})`, `RegisterMaintenanceRoute`) o `null` si solo se ve el shell con tabs.
- **`AppRouterDelegate`** (`extends RouterDelegate<AppRoutePath> with ChangeNotifier, PopNavigatorRouterDelegateMixin`): mantiene el `GlobalKey<NavigatorState>` y construye la pila de `Page`s en `build()`, leyendo `authControllerProvider.status`:
  - `unknown` (restaurando sesión desde `flutter_secure_storage`, ver sección "Persistencia de sesión") → `[MaterialPage(child: SplashScreen())]`, una pantalla mínima con el spinner/branding Blueprint.
  - `unauthenticated` → `[MaterialPage(child: LoginScreen())]` o `[..., MaterialPage(child: RegisterScreen())]`.
  - `authenticated` → `[MaterialPage(child: AppShell(tabIndex: ...))]` + una página adicional por cada `pushedRoute` en una pila interna (`List<AppPushedRoute> _pushedStack`) que el delegate expone vía métodos imperativos: `pushSettings()`, `pushAddVehicle()`, `pushRegisterFuel()`, `pushRegisterDocument({type})`, `pushRegisterMaintenance()`, y `popRoute()`/`onPopPage` para los botones de retroceso y el botón atrás del sistema (Android).
  - El índice de tab seleccionado (Inicio/Gasolina/Acciones/Legal/Taller) vive en un provider Riverpod simple (no en la pila de páginas), ya que las 5 pantallas del bottom nav no tienen historial propio — el `AppShell` solo muestra la pantalla del tab activo dentro de un `IndexedStack`.
  - El delegate se suscribe (constructor) a `authControllerProvider` (vía el `Ref` que recibe `app.dart`) para llamar `notifyListeners()` cuando cambia el estado de auth, limpiando `_pushedStack` en logout.
- **`AppRouteInformationParser`** (`extends RouteInformationParser<AppRoutePath>`): traduce `RouteInformation` (ruta inicial / restauración de estado) hacia/desde `AppRoutePath` usando los mismos strings de ruta (`/login`, `/dashboard`, `/settings`, etc.) por legibilidad y para integrarse de forma estándar con el botón atrás predictivo de Android — aunque no se usa deep-linking real en esta pasada.
- **`app.dart`**: `MaterialApp.router(routerDelegate: _delegate, routeInformationParser: _parser, backButtonDispatcher: RootBackButtonDispatcher())`, dentro de un `ConsumerWidget` que crea el delegate una sola vez (`useMemoized`-style vía `late final` en un `StatefulWidget` envolvente) y hace `ref.listen(authControllerProvider, (_, __) => delegate.notifyListeners())`.

```
Rutas lógicas (strings usados solo por el parser, no URLs reales):
/login, /register                         (fuera del shell)
Shell (TopAppBar + BottomNavBar, IndexedStack por tabIndex)
  tab 0  Inicio        (Dashboard)
  tab 1  Gasolina      (Tanqueos y Consumo)
  tab 2  Acciones      (Acciones Rápidas)
  tab 3  Legal         (Garaje Legal)
  tab 4  Taller        (Mantenimientos y Taller)
/settings, /vehicles/add,
/fuel/register, /legal/register, /maintenance/register   (pusheadas sobre el shell, con botón atrás)
```

Dos variantes de AppBar comparten tokens visuales: `BlueprintTopAppBar` (avatar + settings, solo en el shell) y `BlueprintFormAppBar` (botón atrás, en pantallas pusheadas). La navegación desde widgets (botones, FABs) se hace resolviendo el `AppRouterDelegate` vía `Router.of(context).routerDelegate` o exponiéndolo como un provider (`appRouterDelegateProvider`) para llamarlo desde código Riverpod sin `BuildContext`.

---

## Tema Blueprint

- Colores base del spec: `background #0B1623`, `gridLine #1C2B3A`, `accentOrange #FF9F30`, `successGreen #00FF9D`. Colores derivados no especificados por el design_spec (documentados como tal en el código): `surfaceContainerLow`, `outlineVariant`, `textPrimary`, `textMuted`.
- Tipografía JetBrains Mono (assets empaquetados) mapeada a `TextTheme` (`headlineLarge` para el wordmark, `titleLarge` para el TopAppBar, `labelMedium` para el bottom nav).
- Forma compartida: `RoundedRectangleBorder` con radio 0 aplicado globalmente (cards, inputs, botones) para las "esquinas afiladas, bordes industriales".
- `BlueprintScaffold`: envuelve `Scaffold` pintando el grid overlay con un `CustomPainter`.

---

## Pico y Placa (constante + lógica)

`lib/core/constants/pico_y_placa_medellin.dart` — estructura `PicoYPlacaSchedule` con `effectivePeriodLabel`, `effectiveFrom`/`effectiveTo` y un mapa `día de semana → dígitos restringidos`, poblado exactamente con la tabla de `claude/pico_y_placa_Medellin.md` (Lunes 0-2, Martes 6-9, Miércoles 3-7, Jueves 4-8, Viernes 1-5). Función `isVehicleRestrictedToday(plate, today)` para el indicador del Dashboard, y `isPicoYPlacaScheduleStale(now)` que dispara un banner de advertencia visible cuando pase el semestre vigente (para que la desactualización de la tabla sea obvia, no silenciosa, dado que rota cada 6 meses).

---

## Persistencia de sesión (`flutter_secure_storage`)

**Qué se persiste**: como el backend es mock (no hay token real de Supabase todavía), se guarda el perfil mínimo del usuario autenticado como JSON bajo una sola clave (`session_user`): `{id, email, fullName, cityCode}`. No es un token de sesión real — es el mismo objeto `AppUser` serializado, suficiente para restaurar el estado "autenticado" sin depender del repositorio mock (que se resiembra vacío en cada arranque).

**Por qué no basta con guardar solo el `userId`**: los repositorios mock viven en memoria y se re-siembran en cada `flutter run`. Si un usuario se registró (no es el usuario semilla) y cerramos/reabrimos la app, ese id ya no existiría en el `UserRepository` recién sembrado — restaurar la sesión solo por id fallaría o apuntaría a un usuario fantasma. Por eso se persiste el perfil completo y, al restaurar, se hace un `upsert` de ese `AppUser` en el `UserRepository` mock antes de marcar el estado como `authenticated`, para que el resto de la app (que lee "usuario actual" vía el repositorio) sea consistente.

**Flujo en `AuthController`**:
- Al construirse, dispara `_restoreSession()`: `sessionStoreProvider.read()` → si hay datos, decodifica, hace upsert en `userRepositoryProvider`, estado → `authenticated(user)`; si no hay nada o el JSON es inválido/corrupto → `unauthenticated`. Mientras se resuelve esta lectura async, el estado es `unknown` (ver Splash en Routing).
- `login(...)` / `register(...)` exitosos → `sessionStoreProvider.save(user)` además de fijar el estado en memoria.
- `logout()` → `sessionStoreProvider.clear()` + estado `unauthenticated`. Solo borra la sesión, no los datos mock de vehículos/documentos/etc. (esos ya son volátiles por diseño).

**`SessionStore`** (`services/session/session_store.dart`): interfaz abstracta (`Future<void> save(AppUser)`, `Future<AppUser?> read()`, `Future<void> clear()`) — mismo patrón repositorio-interfaz-swap que el resto del proyecto. `SecureSessionStore` es la única implementación, envolviendo una instancia inyectada de `FlutterSecureStorage` (no un singleton estático global) para que los tests puedan sustituir un `InMemorySessionStore` fake sin tocar el plugin nativo.

**Configuración Android**: agregar `android:allowBackup="false"` al tag `<application>` de `AndroidManifest.xml` — es la recomendación del paquete para evitar que Android intente respaldar/restaurar el archivo de `EncryptedSharedPreferences` a través de Auto Backup (puede causar `InvalidKeyException` si se restaura en un dispositivo distinto). Dado que en esta pasada no hay ningún otro dato de usuario que valga la pena respaldar (todo lo demás es mock), desactivar el backup completo es aceptable; si más adelante se agrega persistencia real de datos de dominio, se puede refinar con `dataExtractionRules`/`fullBackupContent` para excluir solo el archivo de secure storage. `minSdkVersion` ya es 24 (por defecto de Flutter), por encima del mínimo 23 que exige el paquete — no se requiere subir el mínimo.

**Configuración iOS**: no se requiere entitlement de Keychain Sharing (`keychain-access-groups`) porque no hay extensiones de la app compartiendo el Keychain — el uso por defecto del plugin en un solo target funciona sin configuración adicional. Se fija `IOSOptions(accessibility: KeychainAccessibility.first_unlock)` explícitamente (en vez del default `unlocked`) para que la sesión pueda restaurarse aunque el usuario abra la app antes del primer desbloqueo manual tras un reinicio del dispositivo — apropiado para un login "silencioso" al arrancar.

---

## Pantallas (9 del design_spec + Login/Registro + Settings)

Cada pantalla usa `BlueprintScaffold` + los widgets compartidos (`TopAppBar`/`BottomNavBar` del JSON del design_spec) y lee de los providers de la tabla anterior:

- **Splash** (nueva, mínima): se muestra mientras `authControllerProvider` restaura la sesión desde `flutter_secure_storage` al arrancar la app; branding Blueprint + spinner, sin providers de dominio.
- **Login / Registro** (nuevas): formulario mock, sin backend real; registro fija `cityCode: 'MED'`. Si ya existe una sesión persistida válida, el usuario nunca ve estas pantallas al reabrir la app — pasa directo de Splash a Dashboard.
- **Dashboard**: selector de vehículo, actualización rápida de odómetro, indicador Pico y Placa (+ alerta de vigencia), semáforo SOAT/RTM.
- **Tanqueos y Consumo**: curva Km/Gal (`fl_chart`, solo con tanqueos "full tank"), KPI cards costo/km, historial con badges.
- **Garaje Legal**: tabs Vehículo/Impuestos/Conductor, countdown de vencimiento, botón de vista previa de documento.
- **Mantenimientos y Taller**: barras de vida útil (Aceite/Llantas/Frenos, con intervalos por defecto configurables como constantes), historial segmentado Preventivo/Correctivo.
- **Acciones Rápidas**: accesos directos a los 3 formularios.
- **Registrar Tanqueo / Registrar Documento / Registrar Mantenimiento**: formularios según spec, con `UploadZone` y `OcrScanButton` (simulado) donde aplica.
- **Agregar Vehículo**: placa, marca/modelo/año, tipo de combustible, odómetro inicial, scanner OCR simulado.
- **Settings** (nueva, placeholder ligero): ciudad fija (Medellín), toggle de notificaciones, cerrar sesión.

---

## Notificaciones locales

- Cadencia: 30/15/7/1 días antes de `expiration_date` (no se agendan recordatorios con fecha ya pasada).
- IDs determinísticos por (documento, offset) para que reprogramar sea idempotente.
- Zona horaria fija `America/Bogota` (Colombia no tiene DST).
- Disparadores: crear/editar documento → cancelar y reprogramar sus recordatorios; eliminar → cancelar; login/inicio de app → reconciliación completa (`cancelAll` + reprogramar todo lo que exista en el repo mock); toggle de settings apagado → `cancelAll`.
- Permisos: pedidos justo después del primer login exitoso (Android 13+ `POST_NOTIFICATIONS`, iOS `requestPermissions`), usando `AndroidScheduleMode.inexactAllowWhileIdle` para evitar el permiso de alarma exacta.

---

## Datos semilla (demo)

`data/seed/seed_data.dart`, calculados relativos a `DateTime.now()` para que la demo se vea vigente sin importar cuándo se ejecute: 1 usuario, 1 vehículo (placa con dígito que sí cae en alguna restricción de la semana), ~6 tanqueos (mezcla full/parcial), 4 documentos legales (uno por vencer pronto, uno vencido, dos vigentes lejanos) y 3-4 registros de mantenimiento (uno próximo a vencer por km, uno vencido, uno reciente).

---

## Verificación

1. `flutter analyze` sin issues; `dart format --set-exit-if-changed lib test`.
2. Tests unitarios: lógica de Pico y Placa (todas las combinaciones día×dígito de la tabla real), cálculo de métricas de combustible (curva solo con full-tank, costo/km con todos), cálculo de vida útil de mantenimiento, CRUD de repositorios mock, roundtrip de `SessionStore` (save→read→clear) contra un fake en memoria.
3. Test de widget: reemplazar `test/widget_test.dart` (hoy prueba el contador) por un smoke test que monta la app con `ProviderScope` y repos sembrados, verificando que el Dashboard muestra el vehículo semilla; agregar un caso con `sessionStoreProvider` override devolviendo una sesión existente y verificar que la app arranca directo en Dashboard (sin pasar por Login).
4. Recorrido manual end-to-end con `flutter run`: Login → Dashboard (verificar Pico y Placa del día real y semáforo de documentos) → Agregar Vehículo (probar simulación OCR) → Registrar Tanqueo (ver reflejo en Gasolina) → Registrar Documento (ver countdown y semáforo actualizado) → Registrar Mantenimiento (ver barra de vida útil actualizada) → Settings (toggle notificaciones, cerrar sesión) → vuelta a Login.
5. **Verificación específica de persistencia de sesión**: iniciar sesión → forzar cierre completo de la app (no hot restart, sino matar el proceso/swipe-close) → reabrir → debe aparecer brevemente Splash y luego ir directo a Dashboard sin pedir login de nuevo. Luego, desde Settings, "Cerrar sesión" → cerrar y reabrir la app → debe aparecer Login (sesión limpiada correctamente).

### Archivos críticos
- `lib/core/router/app_router_delegate.dart`
- `lib/core/router/app_route_path.dart`
- `lib/data/repositories/providers.dart`
- `lib/core/theme/blueprint_theme.dart`
- `lib/core/constants/pico_y_placa_medellin.dart`
- `lib/services/session/secure_session_store.dart`
- `lib/features/auth/application/auth_controller.dart`
- `lib/services/notifications/notification_scheduler.dart`
- `lib/data/seed/seed_data.dart`
