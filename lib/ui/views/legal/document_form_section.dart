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
///
/// Los mismos límites del date picker impiden elegir una expedición
/// posterior al vencimiento; la validación de fechas cubre además documentos
/// viejos que ya quedaron guardados así.
class DocumentFormSection extends ConsumerStatefulWidget {
  const DocumentFormSection({
    required this.saveLabel,
    required this.saving,
    required this.onSubmit,
    this.initial,
    this.prefilledType,
    this.vehicleId,
    this.onDirtyChanged,
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

  /// Avisa cuando el formulario pasa a tener (o deja de tener) cambios sin
  /// guardar, para que la pantalla que lo aloja proteja la salida (ver
  /// [BlueprintUnsavedChangesGuard]).
  final ValueChanged<bool>? onDirtyChanged;

  @override
  ConsumerState<DocumentFormSection> createState() =>
      _DocumentFormSectionState();
}

/// Valores del formulario ya normalizados. Implementa `==` por valor
/// para detectar si hay cambios sin guardar.
class _DocumentFormValues {
  const _DocumentFormValues({
    required this.type,
    required this.issueDate,
    required this.expirationDate,
    required this.entityName,
    required this.documentNumber,
    required this.cost,
    required this.notes,
    required this.attachmentPath,
  });

  final DocumentType type;
  final DateTime? issueDate;
  final DateTime expirationDate;
  final String? entityName;
  final String? documentNumber;
  final int? cost;
  final String? notes;
  final String? attachmentPath;

  @override
  bool operator ==(Object other) =>
      other is _DocumentFormValues &&
      other.type == type &&
      other.issueDate == issueDate &&
      other.expirationDate == expirationDate &&
      other.entityName == entityName &&
      other.documentNumber == documentNumber &&
      other.cost == cost &&
      other.notes == notes &&
      other.attachmentPath == attachmentPath;

  @override
  int get hashCode => Object.hash(
    type,
    issueDate,
    expirationDate,
    entityName,
    documentNumber,
    cost,
    notes,
    attachmentPath,
  );
}

class _DocumentFormSectionState extends ConsumerState<DocumentFormSection>
    with _AttachmentUploadMixin<DocumentFormSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DocumentType _type;
  DateTime? _issueDate;
  late DateTime _expirationDate;
  final TextEditingController _entityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _documentNumberController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _attachmentPath;

  late final _DocumentFormValues _initialValues;
  bool _dirty = false;

  static final DateTime _firstDate = DateTime(2000);
  static final DateTime _lastDate = DateTime(2100);

  @override
  void initState() {
    super.initState();
    LegalDocument? document = widget.initial;
    if (document == null) {
      _type = widget.prefilledType ?? DocumentType.soat;
      _expirationDate = DateUtils.dateOnly(
        DateTime.now().add(const Duration(days: 365)),
      );
    } else {
      _type = document.documentType;
      _issueDate = document.issueDate;
      _expirationDate = document.expirationDate;
      _entityController.text = document.entityName ?? '';
      double? cost = document.cost;
      _costController.text = cost == null
          ? ''
          : integerFormat.format(cost.round());
      _documentNumberController.text = document.documentNumber ?? '';
      _notesController.text = document.notes ?? '';
      _attachmentPath = document.documentUrl;
    }
    _initialValues = _readForm();
  }

  @override
  void dispose() {
    _entityController.dispose();
    _costController.dispose();
    _documentNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  _DocumentFormValues _readForm() => _DocumentFormValues(
    type: _type,
    issueDate: _issueDate,
    expirationDate: _expirationDate,
    entityName: trimmedOrNull(_entityController.text),
    documentNumber: trimmedOrNull(_documentNumberController.text),
    cost: parseGroupedInt(_costController.text),
    notes: trimmedOrNull(_notesController.text),
    attachmentPath: _attachmentPath,
  );

  void _updateDirty() {
    bool dirty = _readForm() != _initialValues;
    if (dirty == _dirty) return;
    _dirty = dirty;
    widget.onDirtyChanged?.call(dirty);
  }

  /// La expedición no puede ser posterior al vencimiento.
  String? get _datesError {
    DateTime? issueDate = _issueDate;
    if (issueDate == null || !issueDate.isAfter(_expirationDate)) return null;
    return 'No puede ser posterior al vencimiento.';
  }

  static DateTime _clampDate(DateTime date, DateTime min, DateTime max) =>
      date.isBefore(min) ? min : (date.isAfter(max) ? max : date);

  Future<void> _pickIssueDate() async {
    DateTime today = DateUtils.dateOnly(DateTime.now());
    DateTime last = _expirationDate.isBefore(today) ? _expirationDate : today;
    if (last.isBefore(_firstDate)) last = _firstDate;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _clampDate(_issueDate ?? last, _firstDate, last),
      firstDate: _firstDate,
      lastDate: last,
    );
    if (picked == null) return;
    setState(() => _issueDate = picked);
    _updateDirty();
  }

  Future<void> _pickExpirationDate() async {
    DateTime first = _issueDate ?? _firstDate;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _clampDate(_expirationDate, first, _lastDate),
      firstDate: first,
      lastDate: _lastDate,
    );
    if (picked == null) return;
    setState(() => _expirationDate = picked);
    _updateDirty();
  }

