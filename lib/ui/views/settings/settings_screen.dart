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
          // `FlutterLocalNotificationService` es no-op en web (no existe
          // implementación de plataforma del plugin ahí, ver
          // flutter_local_notification_service.dart), así que el switch se
          // deja visible pero deshabilitado en vez de prometer una
          // funcionalidad que no hace nada: mismo layout en todas las
          // plataformas, con un subtítulo que explica la limitación (igual
          // patrón que el ListTile de "Ciudad" arriba).
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notificaciones de vencimientos'),
            subtitle: kIsWeb
                ? const Text('No disponible en la versión web.')
                : null,
            value: settings.notificationsEnabled,
            onChanged: kIsWeb
                ? null
                : (bool v) => ref
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
