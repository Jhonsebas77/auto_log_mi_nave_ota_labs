part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class FuelHistoryList extends ConsumerWidget {
  const FuelHistoryList({required this.logs, super.key});

  final List<FuelLog> logs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<FuelLog> descending = logs.reversed.toList();
    return Column(
      children: <Widget>[
        for (final FuelLog log in descending)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: BlueprintColors.outlineVariant),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _formatDate(log.date),
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: <Widget>[
                          Text(
                            '${log.odometer} km · '
                            '${log.gallons.toStringAsFixed(1)} gal',
                            style: AppTextStyles.bodyMedium,
                          ),
                          if (log.isFullTank) ...<Widget>[
                            const SizedBox(width: 8),
                            const FullTankBadge(),
                          ],
                        ],
                      ),
                      if (log.stationName != null)
                        Text(log.stationName!, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      copFormat.format(log.totalCost),
                      style: AppTextStyles.bodyLarge,
                    ),
                    if (log.pricePerGallon != null)
                      Text(
                        '${copFormat.format(log.pricePerGallon)}/gal',
                        style: AppTextStyles.bodySmall,
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: BlueprintColors.danger,
                    size: 20,
                  ),
                  tooltip: 'Eliminar tanqueo',
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => _confirmDelete(context, ref, log),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FuelLog log,
  ) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: BlueprintColors.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('Eliminar tanqueo'),
        content: const Text(
          '¿Seguro que quieres eliminar este registro de tanqueo? '
          'Esta acción no se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(fuelLogActionsProvider).delete(log);
      if (context.mounted) {
        showSuccessSnackBar(context, 'Tanqueo eliminado');
      }
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
