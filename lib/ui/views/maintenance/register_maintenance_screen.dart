part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Valores del formulario ya normalizados. Implementa `==` por valor
/// para detectar si hay cambios sin guardar.
class _MaintenanceFormValues {
  const _MaintenanceFormValues({
    required this.serviceType,
    required this.category,
    required this.date,
    required this.workshop,
    required this.odometer,
    required this.totalCost,
    required this.notes,
    required this.invoicePath,
  });

  final MaintenanceServiceType serviceType;
  final String category;
  final DateTime date;
  final String? workshop;
  final int? odometer;
  final int? totalCost;
  final String? notes;
  final String? invoicePath;

  @override
  bool operator ==(Object other) =>
      other is _MaintenanceFormValues &&
      other.serviceType == serviceType &&
      other.category == category &&
      other.date == date &&
      other.workshop == workshop &&
      other.odometer == odometer &&
      other.totalCost == totalCost &&
      other.notes == notes &&
      other.invoicePath == invoicePath;

  @override
  int get hashCode => Object.hash(
    serviceType,
    category,
    date,
    workshop,
    odometer,
    totalCost,
    notes,
    invoicePath,
  );
}

class RegisterMaintenanceScreen extends ConsumerStatefulWidget {
  const RegisterMaintenanceScreen({super.key});
  static const String route = '/maintenance/register';

  @override
  ConsumerState<RegisterMaintenanceScreen> createState() =>
      _RegisterMaintenanceScreenState();
}

