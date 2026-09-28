part of com.auto_log_mi_nave_ota_labs.app.core.providers;

class AuthState {
  const AuthState({required this.status, this.user, this.errorMessage});

  factory AuthState.authenticated(AppUser user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  /// Sesión cerrada porque no se pudo validar (ej. falla de red al refrescar
  /// el token) en vez de un logout explícito del usuario — `errorMessage` se
  /// muestra una sola vez, vía snackbar, en `AuthGate`.
  factory AuthState.unauthenticatedWithError(String errorMessage) =>
      AuthState(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  static const AuthState unknown = AuthState(status: AuthStatus.unknown);
  static const AuthState unauthenticated = AuthState(
    status: AuthStatus.unauthenticated,
  );

  /// Igualdad estructural (por `status` + `user.id`): evita que Riverpod
  /// notifique un rebuild cuando el listener de Supabase reemite el mismo
  /// estado que ya teníamos (ver comentario en `_handleAuthStateChange`).
  /// `errorMessage` queda fuera a propósito: es un aviso de una sola vez,
  /// no parte del estado de auth en sí.
  @override
  bool operator ==(Object other) =>
      other is AuthState &&
      status == other.status &&
      user?.id == other.user?.id;

  @override
  int get hashCode => Object.hash(status, user?.id);
}

/// Login contra Supabase Auth. La sesión la persiste `supabase_flutter` con
/// su storage local propio (no hace falta un SessionStore propio); este
/// controller solo traduce el estado de Supabase a [AuthState] y mapea el
/// `User` de Supabase a nuestro [AppUser].
///
/// Nota: los tipos de `supabase_flutter` se usan con el prefijo `sb.` porque
/// el paquete define su propia clase `AuthState`, que choca con la de arriba.
class AuthController extends Notifier<AuthState> {
  static const Logger _log = Logger('AuthController');

  sb.GoTrueClient get _auth => sb.Supabase.instance.client.auth;

  @override
  AuthState build() {
    // `onAuthStateChange` está respaldado por un BehaviorSubject (rxdart):
    // al suscribirnos reemite el último evento — puede llegar antes de que
    // build() siquiera retorne. Por eso NO se usa un campo `late final`
    // (queda "muerto": nunca se lee salvo al disponer, y entonces sí
    // dispara ese replay en mitad de lo que sea que esté construyéndose en
    // ese momento) — se suscribe explícitamente aquí, cancelando al
    // disponer el provider.
    StreamSubscription<sb.AuthState> subscription = _auth.onAuthStateChange
        .listen(_handleAuthStateChange, onError: _handleAuthStateError);
    ref.onDispose(subscription.cancel);

    sb.Session? session = _auth.currentSession;
    if (session != null) {
      unawaited(_afterAuthenticated());
      return AuthState.authenticated(_toAppUser(session.user));
    }
    return AuthState.unauthenticated;
  }

  /// El BehaviorSubject de `onAuthStateChange` puede reemitir el evento
  /// actual de forma síncrona apenas nos suscribimos en `build()` — si eso
  /// pasara mientras build() de este u otro provider/widget sigue en curso,
  /// escribir `state` en el acto revienta con
  /// "setState() or markNeedsBuild() called during build". Se difiere a un
  /// microtask para que la escritura ocurra siempre fuera de cualquier fase
  /// de build. El `==` de [AuthState] evita rebuilds redundantes si el
  /// evento reemitido no cambia nada.
  void _handleAuthStateChange(sb.AuthState data) {
    Future<void>.microtask(() {
      sb.Session? session = data.session;
      state = session == null
          ? AuthState.unauthenticated
          : AuthState.authenticated(_toAppUser(session.user));
    });
  }

  /// GoTrue emite un error por este stream cuando el refresh automático del
  /// token falla de forma "retryable" (típicamente
  /// `AuthRetryableFetchException` por no poder alcanzar Supabase, ej. sin
  /// internet) — a diferencia de un refresh token inválido, en ese caso
  /// GoTrue NO cierra la sesión por su cuenta (sigue reintentando en el
  /// siguiente tick), así que sin este handler el error queda sin capturar
  /// y revienta la app.
  ///
  /// Como no hay red para confirmar si el token sigue siendo válido, no
  /// tiene sentido dejar al usuario en un estado "autenticado" que no se
  /// puede verificar: se cierra la sesión localmente y se avisa con un
  /// mensaje (mostrado una vez, vía `AuthGate`) para que vuelva a iniciar
  /// sesión cuando tenga conexión.
  void _handleAuthStateError(Object error, StackTrace stackTrace) {
    _log.error('onAuthStateChange error: $error');
    Future<void>.microtask(() async {
      state = AuthState.unauthenticatedWithError(_authErrorMessage(error));
      try {
        // Ya se marcó el estado local como no autenticado arriba; este
        // signOut solo intenta avisarle a Supabase, y sin red va a fallar
        // de la misma forma (AuthRetryableFetchException) — se ignora.
        await _auth.signOut(scope: sb.SignOutScope.local);
      } catch (_) {
        // No hay nada más que hacer sin conexión: lo local ya quedó limpio.
      }
    });
  }

  String _authErrorMessage(Object error) =>
      error is sb.AuthRetryableFetchException
      ? 'No se pudo validar tu sesión por falta de conexión. '
            'Inicia sesión de nuevo cuando tengas internet.'
      : 'Tu sesión expiró o no se pudo validar. Inicia sesión de nuevo.';

  AppUser _toAppUser(sb.User user) => AppUser(
    id: user.id,
    email: user.email ?? '',
    fullName:
        (user.userMetadata?['full_name'] as String?) ??
        (user.email?.split('@').first ?? user.id),
    createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
  );

  /// Pide permiso de notificaciones (una vez, en contexto tras el primer
  /// login/restauración exitosa) y reconcilia los recordatorios pendientes.
  ///
  /// A propósito NO dispara acá una carga explícita de `vehiclesProvider`:
  /// `VehiclesNotifier.build()` ya hace `ref.watch(authControllerProvider)`,
  /// así que se recarga solo en cuanto cambia el estado de auth — intentar
  /// leerlo desde este controller (que es justo de quien depende) revienta
  /// con `CircularDependencyError`, sin importar si el `read` se hace en el
  /// acto o diferido a un microtask/Future. El primer consumidor real
  /// (el dashboard, vía `ref.watch(vehiclesProvider)`) es quien dispara el
  /// fetch, ya con el `userId` correcto porque a esa altura el estado de
  /// auth ya está resuelto.
  Future<void> _afterAuthenticated() async {
    await ref.read(notificationServiceProvider).requestPermissions();
    bool notificationsEnabled = ref
        .read(settingsControllerProvider)
        .notificationsEnabled;
    await ref
        .read(notificationReconcilerProvider)
        .reconcileAll(
          now: DateTime.now(),
          notificationsEnabled: notificationsEnabled,
        );
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'Ingresa correo y contraseña.';
    }
    // Freno de UX (ver LoginThrottleState): mientras dure la espera no se
    // llama a Supabase.
    LoginThrottleController throttle = ref.read(loginThrottleProvider.notifier);
    Duration remaining = ref
        .read(loginThrottleProvider)
        .remaining(DateTime.now());
    if (remaining > Duration.zero) return loginCooldownMessage(remaining);
    try {
      sb.AuthResponse response = await _auth.signInWithPassword(
        email: hardcodedEmail.trim(),
        password: password,
      );
      sb.User? user = response.user;
      if (user == null) return 'No fue posible iniciar sesión.';
      throttle.reset();
      state = AuthState.authenticated(_toAppUser(user));
      await _afterAuthenticated();
      return null;
    } on sb.AuthException catch (e) {
      // Supabase rechazó por exceso de intentos (rate limit de GoTrue).
      if (e.statusCode == '429' || e.code == 'over_request_rate_limit') {
        _log.error('login: rate limited (${e.code})');
        DateTime now = DateTime.now();
        throttle.registerRateLimited(now);
        return loginCooldownMessage(
          ref.read(loginThrottleProvider).remaining(now),
        );
      }
      if (e.statusCode == '400') {
        // Solo cuentan los fallos de credenciales: un error de red no es un
        // intento de adivinar la contraseña.
        DateTime now = DateTime.now();
        throttle.registerFailure(now);
        Duration cooldown = ref.read(loginThrottleProvider).remaining(now);
        return cooldown > Duration.zero
            ? 'Correo o contraseña incorrectos. '
                  '${loginCooldownMessage(cooldown)}'
            : 'Correo o contraseña incorrectos.';
      }
      _log.error('login: ${e.message}');
      return 'Lo sentimos, hubo un error.';
    } catch (e) {
      _log.error('login: $e');
      return 'Lo sentimos, hubo un error.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = AuthState.unauthenticated;
  }
}

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
