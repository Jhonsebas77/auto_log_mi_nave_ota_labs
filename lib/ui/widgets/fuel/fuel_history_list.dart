part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class FuelHistoryList extends StatelessWidget {
  const FuelHistoryList({required this.logs, super.key});

  final List<FuelLog> logs;

  @override
  Widget build(BuildContext context) {
    List<FuelLog> descending = logs.reversed.toList();
    return Column(
      children: <Widget>[
        for (final FuelLog log in descending)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: BlueprintColors.outlineVariant),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            '${log.odometer} km · '
                            '${log.gallons.toStringAsFixed(1)} gal',
                            style: AppTextStyles.bodyMedium,
                          ),
                          if (log.isFullTank) ...<Widget>[
                            const SizedBox(width: 8),
                            const FullTankBadge(),
                          ],
                        ],
                      ),
                      if (log.stationName != null)
                        Text(log.stationName!, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Text(
                  copFormat.format(log.totalCost),
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
