library com.auto_log_mi_nave_ota_labs.app.core.providers;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../constants/constants.dart';
import '../data/repositories/repositories.dart';
import '../enums/enums.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';

part 'auth_controller.dart';
part 'fuel_providers.dart';
part 'home_providers.dart';
part 'legal_document_providers.dart';
part 'login_throttle.dart';
part 'maintenance_providers.dart';
part 'settings_controller.dart';
part 'vehicle_providers.dart';
