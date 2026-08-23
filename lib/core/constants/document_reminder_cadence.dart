part of com.auto_log_mi_nave_ota_labs.app.core.constants;

/// Días antes del vencimiento de un `LegalDocument` en los que se agenda un
/// recordatorio local. 30/15/7/1: da margen para agendar cita de RTM o pago,
/// más dos recordatorios estándar y un último aviso.
const List<int> kDocumentReminderOffsetsDays = <int>[30, 15, 7, 1];
