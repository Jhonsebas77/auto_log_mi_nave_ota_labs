part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Semáforo SOAT/RTM resumido del Dashboard.
class DocumentStatusRow extends StatelessWidget {
  const DocumentStatusRow({
    required this.documents,
    required this.now,
    super.key,
  });

  final List<LegalDocument> documents;
  final DateTime now;

  LegalDocument? _find(DocumentType type) {
    for (LegalDocument d in documents) {
      if (d.documentType == type) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    LegalDocument? soat = _find(DocumentType.soat);
    LegalDocument? rtm = _find(DocumentType.rtm);
    return Row(
      children: <Widget>[
        Expanded(
          child: StatusTrafficLight(
            label: soat == null ? 'SOAT: sin registro' : 'SOAT',
            level: soat == null
                ? TrafficLightLevel.warning
                : documentStatusLevel(soat, now),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatusTrafficLight(
            label: rtm == null ? 'RTM: sin registro' : 'RTM',
            level: rtm == null
                ? TrafficLightLevel.warning
                : documentStatusLevel(rtm, now),
          ),
        ),
      ],
    );
  }
}
