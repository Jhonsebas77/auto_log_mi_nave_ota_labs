part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Placas colombianas: carro `ABC123`, moto `ABC12D` y moto antigua `ABC12`.
/// Se valida sobre la placa ya normalizada (ver [_normalizePlate]).
final RegExp _plateRegExp = RegExp(r'^[A-Z]{3}[0-9]{2}[A-Z0-9]?$');

/// Mayúsculas, sin espacios ni guiones: "abc-123 " → "ABC123".
String _normalizePlate(String plate) =>
    plate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

const int _minVehicleYear = 1950;
const double _maxTankCapacityGallons = 100;

/// Valores del formulario ya normalizados. Implementa `==` por valor
/// para detectar si hay cambios sin guardar.
class _VehicleFormValues {
  const _VehicleFormValues({
    required this.nickname,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    required this.odometer,
    required this.tankCapacity,
    required this.fuelType,
    required this.color,
    required this.photoPath,
  });

  final String? nickname;
  final String plate;
  final String brand;
  final String model;
  final int? year;
  final int? odometer;
  final double? tankCapacity;
  final FuelType fuelType;
  final String color;
  final String? photoPath;

  @override
  bool operator ==(Object other) =>
      other is _VehicleFormValues &&
      other.nickname == nickname &&
      other.plate == plate &&
      other.brand == brand &&
      other.model == model &&
      other.year == year &&
      other.odometer == odometer &&
      other.tankCapacity == tankCapacity &&
      other.fuelType == fuelType &&
      other.color == color &&
      other.photoPath == photoPath;

  @override
  int get hashCode => Object.hash(
    nickname,
    plate,
    brand,
    model,
    year,
    odometer,
    tankCapacity,
    fuelType,
    color,
    photoPath,
  );
}

/// Formulario compartido para crear y editar un vehículo.
///
/// Con [initial] nulo actúa como "Agregar Vehículo" (crea uno nuevo); con un
/// [Vehicle] no nulo actúa como "Editar Vehículo" (actualiza ese vehículo).
/// Los casos de borde de cada flujo (ya existe un vehículo al agregar; no se
/// encontró el vehículo al editar) los resuelven los wrappers
/// [AddVehicleScreen] y [EditVehicleScreen] antes de construir este widget.
class VehicleFormScreen extends ConsumerStatefulWidget {
  const VehicleFormScreen({this.initial, super.key});

  final Vehicle? initial;

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen>
    with _AttachmentUploadMixin<VehicleFormScreen> {
  static const Logger _log = Logger('VehicleFormScreen');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _plateController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _odometerController;
  late final TextEditingController _tankCapacityController;
  late FuelType _fuelType;
  late String _color;
  String? _photoPath;
  bool _saving = false;

  late final _VehicleFormValues _initialValues;
  bool _dirty = false;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    Vehicle? vehicle = widget.initial;
    _nicknameController = TextEditingController(text: vehicle?.nickname ?? '');
    _plateController = TextEditingController(
      text: vehicle == null ? '' : _normalizePlate(vehicle.licensePlate),
    );
    _brandController = TextEditingController(text: vehicle?.brand);
    _modelController = TextEditingController(text: vehicle?.model);
    _yearController = TextEditingController(text: vehicle?.year.toString());
    _odometerController = TextEditingController(
      text: integerFormat.format(vehicle?.currentOdometer ?? 0),
    );
    _tankCapacityController = TextEditingController(
      text: vehicle?.tankCapacityGallons?.toString() ?? '',
    );
    _fuelType = vehicle?.fuelType ?? FuelType.gasolinaCorriente;
    // vehicle.color puede venir en formato legacy (label como 'Rojo', ver
    // colorSwatchForVehicle) — se normaliza a hex para que el picker
    // arranque mostrando el color real en vez de caer al de respaldo.
    _color = colorToHex(
      vehicle == null
          ? kVehicleColorOptions.first.swatch
          : colorSwatchForVehicle(vehicle.color),
    );
    _photoPath = vehicle?.photoUrl;
    _initialValues = _readForm();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _odometerController.dispose();
    _tankCapacityController.dispose();
    super.dispose();
  }

