import 'package:auto_log_mi_nave_ota_labs/core/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DateTime now = DateTime(2026, 1, 1, 12);

  group('LoginThrottleController.cooldownFor', () {
    test('los 2 primeros fallos no tienen espera y luego se duplica', () {
      expect(LoginThrottleController.cooldownFor(1), Duration.zero);
      expect(LoginThrottleController.cooldownFor(2), Duration.zero);
      expect(
        LoginThrottleController.cooldownFor(3),
        const Duration(seconds: 5),
      );
      expect(
        LoginThrottleController.cooldownFor(4),
        const Duration(seconds: 10),
      );
      expect(
        LoginThrottleController.cooldownFor(5),
        const Duration(seconds: 20),
      );
    });

    test('tiene un tope de 5 minutos, incluso con muchísimos fallos', () {
      expect(
        LoginThrottleController.cooldownFor(10),
        LoginThrottleController.maxCooldown,
      );
      expect(
        LoginThrottleController.cooldownFor(1000),
        LoginThrottleController.maxCooldown,
      );
    });
  });

  group('LoginThrottleController', () {
    late ProviderContainer container;
    LoginThrottleController controller() =>
        container.read(loginThrottleProvider.notifier);
    LoginThrottleState state() => container.read(loginThrottleProvider);

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('bloquea a partir del tercer fallo seguido', () {
      controller()
        ..registerFailure(now)
        ..registerFailure(now);
      expect(state().remaining(now), Duration.zero);

      controller().registerFailure(now);
      expect(state().failures, 3);
      expect(state().remaining(now), const Duration(seconds: 5));
      expect(
        state().remaining(now.add(const Duration(seconds: 5))),
        Duration.zero,
      );
    });

    test('un 429 de Supabase bloquea al menos 1 minuto', () {
      controller().registerRateLimited(now);
      expect(
        state().remaining(now),
        LoginThrottleController.rateLimitedCooldown,
      );
    });

    test('un 429 no acorta una espera más larga que ya estaba activa', () {
      for (int i = 0; i < 10; i++) {
        controller().registerFailure(now);
      }
      controller().registerRateLimited(now);
      expect(state().remaining(now), LoginThrottleController.maxCooldown);
    });

    test('un login exitoso reinicia el contador', () {
      for (int i = 0; i < 4; i++) {
        controller().registerFailure(now);
      }
      controller().reset();
      expect(state().failures, 0);
      expect(state().remaining(now), Duration.zero);
    });
  });

  test('loginCooldownMessage muestra segundos o minutos', () {
    expect(
      loginCooldownMessage(const Duration(milliseconds: 4200)),
      'Demasiados intentos fallidos. Espera 5 s para volver a intentar.',
    );
    expect(
      loginCooldownMessage(const Duration(seconds: 90)),
      'Demasiados intentos fallidos. Espera 2 min para volver a intentar.',
    );
  });
}
