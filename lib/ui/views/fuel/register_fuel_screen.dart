part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Valores del formulario ya normalizados. Implementa `==` por valor
/// para detectar si hay cambios sin guardar.
class _FuelFormValues {
  const _FuelFormValues({
    required this.date,
    required this.odometer,
    required this.gallons,
    required this.totalCost,
    required this.station,
    required this.fullTank,
    required this.extraFuel,
  });

  final DateTime date;
  final int? odometer;
  final double? gallons;
  final int? totalCost;
  final String? station;
  final bool fullTank;
  final bool extraFuel;

  @override
  bool operator ==(Object other) =>
      other is _FuelFormValues &&
      other.date == date &&
      other.odometer == odometer &&
      other.gallons == gallons &&
      other.totalCost == totalCost &&
      other.station == station &&
      other.fullTank == fullTank &&
      other.extraFuel == extraFuel;

  @override
  int get hashCode => Object.hash(
    date,
    odometer,
    gallons,
    totalCost,
    station,
    fullTank,
    extraFuel,
  );
}

/// Tipos de combustible para los que tiene sentido distinguir corriente vs.
/// extra al tanquear.
const Set<FuelType> _gasolineFuelTypes = <FuelType>{
  FuelType.gasolinaCorriente,
  FuelType.gasolinaExtra,
  FuelType.hibrido,
};

class RegisterFuelScreen extends ConsumerStatefulWidget {
  const RegisterFuelScreen({super.key});
  static const String route = '/fuel/register';

  @override
  ConsumerState<RegisterFuelScreen> createState() => _RegisterFuelScreenState();
}

class _RegisterFuelScreenState extends ConsumerState<RegisterFuelScreen> {
  static const Logger _log = Logger('RegisterFuelScreen');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _gallonsController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _fullTank = false;
  bool _extraFuel = false;
  bool _saving = false;

