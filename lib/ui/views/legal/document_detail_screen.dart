part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Detalle de un [LegalDocument] ya registrado, con edición in-place.
///
/// Recibe `vehicleId` + `documentId` (no el [LegalDocument] completo) para
/// no acarrear una copia potencialmente desactualizada a través de la
/// navegación — la versión vigente se busca en [legalDocumentsProvider] al
/// construir, igual que en EditVehicleScreen.
class DocumentDetailScreen extends ConsumerStatefulWidget {
  const DocumentDetailScreen({
    required this.vehicleId,
    required this.documentId,
    super.key,
  });

  final String vehicleId;
  final String documentId;
  static const String route = '/legal/detail';

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  final TextEditingController _entityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _documentNumberController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DocumentType _type = DocumentType.soat;
  DateTime? _issueDate;
  DateTime _expirationDate = DateTime.now();
  String? _attachmentPath;
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _entityController.dispose();
    _costController.dispose();
    _documentNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadFrom(LegalDocument document) {
    _type = document.documentType;
    _issueDate = document.issueDate;
    _expirationDate = document.expirationDate;
    _entityController.text = document.entityName ?? '';
    _costController.text = document.cost?.toString() ?? '';
    _documentNumberController.text = document.documentNumber ?? '';
    _notesController.text = document.notes ?? '';
    _attachmentPath = document.documentUrl;
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

  void _startEditing(LegalDocument document) {
    setState(() {
      _loadFrom(document);
      _editing = true;
    });
  }

  void _cancelEditing(LegalDocument document) {
    setState(() {
      _loadFrom(document);
      _editing = false;
    });
  }

  Future<void> _submit(LegalDocument original) async {
    setState(() => _saving = true);
    LegalDocument updated = original.copyWith(
      documentType: _type,
      issueDate: _issueDate,
      expirationDate: _expirationDate,
      cost: double.tryParse(_costController.text),
      entityName: _entityController.text.trim().isEmpty
          ? null
          : _entityController.text.trim(),
      documentUrl: _attachmentPath,
      documentNumber: _documentNumberController.text.trim().isEmpty
          ? null
          : _documentNumberController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    await ref.read(legalDocumentActionsProvider).update(updated);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<LegalDocument> documents =
        ref.watch(legalDocumentsProvider(widget.vehicleId)).value ??
        const <LegalDocument>[];
    LegalDocument? found;
    for (LegalDocument d in documents) {
      if (d.id == widget.documentId) {
        found = d;
        break;
      }
    }

    if (found == null) {
      return const BlueprintScaffold(
        appBar: BlueprintFormAppBar(title: 'Documento'),
        body: Center(
          child: Text(
            'No se encontró el documento.',
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }
    LegalDocument document = found;

    return BlueprintScaffold(
      appBar: BlueprintFormAppBar(
        title: _editing ? 'Editar Documento' : document.documentType.label,
        actions: <Widget>[
          if (!_editing)
            IconButton(
              onPressed: () => _startEditing(document),
              icon: const Icon(Icons.edit),
            )
          else
            TextButton(
              onPressed: _saving ? null : () => _cancelEditing(document),
              child: const Text('CANCELAR'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _editing
            ? _buildEditForm(document)
            : _buildReadOnlyView(document),
      ),
    );
  }

  Widget _buildReadOnlyView(LegalDocument document) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: CountdownChip(
          expirationDate: document.expirationDate,
          now: DateTime.now(),
        ),
      ),
      const SizedBox(height: 16),
      _DetailRow(
        label: '# de documento',
        value: document.documentNumber ?? 'Sin definir',
      ),
      _DetailRow(
        label: 'Fecha de expedición',
        value: document.issueDate == null
            ? 'Sin definir'
            : _formatDate(document.issueDate!),
      ),
      _DetailRow(
        label: 'Fecha de vencimiento',
        value: _formatDate(document.expirationDate),
      ),
      _DetailRow(label: 'Entidad', value: document.entityName ?? 'Sin definir'),
      _DetailRow(
        label: 'Costo',
        value: document.cost == null
            ? 'Sin definir'
            : '\$${document.cost!.toStringAsFixed(2)}',
      ),
      _DetailRow(
        label: 'Información adicional',
        value: document.notes ?? 'Sin definir',
      ),
      if (document.documentUrl != null) ...<Widget>[
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Documento adjunto'),
          trailing: const Icon(Icons.attachment),
          onTap: () =>
              showDocumentPreviewDialog(context, document.documentUrl!),
        ),
      ],
    ],
  );

  Widget _buildEditForm(LegalDocument document) => Column(
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
        label: 'GUARDAR CAMBIOS',
        loading: _saving,
        onPressed: () => _submit(document),
      ),
    ],
  );

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodyLarge),
      ],
    ),
  );
}
