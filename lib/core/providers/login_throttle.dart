part of com.auto_log_mi_nave_ota_labs.app.core.providers;

/// Estado del freno de intentos de login.
///
/// OJO: esto es una medida de UX, no de seguridad. La publishable key es
/// pública y cualquiera puede llamar a Supabase Auth sin pasar por la app;
/// la protección real contra fuerza bruta es del lado del servidor (rate
/// limit de GoTrue, CAPTCHA, MFA). Esto solo evita martillar el botón y
/// explica por qué hay que esperar.
class LoginThrottleState {
  const LoginThrottleState({this.failures = 0, this.lockedUntil});

  /// Intentos fallidos seguidos (contraseña incorrecta) desde el último
  /// login exitoso.
  final int failures;

  /// Hasta cuándo no se permite un nuevo intento, si aplica.
  final DateTime? lockedUntil;

  static const LoginThrottleState initial = LoginThrottleState();

  /// Cuánto falta para poder intentar de nuevo ([Duration.zero] si ya se
  /// puede).
  Duration remaining(DateTime now) {
    DateTime? until = lockedUntil;
    if (until == null || !until.isAfter(now)) return Duration.zero;
    return until.difference(now);
  }
}

class LoginThrottleController extends Notifier<LoginThrottleState> {
  /// Fallos permitidos sin espera.
  static const int freeAttempts = 2;

  /// Espera tras el primer fallo que ya no es "gratis"; se duplica con cada
  /// fallo adicional hasta [maxCooldown].
  static const Duration baseCooldown = Duration(seconds: 5);
  static const Duration maxCooldown = Duration(minutes: 5);

  /// Espera mínima cuando es Supabase quien rechaza por exceso de intentos
  /// (HTTP 429): su ventana de rate limit es de minutos, así que reintentar
  /// antes solo vuelve a fallar.
  static const Duration rateLimitedCooldown = Duration(minutes: 1);

  /// Espera que corresponde tras [failures] fallos seguidos: 1–2 → ninguna,
  /// 3 → 5 s, 4 → 10 s, 5 → 20 s… hasta 5 min.
  static Duration cooldownFor(int failures) {
    int exponent = failures - freeAttempts - 1;
    if (exponent < 0) return Duration.zero;
    // Tope al exponente para no desbordar con muchos fallos.
    int seconds = baseCooldown.inSeconds * (1 << math.min(exponent, 16));
    return Duration(seconds: math.min(seconds, maxCooldown.inSeconds));
  }

  @override
  LoginThrottleState build() => LoginThrottleState.initial;

  void registerFailure(DateTime now) {
    int failures = state.failures + 1;
    Duration cooldown = cooldownFor(failures);
    state = LoginThrottleState(
      failures: failures,
      lockedUntil: cooldown == Duration.zero ? null : now.add(cooldown),
    );
  }

  void registerRateLimited(DateTime now) {
    DateTime until = now.add(rateLimitedCooldown);
    DateTime? current = state.lockedUntil;
    state = LoginThrottleState(
      failures: state.failures,
      lockedUntil: current != null && current.isAfter(until) ? current : until,
    );
  }

  void reset() => state = LoginThrottleState.initial;
}

final NotifierProvider<LoginThrottleController, LoginThrottleState>
loginThrottleProvider =
    NotifierProvider<LoginThrottleController, LoginThrottleState>(
      LoginThrottleController.new,
    );

/// Mensaje para mostrar mientras hay que esperar.
String loginCooldownMessage(Duration remaining) {
  int seconds = (remaining.inMilliseconds / 1000).ceil();
  String wait = seconds >= 60 ? '${(seconds / 60).ceil()} min' : '$seconds s';
  return 'Demasiados intentos fallidos. Espera $wait para volver a intentar.';
}
