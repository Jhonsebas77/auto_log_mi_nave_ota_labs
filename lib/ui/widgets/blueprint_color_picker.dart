part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// `Color.red`/`.green`/`.blue` (0-255 int) están deprecados en favor de los
/// componentes `.r`/`.g`/`.b` (double 0.0-1.0) — este helper hace la
/// conversión de vuelta a 0-255 para los sliders.
int _colorChannel255(double component) => (component * 255.0).round().clamp(
  0,
  255,
);

/// Selector de color RGB/hex del vehículo (reemplaza la paleta fija de
/// chips). El swatch de previsualización, los tres sliders R/G/B y el
/// campo hex se mantienen siempre sincronizados entre sí.
class BlueprintColorPicker extends StatefulWidget {
  const BlueprintColorPicker({
    required this.colorHex,
    required this.onChanged,
    super.key,
  });

  /// Color actual, en formato `#RRGGBB` (o `RRGGBB`).
  final String colorHex;
  final ValueChanged<String> onChanged;

  @override
  State<BlueprintColorPicker> createState() => _BlueprintColorPickerState();
}

class _BlueprintColorPickerState extends State<BlueprintColorPicker> {
  late Color _color;
  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _color = colorFromHex(widget.colorHex) ?? kVehicleColorFallback;
    _hexController = TextEditingController(
      text: colorToHex(_color, includeHash: false),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _emit(Color color) {
    setState(() => _color = color);
    widget.onChanged(colorToHex(color));
  }

  /// El usuario escribe/pega un hex directamente.
  void _onHexChanged(String value) {
    Color? parsed = colorFromHex(value);
    if (parsed == null) return; // aún incompleto/inválido: no interrumpe.
    _emit(parsed);
  }

  /// El usuario mueve uno de los sliders R/G/B.
  void _updateChannel({int? red, int? green, int? blue}) {
    Color updated = Color.fromARGB(
      255,
      red ?? _colorChannel255(_color.r),
      green ?? _colorChannel255(_color.g),
      blue ?? _colorChannel255(_color.b),
    );
    _hexController.text = colorToHex(updated, includeHash: false);
    _emit(updated);
  }

  void _applyPreset(Color preset) {
    _hexController.text = colorToHex(preset, includeHash: false);
    _emit(preset);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: _color,
              border: Border.all(color: BlueprintColors.outlineVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BlueprintTextField(
              label: 'Hex',
              controller: _hexController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              onChanged: _onHexChanged,
              validator: (String? v) => colorFromHex(v ?? '') == null
                  ? 'Hex inválido (ej. FF5733).'
                  : null,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      _ColorChannelSlider(
        label: 'R',
        value: _colorChannel255(_color.r),
        trackColor: const Color(0xFFFF6B6B),
        onChanged: (int v) => _updateChannel(red: v),
      ),
      _ColorChannelSlider(
        label: 'G',
        value: _colorChannel255(_color.g),
        trackColor: const Color(0xFF6BCB77),
        onChanged: (int v) => _updateChannel(green: v),
      ),
      _ColorChannelSlider(
        label: 'B',
        value: _colorChannel255(_color.b),
        trackColor: const Color(0xFF4D96FF),
        onChanged: (int v) => _updateChannel(blue: v),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          for (final VehicleColorOption option in kVehicleColorOptions)
            Tooltip(
              message: option.label,
              child: InkWell(
                onTap: () => _applyPreset(option.swatch),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: option.swatch,
                    border: Border.all(color: BlueprintColors.outlineVariant),
                  ),
                ),
              ),
            ),
        ],
      ),
    ],
  );
}

class _ColorChannelSlider extends StatelessWidget {
  const _ColorChannelSlider({
    required this.label,
    required this.value,
    required this.trackColor,
    required this.onChanged,
  });

  final String label;
  final int value;
  final Color trackColor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      SizedBox(
        width: 16,
        child: Text(label, style: AppTextStyles.bodySmall),
      ),
      Expanded(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: trackColor,
            thumbColor: trackColor,
            overlayColor: trackColor.withAlpha(40),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            divisions: 255,
            onChanged: (double v) => onChanged(v.round()),
          ),
        ),
      ),
      SizedBox(
        width: 32,
        child: Text(
          '$value',
          textAlign: TextAlign.end,
          style: AppTextStyles.bodySmall,
        ),
      ),
    ],
  );
}