  void _clearIssueDate() {
    setState(() => _issueDate = null);
    _updateDirty();
  }

  Future<void> _onAttachmentTap() => _pickAttachment(
    category: 'legal',
    hasAttachment: _attachmentPath != null,
    allowPdf: true,
    onChanged: (String? path) {
      setState(() => _attachmentPath = path);
      _updateDirty();
    },
  );

  Future<void> _submit() async {
    bool fieldsValid = _formKey.currentState?.validate() ?? false;
    if (!fieldsValid || _datesError != null) return;
    _DocumentFormValues values = _readForm();
    double? cost = values.cost?.toDouble();
    LegalDocument? original = widget.initial;
    LegalDocument document = original == null
        ? LegalDocument(
            id: generateId(),
            vehicleId: widget.vehicleId!,
            documentType: values.type,
            issueDate: values.issueDate,
            expirationDate: values.expirationDate,
            cost: cost,
            entityName: values.entityName,
            documentUrl: values.attachmentPath,
            documentNumber: values.documentNumber,
            notes: values.notes,
          )
        : original.copyWith(
            documentType: values.type,
            issueDate: ValueWrapper<DateTime>(values.issueDate),
            expirationDate: values.expirationDate,
            cost: ValueWrapper<double>(cost),
            entityName: ValueWrapper<String>(values.entityName),
            documentUrl: ValueWrapper<String>(values.attachmentPath),
            documentNumber: ValueWrapper<String>(values.documentNumber),
            notes: ValueWrapper<String>(values.notes),
          );
    await widget.onSubmit(document);
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    onChanged: _updateDirty,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const BlueprintFormSectionHeader('Documento', first: true),
        BlueprintDropdownField<DocumentType>(
          label: 'Tipo de documento',
          value: _type,
          items: DocumentType.values,
          itemLabel: (DocumentType t) => t.label,
          onChanged: (DocumentType t) {
            setState(() => _type = t);
            _updateDirty();
          },
        ),
        const SizedBox(height: 16),
        BlueprintTextField(
          label: '# de documento (opcional)',
          controller: _documentNumberController,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        BlueprintTextField(
          label: 'Entidad (opcional)',
          controller: _entityController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const BlueprintFormSectionHeader('Vigencia'),
        BlueprintFieldPair(
          first: BlueprintDateField(
            label: 'Expedición (opcional)',
            date: _issueDate,
            onTap: _pickIssueDate,
            onClear: _clearIssueDate,
            errorText: _datesError,
          ),
          second: BlueprintDateField(
            label: 'Vencimiento',
            date: _expirationDate,
            onTap: _pickExpirationDate,
          ),
        ),
        const BlueprintFormSectionHeader('Detalle'),
        BlueprintTextField(
          label: 'Costo (COP, opcional)',
          controller: _costController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: const <TextInputFormatter>[
            ThousandsSeparatorInputFormatter(),
          ],
        ),
        const SizedBox(height: 16),
        BlueprintTextField(
          label: 'Información adicional (opcional)',
          controller: _notesController,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        UploadZone(
          filePath: _attachmentPath,
          onTap: _onAttachmentTap,
          loading: _uploadingAttachment,
        ),
        const SizedBox(height: 32),
        BlueprintPrimaryButton(
          label: widget.saveLabel,
          loading: widget.saving,
          // Mientras sube el adjunto todavía no hay ruta que guardar.
          onPressed: _uploadingAttachment ? null : _submit,
        ),
      ],
    ),
  );
}
