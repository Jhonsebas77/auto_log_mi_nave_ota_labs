part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Dropdown de formulario con los mismos tokens visuales que
/// [BlueprintTextField] (tipografía y decoración del tema), para que los
/// selectores de enums no se vean distintos al resto de los inputs.
class BlueprintDropdownField<T> extends StatelessWidget {
  const BlueprintDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: value,
    style: AppTextStyles.bodyLarge,
    decoration: InputDecoration(label: Text(label)),
    items: <DropdownMenuItem<T>>[
      for (final T item in items)
        DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
    ],
    onChanged: (T? item) {
      if (item != null) onChanged(item);
    },
  );
}
