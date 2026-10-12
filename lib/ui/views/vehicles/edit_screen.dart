part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Edita un vehículo ya existente. Recibe solo el `vehicleId` (no el
/// [Vehicle] completo) para no acarrear un objeto potencialmente
/// desactualizado a través de la navegación — se busca la versión vigente
/// en [vehiclesProvider] al construir la pantalla.
///
/// Wrapper fino sobre [VehicleFormScreen]: resuelve el único caso de borde
/// propio de "editar" (que el vehículo no se encuentre) y, si lo encuentra,
/// delega el formulario.
///
/// El vehículo se fija la primera vez que la lista está cargada: si se
/// volviera a buscar en cada build, guardar el formulario (que actualiza
/// [vehiclesProvider]) le cambiaría el `initial` al formulario en medio de
/// la salida.
class EditVehicleScreen extends ConsumerStatefulWidget {
  const EditVehicleScreen({required this.vehicleId, super.key});

  final String vehicleId;
  static const String route = '/vehicles/edit';
  @override
  ConsumerState<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends ConsumerState<EditVehicleScreen> {
  static const String _title = 'Editar Vehículo';
  Vehicle? _original;
  bool _resolved = false;

  @override
  Widget build(BuildContext context) {
    if (!_resolved) {
      AsyncValue<List<Vehicle>> vehicles = ref.watch(vehiclesProvider);
      if (!vehicles.hasValue && !vehicles.hasError) {
        return const BlueprintScaffold(
          appBar: BlueprintFormAppBar(title: _title),
          body: Center(child: CircularProgressIndicator()),
        );
      }
      _resolved = true;
      for (Vehicle v in vehicles.value ?? const <Vehicle>[]) {
        if (v.id == widget.vehicleId) {
          _original = v;
          break;
        }
      }
    }
    Vehicle? original = _original;
    if (original == null) {
      return const BlueprintScaffold(
        appBar: BlueprintFormAppBar(title: _title),
        body: Center(
          child: Text(
            'No se encontró el vehículo.',
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }
    return VehicleFormScreen(initial: original);
  }
}
