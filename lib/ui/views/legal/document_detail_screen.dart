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
  static const Logger _log = Logger('DocumentDetailScreen');
  bool _editing = false;
  bool _saving = false;
  bool _dirty = false;

  void _startEditing() => setState(() => _editing = true);

  Future<void> _cancelEditing() async {
    if (_dirty && !await showDiscardChangesDialog(context)) return;
    if (!mounted) return;
    setState(() {
      _editing = false;
      _dirty = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<LegalDocument>> documentsAsync = ref.watch(
      legalDocumentsProvider(widget.vehicleId),
    );
    if (!documentsAsync.hasValue && !documentsAsync.hasError) {
      return const BlueprintScaffold(
        appBar: BlueprintFormAppBar(title: 'Documento'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    List<LegalDocument> documents =
        documentsAsync.value ?? const <LegalDocument>[];
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

    return BlueprintUnsavedChangesGuard(
      dirty: _editing && _dirty,
      busy: _saving,
      child: BlueprintScaffold(
        appBar: BlueprintFormAppBar(
          title: _editing ? 'Editar Documento' : document.documentType.label,
          actions: <Widget>[
            if (!_editing)
              IconButton(onPressed: _startEditing, icon: const Icon(Icons.edit))
            else
              TextButton(
                onPressed: _saving ? null : _cancelEditing,
                child: const Text('CANCELAR'),
              ),
          ],
        ),
        body: BlueprintFormBody(
          child: _editing
              ? DocumentFormSection(
                  initial: document,
                  saveLabel: 'GUARDAR CAMBIOS',
                  saving: _saving,
                  onDirtyChanged: (bool dirty) =>
                      setState(() => _dirty = dirty),
                  onSubmit: (LegalDocument updated) async {
                    setState(() => _saving = true);
                    try {
                      await ref
                          .read(legalDocumentActionsProvider)
                          .update(updated);
                    } catch (e) {
                      _log.error('update(${updated.id}): $e');
                      if (!context.mounted) return;
                      setState(() => _saving = false);
                      showErrorSnackBar(
                        context,
                        'No se pudo actualizar el documento.',
                      );
                      return;
                    }
                    if (!mounted) return;
                    setState(() {
                      _saving = false;
                      _editing = false;
                      _dirty = false;
                    });
                  },
                )
              : _buildReadOnlyView(document),
        ),
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
            : formatShortDate(document.issueDate!),
      ),
      _DetailRow(
        label: 'Fecha de vencimiento',
        value: formatShortDate(document.expirationDate),
      ),
      _DetailRow(label: 'Entidad', value: document.entityName ?? 'Sin definir'),
      _DetailRow(
        label: 'Costo',
        value: document.cost == null
            ? 'Sin definir'
            : copFormat.format(document.cost),
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
