part of com.auto_log_mi_nave_ota_labs.app.core.utils;

/// Resuelve un `ImageProvider` para una ruta de adjunto local (foto de
/// vehículo/documento), funcionando tanto en mobile (ruta real de archivo)
/// como en web (blob URL entregada por image_picker, servida vía red por el
/// propio navegador — `dart:io`'s `File` no existe en web).
ImageProvider attachmentImageProvider(String path) {
  if (kIsWeb) return NetworkImage(path);
  return FileImage(File(path));
}
