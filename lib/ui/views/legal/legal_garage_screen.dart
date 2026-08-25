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
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: path.toLowerCase().endsWith('.pdf')
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Documento PDF adjunto (vista previa no disponible en '
                  'esta demo).',
                ),
              )
            : Image(
                image: attachmentImageProvider(path),
                errorBuilder: (_, __, ___) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No fue posible cargar la imagen adjunta.'),
                ),
              ),
      ),
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

class _DocumentGroupList extends StatelessWidget {
  const _DocumentGroupList({required this.documents, required this.onPreview});

  final List<LegalDocument> documents;
  final void Function(LegalDocument) onPreview;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
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
        for (final LegalDocument d in documents)
          DocumentExpirationCountdown(
            document: d,
            onTapPreview: () => onPreview(d),
          ),
      ],
    );
  }
}
