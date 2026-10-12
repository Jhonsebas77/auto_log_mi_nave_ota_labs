library com.auto_log_mi_nave_ota_labs.app.ui.views;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/constants.dart';
import '../../core/enums/enums.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/services/services.dart';
import '../../core/utils/utils.dart';
import '../navigator.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

part 'auth/auth_gate.dart';
part 'auth/login_screen.dart';
part 'auth/splash_screen.dart';
part 'dashboard/view.dart';
part 'fuel/metrics_screen.dart';
part 'fuel/register_fuel_screen.dart';
part 'home/app_home.dart';
part 'legal/document_detail_screen.dart';
part 'legal/document_form_section.dart';
part 'legal/garage_screen.dart';
part 'legal/register_document_screen.dart';
part 'maintenance/register_maintenance_screen.dart';
part 'maintenance/view.dart';
part 'quick_actions_screen.dart';
part 'settings/settings_screen.dart';
part 'shared/attachment_upload_mixin.dart';
part 'shared/form_validators.dart';
part 'vehicles/add_screen.dart';
part 'vehicles/edit_screen.dart';
part 'vehicles/vehicle_form_screen.dart';
