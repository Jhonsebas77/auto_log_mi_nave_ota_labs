part of com.auto_log_mi_nave_ota_labs.app.ui.views;

const List<String> _tabGroups = <String>['Vehículo', 'Impuestos', 'Conductor'];

class LegalGarageScreen extends ConsumerStatefulWidget {
  const LegalGarageScreen({super.key});

  @override
  ConsumerState<LegalGarageScreen> createState() => _LegalGarageScreenState();
}

class _LegalGarageScreenState extends ConsumerState<LegalGarageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabGroups.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previewDocument(LegalDocument document) {
    String? path = document.documentUrl;
    if (path == null) return;
    showDocumentPreviewDialog(context, path);
  }

  void _openDetail(Vehicle vehicle, LegalDocument document) {
    CustomNavigator().push(
      context,
      DocumentDetailScreen(vehicleId: vehicle.id, documentId: document.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    if (vehicle == null) {
      return const Center(
        child: Text('Agrega un vehículo para ver su documentación.'),
      );
    }

    AsyncValue<List<LegalDocument>> documentsAsync = ref.watch(
      legalDocumentsProvider(vehicle.id),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        // Ver comentario en fuel_metrics_screen.dart: tag único por tab
        // porque AppShell mantiene todos los tabs montados en un
        // IndexedStack (todos los FAB sin tag comparten el mismo tag
        // implícito).
        heroTag: 'fab-register-document',
        onPressed: () =>
            CustomNavigator().push(context, const RegisterDocumentScreen()),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: <Widget>[for (final String g in _tabGroups) Tab(text: g)],
          ),
          Expanded(
            child: documentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => Center(child: Text('Error: $error')),
              data: (List<LegalDocument> documents) => TabBarView(
                controller: _tabController,
                children: <Widget>[
                  for (final String group in _tabGroups)
                    _DocumentGroupList(
                      documents: documents
                          .where(
                            (LegalDocument d) =>
                                d.documentType.garageTabGroup == group,
                          )
                          .toList(),
                      onPreview: _previewDocument,
                      onTap: (LegalDocument d) => _openDetail(vehicle, d),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentGroupList extends ConsumerStatefulWidget {
  const _DocumentGroupList({
    required this.documents,
    required this.onPreview,
    required this.onTap,
  });

  final List<LegalDocument> documents;
  final void Function(LegalDocument) onPreview;
  final void Function(LegalDocument) onTap;

  @override
  ConsumerState<_DocumentGroupList> createState() => _DocumentGroupListState();
}

class _DocumentGroupListState extends ConsumerState<_DocumentGroupList> {
  static const Logger _log = Logger('DocumentGroupList');

  // Igual que FuelHistorySliver: se oculta de inmediato al deslizar y solo se
  // revierte si el borrado remoto falla.
  final Set<String> _removedIds = <String>{};

  @override
  Widget build(BuildContext context) {
    List<LegalDocument> visible = widget.documents
        .where((LegalDocument d) => !_removedIds.contains(d.id))
        .toList();
    if (visible.isEmpty) {
      return const Center(
        child: Text(
          'Sin documentos registrados.',
          style: AppTextStyles.bodySmall,
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        for (final LegalDocument d in visible)
          Dismissible(
            key: ValueKey<String>(d.id),
            direction: DismissDirection.endToStart,
            background: _deleteSwipeBackground(),
            confirmDismiss: (_) => _confirmDelete(context, d),
            onDismissed: (_) => _deleteDocument(d),
            child: DocumentExpirationCountdown(
              document: d,
              onTapPreview: () => widget.onPreview(d),
              onTap: () => widget.onTap(d),
            ),
          ),
      ],
    );
  }

  Widget _deleteSwipeBackground() => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: Alignment.centerRight,
    color: BlueprintColors.danger,
    child: const Icon(Icons.delete_outline, color: Colors.white),
  );

  /// Además de confirmar, advierte que se cancelan los recordatorios de
  /// vencimiento asociados (ver NotificationReconciler.cancelForDocument).
  Future<bool> _confirmDelete(
    BuildContext context,
    LegalDocument document,
  ) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: BlueprintColors.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('Eliminar documento'),
        content: Text(
          'Vas a eliminar "${document.documentType.label}"'
          '${document.entityName == null ? '' : ' (${document.entityName})'}.'
          '\n\nEsta acción no se puede deshacer y se cancelarán los '
          'recordatorios de vencimiento asociados.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _deleteDocument(LegalDocument document) async {
    setState(() => _removedIds.add(document.id));
    try {
      await ref.read(legalDocumentActionsProvider).delete(document);
      if (mounted) showSuccessSnackBar(context, 'Documento eliminado');
    } catch (e) {
      _log.error('_deleteDocument(${document.id}): $e');
      // El borrado remoto falló: se revierte el ocultamiento optimista para
      // que el documento vuelva a aparecer, en vez de quedar "eliminado"
      // solo en la UI mientras sigue existiendo en el repositorio.
      if (mounted) {
        setState(() => _removedIds.remove(document.id));
        showErrorSnackBar(context, 'No se pudo eliminar el documento.');
      }
    }
  }
}
