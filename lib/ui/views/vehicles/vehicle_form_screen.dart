part of com.auto_log_mi_nave_ota_labs.app.ui.views;

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

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
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

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    Vehicle? vehicle = widget.initial;
    _nicknameController = TextEditingController(text: vehicle?.nickname ?? '');
    _plateController = TextEditingController(text: vehicle?.licensePlate);
    _brandController = TextEditingController(text: vehicle?.brand);
    _modelController = TextEditingController(text: vehicle?.model);
    _yearController = TextEditingController(text: vehicle?.year.toString());
    _odometerController = TextEditingController(
      text: vehicle == null ? '0' : vehicle.currentOdometer.toString(),
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

  Future<void> _pickPhoto() async {
    String? userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return;
    String? path = await showModalBottomSheet<String?>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () async {
                String? p = await ref
                    .read(attachmentPickerServiceProvider)
                    .pickImageFromCamera(userId: userId, category: 'vehicle');
                if (context.mounted) Navigator.pop(context, p);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () async {
                String? p = await ref
                    .read(attachmentPickerServiceProvider)
                    .pickImageFromGallery(userId: userId, category: 'vehicle');
                if (context.mounted) Navigator.pop(context, p);
              },
            ),
          ],
        ),
      ),
    );
    if (path != null) setState(() => _photoPath = path);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Vehicle? original = widget.initial;
    if (original == null) {
      String? userId = ref.read(authControllerProvider).user?.id;
      if (userId == null) return;
      List<Vehicle> vehicles =
          ref.read(vehiclesProvider).value ?? const <Vehicle>[];
      // Solo se permite un vehículo por cuenta.
      if (vehicles.isNotEmpty) return;
      setState(() => _saving = true);
      Vehicle vehicle = Vehicle(
        id: generateId(),
        userId: userId,
        licensePlate: _plateController.text.trim().toUpperCase(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text),
        fuelType: _fuelType,
        currentOdometer: int.parse(_odometerController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: _color,
        photoUrl: _photoPath,
        nickname: _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
        tankCapacityGallons: double.tryParse(_tankCapacityController.text),
      );
      await ref.read(vehiclesProvider.notifier).addVehicle(vehicle);
    } else {
      setState(() => _saving = true);
      Vehicle updated = original.copyWith(
        licensePlate: _plateController.text.trim().toUpperCase(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text),
        fuelType: _fuelType,
        currentOdometer: int.parse(_odometerController.text),
        color: _color,
        photoUrl: ValueWrapper<String>(_photoPath),
        nickname: ValueWrapper<String>(
          _nicknameController.text.trim().isEmpty
              ? null
              : _nicknameController.text.trim(),
        ),
        tankCapacityGallons: ValueWrapper<double>(
          double.tryParse(_tankCapacityController.text),
        ),
      );
      await ref.read(vehiclesProvider.notifier).updateVehicle(updated);
    }
    if (!mounted) return;
    unawaited(Navigator.of(context).maybePop());
  }

  @override
  Widget build(BuildContext context) {
    bool editing = _editing;
    return BlueprintScaffold(
      appBar: BlueprintFormAppBar(
        title: editing ? 'Editar Vehículo' : 'Agregar Vehículo',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlueprintTextField(
                label: 'Apodo (opcional)',
                controller: _nicknameController,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              BlueprintTextField(
                label: 'Placa',
                controller: _plateController,
                textCapitalization: TextCapitalization.characters,
                validator: (String? v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa la placa.'
                    : null,
              ),
              const SizedBox(height: 16),
              if (editing) ...<Widget>[
                const CustomDivider(
                  color: BlueprintColors.outlineVariant,
                  thickness: 1,
                  isDash: true,
                ),
                const SizedBox(height: 16),
                const CustomDivider(
                  color: BlueprintColors.successGreen,
                  thickness: 1,
                  isDash: false,
                ),
                const SizedBox(height: 16),
                const CustomDividerWithLabel(
                  color: BlueprintColors.danger,
                  label: 'Combustible',
                ),
                const SizedBox(height: 16),
              ],
              BlueprintTextField(
                label: 'Marca',
                controller: _brandController,
                validator: (String? v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa la marca.'
                    : null,
              ),
              const SizedBox(height: 16),
              BlueprintTextField(
                label: 'Modelo',
                controller: _modelController,
                validator: (String? v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa el modelo.'
                    : null,
              ),
              const SizedBox(height: 16),
              BlueprintTextField(
                label: 'Año',
                controller: _yearController,
                keyboardType: TextInputType.number,
                validator: (String? v) => int.tryParse(v ?? '') == null
                    ? 'Ingresa un año válido.'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FuelType>(
                initialValue: _fuelType,
                decoration: const InputDecoration(
                  label: Text('Tipo de combustible'),
                ),
                items: <DropdownMenuItem<FuelType>>[
                  for (final FuelType t in FuelType.values)
                    DropdownMenuItem<FuelType>(value: t, child: Text(t.label)),
                ],
                onChanged: (FuelType? t) =>
                    setState(() => _fuelType = t ?? _fuelType),
              ),
              const SizedBox(height: 16),
              BlueprintTextField(
                label: editing ? 'Odómetro (km)' : 'Odómetro inicial (km)',
                controller: _odometerController,
                keyboardType: TextInputType.number,
                validator: (String? v) => int.tryParse(v ?? '') == null
                    ? 'Ingresa un número válido.'
                    : null,
              ),
              const SizedBox(height: 16),
              BlueprintTextField(
                label: 'Capacidad del tanque (galones, opcional)',
                controller: _tankCapacityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (String? v) => (v == null || v.trim().isEmpty)
                    ? null
                    : (double.tryParse(v) == null
                          ? 'Ingresa un número válido.'
                          : null),
              ),
              const SizedBox(height: 16),
              const Text('Color', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              BlueprintColorPicker(
                colorHex: _color,
                onChanged: (String hex) => setState(() => _color = hex),
              ),
              const SizedBox(height: 16),
              const Text(
                'Foto del vehículo (opcional)',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 8),
              UploadZone(
                filePath: _photoPath,
                onTap: _pickPhoto,
                label: editing ? 'Cambiar foto' : 'Agregar foto',
              ),
              const SizedBox(height: 24),
              BlueprintPrimaryButton(
                label: editing ? 'GUARDAR CAMBIOS' : 'GUARDAR',
                loading: _saving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
