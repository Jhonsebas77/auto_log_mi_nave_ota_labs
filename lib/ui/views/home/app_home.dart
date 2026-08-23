part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Shell persistente: TopAppBar + BottomNavBar + IndexedStack de los 5 tabs
/// del design_spec (Inicio/Gasolina/Legal/Taller/Acciones). Acciones va al
/// final de la pila: no aparece como pill del bottom nav, se abre desde el
/// botón circular separado (ver [BlueprintBottomNavBar]).
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const int quickActionsIndex = 4;

  static const List<Widget> _tabs = <Widget>[
    DashboardScreen(),
    FuelMetricsScreen(),
    LegalGarageScreen(),
    MaintenanceScreen(),
    QuickActionsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int tabIndex = ref.watch(selectedTabIndexProvider);
    return BlueprintScaffold(
      appBar: BlueprintTopAppBar(
        onSettingsTap: () =>
            CustomNavigator().push(context, const SettingsScreen()),
      ),
      body: IndexedStack(index: tabIndex, children: _tabs),
      bottomNavigationBar: BlueprintBottomNavBar(
        currentIndex: tabIndex,
        onDestinationSelected: (int index) =>
            ref.read(selectedTabIndexProvider.notifier).current = index,
        quickActionsSelected: tabIndex == quickActionsIndex,
        onQuickActionsTap: () =>
            ref.read(selectedTabIndexProvider.notifier).current =
                quickActionsIndex,
      ),
    );
  }
}
