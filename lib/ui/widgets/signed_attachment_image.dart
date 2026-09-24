part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Renderiza un adjunto (foto de vehículo o documento legal) que puede venir
/// como:
/// - un *object path* del bucket privado `attachments` (dato nuevo, desde
///   `0006_attachments_private.sql`): hay que resolverlo a una URL firmada
///   con [AttachmentPickerService.signedUrlFor] antes de poder mostrarlo.
/// - una URL pública completa (`http(s)://...`, dato viejo guardado cuando
///   el bucket todavía era público): se muestra directo, sin pedir firma.
///
/// Envuelve esa resolución en un único `FutureBuilder` para no repetirla en
/// cada punto que muestra un adjunto.
class SignedAttachmentImage extends ConsumerWidget {
  const SignedAttachmentImage({
    required this.path,
    super.key,
    this.fit,
    this.width,
    this.height,
    this.errorBuilder,
    this.placeholderBuilder,
  });

  final String path;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  /// Qué mostrar mientras se resuelve la URL firmada (o, para una URL
  /// pública vieja, mientras la imagen carga). Por defecto, un spinner
  /// pequeño centrado.
  final WidgetBuilder? placeholderBuilder;

  bool get _isLegacyPublicUrl =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isLegacyPublicUrl) {
      return Image(
        image: attachmentImageProvider(path),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
      );
    }
    return FutureBuilder<String>(
      future: ref.read(attachmentPickerServiceProvider).signedUrlFor(path),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          if (placeholderBuilder != null) return placeholderBuilder!(context);
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        String? signedUrl = snapshot.data;
        if (snapshot.hasError || signedUrl == null) {
          return errorBuilder != null
              ? errorBuilder!(
                  context,
                  snapshot.error ?? StateError('signed url vacía'),
                  null,
                )
              : const Icon(
                  Icons.broken_image_outlined,
                  color: BlueprintColors.textMuted,
                );
        }
        return Image(
          image: attachmentImageProvider(signedUrl),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: errorBuilder,
        );
      },
    );
  }
}
