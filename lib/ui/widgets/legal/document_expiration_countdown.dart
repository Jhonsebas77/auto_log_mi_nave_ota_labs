part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class DocumentExpirationCountdown extends StatelessWidget {
  const DocumentExpirationCountdown({
    required this.document,
    required this.onTapPreview,
    super.key,
  });

  final LegalDocument document;
  final VoidCallback onTapPreview;

  @override
  Widget build(BuildContext context) => Container(
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
              Text(document.documentType.label, style: AppTextStyles.bodyLarge),
              if (document.entityName != null)
                Text(document.entityName!, style: AppTextStyles.bodySmall),
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
  );
}
