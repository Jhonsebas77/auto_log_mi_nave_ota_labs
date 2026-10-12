import 'package:auto_log_mi_nave_ota_labs/core/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('copFormat', () {
    // El espacio entre "$" y el número es no separable (U+00A0).
    test('pone el símbolo adelante con punto de miles', () {
      expect(copFormat.format(240000), '\$ 240.000');
      expect(copFormat.format(12845000), '\$ 12.845.000');
    });

    test('redondea a pesos enteros', () {
      expect(copFormat.format(312.4), '\$ 312');
      expect(copFormat.format(0), '\$ 0');
    });
  });
}