class _RegisterMaintenanceScreenState
    extends ConsumerState<RegisterMaintenanceScreen>
    with _AttachmentUploadMixin<RegisterMaintenanceScreen> {
  static const Logger _log = Logger('RegisterMaintenanceScreen');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MaintenanceServiceType _serviceType = MaintenanceServiceType.preventivo;
  final TextEditingController _categoryController = TextEditingController();
  final FocusNode _categoryFocusNode = FocusNode();
  final TextEditingController _workshopController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  String? _invoicePath;
  bool _saving = false;

  late final _MaintenanceFormValues _initialValues;
  bool _dirty = false;

  /// Categorías predefinidas (las que reconoce el cálculo de vida útil, ver
  /// `lifespan_calculator.dart`). "Otro" no es una categoría: limpia el
  /// campo para escribir una libre.
  static const List<String> _presetCategories = <String>[
    'Aceite',
    'Llantas',
    'Frenos',
  ];

  @override
  void initState() {
    super.initState();
    _initialValues = _readForm();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _categoryFocusNode.dispose();
    _workshopController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  _MaintenanceFormValues _readForm() => _MaintenanceFormValues(
    serviceType: _serviceType,
    category: _categoryController.text.trim(),
    date: _date,
    workshop: trimmedOrNull(_workshopController.text),
    odometer: parseGroupedInt(_odometerController.text),
    totalCost: parseGroupedInt(_costController.text),
    notes: trimmedOrNull(_notesController.text),
    invoicePath: _invoicePath,
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
  }

  void _selectCategory(String? category) {
    if (category == null) {
      _categoryController.clear();
      _categoryFocusNode.requestFocus();
    } else {
      _categoryController.text = category;
    }
    _updateDirty();
  }

  Future<void> _onInvoiceTap() => _pickAttachment(
    category: 'maintenance',
    hasAttachment: _invoicePath != null,
    allowPdf: true,
    removeLabel: 'Quitar factura',
    errorMessage: 'No se pudo subir la factura.',
    onChanged: (String? path) {
      setState(() => _invoicePath = path);
      _updateDirty();
    },
  );

  Future<void> _submit(String vehicleId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _MaintenanceFormValues values = _readForm();
    setState(() => _saving = true);
    MaintenanceRecord record = MaintenanceRecord(
      id: generateId(),
      vehicleId: vehicleId,
      serviceType: values.serviceType,
      category: values.category,
      date: values.date,
      odometer: values.odometer!,
      totalCost: values.totalCost!.toDouble(),
      workshopName: values.workshop,
      invoiceUrl: values.invoicePath,
      notes: values.notes,
    );
    try {
      await ref.read(maintenanceActionsProvider).create(record);
    } catch (e) {
      _log.error('_submit(${record.id}): $e');
      // Se queda en la pantalla para que el usuario pueda reintentar sin
      // perder lo que llenó.
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorSnackBar(context, 'No se pudo registrar el mantenimiento.');
      return;
    }
    if (!mounted) return;
    // `pop` (no `maybePop`) para saltarse el guard de cambios sin guardar.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    return BlueprintUnsavedChangesGuard(
      dirty: _dirty,
      busy: _saving,
      child: BlueprintScaffold(
        appBar: const BlueprintFormAppBar(title: 'Registrar Mantenimiento'),
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
                      const BlueprintFormSectionHeader('Servicio', first: true),
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
                        onSelectionChanged: (Set<MaintenanceServiceType> s) {
                          setState(() => _serviceType = s.first);
                          _updateDirty();
                        },
                      ),
                      const SizedBox(height: 16),
                      BlueprintTextField(
                        label: 'Categoría',
                        controller: _categoryController,
                        focusNode: _categoryFocusNode,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        validator: (String? v) =>
                            _validateRequired(v, 'Ingresa la categoría.'),
                      ),
                      const SizedBox(height: 8),
                      _CategoryChips(
                        controller: _categoryController,
                        presets: _presetCategories,
                        onSelected: _selectCategory,
                      ),
                      const SizedBox(height: 16),
                      BlueprintDateField(
                        label: 'Fecha del servicio',
                        date: _date,
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 16),
                      BlueprintTextField(
                        label: 'Taller (opcional)',
                        controller: _workshopController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      const BlueprintFormSectionHeader('Kilometraje y costo'),
                      BlueprintFieldPair(
                        first: BlueprintTextField(
                          label: 'Odómetro (km)',
                          controller: _odometerController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: const <TextInputFormatter>[
                            ThousandsSeparatorInputFormatter(maxDigits: 7),
                          ],
                          helperText:
                              'Actual: '
                              '${integerFormat.format(vehicle.currentOdometer)}'
                              ' km',
                          validator: _validateOdometerText,
                        ),
                        second: BlueprintTextField(
                          label: 'Costo total (COP)',
                          controller: _costController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: const <TextInputFormatter>[
                            ThousandsSeparatorInputFormatter(),
                          ],
                          // 0 es válido: p. ej. un servicio por garantía.
                          validator: (String? v) =>
                              _validateCopAmount(v, allowZero: true),
                        ),
                      ),
                      const BlueprintFormSectionHeader('Detalle'),
                      BlueprintTextField(
                        label: 'Notas / repuestos (opcional)',
                        controller: _notesController,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      UploadZone(
                        filePath: _invoicePath,
                        onTap: _onInvoiceTap,
                        loading: _uploadingAttachment,
                        label: 'Adjuntar factura (opcional)',
                      ),
                      const SizedBox(height: 32),
                      BlueprintPrimaryButton(
                        label: 'GUARDAR',
                        loading: _saving,
                        // Mientras sube la factura todavía no hay ruta que
                        // guardar.
                        onPressed: _uploadingAttachment
                            ? null
                            : () => _submit(vehicle.id),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Chips de categoría: marca la que coincide con lo escrito en
/// [controller]. "Otro" queda marcado con cualquier texto libre y, al
/// tocarlo, [onSelected] recibe `null` para limpiar el campo.
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.controller,
    required this.presets,
    required this.onSelected,
  });

  final TextEditingController controller;
  final List<String> presets;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (BuildContext context, TextEditingValue value, Widget? _) {
          String text = value.text.trim().toLowerCase();
          bool isPreset = presets.any((String p) => p.toLowerCase() == text);
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final String preset in presets)
                ChoiceChip(
                  label: Text(preset),
                  selected: preset.toLowerCase() == text,
                  onSelected: (_) => onSelected(preset),
                ),
              ChoiceChip(
                label: const Text('Otro'),
                selected: text.isNotEmpty && !isPreset,
                onSelected: (_) => onSelected(null),
              ),
            ],
          );
        },
      );
}
