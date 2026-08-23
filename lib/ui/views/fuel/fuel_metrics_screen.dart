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
        data: (List<FuelLog> logs) => SingleChildScrollView(
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
