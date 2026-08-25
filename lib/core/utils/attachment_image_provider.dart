part of com.auto_log_mi_nave_ota_labs.app.core.utils;

/// Resuelve un `ImageProvider` para un adjunto (foto de vehículo/documento).
///
/// Los adjuntos nuevos son siempre una URL pública de Supabase Storage (ver
/// `AttachmentPickerService`), así que el caso normal es `NetworkImage`. El
/// fallback a `FileImage` es solo por compatibilidad con datos viejos que
/// hayan quedado guardados como ruta local de archivo antes de ese cambio —
/// no existe en web (`dart:io`'s `File` no funciona ahí) y, aunque exista en
/// mobile, el archivo puede no estar ya en disco (ver `_isImage`/`Image` con
/// `errorBuilder` en los widgets que consumen esto, que cubren ese caso sin
/// crashear la UI).
ImageProvider attachmentImageProvider(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }
  if (kIsWeb) return NetworkImage(path);
  return FileImage(File(path));
}
