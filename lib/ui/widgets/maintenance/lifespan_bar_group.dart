part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class LifespanBarGroup extends StatelessWidget {
  const LifespanBarGroup({required this.statuses, super.key});

  final List<LifespanStatus> statuses;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      for (final LifespanStatus s in statuses) ...<Widget>[
        LifespanBar(
          label: lifespanCategoryLabel(s.category),
          progress: s.progress,
        ),
        const SizedBox(height: 16),
      ],
    ],
  );
}
