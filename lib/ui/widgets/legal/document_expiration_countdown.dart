part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class DocumentExpirationCountdown extends StatelessWidget {
  const DocumentExpirationCountdown({
    required this.document,
    required this.onTapPreview,
    required this.now,
    this.onTap,
    this.superseded = false,
    super.key,
  });

  final LegalDocument document;
  final VoidCallback onTapPreview;
  final VoidCallback? onTap;

  /// Fecha de referencia del contador; se recibe para que toda la lista use
  /// la misma.
  final DateTime now;

  /// Documento reemplazado por uno más reciente del mismo tipo (historial):
  /// se muestra atenuado y con su fecha de vencimiento en vez del contador,
  /// para que un SOAT ya renovado no se lea como "Vencido".
  final bool superseded;

  /// Entidad y # de documento en una sola línea, cuando estén disponibles
  /// (p.ej. "Seguros XYZ · # ABC123").
  String? get _subtitle {
    List<String> parts = <String>[
      if (document.entityName != null) document.entityName!,
      if (document.documentNumber != null) '# ${document.documentNumber}',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: superseded ? 0.6 : 1,
    // Separación fuera del InkWell para que el ripple no la cubra; el fondo
    // de "deslizar para eliminar" de Garaje Legal usa el mismo margen.
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(onTap: onTap, child: _buildCard()),
    ),
  );

  Widget _buildCard() => Container(
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
              Text(document.documentType.label, style: AppTextStyles.bodyLarge),
              if (_subtitle != null)
                Text(_subtitle!, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        if (superseded)
          Text(
            'Hasta ${formatShortDate(document.expirationDate)}',
            style: AppTextStyles.bodySmall,
          )
        else
          CountdownChip(expirationDate: document.expirationDate, now: now),
        if (document.documentUrl != null)
          IconButton(
            onPressed: onTapPreview,
            tooltip: 'Ver adjunto',
            icon: const Icon(
              Icons.picture_as_pdf,
              color: BlueprintColors.textMuted,
            ),
          ),
      ],
    ),
  );
}
