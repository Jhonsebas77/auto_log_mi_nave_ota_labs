part of com.auto_log_mi_nave_ota_labs.app.ui.views;

// Verde Oliva 526259
/// Wrapper fino sobre [VehicleFormScreen]. Antes de mostrar el formulario,
/// resuelve el único caso de borde propio de "agregar": la app solo soporta
/// un vehículo por cuenta, así que si ya existe uno se muestra un aviso en
/// vez del formulario.
///
/// La decisión se toma una sola vez, con la primera lista de vehículos
/// cargada: si se re-evaluara en cada build, al guardar el vehículo nuevo
/// la pantalla cambiaría al aviso de "ya tienes un vehículo" justo durante
/// la animación de salida.
class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});
  static const String route = '/vehicles/add';

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  static const String _title = 'Agregar Vehículo';
  bool? _hasVehicle;

  @override
  Widget build(BuildContext context) {
    if (_hasVehicle == null) {
      AsyncValue<List<Vehicle>> vehicles = ref.watch(vehiclesProvider);
      if (!vehicles.hasValue) {
        return BlueprintScaffold(
          appBar: const BlueprintFormAppBar(title: _title),
          body: Center(
            child: vehicles.hasError
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No se pudieron cargar tus vehículos.',
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
        );
      }
      _hasVehicle = vehicles.requireValue.isNotEmpty;
    }
    if (_hasVehicle!) {
      return const BlueprintScaffold(
        appBar: BlueprintFormAppBar(title: _title),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Ya tienes un vehículo registrado. Solo se permite '
              'un vehículo por cuenta.',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return const VehicleFormScreen();
  }
}
