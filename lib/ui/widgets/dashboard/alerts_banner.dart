part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Aviso al tope del dashboard con los documentos vencidos o por vencer
/// (los de cualquier tipo, no solo los 4 del resumen), del más urgente al
/// menos. Sin nada que avisar no ocupa espacio.
///
/// Los documentos sin registrar no van aquí: ya los marca la sección de
/// documentos, y no son una urgencia de vencimiento.
class DashboardAlertsBanner extends StatelessWidget {
  const DashboardAlertsBanner({
    required this.documents,
    required this.now,
    required this.onOpen,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final List<LegalDocument> documents;
  final DateTime now;
  final ValueChanged<LegalDocument> onOpen;

  /// Espacio alrededor del aviso; solo se aplica cuando hay algo que avisar.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    List<LegalDocument> urgent =
        latestDocumentByType(documents).values
            .where(
              (LegalDocument d) =>
                  documentStatusLevel(d, now) != TrafficLightLevel.ok,
            )
            .toList()
          ..sort(
            (LegalDocument a, LegalDocument b) =>
                a.expirationDate.compareTo(b.expirationDate),
          );
    if (urgent.isEmpty) return const SizedBox.shrink();

    bool anyExpired = urgent.any(
      (LegalDocument d) =>
          documentStatusLevel(d, now) == TrafficLightLevel.danger,
    );
    Widget card = DashboardSectionCard(
      title: 'REQUIERE ATENCIÓN',
      icon: Icons.warning_amber_rounded,
      accentColor: anyExpired
          ? BlueprintColors.danger
          : BlueprintColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < urgent.length; i++) ...<Widget>[
            if (i > 0)
              const Divider(height: 1, color: BlueprintColors.outlineVariant),
            InkWell(
              onTap: () => onOpen(urgent[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        urgent[i].documentType.label,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CountdownChip(
                      expirationDate: urgent[i].expirationDate,
                      now: now,
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: BlueprintColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
    return Padding(padding: padding, child: card);
  }
}
