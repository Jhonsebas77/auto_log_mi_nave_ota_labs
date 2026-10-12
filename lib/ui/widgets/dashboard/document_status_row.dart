part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Semáforo resumido de documentos del Dashboard en móvil: los mismos tipos
/// que [DocumentStatusCards] (tablet/web) en una grilla 2×2 de chips. Tocar
/// un chip abre el documento o, si no está registrado, el formulario.
class DocumentStatusRow extends StatelessWidget {
  const DocumentStatusRow({
    required this.documents,
    required this.now,
    required this.onOpen,
    required this.onRegister,
    super.key,
  });

  final List<LegalDocument> documents;
  final DateTime now;
  final ValueChanged<LegalDocument> onOpen;
  final ValueChanged<DocumentType> onRegister;

  /// Etiquetas cortas: en media pantalla de móvil "Revisión
  /// Técnico-Mecánica: sin registro" no cabe.
  static String _shortLabel(DocumentType type) => switch (type) {
    DocumentType.rtm => 'RTM',
    DocumentType.polizaTodoRiesgo => 'Todo Riesgo',
    DocumentType.licenciaConduccion => 'Licencia',
    _ => type.label,
  };

  @override
  Widget build(BuildContext context) {
    Map<DocumentType, LegalDocument> latest = latestDocumentByType(documents);
    List<Widget> chips = <Widget>[
      for (final DocumentType type in DocumentStatusCards.types)
        _chip(type, latest[type]),
    ];
    return Column(
      children: <Widget>[
        for (int i = 0; i < chips.length; i += 2) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: chips[i]),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < chips.length
                      ? chips[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip(DocumentType type, LegalDocument? document) {
    String label = _shortLabel(type);
    return StatusTrafficLight(
      label: document == null ? '$label: sin registro' : label,
      level: document == null
          ? TrafficLightLevel.warning
          : documentStatusLevel(document, now),
      onTap: document == null ? () => onRegister(type) : () => onOpen(document),
    );
  }
}
