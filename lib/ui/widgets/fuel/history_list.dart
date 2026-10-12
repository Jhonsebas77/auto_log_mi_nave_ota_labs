part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Historial de tanqueos como sliver: se usa dentro de un `CustomScrollView`
/// para que la lista virtualice de verdad (solo construye los `Dismissible`
/// visibles en el viewport, no todo el historial en cada rebuild).
class FuelHistorySliver extends ConsumerStatefulWidget {
  const FuelHistorySliver({
    required this.logs,
    this.sortDescending = true,
    super.key,
  });

  /// Siempre ascendente por fecha
  /// (ver `SupabaseFuelLogRepository.getByVehicle`).
  final List<FuelLog> logs;

  /// `true` = más reciente primero, `false` = más antigua primero.
  final bool sortDescending;

  @override
  ConsumerState<FuelHistorySliver> createState() => _FuelHistorySliverState();
}

class _FuelHistorySliverState extends ConsumerState<FuelHistorySliver> {
  static const Logger _log = Logger('FuelHistorySliver');

  // Ocultamiento optimista mientras el borrado remoto está en vuelo: entre
  // el swipe y que `fuelLogsProvider` termine de refrescar (dos round-trips
  // de red), Riverpod sigue mostrando la lista anterior
  // (AsyncValue.when con skipLoadingOnRefresh = true, default), así que sin
  // este Set el tanqueo recién borrado reaparecería un instante. Se limpia
  // en didUpdateWidget apenas llega una lista `logs` distinta, para que no
  // crezca sin límite.
  final Set<String> _removedIds = <String>{};

  List<FuelLog> _visible = <FuelLog>[];

  @override
  void initState() {
    super.initState();
    _recomputeVisible();
  }

  @override
  void didUpdateWidget(FuelHistorySliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.logs, widget.logs) ||
        oldWidget.sortDescending != widget.sortDescending) {
      if (!identical(oldWidget.logs, widget.logs)) {
        // Llegó una lista nueva de verdad (no la misma referencia que
        // Riverpod conserva mientras refresca): lo que estaba oculto de
        // forma optimista ya no hace falta seguir ocultándolo.
        _removedIds.clear();
      }
      _recomputeVisible();
    }
  }

  void _recomputeVisible() {
    List<FuelLog> sorted = widget.sortDescending
        ? widget.logs.reversed.toList()
        : widget.logs;
    _visible = sorted
        .where((FuelLog log) => !_removedIds.contains(log.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) => SliverList.builder(
    itemCount: _visible.length,
    itemBuilder: (BuildContext context, int index) {
      FuelLog log = _visible[index];
      return Dismissible(
        key: ValueKey<String>(log.id),
        direction: DismissDirection.endToStart,
        background: _deleteSwipeBackground(),
        confirmDismiss: (_) => _confirmDelete(context, log),
        onDismissed: (_) => _deleteLog(log),
        child: Container(
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
                    Text(_formatDate(log.date), style: AppTextStyles.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      '${log.odometer} km · '
                      '${log.gallons.toStringAsFixed(1)} gal',
                      style: AppTextStyles.bodyMedium,
                    ),
                    if (log.stationName != null)
                      Text(log.stationName!, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (log.isFullTank) ...<Widget>[
                    const CustomBadge(
                      label: 'TANQUE LLENO',
                      color: BlueprintColors.successGreen,
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (log.isExtraFuel) ...<Widget>[
                    const CustomBadge(
                      label: 'GASOLINA EXTRA',
                      color: BlueprintColors.infoBlue,
                    ),
                    const SizedBox(height: 4),
                  ],
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
            ],
          ),
        ),
      );
    },
  );

  Widget _deleteSwipeBackground() => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: Alignment.centerRight,
    color: BlueprintColors.danger,
    child: const Icon(Icons.delete_outline, color: Colors.white),
  );

  /// Además de confirmar, explica qué se pierde al eliminar (no solo "no se
  /// puede deshacer") porque este tanqueo puede ser parte del par que
  /// alimenta la curva km/gal o el costo/km del vehículo.
  Future<bool> _confirmDelete(BuildContext context, FuelLog log) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: BlueprintColors.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('Eliminar tanqueo'),
        content: Text(
          'Vas a eliminar el tanqueo del ${_formatDate(log.date)} '
          '(${log.gallons.toStringAsFixed(1)} gal · '
          '${copFormat.format(log.totalCost)}).\n\n'
          'Esta acción no se puede deshacer y el registro dejará de contar '
          'en el cálculo de rendimiento (curva km/gal) y en el costo por km '
          'de este vehículo.',
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
    return confirmed ?? false;
  }

  Future<void> _deleteLog(FuelLog log) async {
    setState(() {
      _removedIds.add(log.id);
      _recomputeVisible();
    });
    try {
      await ref.read(fuelLogActionsProvider).delete(log);
      if (mounted) showSuccessSnackBar(context, 'Tanqueo eliminado');
    } catch (e) {
      _log.error('_deleteLog(${log.id}): $e');
      // El borrado remoto falló: se revierte el ocultamiento optimista para
      // que el registro vuelva a aparecer, en vez de quedar "eliminado" solo
      // en la UI mientras sigue existiendo en Supabase.
      if (mounted) {
        setState(() {
          _removedIds.remove(log.id);
          _recomputeVisible();
        });
        showErrorSnackBar(context, 'No se pudo eliminar el tanqueo.');
      }
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
