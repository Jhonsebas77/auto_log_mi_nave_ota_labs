part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class RegisterMaintenanceScreen extends ConsumerStatefulWidget {
  const RegisterMaintenanceScreen({super.key});
 static const String route = '/maintenance/register';

  @override
  ConsumerState<RegisterMaintenanceScreen> createState() =>
      _RegisterMaintenanceScreenState();
}

class _RegisterMaintenanceScreenState
    extends ConsumerState<RegisterMaintenanceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MaintenanceServiceType _serviceType = MaintenanceServiceType.preventivo;
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _workshopController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _invoicePath;
  bool _saving = false;

  static const List<String> _categoryChips = <String>[
    'Aceite',
    'Llantas',
    'Frenos',
    'Otro',
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    _workshopController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickInvoice() async {
    String? userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return;
    String? path = await ref
        .read(attachmentPickerServiceProvider)
        .pickImageFromCamera(userId: userId, category: 'maintenance');
    if (path != null) setState(() => _invoicePath = path);
  }

  Future<void> _submit(String vehicleId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    MaintenanceRecord record = MaintenanceRecord(
      id: generateId(),
      vehicleId: vehicleId,
      serviceType: _serviceType,
      category: _categoryController.text.trim(),
      date: DateTime.now(),
      odometer: int.parse(_odometerController.text),
      totalCost: double.parse(_costController.text),
      workshopName: _workshopController.text.trim().isEmpty
          ? null
          : _workshopController.text.trim(),
      invoiceUrl: _invoicePath,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    await ref.read(maintenanceActionsProvider).create(record);
    if (!mounted) return;
    unawaited(Navigator.of(context).maybePop());
  }

  @override
  Widget build(BuildContext context) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    return BlueprintScaffold(
      appBar: const BlueprintFormAppBar(title: 'Registrar Mantenimiento'),
      body: vehicle == null
          ? const Center(child: Text('Selecciona un vehículo primero.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SegmentedButton<MaintenanceServiceType>(
                      segments: <ButtonSegment<MaintenanceServiceType>>[
                        for (final MaintenanceServiceType t
                            in MaintenanceServiceType.values)
                          ButtonSegment<MaintenanceServiceType>(
                            value: t,
                            label: Text(t.label),
                          ),
                      ],
                      selected: <MaintenanceServiceType>{_serviceType},
                      onSelectionChanged: (Set<MaintenanceServiceType> s) =>
                          setState(() => _serviceType = s.first),
                    ),
                    const SizedBox(height: 16),
                    BlueprintTextField(
                      label: 'Categoría',
                      controller: _categoryController,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: <Widget>[
                        for (final String chip in _categoryChips)
                          ActionChip(
                            label: Text(chip),
                            onPressed: () =>
                                setState(() => _categoryController.text = chip),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlueprintTextField(
                      label: 'Taller',
                      controller: _workshopController,
                    ),
                    const SizedBox(height: 16),
                    BlueprintTextField(
                      label: 'Odómetro (km)',
                      controller: _odometerController,
                      keyboardType: TextInputType.number,
                      validator: (String? v) => int.tryParse(v ?? '') == null
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
                      label: 'Notas / repuestos (opcional)',
                      controller: _notesController,
                    ),
                    const SizedBox(height: 16),
                    UploadZone(
                      filePath: _invoicePath,
                      onTap: _pickInvoice,
                      label: 'Adjuntar factura',
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
    );
  }
}
