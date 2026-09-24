library com.auto_log_mi_nave_ota_labs.app.core.models;

import '../enums/enums.dart';

part 'app_user.dart';
part 'document_ocr_result.dart';
part 'fuel_log.dart';
part 'legal_document.dart';
part 'license_plate_restriction/day_rule.dart';
part 'license_plate_restriction/result.dart';
part 'license_plate_restriction/schedule.dart';
part 'maintenance_record.dart';
part 'scheduled_reminder.dart';
part 'vehicle.dart';
part 'vehicle_ocr_result.dart';

/// Centinela usado por los `copyWith` de este library para distinguir
/// "parámetro no pasado" (se conserva el valor actual) de "pasado
/// explícitamente como `null`" (se debe vaciar el campo). Necesario solo en
/// campos nullable: con el patrón `campo ?? this.campo` de Dart, pasar
/// `null` explícito es indistinguible de no pasar nada, así que nunca se
/// puede vaciar un campo opcional a través de `copyWith`.
const Object _unset = Object();