  _VehicleFormValues _readForm() => _VehicleFormValues(
    nickname: trimmedOrNull(_nicknameController.text),
    plate: _normalizePlate(_plateController.text),
    brand: _brandController.text.trim(),
    model: _modelController.text.trim(),
    year: int.tryParse(_yearController.text.trim()),
    odometer: parseGroupedInt(_odometerController.text),
    tankCapacity: parseDecimal(_tankCapacityController.text),
    fuelType: _fuelType,
    color: _color,
    photoPath: _photoPath,
  );

  void _updateDirty() {
    bool dirty = _readForm() != _initialValues;
    if (dirty != _dirty) setState(() => _dirty = dirty);
  }

  Future<void> _onPhotoTap() => _pickAttachment(
    category: 'vehicle',
    hasAttachment: _photoPath != null,
    removeLabel: 'Quitar foto',
    errorMessage: 'No se pudo subir la foto.',
    onChanged: (String? path) {
      setState(() => _photoPath = path);
      _updateDirty();
    },
  );

  Future<bool> _confirmLowerOdometer(int current) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: BlueprintColors.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('Bajar el odómetro'),
        content: Text(
          'El odómetro quedará por debajo del valor actual '
          '(${integerFormat.format(current)} km).\n\nÚsalo solo para '
          'corregir un error: los tanqueos y mantenimientos registrados con '
          'un kilometraje mayor pueden quedar inconsistentes.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar igual'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _VehicleFormValues values = _readForm();
    Vehicle? original = widget.initial;
    if (original == null) {
      String? userId = ref.read(authControllerProvider).user?.id;
      if (userId == null) return;
      List<Vehicle> vehicles =
          ref.read(vehiclesProvider).value ?? const <Vehicle>[];
      // Solo se permite un vehículo por cuenta.
      if (vehicles.isNotEmpty) {
        showErrorSnackBar(context, 'Ya tienes un vehículo registrado.');
        return;
      }
      setState(() => _saving = true);
      Vehicle vehicle = Vehicle(
        id: generateId(),
        userId: userId,
        licensePlate: values.plate,
        brand: values.brand,
        model: values.model,
        year: values.year!,
        fuelType: values.fuelType,
        currentOdometer: values.odometer!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: values.color,
        photoUrl: values.photoPath,
        nickname: values.nickname,
        tankCapacityGallons: values.tankCapacity,
      );
      try {
        await ref.read(vehiclesProvider.notifier).addVehicle(vehicle);
      } catch (e) {
        _log.error('addVehicle(${vehicle.id}): $e');
        _onSubmitError('No se pudo agregar el vehículo.');
        return;
      }
    } else {
      if (values.odometer! < original.currentOdometer &&
          !await _confirmLowerOdometer(original.currentOdometer)) {
        return;
      }
      if (!mounted) return;
      setState(() => _saving = true);
      Vehicle updated = original.copyWith(
        licensePlate: values.plate,
        brand: values.brand,
        model: values.model,
        year: values.year,
        fuelType: values.fuelType,
        currentOdometer: values.odometer,
        color: values.color,
        photoUrl: ValueWrapper<String>(values.photoPath),
        nickname: ValueWrapper<String>(values.nickname),
        tankCapacityGallons: ValueWrapper<double>(values.tankCapacity),
      );
      try {
        await ref.read(vehiclesProvider.notifier).updateVehicle(updated);
      } catch (e) {
        _log.error('updateVehicle(${updated.id}): $e');
        _onSubmitError('No se pudo actualizar el vehículo.');
        return;
      }
    }
    if (!mounted) return;
    // `pop` (no `maybePop`) para saltarse el guard de cambios sin guardar:
    // acaban de guardarse.
    Navigator.of(context).pop();
  }

  /// Se queda en el formulario (sin perder lo que se llenó) para que el
  /// usuario pueda reintentar.
  void _onSubmitError(String message) {
    if (!mounted) return;
    setState(() => _saving = false);
    showErrorSnackBar(context, message);
  }

  String? _validatePlate(String? v) {
    String plate = _normalizePlate(v ?? '');
    if (plate.isEmpty) return 'Ingresa la placa.';
    if (!_plateRegExp.hasMatch(plate)) {
      return 'Placa inválida (ej. ABC123 o ABC12D).';
    }
    return null;
  }

