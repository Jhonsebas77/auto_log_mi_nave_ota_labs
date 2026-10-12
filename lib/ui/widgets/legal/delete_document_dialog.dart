part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Confirma la eliminación de un [LegalDocument]. Además de confirmar,
/// advierte que se cancelan los recordatorios de vencimiento asociados (ver
/// NotificationReconciler.cancelForDocument). Compartido entre la lista de
/// Garaje Legal y la pantalla de detalle.
Future<bool> showDeleteDocumentDialog(
  BuildContext context,
  LegalDocument document,
) async {
  bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: BlueprintColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: const Text('Eliminar documento'),
      content: Text(
        'Vas a eliminar "${document.documentType.label}"'
        '${document.entityName == null ? '' : ' (${document.entityName})'}.'
        '\n\nEsta acción no se puede deshacer y se cancelarán los '
        'recordatorios de vencimiento asociados.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: BlueprintColors.danger),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
