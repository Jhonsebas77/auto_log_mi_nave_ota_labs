part of com.auto_log_mi_nave_ota_labs.app.services;

/// Selección y subida de adjuntos (foto/PDF) para documentos legales,
/// facturas de mantenimiento y fotos de vehículo.
///
/// El archivo elegido se sube directo a Supabase Storage (bucket privado
/// `attachments`, ver `supabase/sql/0002_storage.sql` y
/// `0006_attachments_private.sql`) bajo `{userId}/{category}/{id}.{ext}`, y
/// se retorna el *object path* resultante — no una URL, porque el bucket es
/// privado y solo sirve mediante URLs firmadas con TTL (ver
/// [signedUrlFor]) — ya no se guarda ninguna ruta local. Se lee como bytes
/// (`XFile.readAsBytes` / `PlatformFile.bytes`) en vez de usar `dart:io`, así
/// el mismo código funciona igual en mobile y en web.
class AttachmentPickerService {
  final ImagePicker _imagePicker = ImagePicker();

  static const String _bucket = 'attachments';

  StorageFileApi get _bucketApi =>
      Supabase.instance.client.storage.from(_bucket);

  Future<String?> pickImageFromCamera({
    required String userId,
    required String category,
  }) => _pickImage(ImageSource.camera, userId: userId, category: category);

  Future<String?> pickImageFromGallery({
    required String userId,
    required String category,
  }) => _pickImage(ImageSource.gallery, userId: userId, category: category);

  Future<String?> _pickImage(
    ImageSource source, {
    required String userId,
    required String category,
  }) async {
    XFile? picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return _upload(
      bytes: await picked.readAsBytes(),
      extension: picked.path.split('.').last,
      userId: userId,
      category: category,
    );
  }

  Future<String?> pickPdf({
    required String userId,
    required String category,
  }) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['pdf'],
      withData: true,
    );
    Uint8List? bytes = result?.files.single.bytes;
    if (bytes == null) return null;
    return _upload(
      bytes: bytes,
      extension: 'pdf',
      userId: userId,
      category: category,
    );
  }

  Future<String> _upload({
    required Uint8List bytes,
    required String extension,
    required String userId,
    required String category,
  }) async {
    String objectPath = '$userId/$category/${generateId()}.$extension';
    await _bucketApi.uploadBinary(objectPath, bytes);
    // Se persiste la ruta del objeto, no una URL: el bucket es privado y las
    // URLs firmadas caducan, así que no tiene sentido guardarlas.
    return objectPath;
  }

  /// TTL de 1 hora: alcanza de sobra para ver el adjunto en pantalla y evita
  /// que un link copiado siga sirviendo indefinidamente.
  static const int _signedUrlTtlSeconds = 3600;

  Future<String> signedUrlFor(String objectPath) =>
      _bucketApi.createSignedUrl(objectPath, _signedUrlTtlSeconds);
}
