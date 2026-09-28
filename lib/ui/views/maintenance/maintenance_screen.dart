part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? vehicleId = ref.watch(
      selectedVehicleProvider.select((Vehicle? v) => v?.id),
    );
    if (vehicleId == null) {
      return const Center(
        child: Text('Agrega un vehículo para ver su mantenimiento.'),
      );
    }

    AsyncValue<List<MaintenanceRecord>> recordsAsync = ref.watch(
      maintenanceRecordsProvider(vehicleId),
    );
    List<LifespanStatus> lifespans = ref.watch(lifespanProvider(vehicleId));
    // Ver maintenanceAvailableProvider: sin datos (cargando o módulo aún no
    // disponible en Supabase) no se muestra el botón +.
    bool available = ref.watch(maintenanceAvailableProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: !available
          ? null
          : FloatingActionButton(
              // Ver comentario en fuel_metrics_screen.dart: tag único por tab
              // porque AppShell mantiene todos los tabs montados en un
              // IndexedStack (todos los FAB sin tag comparten el mismo tag
              // implícito).
              heroTag: 'fab-register-maintenance',
              onPressed: () => CustomNavigator().push(
                context,
                const RegisterMaintenanceScreen(),
              ),
              child: const Icon(Icons.add),
            ),
      body: recordsAsync.when(
        loading: () => const MaintenanceSkeleton(),
        error: (Object error, _) => _MaintenanceUnavailableState(
          retrying: recordsAsync.isLoading,
          onRetry: () => ref.invalidate(maintenanceRecordsProvider(vehicleId)),
        ),
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

/// Estado vacío cuando no se pudieron cargar los mantenimientos. Hoy el
/// caso esperado es que el módulo todavía no esté habilitado en Supabase,
/// así que se muestra como "no disponible" en vez de un error técnico.
class _MaintenanceUnavailableState extends StatelessWidget {
  const _MaintenanceUnavailableState({
    required this.onRetry,
    required this.retrying,
  });

  final VoidCallback onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.build_outlined,
            size: 48,
            color: BlueprintColors.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'El taller aún no está disponible.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Estamos terminando de habilitar el registro de mantenimientos. '
            'Pronto podrás ver aquí la vida útil de aceite, llantas y frenos '
            'y tu historial de servicios.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: retrying ? null : onRetry,
            icon: retrying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}
