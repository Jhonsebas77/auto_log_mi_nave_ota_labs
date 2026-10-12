library com.auto_log_mi_nave_ota_labs.app.core.constants;

import 'dart:ui';

import '../enums/enums.dart';
import '../models/models.dart';

part 'document_reminder_cadence.dart';
part 'license_plate_restriction_medellin.dart';
part 'maintenance_intervals.dart';
part 'vehicle_colors.dart';

const String hardcodedEmail = String.fromEnvironment('AUTH_EMAIL');

const List<String> monthsInSpanish = <String>[
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

const List<String> monthsInSpanishShort = <String>[
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];
