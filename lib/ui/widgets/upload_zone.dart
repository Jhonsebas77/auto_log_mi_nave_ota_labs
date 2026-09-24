part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Zona técnica de carga de adjuntos (foto/PDF), estilo "drop-zone" del
/// design system. Presentacional: la lógica real de selección de archivo
/// vive en [AttachmentPickerService] y se invoca vía [onTap].
class UploadZone extends StatelessWidget {
  const UploadZone({
    required this.filePath,
    required this.onTap,
    super.key,
    this.label = 'Adjuntar documento',
  });

  final String? filePath;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    bool hasFile = filePath != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasFile
                ? BlueprintColors.successGreen
                : BlueprintColors.outlineVariant,
          ),
        ),
        child: hasFile
            ? Row(
                children: <Widget>[
                  if (_isImage(filePath!))
                    ClipRRect(
                      child: SignedAttachmentImage(
                        path: filePath!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        // Adjuntos viejos guardados como ruta local (antes de
                        // subir a Supabase Storage) pueden ya no existir en
                        // disco — se muestra un ícono en vez de crashear.
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          color: BlueprintColors.textMuted,
                          size: 32,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.picture_as_pdf,
                      color: BlueprintColors.successGreen,
                      size: 32,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      filePath!.split('/').last,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: BlueprintColors.successGreen,
                    size: 20,
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  const Icon(
                    Icons.upload_file,
                    color: BlueprintColors.textMuted,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(label, style: AppTextStyles.bodySmall),
                ],
              ),
      ),
    );
  }

  bool _isImage(String path) {
    String lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
  }
}
