part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Confirma si se descartan los cambios sin guardar de un formulario al
/// salir de él. Devuelve `true` solo si el usuario elige descartar.
Future<bool> showDiscardChangesDialog(BuildContext context) async {
  bool? discard = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: BlueprintColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: const Text('Descartar cambios'),
      content: const Text(
        'Tienes cambios sin guardar. Si sales ahora se perderán.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Seguir editando'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Descartar'),
        ),
      ],
    ),
  );
  return discard ?? false;
}
