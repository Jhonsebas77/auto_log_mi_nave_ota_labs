part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  static const String route = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SettingsState settings = ref.watch(settingsControllerProvider);
    AppUser? user = ref.watch(authControllerProvider).user;

    return BlueprintScaffold(
      appBar: const BlueprintFormAppBar(title: 'Configuración'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (user != null) ...<Widget>[
            Text(user.fullName, style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
          ],
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.location_on, color: BlueprintColors.textMuted),
            title: Text('Ciudad'),
            subtitle: Text('Medellín, Antioquia (fijo)'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notificaciones de vencimientos'),
            value: settings.notificationsEnabled,
            onChanged: (bool v) => ref
                .read(settingsControllerProvider.notifier)
                .toggleNotifications(v),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            child: const Text('Cerrar sesión'),
          ),
          const SizedBox(height: 24),
          const Center(child: VersionWidget()),
        ],
      ),
    );
  }
}
