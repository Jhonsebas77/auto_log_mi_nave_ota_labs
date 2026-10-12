part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class _BlueprintNavDestination {
  const _BlueprintNavDestination(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Destinos de los tabs, compartidos por [BlueprintBottomNavBar] (móvil) y
/// [BlueprintSideNav] (tablet/escritorio).
const List<_BlueprintNavDestination> _kNavDestinations =
    <_BlueprintNavDestination>[
      _BlueprintNavDestination('Inicio', Icons.dashboard),
      _BlueprintNavDestination('Gasolina', Icons.local_gas_station),
      _BlueprintNavDestination('Legal', Icons.gavel),
      _BlueprintNavDestination('Taller', Icons.home_repair_service),
    ];

/// BottomNavBar tipo "pill": 4 destinos (Inicio/Gasolina/Legal/Taller) en una
/// cápsula, más un botón circular separado a la derecha para Acciones
/// Rápidas — layout pedido por el usuario a partir de una imagen de
/// referencia (cápsula de tabs + círculo de acción aparte).
class BlueprintBottomNavBar extends StatelessWidget {
  const BlueprintBottomNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.quickActionsSelected,
    required this.onQuickActionsTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool quickActionsSelected;
  final VoidCallback onQuickActionsTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: BlueprintColors.background),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 64,
          child: Row(
            children: <Widget>[
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: BlueprintColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: BlueprintColors.outlineVariant),
                  ),
                  child: Row(
                    children: <Widget>[
                      for (int i = 0; i < _kNavDestinations.length; i++)
                        Expanded(
                          child: _NavItem(
                            destination: _kNavDestinations[i],
                            selected: i == currentIndex,
                            onTap: () => onDestinationSelected(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _QuickActionsButton(
                selected: quickActionsSelected,
                onTap: onQuickActionsTap,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _BlueprintNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color foreground = selected
        ? BlueprintColors.background
        : BlueprintColors.textMuted;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: selected ? BlueprintColors.accentOrange : Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(destination.icon, color: foreground, size: 20),
              const SizedBox(height: 2),
              Text(
                destination.label,
                style: AppTextStyles.labelMedium.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón circular separado de la cápsula de tabs, para Acciones Rápidas.
class _QuickActionsButton extends StatelessWidget {
  const _QuickActionsButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color foreground = selected
        ? BlueprintColors.background
        : BlueprintColors.textMuted;
    return SizedBox(
      width: 64,
      height: 64,
      child: Material(
        color: selected
            ? BlueprintColors.accentOrange
            : BlueprintColors.surfaceContainerLow,
        shape: const CircleBorder(
          side: BorderSide(color: BlueprintColors.outline),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(Icons.bolt, color: foreground, size: 26),
        ),
      ),
    );
  }
}
