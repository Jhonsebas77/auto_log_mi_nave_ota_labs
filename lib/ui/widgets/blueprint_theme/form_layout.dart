part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Título de cada grupo de campos de un formulario.
class BlueprintFormSectionHeader extends StatelessWidget {
  const BlueprintFormSectionHeader(this.label, {super.key, this.first = false});

  final String label;

  /// El primer encabezado no lleva espacio arriba.
  final bool first;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: first ? 0 : 32, bottom: 16),
    child: CustomDividerWithLabel(
      label: label.toUpperCase(),
      color: BlueprintColors.textMuted,
    ),
  );
}

/// Dos campos lado a lado cuando hay ancho suficiente; apilados si no (ej.
/// teléfonos angostos).
class BlueprintFieldPair extends StatelessWidget {
  const BlueprintFieldPair({
    required this.first,
    required this.second,
    super.key,
  });

  static const double _minRowWidth = 400;

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) =>
        constraints.maxWidth >= _minRowWidth
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: first),
              const SizedBox(width: 16),
              Expanded(child: second),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[first, const SizedBox(height: 16), second],
          ),
  );
}
