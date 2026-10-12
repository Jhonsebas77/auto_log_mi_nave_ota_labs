part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class LegalGarageScreen extends ConsumerStatefulWidget {
  const LegalGarageScreen({super.key});

  @override
  ConsumerState<LegalGarageScreen> createState() => _LegalGarageScreenState();
}

class _LegalGarageScreenState extends ConsumerState<LegalGarageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _tabIndex = 0;

  List<LegalDocument>? _groupedFrom;
  List<GarageDocumentGroup> _groups = const <GarageDocumentGroup>[];

  /// Grupo de cada tab, indexado por [GarageTabGroup.index].
  List<GarageDocumentGroup> _groupsFor(List<LegalDocument> documents) {
    if (identical(documents, _groupedFrom)) return _groups;
    _groupedFrom = documents;
    return _groups = <GarageDocumentGroup>[
      for (final GarageTabGroup group in GarageTabGroup.values)
        garageDocumentGroup(documents, group),
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: GarageTabGroup.values.length,
      vsync: this,
    );
    // El FAB precarga el tipo según la tab activa.
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.index == _tabIndex) return;
    setState(() => _tabIndex = _tabController.index);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _previewDocument(LegalDocument document) {
    String? path = document.documentUrl;
    if (path == null) return;
    showDocumentPreviewDialog(context, path);
  }

  void _openDetail(String vehicleId, LegalDocument document) {
    CustomNavigator().push(
      context,
      DocumentDetailScreen(vehicleId: vehicleId, documentId: document.id),
    );
  }

  void _register([DocumentType? type]) {
    CustomNavigator().push(
      context,
      RegisterDocumentScreen(prefilledType: type),
    );
  }

  /// Si la tab activa tiene un único tipo (Impuestos, Conductor), el FAB lo
  /// precarga; en Vehículo hay varios y se deja elegir.
  DocumentType? get _fabPrefilledType {
    List<DocumentType> types = GarageTabGroup.values[_tabIndex].documentTypes;
    return types.length == 1 ? types.single : null;
  }

  Future<void> _refresh(String vehicleId) => ref
      .refresh(legalDocumentsProvider(vehicleId).future)
      // El error ya lo muestra la vista (con "Reintentar"); aquí solo se
      // cierra el indicador.
      .then<void>((_) {}, onError: (_) {});

  @override
  Widget build(BuildContext context) {
    String? vehicleId = ref.watch(
      selectedVehicleProvider.select((Vehicle? v) => v?.id),
    );
    if (vehicleId == null) {
      return _NoVehicleState(
        onAddVehicle: () =>
            CustomNavigator().push(context, const AddVehicleScreen()),
      );
    }

    AsyncValue<List<LegalDocument>> documentsAsync = ref.watch(
      legalDocumentsProvider(vehicleId),
    );
    DateTime now = DateTime.now();
    List<LegalDocument>? documents = documentsAsync.value;
    List<GarageDocumentGroup>? groups = documents == null
        ? null
        : _groupsFor(documents);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-register-document',
        tooltip: 'Registrar documento',
        onPressed: () => _register(_fabPrefilledType),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: <Widget>[
              for (final GarageTabGroup group in GarageTabGroup.values)
                Tab(
                  child: _TabLabel(
                    label: group.label,
                    level: groups?[group.index].level(now),
                  ),
                ),
            ],
          ),
          Expanded(
            child: documentsAsync.when(
              loading: () => const LegalDocumentsSkeleton(),
              // El error ya lo loguea legalDocumentsProvider; aquí solo se
              // ofrece reintentar sin mostrar la excepción al usuario.
              error: (Object error, _) => _DocumentsErrorState(
                retrying: documentsAsync.isLoading,
                onRetry: () =>
                    ref.invalidate(legalDocumentsProvider(vehicleId)),
              ),
              data: (List<LegalDocument> documents) => TabBarView(
                controller: _tabController,
                children: <Widget>[
                  for (final GarageTabGroup group in GarageTabGroup.values)
                    _DocumentGroupList(
                      tabGroup: group,
                      group: _groupsFor(documents)[group.index],
                      now: now,
                      onRefresh: () => _refresh(vehicleId),
                      onPreview: _previewDocument,
                      onTap: (LegalDocument d) => _openDetail(vehicleId, d),
                      onRegister: _register,
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

/// Nombre de la tab con un punto de semáforo cuando alguno de sus
/// documentos vigentes está vencido o por vencer.
class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.label, required this.level});

  final String label;
  final TrafficLightLevel? level;

  @override
  Widget build(BuildContext context) {
    TrafficLightLevel? level = this.level;
    if (level == null || level == TrafficLightLevel.ok) return Text(label);
    return Semantics(
      label: level == TrafficLightLevel.danger
          ? '$label, con documentos vencidos'
          : '$label, con documentos por vencer',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label),
          const SizedBox(width: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: trafficLightColor(level),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentGroupList extends ConsumerStatefulWidget {
  const _DocumentGroupList({
    required this.tabGroup,
    required this.group,
    required this.now,
    required this.onRefresh,
    required this.onPreview,
    required this.onTap,
    required this.onRegister,
  });

  final GarageTabGroup tabGroup;
  final GarageDocumentGroup group;
  final DateTime now;
  final Future<void> Function() onRefresh;
  final void Function(LegalDocument) onPreview;
  final void Function(LegalDocument) onTap;
  final void Function(DocumentType) onRegister;

  @override
  ConsumerState<_DocumentGroupList> createState() => _DocumentGroupListState();
}

class _DocumentGroupListState extends ConsumerState<_DocumentGroupList> {
  static const Logger _log = Logger('DocumentGroupList');

  /// Eliminados de forma optimista mientras llega la lista recargada.
  final Set<String> _removedIds = <String>{};

  @override
  void didUpdateWidget(covariant _DocumentGroupList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.group, widget.group)) _removedIds.clear();
  }

  List<LegalDocument> _visible(List<LegalDocument> documents) => documents
      .where((LegalDocument d) => !_removedIds.contains(d.id))
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    List<LegalDocument> current = _visible(widget.group.current);
    List<LegalDocument> history = _visible(widget.group.history);
    List<DocumentType> missing = widget.group.missingTypes;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: current.isEmpty && history.isEmpty
          ? _buildEmpty(missing)
          : ListView(
              // Para que "deslizar para refrescar" funcione aunque el
              // contenido quepa en pantalla.
              physics: const AlwaysScrollableScrollPhysics(),
              // Margen inferior para que el FAB no tape el último ítem.
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              children: <Widget>[
                for (final LegalDocument d in current) _buildItem(d),
                if (missing.isNotEmpty)
                  _MissingDocumentsPrompt(
                    types: missing,
                    onRegister: widget.onRegister,
                  ),
                if (history.isNotEmpty) _buildHistory(history),
              ],
            ),
    );
  }

  Widget _buildEmpty(List<DocumentType> missing) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) =>
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.description_outlined,
                  size: 48,
                  color: BlueprintColors.textMuted,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sin documentos registrados.',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _MissingDocumentsPrompt(
                  types: missing,
                  onRegister: widget.onRegister,
                  centered: true,
                ),
              ],
            ),
          ),
        ),
  );

  Widget _buildHistory(List<LegalDocument> history) => Theme(
    // Sin los divisores que ExpansionTile dibuja al expandirse.
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      // Conserva expandido/plegado al cambiar de tab.
      key: PageStorageKey<String>('garage-history-${widget.tabGroup.name}'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      iconColor: BlueprintColors.textMuted,
      collapsedIconColor: BlueprintColors.textMuted,
      title: Text(
        'Historial (${history.length})',
        style: AppTextStyles.bodySmall,
      ),
      subtitle: const Text(
        'Documentos reemplazados al renovar',
        style: AppTextStyles.bodySmall,
      ),
      children: <Widget>[
        for (final LegalDocument d in history) _buildItem(d, superseded: true),
      ],
    ),
  );

  Widget _buildItem(LegalDocument d, {bool superseded = false}) => Dismissible(
    key: ValueKey<String>(d.id),
    direction: DismissDirection.endToStart,
    background: _deleteSwipeBackground(),
    confirmDismiss: (_) => showDeleteDocumentDialog(context, d),
    onDismissed: (_) => _deleteDocument(d),
    child: DocumentExpirationCountdown(
      document: d,
      now: widget.now,
      superseded: superseded,
      onTapPreview: () => widget.onPreview(d),
      onTap: () => widget.onTap(d),
    ),
  );

  Widget _deleteSwipeBackground() => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: Alignment.centerRight,
    color: BlueprintColors.danger,
    child: const Icon(Icons.delete_outline, color: Colors.white),
  );

  Future<void> _deleteDocument(LegalDocument document) async {
    setState(() => _removedIds.add(document.id));
    try {
      await ref.read(legalDocumentActionsProvider).delete(document);
      if (mounted) showSuccessSnackBar(context, 'Documento eliminado');
    } catch (e) {
      _log.error('_deleteDocument(${document.id}): $e');
      if (mounted) {
        setState(() => _removedIds.remove(document.id));
        showErrorSnackBar(context, 'No se pudo eliminar el documento.');
      }
    }
  }
}

