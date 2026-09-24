part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Edita un vehículo ya existente. Recibe solo el `vehicleId` (no el
/// [Vehicle] completo) para no acarrear un objeto potencialmente
/// desactualizado a través de la navegación — se busca la versión vigente
/// en [vehiclesProvider] al construir la pantalla.
///
/// Wrapper fino sobre [VehicleFormScreen]: resuelve el único caso de borde
/// propio de "editar" (que el vehículo no se encuentre) y, si lo encuentra,
/// delega el formulario.
class EditVehicleScreen extends ConsumerStatefulWidget {
  const EditVehicleScreen({required this.vehicleId, super.key});

  final String vehicleId;
  static const String route = '/vehicles/edit';
  @override
  ConsumerState<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends ConsumerState<EditVehicleScreen> {
  Vehicle? _original;

  @override
  void initState() {
    super.initState();
    List<Vehicle> vehicles =
        ref.read(vehiclesProvider).value ?? const <Vehicle>[];
    Vehicle? vehicle;
    for (Vehicle v in vehicles) {
      if (v.id == widget.vehicleId) {
        vehicle = v;
        break;
      }
    }
    _original = vehicle;
  }

  @override
  Widget build(BuildContext context) {
    if (_original == null) {
      return const BlueprintScaffold(
        appBar: BlueprintFormAppBar(title: 'Editar Vehículo'),
        body: Center(
          child: Text(
            'No se encontró el vehículo.',
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }
    return VehicleFormScreen(initial: _original);
  }
}
