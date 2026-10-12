part of com.auto_log_mi_nave_ota_labs.app.ui.views;

// Verde Oliva 526259
/// Wrapper fino sobre [VehicleFormScreen]. Antes de mostrar el formulario,
/// resuelve el único caso de borde propio de "agregar": la app solo soporta
/// un vehículo por cuenta, así que si ya existe uno se muestra un aviso en
/// vez del formulario.
class AddVehicleScreen extends ConsumerWidget {
  const AddVehicleScreen({super.key});
  static const String route = '/vehicles/add';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool hasVehicle = ref.watch(vehiclesProvider).value?.isNotEmpty ?? false;
    if (hasVehicle) {
      return const BlueprintScaffold(
        appBar: BlueprintFormAppBar(title: 'Agregar Vehículo'),
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
