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
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    return BlueprintScaffold(
      appBar: const BlueprintFormAppBar(title: 'Registrar Documento'),
      body: vehicle == null
          ? const Center(child: Text('Selecciona un vehículo primero.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DocumentFormSection(
                prefilledType: widget.prefilledType,
                vehicleId: vehicle.id,
                saveLabel: 'GUARDAR',
                saving: _saving,
                onSubmit: (LegalDocument document) async {
                  setState(() => _saving = true);
                  await ref.read(legalDocumentActionsProvider).create(document);
                  if (!context.mounted) return;
                  unawaited(Navigator.of(context).maybePop());
                },
              ),
            ),
    );
  }
}
