part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

Color trafficLightColor(TrafficLightLevel level) {
  switch (level) {
    case TrafficLightLevel.ok:
      return BlueprintColors.successGreen;
    case TrafficLightLevel.warning:
      return BlueprintColors.warning;
    case TrafficLightLevel.danger:
      return BlueprintColors.danger;
  }
}

/// Chip de semáforo usado por Dashboard/Garaje Legal para el estado de un
/// documento (SOAT/RTM/etc.). Con [onTap] se puede tocar (el dashboard
/// móvil lo usa para abrir o registrar el documento).
class StatusTrafficLight extends StatelessWidget {
  const StatusTrafficLight({
    required this.label,
    required this.level,
    this.onTap,
    super.key,
  });

  final String label;
  final TrafficLightLevel level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color color = trafficLightColor(level);
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          // Flexible: en una celda angosta la etiqueta pasa a 2 líneas en
          // vez de desbordar.
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return Semantics(
      button: true,
      child: InkWell(onTap: onTap, child: chip),
    );
  }
}