/// Atajos para registrar los tipos de la tab que aún no tienen documento.
class _MissingDocumentsPrompt extends StatelessWidget {
  const _MissingDocumentsPrompt({
    required this.types,
    required this.onRegister,
    this.centered = false,
  });

  final List<DocumentType> types;
  final void Function(DocumentType) onRegister;
  final bool centered;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Sin registrar:', style: AppTextStyles.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final DocumentType type in types)
              OutlinedButton.icon(
                onPressed: () => onRegister(type),
                icon: const Icon(Icons.add, size: 16),
                label: Text(type.label),
              ),
          ],
        ),
      ],
    ),
  );
}

class _DocumentsErrorState extends StatelessWidget {
  const _DocumentsErrorState({required this.onRetry, required this.retrying});

  final VoidCallback onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: BlueprintColors.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'No pudimos cargar tus documentos.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa tu conexión a internet e inténtalo de nuevo.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: retrying ? null : onRetry,
            icon: retrying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}

class _NoVehicleState extends StatelessWidget {
  const _NoVehicleState({required this.onAddVehicle});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Agrega un vehículo para ver su documentación.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          BlueprintPrimaryButton(
            label: 'AGREGAR VEHÍCULO',
            onPressed: onAddVehicle,
          ),
        ],
      ),
    ),
  );
}
