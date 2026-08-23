part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Botón compartido "Escanear con OCR". La simulación (delay + autocompletado)
/// vive en OcrSimulationService; este widget solo refleja loading/onTap.
class OcrScanButton extends StatelessWidget {
  const OcrScanButton({required this.loading, required this.onTap, super.key});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: loading ? null : onTap,
    icon: loading
        ? const SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: BlueprintColors.accentOrange,
            ),
          )
        : const Icon(Icons.document_scanner, size: 18),
    label: Text(
      loading ? 'Escaneando (simulado)...' : 'Escanear con OCR (simulado)',
    ),
  );
}
