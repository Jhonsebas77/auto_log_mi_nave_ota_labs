part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Historial de servicios como sliver: se usa dentro de un `CustomScrollView`
/// para que la lista virtualice de verdad (ver `FuelHistorySliver`, mismo
/// motivo). Agrupa el `SegmentedButton` de filtro y, debajo, o el mensaje de
/// lista vacía o el `SliverList` de registros filtrados.
class ServiceHistorySegmentedList extends StatefulWidget {
  const ServiceHistorySegmentedList({required this.records, super.key});

  final List<MaintenanceRecord> records;

  @override
  State<ServiceHistorySegmentedList> createState() =>
      _ServiceHistorySegmentedListState();
}

class _ServiceHistorySegmentedListState
    extends State<ServiceHistorySegmentedList> {
  MaintenanceServiceType? _filter;

  @override
  Widget build(BuildContext context) {
    List<MaintenanceRecord> filtered = widget.records
        .where(
          (MaintenanceRecord r) => _filter == null || r.serviceType == _filter,
        )
        .toList();
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SegmentedButton<MaintenanceServiceType?>(
                segments: const <ButtonSegment<MaintenanceServiceType?>>[
                  ButtonSegment<MaintenanceServiceType?>(
                    value: null,
                    label: Text('Todos'),
                  ),
                  ButtonSegment<MaintenanceServiceType?>(
                    value: MaintenanceServiceType.preventivo,
                    label: Text('Preventivo'),
                  ),
                  ButtonSegment<MaintenanceServiceType?>(
                    value: MaintenanceServiceType.correctivo,
                    label: Text('Correctivo'),
                  ),
                ],
                selected: <MaintenanceServiceType?>{_filter},
                onSelectionChanged: (Set<MaintenanceServiceType?> s) =>
                    setState(() => _filter = s.first),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        if (filtered.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin registros.', style: AppTextStyles.bodySmall),
            ),
          )
        else
          SliverList.builder(
            itemCount: filtered.length,
            itemBuilder: (BuildContext context, int index) {
              MaintenanceRecord r = filtered[index];
              return Container(
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
                          Text(r.category, style: AppTextStyles.bodyLarge),
                          Text(
                            '${r.serviceType.label} · ${r.odometer} km · '
                            '${r.workshopName ?? "—"}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      copFormat.format(r.totalCost),
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
