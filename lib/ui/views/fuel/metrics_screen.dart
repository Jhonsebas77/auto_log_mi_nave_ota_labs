part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class FuelMetricsScreen extends ConsumerWidget {
  const FuelMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo el id: cambios de odómetro/foto/apodo del vehículo no deben
    // reconstruir este tab (AppShell lo mantiene montado).
    String? vehicleId = ref.watch(
      selectedVehicleProvider.select((Vehicle? v) => v?.id),
    );
    if (vehicleId == null) {
      return const Center(
        child: Text('Agrega un vehículo para ver tus tanqueos.'),
      );
    }

    AsyncValue<List<FuelLog>> logsAsync = ref.watch(
      fuelLogsProvider(vehicleId),
    );
    FuelMetrics metrics = ref.watch(fuelMetricsProvider(vehicleId));

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
        loading: () => const FuelMetricsSkeleton(),
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
                            ],
                          ),
                        ),
                        _FuelHistorySection(logs: logs),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Encabezado "Historial" + lista. El orden vive acá (y no en
/// [FuelMetricsScreen]) para que cambiarlo solo reconstruya el historial,
/// no la gráfica ni los KPIs.
class _FuelHistorySection extends StatefulWidget {
  const _FuelHistorySection({required this.logs});

  final List<FuelLog> logs;

  @override
  State<_FuelHistorySection> createState() => _FuelHistorySectionState();
}

class _FuelHistorySectionState extends State<_FuelHistorySection> {
  bool _sortDescending = true;

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: <Widget>[
              const Text('Historial', style: AppTextStyles.titleMedium),
              const Spacer(),
              _SortHistoryButton(
                descending: _sortDescending,
                onChanged: (bool value) =>
                    setState(() => _sortDescending = value),
              ),
            ],
          ),
        ),
      ),
      FuelHistorySliver(logs: widget.logs, sortDescending: _sortDescending),
    ],
  );
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
