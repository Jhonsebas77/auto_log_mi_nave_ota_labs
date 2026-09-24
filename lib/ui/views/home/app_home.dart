part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Shell persistente: TopAppBar + BottomNavBar + IndexedStack de los 5 tabs
/// del design_spec (Inicio/Gasolina/Legal/Taller/Acciones). Acciones va al
/// final de la pila: no aparece como pill del bottom nav, se abre desde el
/// botón circular separado (ver [BlueprintBottomNavBar]).
///
/// Layout adaptativo según [Breakpoints.windowSizeOf]: en móvil usa el
/// bottom nav; en tablet un riel lateral compacto junto al TopAppBar; en
/// escritorio el sidebar completo (sin TopAppBar, el logo y Ajustes viven en
/// el sidebar). En tablet/escritorio el contenido de los tabs se centra con
/// un ancho máximo de [Breakpoints.contentMaxWidth].
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
    WindowSize windowSize = Breakpoints.windowSizeOf(context);
    void openSettings() =>
        CustomNavigator().push(context, const SettingsScreen());
    void selectTab(int index) =>
        ref.read(selectedTabIndexProvider.notifier).current = index;
    Widget tabs = IndexedStack(index: tabIndex, children: _tabs);

    if (windowSize == WindowSize.compact) {
      return BlueprintScaffold(
        appBar: BlueprintTopAppBar(onSettingsTap: openSettings),
        body: tabs,
        bottomNavigationBar: BlueprintBottomNavBar(
          currentIndex: tabIndex,
          onDestinationSelected: selectTab,
          quickActionsSelected: tabIndex == quickActionsIndex,
          onQuickActionsTap: () => selectTab(quickActionsIndex),
        ),
      );
    }

    bool expanded = windowSize == WindowSize.expanded;
    return BlueprintScaffold(
      appBar: expanded ? null : BlueprintTopAppBar(onSettingsTap: openSettings),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlueprintSideNav(
            extended: expanded,
            currentIndex: tabIndex,
            onDestinationSelected: selectTab,
            quickActionsSelected: tabIndex == quickActionsIndex,
            onQuickActionsTap: () => selectTab(quickActionsIndex),
            onSettingsTap: openSettings,
          ),
          Expanded(
            // Sin TopAppBar (escritorio) nadie más reserva el área segura
            // superior para el contenido.
            child: SafeArea(
              left: false,
              top: expanded,
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Breakpoints.contentMaxWidth,
                  ),
                  // Constraints tight (ancho y alto completos) para los tabs,
                  // igual que en móvil — Align solo pasa constraints sueltas.
                  child: SizedBox.expand(child: tabs),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
