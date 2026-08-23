part of com.auto_log_mi_nave_ota_labs.app.ui.views;
// Verde Oliva 526259
class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});
  static const String route = '/vehicles/add';

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController(
    text: '0',
  );
  FuelType _fuelType = FuelType.gasolinaCorriente;
  String _color = colorToHex(kVehicleColorOptions.first.swatch);
  String? _photoPath;
  bool _scanning = false;
  bool _saving = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _runOcr() async {
    setState(() => _scanning = true);
    VehicleOcrResult result = await ref
        .read(ocrSimulationServiceProvider)
        .scanVehicleRegistration();
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _plateController.text = result.licensePlate;
      _brandController.text = result.brand;
      _modelController.text = result.model;
    });
  }

  Future<void> _pickPhoto() async {
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
                    .pickImageFromCamera();
                if (context.mounted) Navigator.pop(context, p);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () async {
                String? p = await ref
                    .read(attachmentPickerServiceProvider)
                    .pickImageFromGallery();
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
    String? userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return;
    List<Vehicle> vehicles =
        ref.read(vehiclesProvider).value ?? const <Vehicle>[];
    if (vehicles.isNotEmpty) return; // Solo se permite un vehículo por cuenta.
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
      color: _color,
      photoUrl: _photoPath,
      nickname: _nicknameController.text.trim().isEmpty
          ? null
          : _nicknameController.text.trim(),
    );
    await ref.read(vehiclesProvider.notifier).addVehicle(vehicle);
    if (!mounted) return;
    unawaited(Navigator.of(context).maybePop());
  }

  @override
  Widget build(BuildContext context) {
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
    return BlueprintScaffold(
      appBar: const BlueprintFormAppBar(title: 'Agregar Vehículo'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              OcrScanButton(loading: _scanning, onTap: _runOcr),
              const SizedBox(height: 16),
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
                label: 'Odómetro inicial (km)',
                controller: _odometerController,
                keyboardType: TextInputType.number,
                validator: (String? v) => int.tryParse(v ?? '') == null
                    ? 'Ingresa un número válido.'
                    : null,
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
                label: 'Agregar foto',
              ),
              const SizedBox(height: 24),
              BlueprintPrimaryButton(
                label: 'GUARDAR',
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
