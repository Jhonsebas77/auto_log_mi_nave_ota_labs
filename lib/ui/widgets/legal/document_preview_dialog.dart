part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Muestra el adjunto de un [LegalDocument] (imagen o PDF) en un [Dialog].
/// Compartido entre la lista de documentos y su pantalla de detalle.
void showDocumentPreviewDialog(BuildContext context, String path) {
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
