part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Versión detallada de [DocumentStatusRow] para tablet/web (donde sobra
/// ancho): una card por documento con entidad, número, vencimiento, estado y
/// una acción — basada en la card "ESTADO DOCUMENTOS" (DOC_04) de la
/// pantalla "Dashboard Principal Desktop" de Stitch.
///
/// Con ancho suficiente las cards van en una cuadrícula de [_columns]
/// columnas (cada fila de igual altura); si no, se apilan. La navegación la resuelve quien la usa ([onOpen] /
/// [onRegister]), porque este library no conoce las pantallas.
class DocumentStatusCards extends StatelessWidget {
  const DocumentStatusCards({
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

  /// Documentos que se resumen en el dashboard, en orden.
  static const List<DocumentType> types = <DocumentType>[
    DocumentType.soat,
    DocumentType.rtm,
    DocumentType.polizaTodoRiesgo,
    DocumentType.licenciaConduccion,
  ];

  /// Ancho mínimo para poner las cards lado a lado.
  static const double _rowMinWidth = 720;

  /// Cards por fila. Con 4 documentos, 2×2 deja a cada card ~600px en
  /// escritorio; 4 en fila (~290px) no alcanza para las etiquetas largas.
  static const int _columns = 2;

  @override
  Widget build(BuildContext context) {
    Map<DocumentType, LegalDocument> latest = latestDocumentByType(documents);
    List<Widget> buildCards({required bool inRow}) => <Widget>[
      for (final DocumentType type in types)
        _DocumentStatusCard(
          type: type,
          document: latest[type],
          now: now,
          onOpen: onOpen,
          onRegister: onRegister,
          fillHeight: inRow,
        ),
    ];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < _rowMinWidth) {
          List<Widget> cards = buildCards(inRow: false);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < cards.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: 16),
                cards[i],
              ],
            ],
          );
        }
        List<Widget> cards = buildCards(inRow: true);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int row = 0; row * _columns < cards.length; row++) ...<Widget>[
              if (row > 0) const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (int col = 0; col < _columns; col++) ...<Widget>[
                      if (col > 0) const SizedBox(width: 16),
                      // Si la última fila queda incompleta, el hueco
                      // conserva el ancho de columna.
                      Expanded(
                        child: row * _columns + col < cards.length
                            ? cards[row * _columns + col]
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DocumentStatusCard extends StatelessWidget {
  const _DocumentStatusCard({
    required this.type,
    required this.document,
    required this.now,
    required this.onOpen,
    required this.onRegister,
    required this.fillHeight,
  });

  final DocumentType type;
  final LegalDocument? document;
  final DateTime now;
  final ValueChanged<LegalDocument> onOpen;
  final ValueChanged<DocumentType> onRegister;

  /// En la fila de igual altura empuja el footer al fondo de la card; al
  /// apilarlas (alto sin límite dentro del scroll) no se puede usar.
  final bool fillHeight;

  static const List<String> _months = <String>[
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${_months[date.month - 1]}/'
      '${date.year}';

  String _statusText(TrafficLightLevel level) => switch (level) {
    TrafficLightLevel.ok => 'ESTADO: AL DÍA',
    TrafficLightLevel.warning => 'ALERTA: POR VENCER',
    TrafficLightLevel.danger => 'ESTADO: VENCIDO',
  };

  @override
  Widget build(BuildContext context) {
    LegalDocument? doc = document;
    TrafficLightLevel level = doc == null
        ? TrafficLightLevel.warning
        : documentStatusLevel(doc, now);
    Color color = trafficLightColor(level);
    // Solo se resalta el borde cuando requiere atención, como la card
    // Técnico-Mecánica del diseño de Stitch.
    bool highlight = doc != null && level != TrafficLightLevel.ok;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BlueprintColors.surfaceContainerLow,
        border: Border.all(
          color: highlight ? color : BlueprintColors.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(width: 10, height: 10, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    type.label.toUpperCase(),
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                if (doc != null) ...<Widget>[
                  const SizedBox(width: 8),
                  CountdownChip(expirationDate: doc.expirationDate, now: now),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: BlueprintColors.outlineVariant),
            const SizedBox(height: 16),
            if (doc == null)
              const Text(
                'Sin registro. Agrégalo para recibir alertas de vencimiento.',
                style: AppTextStyles.bodyMedium,
              )
            else ...<Widget>[
              // Mismos campos y etiquetas que DocumentFormSection /
              // DocumentDetailScreen (sin el adjunto: se ve en el detalle).
              // Los opcionales vacíos no se muestran.
              if (doc.entityName case String entity)
                _InfoRow(label: 'Entidad', value: entity),
              if (doc.documentNumber case String number)
                _InfoRow(label: '# de documento', value: number),
              if (doc.issueDate case DateTime issueDate)
                _InfoRow(
                  label: 'Fecha de expedición',
                  value: _formatDate(issueDate),
                ),
              _InfoRow(
                label: 'Fecha de vencimiento',
                value: _formatDate(doc.expirationDate),
                valueColor: color,
              ),
              if (doc.cost case double cost)
                _InfoRow(label: 'Costo', value: copFormat.format(cost)),
              if (doc.notes case String notes)
                _InfoRow(label: 'Información adicional', value: notes),
            ],
            if (fillHeight) const Spacer(),
            const SizedBox(height: 16),
            const Divider(height: 1, color: BlueprintColors.outlineVariant),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    doc == null ? 'ESTADO: SIN REGISTRO' : _statusText(level),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: color,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: BlueprintColors.accentOrange,
                    textStyle: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                    shape: kSharpShape,
                  ),
                  onPressed: doc == null
                      ? () => onRegister(type)
                      : () => onOpen(doc),
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    doc == null ? Icons.add : Icons.open_in_new,
                    size: 16,
                  ),
                  label: Text(doc == null ? 'REGISTRAR' : 'VER DETALLE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label:',
          style: AppTextStyles.bodyMedium.copyWith(
            color: BlueprintColors.textMuted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor,
              fontWeight: valueColor == null ? null : FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
