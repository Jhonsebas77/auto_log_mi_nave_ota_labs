part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Selección y subida de un adjunto (foto/PDF) desde un formulario.
///
/// La hoja inferior solo elige la acción; la subida la hace la pantalla, así
/// el resultado no se pierde si la hoja se cierra a mitad de subida y se
/// puede mostrar el progreso con [_uploadingAttachment] (en [UploadZone]) y
/// bloquear el guardado mientras tanto.
mixin _AttachmentUploadMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  static const Logger _uploadLog = Logger('AttachmentUpload');

  bool _uploadingAttachment = false;

  /// [onChanged] se llama solo si el adjunto cambió: con la nueva ruta en
  /// Storage, o con `null` si el usuario lo quitó.
  Future<void> _pickAttachment({
    required String category,
    required bool hasAttachment,
    required ValueChanged<String?> onChanged,
    bool allowPdf = false,
    String removeLabel = 'Quitar archivo',
    String errorMessage = 'No se pudo subir el archivo.',
  }) async {
    String? userId = ref.read(authControllerProvider).user?.id;
    if (userId == null || _uploadingAttachment) return;
    AttachmentAction? action = await showModalBottomSheet<AttachmentAction>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, AttachmentAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(context, AttachmentAction.gallery),
            ),
            if (allowPdf)
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Elegir PDF'),
                onTap: () => Navigator.pop(context, AttachmentAction.pdf),
              ),
            if (hasAttachment)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: BlueprintColors.danger,
                ),
                title: Text(removeLabel),
                onTap: () => Navigator.pop(context, AttachmentAction.remove),
              ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    if (action == AttachmentAction.remove) {
      onChanged(null);
      return;
    }
    setState(() => _uploadingAttachment = true);
    AttachmentPickerService picker = ref.read(attachmentPickerServiceProvider);
    try {
      String? path = switch (action) {
        AttachmentAction.camera => await picker.pickImageFromCamera(
          userId: userId,
          category: category,
        ),
        AttachmentAction.gallery => await picker.pickImageFromGallery(
          userId: userId,
          category: category,
        ),
        AttachmentAction.pdf => await picker.pickPdf(
          userId: userId,
          category: category,
        ),
        AttachmentAction.remove => null,
      };
      if (path != null && mounted) onChanged(path);
    } catch (e) {
      _uploadLog.error('_pickAttachment($category, ${action.name}): $e');
      if (mounted) showErrorSnackBar(context, errorMessage);
    }
    if (mounted) setState(() => _uploadingAttachment = false);
  }
}