  late final _FuelFormValues _initialValues;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _initialValues = _readForm();
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _gallonsController.dispose();
    _costController.dispose();
    _stationController.dispose();
    super.dispose();
  }

  _FuelFormValues _readForm() => _FuelFormValues(
    date: _date,
    odometer: parseGroupedInt(_odometerController.text),
    gallons: parseDecimal(_gallonsController.text),
    totalCost: parseGroupedInt(_costController.text),
    station: trimmedOrNull(_stationController.text),
    fullTank: _fullTank,
    extraFuel: _extraFuel,
  );

  void _updateDirty() {
    bool dirty = _readForm() != _initialValues;
    if (dirty != _dirty) setState(() => _dirty = dirty);
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
    _updateDirty();
    // Los límites del odómetro dependen de la fecha (ver _odometerBounds):
    // si ya había un error mostrado, se recalcula.
    _formKey.currentState?.validate();
  }

  Future<void> _submit(String vehicleId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _FuelFormValues values = _readForm();
    setState(() => _saving = true);
    double gallons = values.gallons!;
    double totalCost = values.totalCost!.toDouble();
    FuelLog log = FuelLog(
      id: generateId(),
      vehicleId: vehicleId,
      date: values.date,
      odometer: values.odometer!,
      gallons: gallons,
      totalCost: totalCost,
      // Se calcula, no se pide en el formulario — evita que quede
      // inconsistente con costo/galones cargados a mano.
      pricePerGallon: totalCost / gallons,
      isFullTank: values.fullTank,
      isExtraFuel: values.extraFuel,
      stationName: values.station,
    );
    try {
      await ref.read(fuelLogActionsProvider).create(log);
    } catch (e) {
      _log.error('_submit(${log.id}): $e');
      // Sin este catch la excepción (p. ej. PostgrestException) escapaba
      // del onPressed como error no manejado: no había feedback y el botón
      // quedaba en loading para siempre. Se queda en la pantalla para que
      // el usuario pueda reintentar sin perder lo que llenó.
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorSnackBar(context, 'No se pudo registrar el tanqueo.');
      return;
    }
    if (!mounted) return;
    // `pop` (no `maybePop`) para saltarse el guard de cambios sin guardar.
    Navigator.of(context).pop();
  }

  bool get _isToday => DateUtils.isSameDay(_date, DateTime.now());

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
    // `logs` ya llega ascendente por fecha desde el servidor (ver
    // `SupabaseFuelLogRepository.getByVehicle`): no hace falta copiarla y
    // reordenarla en cada validación.
    FuelLog? prev;
    FuelLog? next;
    for (FuelLog log in logs) {
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

  String? _validateOdometer(String? v, ({int? min, int? max}) bounds) {
    int? n = parseGroupedInt(v ?? '');
    if (n == null) return 'Ingresa el kilometraje.';
    if (bounds.min != null && n < bounds.min!) {
      return 'Debe ser ≥ ${integerFormat.format(bounds.min)} km.';
    }
    if (bounds.max != null && n > bounds.max!) {
      return 'Debe ser ≤ ${integerFormat.format(bounds.max)} km.';
    }
    return null;
  }

  String? _validateGallons(String? v, double? tankCapacity) {
    double? gallons = parseDecimal(v ?? '');
    if (gallons == null) return 'Ingresa los galones.';
    if (gallons <= 0) return 'Debe ser mayor a 0.';
    if (tankCapacity != null && gallons > tankCapacity) {
      return 'Supera la capacidad del tanque '
          '(${tankCapacity.toStringAsFixed(1)} gal).';
    }
    return null;
  }

  String _odometerHelper(({int? min, int? max}) bounds) {
    if (bounds.min != null && bounds.max != null) {
      return 'Entre ${integerFormat.format(bounds.min)} y '
          '${integerFormat.format(bounds.max)} km.';
    }
    if (bounds.min != null) {
      return 'Último registrado: ${integerFormat.format(bounds.min)} km.';
    }
    if (bounds.max != null) {
      return 'Máximo ${integerFormat.format(bounds.max)} km.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    List<FuelLog> existingLogs = vehicle == null
        ? const <FuelLog>[]
        : ref.watch(fuelLogsProvider(vehicle.id)).value ?? const <FuelLog>[];
    ({int? min, int? max}) bounds = vehicle == null
        ? (min: null, max: null)
        : _odometerBounds(existingLogs, vehicle.currentOdometer);
    String odometerHelper = _odometerHelper(bounds);
    return BlueprintUnsavedChangesGuard(
      dirty: _dirty,
      busy: _saving,
      child: BlueprintScaffold(
        appBar: const BlueprintFormAppBar(title: 'Registrar Tanqueo'),
        body: vehicle == null
            ? const Center(
                child: Text(
                  'Selecciona un vehículo primero.',
                  style: AppTextStyles.bodyLarge,
                ),
              )
            : BlueprintFormBody(
                child: Form(
                  key: _formKey,
                  onChanged: _updateDirty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      BlueprintDateField(
                        label: 'Fecha del tanqueo',
                        date: _date,
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 16),
                      BlueprintTextField(
                        label: 'Odómetro (km)',
                        controller: _odometerController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: const <TextInputFormatter>[
                          ThousandsSeparatorInputFormatter(maxDigits: 7),
                        ],
                        helperText: odometerHelper.isEmpty
                            ? null
                            : odometerHelper,
                        validator: (String? v) => _validateOdometer(v, bounds),
                      ),
                      const SizedBox(height: 16),
                      BlueprintFieldPair(
                        first: BlueprintTextField(
                          label: 'Galones',
                          controller: _gallonsController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          inputFormatters: <TextInputFormatter>[
                            decimalInputFormatter,
                          ],
                          validator: (String? v) =>
                              _validateGallons(v, vehicle.tankCapacityGallons),
                        ),
                        second: BlueprintTextField(
                          label: 'Costo total (COP)',
                          controller: _costController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: const <TextInputFormatter>[
                            ThousandsSeparatorInputFormatter(),
                          ],
                          validator: _validateCopAmount,
                        ),
                      ),
                      _PricePerGallonPreview(
                        gallonsController: _gallonsController,
                        costController: _costController,
                      ),
                      const SizedBox(height: 16),
                      BlueprintTextField(
                        label: 'Estación (opcional)',
                        controller: _stationController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tanque lleno'),
                        subtitle: const Text(
                          'Marca esto solo si el tanque quedó realmente lleno '
                          'al terminar de tanquear.',
                        ),
                        value: _fullTank,
                        onChanged: (bool v) {
                          setState(() => _fullTank = v);
                          _updateDirty();
                        },
                      ),
                      if (_gasolineFuelTypes.contains(vehicle.fuelType))
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Gasolina extra'),
                          subtitle: const Text(
                            'Marca esto si tanqueaste gasolina extra/premium.',
                          ),
                          value: _extraFuel,
                          onChanged: (bool v) {
                            setState(() => _extraFuel = v);
                            _updateDirty();
                          },
                        ),
                      const SizedBox(height: 24),
                      BlueprintPrimaryButton(
                        label: 'GUARDAR',
                        loading: _saving,
                        onPressed: () => _submit(vehicle.id),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Precio por galón calculado en vivo a partir de galones y costo, para que
/// el usuario detecte un error de digitación antes de guardar. Escucha los
/// controllers directamente para no reconstruir todo el formulario en cada
/// tecla.
class _PricePerGallonPreview extends StatelessWidget {
  const _PricePerGallonPreview({
    required this.gallonsController,
    required this.costController,
  });

  final TextEditingController gallonsController;
  final TextEditingController costController;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge(<Listenable>[
      gallonsController,
      costController,
    ]),
    builder: (BuildContext context, Widget? _) {
      double? gallons = parseDecimal(gallonsController.text);
      int? cost = parseGroupedInt(costController.text);
      if (gallons == null || gallons <= 0 || cost == null || cost <= 0) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Precio por galón: ${copFormat.format(cost / gallons)}',
          style: AppTextStyles.bodySmall,
        ),
      );
    },
  );
}
