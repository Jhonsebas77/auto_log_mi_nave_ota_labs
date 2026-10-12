part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Campo de fecha de formulario: muestra la fecha elegida y abre el picker
/// al tocarlo (el picker lo resuelve [onTap], así cada formulario fija sus
/// propios límites). Con [onClear] y una fecha elegida muestra un botón para
/// dejarla sin definir.
class BlueprintDateField extends StatelessWidget {
  const BlueprintDateField({
    required this.label,
    required this.date,
    required this.onTap,
    super.key,
    this.onClear,
    this.errorText,
    this.placeholder = 'Sin definir',
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String? errorText;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    DateTime? value = date;
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          label: Text(label),
          errorText: errorText,
          suffixIcon: value != null && onClear != null
              ? IconButton(
                  tooltip: 'Quitar fecha',
                  icon: const Icon(Icons.close),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today),
        ),
        child: Text(
          value == null ? placeholder : formatShortDate(value),
          style: value == null
              ? AppTextStyles.bodyLarge.copyWith(
                  color: BlueprintColors.textMuted,
                )
              : AppTextStyles.bodyLarge,
        ),
      ),
    );
  }
}
