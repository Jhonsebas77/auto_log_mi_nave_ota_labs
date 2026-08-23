part of com.auto_log_mi_nave_ota_labs.app.services;

/// Selección local de adjuntos (foto/PDF) para documentos legales, facturas
/// de mantenimiento y fotos de vehículo. Mock-friendly: no sube nada a
/// Storage.
///
/// En mobile (Android/iOS) copia el archivo elegido al directorio de
/// documentos de la app para que la ruta sobreviva más allá del archivo
/// temporal del picker. En web no existe un directorio de documentos ni
/// `dart:io` funcional: el navegador ya entrega una blob URL (`XFile.path`)
/// estable durante la sesión, así que se usa directamente sin copiar.
class AttachmentPickerService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<String?> pickImageFromCamera() => _pickImage(ImageSource.camera);
  Future<String?> pickImageFromGallery() => _pickImage(ImageSource.gallery);

  Future<String?> _pickImage(ImageSource source) async {
    XFile? picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return null;
    if (kIsWeb) return picked.path;
    return _copyToAppStorage(picked.path);
  }

  /// En web, `file_picker` no expone `path` (solo `bytes`), así que por
  /// ahora esta función retorna null en esa plataforma — el flujo de fotos
  /// (cámara/galería) sí funciona en web vía blob URL; adjuntar PDFs en web
  /// requeriría un manejo basado en bytes, fuera de este alcance.
  Future<String?> pickPdf() async {
    if (kIsWeb) return null;
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['pdf'],
    );
    String? path = result?.files.single.path;
    if (path == null) return null;
    return _copyToAppStorage(path);
  }

  Future<String> _copyToAppStorage(String sourcePath) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String extension = sourcePath.split('.').last;
    String destination = '${dir.path}/attachment_${generateId()}.$extension';
    await File(sourcePath).copy(destination);
    return destination;
  }
}
