part of com.auto_log_mi_nave_ota_labs.app.core.providers;

class SettingsState {
  const SettingsState({required this.notificationsEnabled});
  final bool notificationsEnabled;
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState(notificationsEnabled: true);

  Future<void> toggleNotifications(bool enabled) async {
    state = SettingsState(notificationsEnabled: enabled);
    await ref
        .read(notificationReconcilerProvider)
        .reconcileAll(now: DateTime.now(), notificationsEnabled: enabled);
  }
}

final NotifierProvider<SettingsController, SettingsState>
settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
