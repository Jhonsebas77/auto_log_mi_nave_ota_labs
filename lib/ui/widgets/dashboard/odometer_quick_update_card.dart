part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class OdometerQuickUpdateCard extends ConsumerWidget {
  const OdometerQuickUpdateCard({required this.vehicle, super.key});

  final Vehicle vehicle;

  static const Logger _log = Logger('OdometerQuickUpdateCard');

  Future<void> _showUpdateDialog(BuildContext context, WidgetRef ref) async {
    TextEditingController controller = TextEditingController(
      text: vehicle.currentOdometer.toString(),
    );
    try {
      int? result = await showDialog<int>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: BlueprintColors.surfaceContainerLow,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: const Text('Actualizar odómetro'),
          content: BlueprintTextField(
            label: 'Odómetro (km)',
            controller: controller,
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, int.tryParse(controller.text)),
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
      if (result != null && result >= vehicle.currentOdometer) {
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
    } finally {
      controller.dispose();
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
                '${vehicle.currentOdometer} km',
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
