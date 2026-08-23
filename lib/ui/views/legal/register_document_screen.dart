part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class RegisterDocumentScreen extends ConsumerStatefulWidget {
  const RegisterDocumentScreen({super.key, this.prefilledType});

  final DocumentType? prefilledType;
  static const String route = '/legal/register';

  @override
  ConsumerState<RegisterDocumentScreen> createState() =>
      _RegisterDocumentScreenState();
}

class _RegisterDocumentScreenState
    extends ConsumerState<RegisterDocumentScreen> {
  late DocumentType _type = widget.prefilledType ?? DocumentType.soat;
  DateTime? _issueDate;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365));
  final TextEditingController _entityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  String? _attachmentPath;
  bool _scanning = false;
  bool _saving = false;
  bool _wasScanned = false;

  @override
  void dispose() {
    _entityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isExpiration}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExpiration ? _expirationDate : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isExpiration) {
        _expirationDate = picked;
      } else {
        _issueDate = picked;
      }
    });
  }

  Future<void> _runOcr() async {
    setState(() => _scanning = true);
    DocumentOcrResult result = await ref
        .read(ocrSimulationServiceProvider)
        .scanDocument(_type, now: DateTime.now());
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _wasScanned = true;
      _entityController.text = result.entityName;
      _expirationDate = result.expirationDate;
    });
  }

  Future<void> _pickAttachment() async {
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
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Elegir PDF'),
              onTap: () async {
                String? p = await ref
                    .read(attachmentPickerServiceProvider)
                    .pickPdf();
                if (context.mounted) Navigator.pop(context, p);
              },
            ),
          ],
        ),
      ),
    );
    if (path != null) setState(() => _attachmentPath = path);
  }

  Future<void> _submit(String vehicleId) async {
    setState(() => _saving = true);
    LegalDocument document = LegalDocument(
      id: generateId(),
      vehicleId: vehicleId,
      documentType: _type,
      issueDate: _issueDate,
      expirationDate: _expirationDate,
      cost: double.tryParse(_costController.text),
      entityName: _entityController.text.trim().isEmpty
          ? null
          : _entityController.text.trim(),
      documentUrl: _attachmentPath,
    );
    await ref.read(legalDocumentActionsProvider).create(document);
    if (!mounted) return;
    unawaited(Navigator.of(context).maybePop());
  }

  @override
  Widget build(BuildContext context) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    return BlueprintScaffold(
      appBar: const BlueprintFormAppBar(title: 'Registrar Documento'),
      body: vehicle == null
          ? const Center(child: Text('Selecciona un vehículo primero.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  DropdownButtonFormField<DocumentType>(
                    initialValue: _type,
                    decoration: const InputDecoration(
                      label: Text('Tipo de documento'),
                    ),
                    items: <DropdownMenuItem<DocumentType>>[
                      for (final DocumentType t in DocumentType.values)
                        DropdownMenuItem<DocumentType>(
                          value: t,
                          child: Text(t.label),
                        ),
                    ],
                    onChanged: (DocumentType? t) =>
                        setState(() => _type = t ?? _type),
                  ),
                  const SizedBox(height: 16),
                  OcrScanButton(loading: _scanning, onTap: _runOcr),
                  if (_wasScanned)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Campos autocompletados (simulado).',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha de expedición (opcional)'),
                    subtitle: Text(
                      _issueDate == null
                          ? 'Sin definir'
                          : _formatDate(_issueDate!),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(isExpiration: false),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha de vencimiento'),
                    subtitle: Text(_formatDate(_expirationDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(isExpiration: true),
                  ),
                  const SizedBox(height: 8),
                  BlueprintTextField(
                    label: 'Entidad',
                    controller: _entityController,
                  ),
                  const SizedBox(height: 16),
                  BlueprintTextField(
                    label: 'Costo (opcional)',
                    controller: _costController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  UploadZone(filePath: _attachmentPath, onTap: _pickAttachment),
                  const SizedBox(height: 24),
                  BlueprintPrimaryButton(
                    label: 'GUARDAR',
                    loading: _saving,
                    onPressed: () => _submit(vehicle.id),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
