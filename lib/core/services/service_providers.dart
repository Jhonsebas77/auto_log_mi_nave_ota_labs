part of com.auto_log_mi_nave_ota_labs.app.services;

final Provider<OcrSimulationService> ocrSimulationServiceProvider =
    Provider<OcrSimulationService>((Ref ref) => OcrSimulationService());

final Provider<AttachmentPickerService> attachmentPickerServiceProvider =
    Provider<AttachmentPickerService>((Ref ref) => AttachmentPickerService());

/// URL firmada de un adjunto, cacheada por *object path* durante casi todo
/// su TTL (ver `AttachmentPickerService._signedUrlTtlSeconds`). Sin esto,
/// cada rebuild de un `SignedAttachmentImage` pedía una firma nueva a
/// Supabase — y como cada firma trae un token distinto, la imagen además se
/// volvía a descargar y decodificar.
// ignore: always_specify_types
final signedUrlProvider = FutureProvider.autoDispose.family<String, String>((
  Ref ref,
  String objectPath,
) async {
  String url = await ref
      .watch(attachmentPickerServiceProvider)
      .signedUrlFor(objectPath);
  KeepAliveLink link = ref.keepAlive();
  Timer timer = Timer(
    AttachmentPickerService.signedUrlCacheDuration,
    link.close,
  );
  ref.onDispose(timer.cancel);
  return url;
});
