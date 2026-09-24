part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Formulario compartido para registrar y editar un [LegalDocument].
///
/// Con [initial] nulo arma un documento nuevo para [vehicleId] (usado por
/// [RegisterDocumentScreen], que además puede pasar [prefilledType]). Con un
/// [initial] no nulo, edita ese documento (usado por [DocumentDetailScreen]
/// en su modo edición). [saving] y [onSubmit] los controla la pantalla que
/// aloja este formulario: ella decide qué pasa después de guardar (navegar
/// atrás al crear, o volver a modo lectura al editar), así que también es
/// quien guarda el flag de guardado — este widget solo lo refleja.
class DocumentFormSection extends ConsumerStatefulWidget {
  const DocumentFormSection({
    required this.saveLabel,
    required this.saving,
    required this.onSubmit,
    this.initial,
    this.prefilledType,
    this.vehicleId,
    super.key,
  });

  /// Documento existente a editar. Nulo cuando se está registrando uno nuevo.
  final LegalDocument? initial;

  /// Tipo de documento a preseleccionar cuando no hay [initial].
  final DocumentType? prefilledType;

  /// Vehículo dueño del documento nuevo. Requerido cuando [initial] es nulo.
  final String? vehicleId;

  final String saveLabel;
  final bool saving;
  final Future<void> Function(LegalDocument document) onSubmit;

  @override
  ConsumerState<DocumentFormSection> createState() =>
      _DocumentFormSectionState();
}

class _DocumentFormSectionState extends ConsumerState<DocumentFormSection> {
  late DocumentType _type;
  DateTime? _issueDate;
  late DateTime _expirationDate;
  final TextEditingController _entityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _documentNumberController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _attachmentPath;

  @override
  void initState() {
    super.initState();
    LegalDocument? document = widget.initial;
    if (document == null) {
      _type = widget.prefilledType ?? DocumentType.soat;
      _expirationDate = DateTime.now().add(const Duration(days: 365));
    } else {
      _type = document.documentType;
      _issueDate = document.issueDate;
      _expirationDate = document.expirationDate;
      _entityController.text = document.entityName ?? '';
      _costController.text = document.cost?.toString() ?? '';
      _documentNumberController.text = document.documentNumber ?? '';
      _notesController.text = document.notes ?? '';
      _attachmentPath = document.documentUrl;
    }
  }

  @override
  void dispose() {
    _entityController.dispose();
    _costController.dispose();
    _documentNumberController.dispose();
    _notesController.dispose();
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

  Future<void> _pickAttachment() async {
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
                    .pickImageFromCamera(userId: userId, category: 'legal');
                if (context.mounted) Navigator.pop(context, p);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () async {
                String? p = await ref
                    .read(attachmentPickerServiceProvider)
                    .pickImageFromGallery(userId: userId, category: 'legal');
                if (context.mounted) Navigator.pop(context, p);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Elegir PDF'),
              onTap: () async {
                String? p = await ref
                    .read(attachmentPickerServiceProvider)
                    .pickPdf(userId: userId, category: 'legal');
                if (context.mounted) Navigator.pop(context, p);
              },
            ),
          ],
        ),
      ),
    );
    if (path != null) setState(() => _attachmentPath = path);
  }

  Future<void> _submit() async {
    LegalDocument? original = widget.initial;
    String? entityName = _entityController.text.trim().isEmpty
        ? null
        : _entityController.text.trim();
    String? documentNumber = _documentNumberController.text.trim().isEmpty
        ? null
        : _documentNumberController.text.trim();
    String? notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    LegalDocument document = original == null
        ? LegalDocument(
            id: generateId(),
            vehicleId: widget.vehicleId!,
            documentType: _type,
            issueDate: _issueDate,
            expirationDate: _expirationDate,
            cost: double.tryParse(_costController.text),
            entityName: entityName,
            documentUrl: _attachmentPath,
            documentNumber: documentNumber,
            notes: notes,
          )
        : original.copyWith(
            documentType: _type,
            issueDate: ValueWrapper<DateTime>(_issueDate),
            expirationDate: _expirationDate,
            cost: ValueWrapper<double>(double.tryParse(_costController.text)),
            entityName: ValueWrapper<String>(entityName),
            documentUrl: ValueWrapper<String>(_attachmentPath),
            documentNumber: ValueWrapper<String>(documentNumber),
            notes: ValueWrapper<String>(notes),
          );
    await widget.onSubmit(document);
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      DropdownButtonFormField<DocumentType>(
        initialValue: _type,
        decoration: const InputDecoration(label: Text('Tipo de documento')),
        items: <DropdownMenuItem<DocumentType>>[
          for (final DocumentType t in DocumentType.values)
            DropdownMenuItem<DocumentType>(value: t, child: Text(t.label)),
        ],
        onChanged: (DocumentType? t) => setState(() => _type = t ?? _type),
      ),
      const SizedBox(height: 16),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Fecha de expedición (opcional)'),
        subtitle: Text(
          _issueDate == null ? 'Sin definir' : _formatDate(_issueDate!),
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
      BlueprintTextField(label: 'Entidad', controller: _entityController),
      const SizedBox(height: 16),
      BlueprintTextField(
        label: '# de documento (opcional)',
        controller: _documentNumberController,
      ),
      const SizedBox(height: 16),
      BlueprintTextField(
        label: 'Costo (opcional)',
        controller: _costController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 16),
      BlueprintTextField(
        label: 'Información adicional (opcional)',
        controller: _notesController,
        maxLines: 3,
      ),
      const SizedBox(height: 16),
      UploadZone(filePath: _attachmentPath, onTap: _pickAttachment),
      const SizedBox(height: 24),
      BlueprintPrimaryButton(
        label: widget.saveLabel,
        loading: widget.saving,
        onPressed: _submit,
      ),
    ],
  );
}
