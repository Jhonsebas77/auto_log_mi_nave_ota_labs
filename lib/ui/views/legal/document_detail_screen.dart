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
  bool _editing = false;
  bool _saving = false;

  void _startEditing() => setState(() => _editing = true);

  void _cancelEditing() => setState(() => _editing = false);

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
            IconButton(onPressed: _startEditing, icon: const Icon(Icons.edit))
          else
            TextButton(
              onPressed: _saving ? null : _cancelEditing,
              child: const Text('CANCELAR'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _editing
            ? DocumentFormSection(
                initial: document,
                saveLabel: 'GUARDAR CAMBIOS',
                saving: _saving,
                onSubmit: (LegalDocument updated) async {
                  setState(() => _saving = true);
                  await ref.read(legalDocumentActionsProvider).update(updated);
                  if (!mounted) return;
                  setState(() {
                    _saving = false;
                    _editing = false;
                  });
                },
              )
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
