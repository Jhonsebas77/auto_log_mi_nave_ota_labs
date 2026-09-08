part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Decide qué pantalla raíz mostrar según `AuthStatus`. Reemplaza la lógica
/// que antes vivía en el ya borrado `AppRouterDelegate.build()`: al pasar de
/// Navigator 2.0 (RouterDelegate declarativo) a Navigator 1.0 clásico
/// (`CustomNavigator`), ya no hay nada reactivo por defecto — este widget
/// cumple ese rol como `home:` de `MaterialApp`.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  static const Logger _log = Logger('AuthGate');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authControllerProvider, (
      AuthState? previous,
      AuthState next,
    ) {
      // Si se cierra sesión (o expira el token) con pantallas pusheadas
      // encima (ej. Settings), hay que volver a la raíz a mano — a
      // diferencia del AppRouterDelegate que reemplaza, Navigator 1.0 no
      // limpia solo el stack cuando cambia el estado de auth.
      if (previous?.status == AuthStatus.authenticated &&
          next.status != AuthStatus.authenticated) {
        Navigator.of(
          context,
        ).popUntil((Route<dynamic> route) => route.isFirst);
      }

      // Sesión cerrada por el propio AuthController (ej. no se pudo
      // refrescar el token por falta de conexión), no por un logout manual
      // del usuario: avisar con un snackbar antes de caer al login.
      String? errorMessage = next.errorMessage;
      if (errorMessage != null) {
        _log.error('authControllerProvider: $errorMessage');
        showErrorSnackBar(context, errorMessage);
      }
    });

    AuthStatus status = ref.watch(authControllerProvider).status;
    return switch (status) {
      AuthStatus.unknown => const SplashScreen(),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => const AppShell(),
    };
  }
}
