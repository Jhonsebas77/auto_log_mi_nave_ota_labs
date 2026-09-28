part of com.auto_log_mi_nave_ota_labs.app.core.utils;

/// Resuelve un `ImageProvider` para un adjunto (foto de vehículo/documento).
///
/// Los adjuntos nuevos son siempre una URL de Supabase Storage (ver
/// `AttachmentPickerService`), así que el caso normal es `NetworkImage`. El
/// fallback a `FileImage` es solo por compatibilidad con datos viejos que
/// hayan quedado guardados como ruta local de archivo antes de ese cambio —
/// no existe en web (`dart:io`'s `File` no funciona ahí) y, aunque exista en
/// mobile, el archivo puede no estar ya en disco (ver `_isImage`/`Image` con
/// `errorBuilder` en los widgets que consumen esto, que cubren ese caso sin
/// crashear la UI).
///
/// [cacheKey] identifica la imagen en el `ImageCache` en vez de la URL. Se
/// usa para URLs firmadas: cada firma trae un token distinto, así que sin
/// esto la misma foto se descargaba y decodificaba de nuevo con cada firma.
ImageProvider attachmentImageProvider(String path, {String? cacheKey}) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return cacheKey == null
        ? NetworkImage(path)
        : _KeyedNetworkImage(path, cacheKey: cacheKey);
  }
  if (kIsWeb) return NetworkImage(path);
  return FileImage(File(path));
}

/// `NetworkImage` cuya identidad en el `ImageCache` es [cacheKey] (el
/// *object path* del adjunto) y no la URL, que cambia con cada firma.
@immutable
class _KeyedNetworkImage extends ImageProvider<_KeyedNetworkImage> {
  const _KeyedNetworkImage(this.url, {required this.cacheKey});

  final String url;
  final String cacheKey;

  @override
  Future<_KeyedNetworkImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_KeyedNetworkImage>(this);

  @override
  ImageStreamCompleter loadImage(
    _KeyedNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    NetworkImage delegate = NetworkImage(key.url);
    return delegate.loadImage(delegate, decode);
  }

  @override
  bool operator ==(Object other) =>
      other is _KeyedNetworkImage && other.cacheKey == cacheKey;

  @override
  int get hashCode => cacheKey.hashCode;
}
