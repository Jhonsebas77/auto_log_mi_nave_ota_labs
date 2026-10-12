part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.label,
    required this.value,
    super.key,
    this.unit,
    this.icon,
    this.subtitle,
  });

  final String label;
  final String value;

  /// Unidad que acompaña al valor en tamaño menor (p. ej. "km"), para que
  /// la cifra sea lo que resalta.
  final String? unit;
  final IconData? icon;

  /// Contexto del valor (p. ej. "en 12 tanqueos").
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: <String>[
      label,
      if (unit == null) value else '$value $unit',
      ?subtitle,
    ].join(', '),
    child: ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: BlueprintColors.surfaceContainerLow,
          border: Border.all(color: BlueprintColors.outlineVariant),
        ),
        // spaceBetween (y no un Spacer): en la grilla las cards de una fila
        // tienen el mismo alto y el subtítulo queda pegado abajo; usada
        // sola, la card simplemente toma su alto natural.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[
                      Icon(icon, size: 14, color: BlueprintColors.accentOrange),
                      const SizedBox(width: 6),
                    ],
                    // Hasta 2 líneas: en pantallas angostas (~320 px) una
                    // sola línea cortaba "Gasto en octubre" a "Gasto en oc…".
                    Expanded(
                      child: Text(
                        label,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // scaleDown: montos grandes ($12.345.678) se achican en vez de
                // desbordar la card en pantallas angostas.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(value, style: AppTextStyles.titleLarge),
                      if (unit != null) ...<Widget>[
                        const SizedBox(width: 4),
                        Text(unit!, style: AppTextStyles.bodySmall),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: AppTextStyles.labelSmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
