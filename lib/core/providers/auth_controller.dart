part of com.auto_log_mi_nave_ota_labs.app.core.providers;

class AuthState {
  const AuthState({required this.status, this.user});

  factory AuthState.authenticated(AppUser user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  final AuthStatus status;
  final AppUser? user;

  static const AuthState unknown = AuthState(status: AuthStatus.unknown);
  static const AuthState unauthenticated = AuthState(
    status: AuthStatus.unauthenticated,
  );

  /// Igualdad estructural (por `status` + `user.id`): evita que Riverpod
  /// notifique un rebuild cuando el listener de Supabase reemite el mismo
  /// estado que ya teníamos (ver comentario en `_handleAuthStateChange`).
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
        .listen(_handleAuthStateChange);
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
    try {
      sb.AuthResponse response = await _auth.signInWithPassword(
        email: hardcodedEmail.trim(),
        password: password,
      );
      sb.User? user = response.user;
      if (user == null) return 'No fue posible iniciar sesión.';
      state = AuthState.authenticated(_toAppUser(user));
      await _afterAuthenticated();
      return null;
    } on sb.AuthException catch (e) {
      return e.statusCode == '400'
          ? 'Correo o contraseña incorrectos.'
          : e.message;
    } catch (e) {
      return 'Ocurrió un error inesperado. Intenta de nuevo.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = AuthState.unauthenticated;
  }
}

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