  String? _validateYear(String? v) {
    int? year = int.tryParse(v?.trim() ?? '');
    int maxYear = DateTime.now().year + 1;
    if (year == null || year < _minVehicleYear || year > maxYear) {
      return 'Ingresa un año entre $_minVehicleYear y $maxYear.';
    }
    return null;
  }

  String? _validateTankCapacity(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    double? gallons = parseDecimal(v);
    if (gallons == null) return 'Ingresa un número válido.';
    if (gallons <= 0 || gallons > _maxTankCapacityGallons) {
      return 'Debe estar entre 0 y ${_maxTankCapacityGallons.toInt()} gal.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool editing = _editing;
    return BlueprintUnsavedChangesGuard(
      dirty: _dirty,
      busy: _saving,
      child: BlueprintScaffold(
        appBar: BlueprintFormAppBar(
          title: editing ? 'Editar Vehículo' : 'Agregar Vehículo',
        ),
        body: BlueprintFormBody(
          child: Form(
            key: _formKey,
            onChanged: _updateDirty,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const BlueprintFormSectionHeader('Identificación', first: true),
                BlueprintTextField(
                  label: 'Apodo (opcional)',
                  controller: _nicknameController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BlueprintTextField(
                  label: 'Placa',
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[
                    _PlateInputFormatter(),
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: _validatePlate,
                ),
                const SizedBox(height: 16),
                const Text('Color', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                BlueprintColorPicker(
                  colorHex: _color,
                  onChanged: (String hex) {
                    setState(() => _color = hex);
                    _updateDirty();
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Foto del vehículo (opcional)',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                UploadZone(
                  filePath: _photoPath,
                  onTap: _onPhotoTap,
                  loading: _uploadingAttachment,
                  label: editing ? 'Cambiar foto' : 'Agregar foto',
                ),
                const BlueprintFormSectionHeader('Especificaciones'),
                BlueprintFieldPair(
                  first: BlueprintTextField(
                    label: 'Marca',
                    controller: _brandController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (String? v) =>
                        _validateRequired(v, 'Ingresa la marca.'),
                  ),
                  second: BlueprintTextField(
                    label: 'Modelo',
                    controller: _modelController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (String? v) =>
                        _validateRequired(v, 'Ingresa el modelo.'),
                  ),
                ),
                const SizedBox(height: 16),
                BlueprintTextField(
                  label: 'Año',
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: _validateYear,
                ),
                const BlueprintFormSectionHeader('Combustible y uso'),
                BlueprintDropdownField<FuelType>(
                  label: 'Tipo de combustible',
                  value: _fuelType,
                  items: FuelType.values,
                  itemLabel: (FuelType t) => t.label,
                  onChanged: (FuelType t) {
                    setState(() => _fuelType = t);
                    _updateDirty();
                  },
                ),
                const SizedBox(height: 16),
                BlueprintFieldPair(
                  first: BlueprintTextField(
                    label: 'Tanque (gal, opcional)',
                    controller: _tankCapacityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    inputFormatters: <TextInputFormatter>[
                      decimalInputFormatter,
                    ],
                    validator: _validateTankCapacity,
                  ),
                  second: BlueprintTextField(
                    label: editing ? 'Odómetro (km)' : 'Odómetro inicial (km)',
                    controller: _odometerController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: const <TextInputFormatter>[
                      ThousandsSeparatorInputFormatter(maxDigits: 7),
                    ],
                    validator: _validateOdometerText,
                  ),
                ),
                const SizedBox(height: 32),
                BlueprintPrimaryButton(
                  label: editing ? 'GUARDAR CAMBIOS' : 'GUARDAR',
                  loading: _saving,
                  // Sin foto subida todavía no hay ruta que guardar.
                  onPressed: _uploadingAttachment ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placa en mayúsculas y solo letras/dígitos mientras se escribe.
class _PlateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = _normalizePlate(newValue.text);
    if (text == newValue.text) return newValue;
    // Solo cambió a mayúsculas: se conserva la posición del cursor.
    if (text.length == newValue.text.length) {
      return newValue.copyWith(text: text);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
