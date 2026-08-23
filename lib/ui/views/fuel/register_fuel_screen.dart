part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class RegisterFuelScreen extends ConsumerStatefulWidget {
  const RegisterFuelScreen({super.key});
  static const String route = '/fuel/register';

  @override
  ConsumerState<RegisterFuelScreen> createState() => _RegisterFuelScreenState();
}

class _RegisterFuelScreenState extends ConsumerState<RegisterFuelScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _gallonsController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _fullTank = true;
  bool _saving = false;

  @override
  void dispose() {
    _odometerController.dispose();
    _gallonsController.dispose();
    _costController.dispose();
    _stationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _submit(String vehicleId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    FuelLog log = FuelLog(
      id: generateId(),
      vehicleId: vehicleId,
      date: _date,
      odometer: int.parse(_odometerController.text),
      gallons: double.parse(_gallonsController.text),
      totalCost: double.parse(_costController.text),
      isFullTank: _fullTank,
      stationName: _stationController.text.trim().isEmpty
          ? null
          : _stationController.text.trim(),
    );
    await ref.read(fuelLogActionsProvider).create(log);
    if (!mounted) return;
    unawaited(Navigator.of(context).maybePop());
  }

  @override
  Widget build(BuildContext context) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    return BlueprintScaffold(
      appBar: const BlueprintFormAppBar(title: 'Registrar Tanqueo'),
      body: vehicle == null
          ? const Center(child: Text('Selecciona un vehículo primero.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fecha del tanqueo'),
                      subtitle: Text(_formatDate(_date)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 8),
                    BlueprintTextField(
                      label: 'Odómetro (km)',
                      controller: _odometerController,
                      keyboardType: TextInputType.number,
                      validator: (String? v) {
                        int? n = int.tryParse(v ?? '');
                        if (n == null) return 'Ingresa un número válido.';
                        if (n < vehicle.currentOdometer) {
                          return 'Debe ser ≥ ${vehicle.currentOdometer} km.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    BlueprintTextField(
                      label: 'Galones',
                      controller: _gallonsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (String? v) => double.tryParse(v ?? '') == null
                          ? 'Ingresa un número válido.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    BlueprintTextField(
                      label: 'Costo total (COP)',
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (String? v) => double.tryParse(v ?? '') == null
                          ? 'Ingresa un número válido.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    BlueprintTextField(
                      label: 'Estación (opcional)',
                      controller: _stationController,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tanque lleno'),
                      value: _fullTank,
                      onChanged: (bool v) => setState(() => _fullTank = v),
                    ),
                    const SizedBox(height: 16),
                    BlueprintPrimaryButton(
                      label: 'GUARDAR',
                      loading: _saving,
                      onPressed: () => _submit(vehicle.id),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
