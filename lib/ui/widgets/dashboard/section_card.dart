part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Contenedor común de las secciones de resumen del dashboard (alertas,
/// vida útil, gasolina): título en versalitas a la izquierda y, opcional,
/// una acción a la derecha que lleva al tab con el detalle.
class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    required this.title,
    required this.child,
    this.icon,
    this.accentColor,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  /// Color del ícono y del borde. Sin él la card usa el borde neutro.
  final Color? accentColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: BlueprintColors.surfaceContainerLow,
      border: Border.all(color: accentColor ?? BlueprintColors.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(
                icon,
                size: 16,
                color: accentColor ?? BlueprintColors.accentOrange,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: BlueprintColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: BlueprintColors.accentOrange,
                  textStyle: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                  shape: kSharpShape,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

/// Error de carga de una sección del dashboard, con "Reintentar". Se usa en
/// lugar de mostrar la sección vacía: unos documentos que no cargaron no
/// son lo mismo que unos documentos sin registrar.
class DashboardSectionError extends StatelessWidget {
  const DashboardSectionError({
    required this.message,
    required this.onRetry,
    this.retrying = false,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: BlueprintColors.surfaceContainerLow,
      border: Border.all(color: BlueprintColors.danger.withValues(alpha: 0.6)),
    ),
    child: Row(
      children: <Widget>[
        const Icon(Icons.cloud_off_outlined, color: BlueprintColors.danger),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: AppTextStyles.bodyMedium)),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: retrying ? null : onRetry,
          child: retrying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Reintentar'),
        ),
      ],
    ),
  );
}
