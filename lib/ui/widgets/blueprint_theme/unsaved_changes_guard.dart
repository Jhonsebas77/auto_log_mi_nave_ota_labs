part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Evita salir de un formulario con cambios sin guardar: si [dirty], el
/// botón/gesto de volver pide confirmación (ver [showDiscardChangesDialog]).
/// Mientras [busy] (guardando) no se puede salir. Sin cambios se sale
/// normal, así que el gesto de volver de iOS sigue funcionando.
///
/// Para salir después de guardar se usa `Navigator.pop` (no `maybePop`),
/// que no pasa por este guard.
class BlueprintUnsavedChangesGuard extends StatelessWidget {
  const BlueprintUnsavedChangesGuard({
    required this.dirty,
    required this.child,
    super.key,
    this.busy = false,
  });

  final bool dirty;
  final bool busy;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !dirty && !busy,
    onPopInvokedWithResult: (bool didPop, Object? _) async {
      if (didPop || busy) return;
      NavigatorState navigator = Navigator.of(context);
      if (await showDiscardChangesDialog(context)) navigator.pop();
    },
    child: child,
  );
}
