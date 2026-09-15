part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class DocumentExpirationCountdown extends StatelessWidget {
  const DocumentExpirationCountdown({
    required this.document,
    required this.onTapPreview,
    this.onTap,
    super.key,
  });

  final LegalDocument document;
  final VoidCallback onTapPreview;
  final VoidCallback? onTap;

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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
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
                Text(
                  document.documentType.label,
                  style: AppTextStyles.bodyLarge,
                ),
                if (_subtitle != null)
                  Text(_subtitle!, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          CountdownChip(
            expirationDate: document.expirationDate,
            now: DateTime.now(),
          ),
          if (document.documentUrl != null)
            IconButton(
              onPressed: onTapPreview,
              icon: const Icon(
                Icons.picture_as_pdf,
                color: BlueprintColors.textMuted,
              ),
            ),
        ],
      ),
    ),
  );
}
