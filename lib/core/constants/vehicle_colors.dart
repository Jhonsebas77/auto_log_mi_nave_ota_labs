part of com.auto_log_mi_nave_ota_labs.app.core.constants;

/// Preset rápido para `BlueprintColorPicker` — un tap rellena el hex. Ya no
/// es la forma de guardar el color (ver `Vehicle.color`, que ahora persiste
/// un hex `#RRGGBB`); se mantiene solo como sugerencias de un tap.
class VehicleColorOption {
  const VehicleColorOption(this.label, this.swatch);

  final String label;
  final Color swatch;
}

const List<VehicleColorOption> kVehicleColorOptions = <VehicleColorOption>[
  VehicleColorOption('Blanco', Color(0xFFF5F5F5)),
  VehicleColorOption('Negro', Color(0xFF1A1A1A)),
  VehicleColorOption('Gris', Color(0xFF9E9E9E)),
  VehicleColorOption('Plata', Color(0xFFC7CBCF)),
  VehicleColorOption('Rojo', Color(0xFFD32F2F)),
  VehicleColorOption('Azul', Color(0xFF1976D2)),
  VehicleColorOption('Verde', Color(0xFF388E3C)),
  VehicleColorOption('Amarillo', Color(0xFFFBC02D)),
  VehicleColorOption('Naranja', Color(0xFFF57C00)),
  VehicleColorOption('Café', Color(0xFF6D4C41)),
];

/// Color de respaldo cuando `Vehicle.color` no es un hex válido ni coincide
/// con ningún label legacy.
const Color kVehicleColorFallback = Color(0xFF7C93A8);

final RegExp _hexColorPattern = RegExp(r'^[0-9a-fA-F]{6}$');

/// Parsea un color en formato `#RRGGBB`, `RRGGBB`, `#RGB` o `RGB`. Retorna
/// `null` si `input` no es un hex válido (p. ej. es un label legacy como
/// `'Rojo'`).
Color? colorFromHex(String input) {
  String hex = input.trim().replaceFirst('#', '');
  if (hex.length == 3) {
    hex = hex.split('').map((String c) => '$c$c').join();
  }
  if (!_hexColorPattern.hasMatch(hex)) return null;
  return Color(0xFF000000 | int.parse(hex, radix: 16));
}

/// Formatea [color] como `RRGGBB` (o `#RRGGBB` si [includeHash] es true),
/// ignorando el canal alpha.
String colorToHex(Color color, {bool includeHash = true}) {
  String hex = color
      .toARGB32()
      .toRadixString(16)
      .padLeft(8, '0')
      .substring(2)
      .toUpperCase();
  return includeHash ? '#$hex' : hex;
}

/// Resuelve `vehicle.color` a un [Color] real. Antes del selector RGB/hex,
/// `color` guardaba un label fijo (p. ej. `'Rojo'`, ver [kVehicleColorOptions]
/// y `demo_seed.dart`) — se sigue soportando ese formato para no romper datos
/// existentes, pero los vehículos nuevos guardan directamente un hex
/// `#RRGGBB` (ver `BlueprintColorPicker`).
Color colorSwatchForVehicle(String color) {
  Color? hex = colorFromHex(color);
  if (hex != null) return hex;
  for (VehicleColorOption option in kVehicleColorOptions) {
    if (option.label.toLowerCase() == color.toLowerCase()) return option.swatch;
  }
  return kVehicleColorFallback;
}
