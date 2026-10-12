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
///
/// Los tabs se construyen de forma perezosa: un tab no se monta (ni dispara
/// sus consultas a Supabase) hasta la primera vez que se abre, y a partir de
/// ahí queda montado para conservar su estado. Los tabs fuera de pantalla
/// tienen los tickers pausados ([TickerMode]).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  static const int fuelIndex = 1;
  static const int maintenanceIndex = 3;
  static const int quickActionsIndex = 4;

  static const List<Widget> _tabs = <Widget>[
    DashboardScreen(),
    FuelMetricsScreen(),
    LegalGarageScreen(),
    MaintenanceScreen(),
    QuickActionsScreen(),
  ];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final Set<int> _visitedTabs = <int>{};

  @override
  Widget build(BuildContext context) {
    int tabIndex = ref.watch(selectedTabIndexProvider);
    _visitedTabs.add(tabIndex);
    WindowSize windowSize = Breakpoints.windowSizeOf(context);
    void openSettings() =>
        CustomNavigator().push(context, const SettingsScreen());
    void selectTab(int index) =>
        ref.read(selectedTabIndexProvider.notifier).current = index;
    Widget tabs = IndexedStack(
      index: tabIndex,
      children: <Widget>[
        for (int i = 0; i < AppShell._tabs.length; i++)
          TickerMode(
            enabled: i == tabIndex,
            child: _visitedTabs.contains(i)
                ? AppShell._tabs[i]
                : const SizedBox.shrink(),
          ),
      ],
    );

    if (windowSize == WindowSize.compact) {
      return BlueprintScaffold(
        appBar: BlueprintTopAppBar(onSettingsTap: openSettings),
        body: tabs,
        bottomNavigationBar: BlueprintBottomNavBar(
          currentIndex: tabIndex,
          onDestinationSelected: selectTab,
          quickActionsSelected: tabIndex == AppShell.quickActionsIndex,
          onQuickActionsTap: () => selectTab(AppShell.quickActionsIndex),
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
            quickActionsSelected: tabIndex == AppShell.quickActionsIndex,
            onQuickActionsTap: () => selectTab(AppShell.quickActionsIndex),
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
