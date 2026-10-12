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
  static const Logger _log = Logger('RegisterDocumentScreen');
  bool _saving = false;
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    Vehicle? vehicle = ref.watch(selectedVehicleProvider);
    return BlueprintUnsavedChangesGuard(
      dirty: _dirty,
      busy: _saving,
      child: BlueprintScaffold(
        appBar: const BlueprintFormAppBar(title: 'Registrar Documento'),
        body: vehicle == null
            ? const Center(
                child: Text(
                  'Selecciona un vehículo primero.',
                  style: AppTextStyles.bodyLarge,
                ),
              )
            : BlueprintFormBody(
                child: DocumentFormSection(
                  prefilledType: widget.prefilledType,
                  vehicleId: vehicle.id,
                  saveLabel: 'GUARDAR',
                  saving: _saving,
                  onDirtyChanged: (bool dirty) =>
                      setState(() => _dirty = dirty),
                  onSubmit: (LegalDocument document) async {
                    setState(() => _saving = true);
                    try {
                      await ref
                          .read(legalDocumentActionsProvider)
                          .create(document);
                    } catch (e) {
                      _log.error('create(${document.id}): $e');
                      if (!context.mounted) return;
                      setState(() => _saving = false);
                      showErrorSnackBar(
                        context,
                        'No se pudo registrar el documento.',
                      );
                      return;
                    }
                    if (!context.mounted) return;
                    // `pop` (no `maybePop`) para saltarse el guard de
                    // cambios sin guardar.
                    Navigator.of(context).pop();
                  },
                ),
              ),
      ),
    );
  }
}
