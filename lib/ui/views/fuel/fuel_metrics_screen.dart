part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class FuelMetricsScreen extends ConsumerStatefulWidget {
  const FuelMetricsScreen({super.key});

  @override
  ConsumerState<FuelMetricsScreen> createState() => _FuelMetricsScreenState();
}

class _FuelMetricsScreenState extends ConsumerState<FuelMetricsScreen> {
  bool _sortDescending = true;

  @override
  Widget build(BuildContext context) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    if (vehicle == null) {
      return const Center(
        child: Text('Agrega un vehículo para ver tus tanqueos.'),
      );
    }

    AsyncValue<List<FuelLog>> logsAsync = ref.watch(
      fuelLogsProvider(vehicle.id),
    );
    FuelMetrics metrics = ref.watch(fuelMetricsProvider(vehicle.id));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        // Tag explícito: AppShell mantiene todos los tabs montados a la vez
        // en un IndexedStack, así que cada FAB necesita un tag distinto
        // para no chocar con el de los otros tabs (mismo tag implícito por
        // defecto en todos los FloatingActionButton).
        heroTag: 'fab-register-fuel',
        onPressed: () =>
            CustomNavigator().push(context, const RegisterFuelScreen()),
        child: const Icon(Icons.add),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => Center(child: Text('Error: $error')),
        data: (List<FuelLog> logs) => logs.isEmpty
            ? const _FuelEmptyState()
            : CustomScrollView(
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    sliver: SliverMainAxisGroup(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              PerformanceCurveChart(curve: metrics.curve),
                              const SizedBox(height: 16),
                              KpiCardsRow(metrics: metrics),
                              const SizedBox(height: 16),
                              Row(
                                children: <Widget>[
                                  const Text(
                                    'Historial',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                  const Spacer(),
                                  _SortHistoryButton(
                                    descending: _sortDescending,
                                    onChanged: (bool value) =>
                                        setState(() => _sortDescending = value),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        FuelHistorySliver(
                          logs: logs,
                          sortDescending: _sortDescending,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SortHistoryButton extends StatelessWidget {
  const _SortHistoryButton({required this.descending, required this.onChanged});

  final bool descending;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => PopupMenuButton<bool>(
    tooltip: 'Ordenar historial',
    initialValue: descending,
    onSelected: onChanged,
    icon: const Icon(Icons.sort, color: BlueprintColors.textMuted),
    itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
      _sortMenuItem(
        value: true,
        label: 'Más reciente primero',
        selected: descending,
      ),
      _sortMenuItem(
        value: false,
        label: 'Más antigua primero',
        selected: !descending,
      ),
    ],
  );

  PopupMenuItem<bool> _sortMenuItem({
    required bool value,
    required String label,
    required bool selected,
  }) => PopupMenuItem<bool>(
    value: value,
    child: Row(
      children: <Widget>[
        Icon(
          selected ? Icons.check : null,
          size: 18,
          color: BlueprintColors.textMuted,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    ),
  );
}

/// Estado vacío: sin tanqueos todavía no hay nada que graficar ni promediar
/// (ver PerformanceCurveChart/KpiCardsRow, que de todos modos manejan listas
/// vacías) — mejor mostrar un mensaje claro que una gráfica/KPIs en blanco.
class _FuelEmptyState extends StatelessWidget {
  const _FuelEmptyState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.local_gas_station,
            size: 48,
            color: BlueprintColors.textMuted,
          ),
          SizedBox(height: 16),
          Text(
            'Aún no tienes tanqueos registrados.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Usa el botón + para registrar tu primer tanqueo.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
