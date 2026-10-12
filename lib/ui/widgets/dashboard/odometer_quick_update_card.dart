part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class OdometerQuickUpdateCard extends ConsumerWidget {
  const OdometerQuickUpdateCard({required this.vehicle, super.key});

  final Vehicle vehicle;

  static const Logger _log = Logger('OdometerQuickUpdateCard');

  Future<void> _showUpdateDialog(BuildContext context, WidgetRef ref) async {
    int? result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) =>
          OdometerUpdateDialog(currentOdometer: vehicle.currentOdometer),
    );
    // El diálogo ya garantiza result >= odómetro actual; igual no se llama
    // al servidor si no cambió.
    if (result == null || result == vehicle.currentOdometer) return;
    try {
      await ref
          .read(vehiclesProvider.notifier)
          .bumpOdometer(vehicle.id, result);
    } catch (e) {
      _log.error('bumpOdometer(${vehicle.id}): $e');
      if (context.mounted) {
        showErrorSnackBar(context, 'No se pudo actualizar el odómetro.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: BlueprintColors.surfaceContainerLow,
      border: Border.all(color: BlueprintColors.outlineVariant),
    ),
    child: Row(
      children: <Widget>[
        const Icon(Icons.speed, color: BlueprintColors.accentOrange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Odómetro actual', style: AppTextStyles.bodySmall),
              Text(
                '${integerFormat.format(vehicle.currentOdometer)} km',
                style: AppTextStyles.titleLarge,
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => _showUpdateDialog(context, ref),
          child: const Text('Actualizar'),
        ),
      ],
    ),
  );
}

/// Diálogo para subir el odómetro. Es dueño de su [TextEditingController]:
/// liberarlo desde quien llama a `showDialog` justo al cerrarse lo hacía
/// mientras el campo seguía montado durante la animación de salida.
///
/// Devuelve el nuevo valor (siempre >= [currentOdometer]) o `null` si se
/// cancela. Un valor menor no se puede guardar — el servidor lo ignoraría
/// (`bumpOdometerIfHigher`) — así que se avisa en el campo en vez de cerrar.
class OdometerUpdateDialog extends StatefulWidget {
  const OdometerUpdateDialog({required this.currentOdometer, super.key});

  final int currentOdometer;

  @override
  State<OdometerUpdateDialog> createState() => _OdometerUpdateDialogState();
}

class _OdometerUpdateDialogState extends State<OdometerUpdateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentOdometer.toString(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    int? km = int.tryParse(value?.trim() ?? '');
    if (km == null) return 'Ingresa el odómetro en km.';
    if (km < widget.currentOdometer) {
      return 'Debe ser mayor o igual a '
          '${integerFormat.format(widget.currentOdometer)} km.';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, int.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: BlueprintColors.surfaceContainerLow,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    title: const Text('Actualizar odómetro'),
    content: Form(
      key: _formKey,
      child: BlueprintTextField(
        label: 'Odómetro (km)',
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator: _validate,
        onFieldSubmitted: (_) => _submit(),
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      TextButton(onPressed: _submit, child: const Text('Guardar')),
    ],
  );
}
