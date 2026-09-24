part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    if (vehicle == null) {
      return const Center(
        child: Text('Agrega un vehículo para ver su mantenimiento.'),
      );
    }

    AsyncValue<List<MaintenanceRecord>> recordsAsync = ref.watch(
      maintenanceRecordsProvider(vehicle.id),
    );
    List<LifespanStatus> lifespans = ref.watch(lifespanProvider(vehicle.id));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        // Ver comentario en fuel_metrics_screen.dart: tag único por tab
        // porque AppShell mantiene todos los tabs montados en un
        // IndexedStack (todos los FAB sin tag comparten el mismo tag
        // implícito).
        heroTag: 'fab-register-maintenance',
        onPressed: () =>
        CustomNavigator().push(context, const RegisterMaintenanceScreen()),
        child: const Icon(Icons.add),
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => Center(child: Text('Error: $error')),
        data: (List<MaintenanceRecord> records) => CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverMainAxisGroup(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        LifespanBarGroup(statuses: lifespans),
                        const SizedBox(height: 16),
                        const Text(
                          'Historial de servicios',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  ServiceHistorySegmentedList(records: records),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
