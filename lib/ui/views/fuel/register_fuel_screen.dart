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
  bool _fullTank = false;
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
    double gallons = double.parse(_gallonsController.text);
    double totalCost = double.parse(_costController.text);
    FuelLog log = FuelLog(
      id: generateId(),
      vehicleId: vehicleId,
      date: _date,
      odometer: int.parse(_odometerController.text),
      gallons: gallons,
      totalCost: totalCost,
      // Se calcula, no se pide en el formulario — evita que quede
      // inconsistente con costo/galones cargados a mano.
      pricePerGallon: gallons > 0 ? totalCost / gallons : null,
      isFullTank: _fullTank,
      stationName: _stationController.text.trim().isEmpty
          ? null
          : _stationController.text.trim(),
    );
    await ref.read(fuelLogActionsProvider).create(log);
    if (!mounted) return;
    unawaited(Navigator.of(context).maybePop());
  }

  bool get _isToday {
    DateTime now = DateTime.now();
    return _date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day;
  }

  /// Rango válido para el Odómetro de este tanqueo, según su fecha y los
  /// tanqueos vecinos ya guardados (el Odómetro nunca retrocede en el
  /// tiempo):
  /// - Si hay un tanqueo con fecha anterior/igual, el Odómetro no puede ser
  ///   menor al de ese tanqueo.
  /// - Si hay un tanqueo con fecha posterior, no puede ser mayor al de ese.
  /// - Si no hay tanqueo posterior y la fecha es hoy, se trata como el más
  ///   reciente: debe continuar desde `vehicle.currentOdometer`.
  /// - Si no hay tanqueo posterior y la fecha es anterior a hoy (ej. el
  ///   primer tanqueo que se registra, agregado con fecha atrasada), NO se
  ///   acota con `vehicle.currentOdometer` — ese valor puede ser solo el
  ///   que se escribió al crear el vehículo (incluso 0, si no se actualizó),
  ///   no un dato real verificado a esa fecha. Tratarlo como techo bloquea
  ///   justo el caso de cargar historial atrasado en un vehículo nuevo.
  ({int? min, int? max}) _odometerBounds(
    List<FuelLog> logs,
    int currentOdometer,
  ) {
    List<FuelLog> sorted = <FuelLog>[...logs]
      ..sort((FuelLog a, FuelLog b) => a.date.compareTo(b.date));
    FuelLog? prev;
    FuelLog? next;
    for (FuelLog log in sorted) {
      if (!log.date.isAfter(_date)) {
        prev = log;
      } else {
        next = log;
        break;
      }
    }
    int? min = prev?.odometer;
    int? max = next?.odometer;
    if (next == null && _isToday) {
      min = currentOdometer;
    }
    return (min: min, max: max);
  }

  @override
  Widget build(BuildContext context) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    List<FuelLog> existingLogs = vehicle == null
        ? const <FuelLog>[]
        : ref.watch(fuelLogsProvider(vehicle.id)).value ?? const <FuelLog>[];
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
                        ({int? min, int? max}) bounds = _odometerBounds(
                          existingLogs,
                          vehicle.currentOdometer,
                        );
                        if (bounds.min != null && n < bounds.min!) {
                          return 'Debe ser ≥ ${bounds.min} km.';
                        }
                        if (bounds.max != null && n > bounds.max!) {
                          return 'Debe ser ≤ ${bounds.max} km.';
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
                      subtitle: const Text(
                        'Marca esto solo si el tanque quedó realmente lleno '
                        'al terminar de tanquear.',
                      ),
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
