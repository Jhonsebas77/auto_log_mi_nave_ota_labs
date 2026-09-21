part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  static const String route = '/dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Vehicle>> vehiclesAsync = ref.watch(vehiclesProvider);

    return vehiclesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => Center(child: Text('Error: $error')),
      data: (List<Vehicle> vehicles) {
        if (vehicles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Aún no tienes vehículos registrados.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  BlueprintPrimaryButton(
                    label: 'AGREGAR VEHÍCULO',
                    onPressed: () => CustomNavigator().push(
                      context,
                      const AddVehicleScreen(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        Vehicle selected = ref.watch(selectedVehicleProvider) ?? vehicles.first;
        // Se calcula directo (no vía un Provider cacheado): "hoy" depende
        // del reloj, no de ningún estado de la app, y AppShell mantiene el
        // dashboard montado en un IndexedStack — un Provider.family aquí
        // congelaría el resultado del primer build del día y nunca se
        // volvería a evaluar aunque cambiara la fecha mientras la app
        // sigue abierta (ver también DocumentStatusRow/CountdownChip, que
        // por el mismo motivo llaman DateTime.now() directo en el build).
        LicensePlateRestrictionResult picoYPlaca = isVehicleRestrictedToday(
          licensePlate: selected.licensePlate,
          today: DateTime.now(),
        );
        List<LegalDocument> documents =
            ref.watch(legalDocumentsProvider(selected.id)).value ??
            const <LegalDocument>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              VehicleSelector(
                vehicle: selected,
                onEdit: () => CustomNavigator().push(
                  context,
                  EditVehicleScreen(vehicleId: selected.id),
                ),
              ),
              const SizedBox(height: 16),
              OdometerQuickUpdateCard(vehicle: selected),
              const SizedBox(height: 16),
              LicensePlateRestrictionCard(
                result: picoYPlaca,
                licensePlate: selected.licensePlate,
              ),
              const SizedBox(height: 16),
              DocumentStatusRow(documents: documents, now: DateTime.now()),
            ],
          ),
        );
      },
    );
  }
}
