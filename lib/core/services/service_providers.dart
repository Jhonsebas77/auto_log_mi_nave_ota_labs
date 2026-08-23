part of com.auto_log_mi_nave_ota_labs.app.services;

final Provider<OcrSimulationService> ocrSimulationServiceProvider =
    Provider<OcrSimulationService>((Ref ref) => OcrSimulationService());

final Provider<AttachmentPickerService> attachmentPickerServiceProvider =
    Provider<AttachmentPickerService>((Ref ref) => AttachmentPickerService());
