part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class QuickActionsScreen extends StatelessWidget {
  const QuickActionsScreen({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoints.formMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Acciones Rápidas',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 24),
            _ActionCard(
              icon: Icons.local_gas_station,
              label: 'Registrar Tanqueo',
              onTap: () =>
                  CustomNavigator().push(context, const RegisterFuelScreen()),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.build_circle,
              label: 'Registrar Mantenimiento',
              onTap: () => CustomNavigator().push(
                context,
                const RegisterMaintenanceScreen(),
              ),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.gavel,
              label: 'Registrar Documento',
              onTap: () => CustomNavigator().push(
                context,
                const RegisterDocumentScreen(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: BlueprintColors.outline),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: BlueprintColors.accentOrange, size: 28),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
          const Icon(Icons.chevron_right, color: BlueprintColors.textMuted),
        ],
      ),
    ),
  );
}
