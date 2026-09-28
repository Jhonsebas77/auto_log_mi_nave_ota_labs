part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Renderiza un adjunto (foto de vehículo o documento legal) que puede venir
/// como:
/// - un *object path* del bucket privado `attachments` (dato nuevo, desde
///   `0006_attachments_private.sql`): hay que resolverlo a una URL firmada
///   antes de poder mostrarlo. La firma la cachea `signedUrlProvider` por
///   path, así un rebuild no vuelve a pedirla a Supabase.
/// - una URL pública completa (`http(s)://...`, dato viejo guardado cuando
///   el bucket todavía era público): se muestra directo, sin pedir firma.
///
/// La imagen se decodifica al tamaño en que se muestra (ver [_resized]) en
/// vez de a su resolución original.
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
      return _image(attachmentImageProvider(path));
    }
    return ref
        .watch(signedUrlProvider(path))
        .when(
          // Al volver a firmar (cada ~55 min) se sigue mostrando la imagen
          // anterior en vez de parpadear al placeholder.
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          data: (String signedUrl) =>
              _image(attachmentImageProvider(signedUrl, cacheKey: path)),
          loading: () => placeholderBuilder != null
              ? placeholderBuilder!(context)
              : SizedBox(
                  width: width,
                  height: height,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
          error: (Object error, StackTrace stackTrace) => errorBuilder != null
              ? errorBuilder!(context, error, stackTrace)
              : const Icon(
                  Icons.broken_image_outlined,
                  color: BlueprintColors.textMuted,
                ),
        );
  }

  /// Sin [width]/[height] explícitos, el tamaño de decodificación se acota
  /// con el tamaño de la ventana y NO con un `LayoutBuilder`: este widget
  /// se usa dentro de `IntrinsicHeight` (dashboard en escritorio), y
  /// `LayoutBuilder` no soporta el cálculo de dimensiones intrínsecas —
  /// revienta el layout de toda la fila.
  Widget _image(ImageProvider provider) => Builder(
    builder: (BuildContext context) {
      Size window = MediaQuery.sizeOf(context);
      return _buildImage(
        _resized(
          context,
          provider,
          width ?? window.width,
          height ?? window.height,
        ),
      );
    },
  );

  Widget _buildImage(ImageProvider provider) => Image(
    image: provider,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: errorBuilder,
  );

  /// Limita el ancho decodificado al lado mayor del espacio disponible (en
  /// píxeles físicos). Con `BoxFit.cover` se deja el doble de margen, porque
  /// según la proporción de la foto puede terminar escalada por el alto.
  /// `ResizeImage` nunca agranda una imagen más pequeña que ese ancho.
  ImageProvider _resized(
    BuildContext context,
    ImageProvider provider,
    double? targetWidth,
    double? targetHeight,
  ) {
    double side = math.max(targetWidth ?? 0, targetHeight ?? 0);
    if (side <= 0 || !side.isFinite) return provider;
    double factor = fit == BoxFit.cover ? 2 : 1;
    int cacheWidth = (side * MediaQuery.devicePixelRatioOf(context) * factor)
        .round();
    return ResizeImage.resizeIfNeeded(cacheWidth, null, provider);
  }
}
