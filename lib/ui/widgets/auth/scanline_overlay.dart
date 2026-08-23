part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Línea de escaneo horizontal animada de arriba a abajo, en loop cada 8s.
/// Portado de app_track_ota_labs (ScanlineOverlay).
class ScanlineOverlay extends StatefulWidget {
  const ScanlineOverlay({super.key});

  @override
  State<ScanlineOverlay> createState() => _ScanlineOverlayState();
}

class _ScanlineOverlayState extends State<ScanlineOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (BuildContext context, _) => Positioned(
      top: MediaQuery.of(context).size.height * _anim.value,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Colors.transparent,
              BlueprintColors.successGreen.withAlpha(30),
              BlueprintColors.successGreen.withAlpha(50),
              BlueprintColors.successGreen.withAlpha(30),
              Colors.transparent,
            ],
          ),
        ),
      ),
    ),
  );
}
