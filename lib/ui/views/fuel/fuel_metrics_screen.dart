part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class FuelMetricsScreen extends ConsumerWidget {
  const FuelMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    PerformanceCurveChart(curve: metrics.curve),
                    const SizedBox(height: 16),
                    KpiCardsRow(metrics: metrics),
                    const SizedBox(height: 16),
                    const Text('Historial', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    FuelHistoryList(logs: logs),
                  ],
                ),
              ),
      ),
    );
  }
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
