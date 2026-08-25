library com.auto_log_mi_nave_ota_labs.app.services;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../constants/constants.dart';
import '../data/repositories/repositories.dart';
import '../enums/enums.dart';
import '../models/models.dart';
import '../utils/utils.dart';

part 'attachments/attachment_picker_service.dart';
part 'notifications/flutter_local_notification_service.dart';
part 'notifications/notification_providers.dart';
part 'notifications/notification_reconciler.dart';
part 'notifications/notification_reminder_planner.dart';
part 'notifications/notification_service.dart';
part 'ocr/ocr_simulation_service.dart';
part 'service_providers.dart';
