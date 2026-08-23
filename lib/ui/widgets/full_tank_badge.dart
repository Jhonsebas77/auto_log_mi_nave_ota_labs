part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class FullTankBadge extends StatelessWidget {
  const FullTankBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      border: Border.all(color: BlueprintColors.successGreen),
    ),
    child: Text(
      'TANQUE LLENO',
      style: AppTextStyles.labelSmall.copyWith(
        color: BlueprintColors.successGreen,
      ),
    ),
  );
}
