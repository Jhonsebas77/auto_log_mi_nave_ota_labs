part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Barra de acento animada del footer del login (rebota de izquierda a
/// derecha en loop). Portado de app_track_ota_labs (DiagnosticStrip).
class DiagnosticStrip extends StatefulWidget {
  const DiagnosticStrip({super.key});

  @override
  State<DiagnosticStrip> createState() => _DiagnosticStripState();
}

class _DiagnosticStripState extends State<DiagnosticStrip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _anim = Tween<double>(
      begin: -0.4,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 2,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double totalWidth = constraints.maxWidth;
        double barWidth = totalWidth * 0.35;

        return AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            double left = totalWidth * _anim.value;
            return Stack(
              children: <Widget>[
                Container(color: BlueprintColors.gridLine),
                Positioned(
                  left: left,
                  top: 0,
                  bottom: 0,
                  width: barWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.transparent,
                          BlueprintColors.accentOrange.withAlpha(200),
                          BlueprintColors.accentOrange,
                          BlueprintColors.accentOrange.withAlpha(200),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}
