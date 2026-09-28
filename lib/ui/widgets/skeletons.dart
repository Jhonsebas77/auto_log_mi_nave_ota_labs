part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Skeletons de carga inicial (paquete `shimmer`) para los tabs del
/// `AppShell`. Reemplazan al `CircularProgressIndicator` mientras llega la
/// primera respuesta de Supabase, imitando la forma de cada pantalla para
/// que el contenido no "salte" al aparecer.
///
/// Cada skeleton usa un único [Shimmer] para toda la pantalla (una sola
/// animación, no una por bloque) y queda pausado fuera de pantalla gracias
/// al `TickerMode` de `AppShell`. Esquinas rectas, como el resto del tema
/// Blueprint.
class BlueprintShimmer extends StatelessWidget {
  const BlueprintShimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cargando…',
    liveRegion: true,
    child: ExcludeSemantics(
      child: Shimmer.fromColors(
        baseColor: BlueprintColors.surfaceContainerLow,
        highlightColor: BlueprintColors.outlineVariant,
        child: child,
      ),
    ),
  );
}

/// Bloque rectangular de skeleton. El color real lo pinta el [Shimmer] que
/// lo envuelve; aquí solo tiene que ser opaco.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 16});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: const ColoredBox(color: BlueprintColors.surfaceContainerLow),
  );
}

/// Fila de lista genérica: título + subtítulo a la izquierda y un valor a la
/// derecha (tanqueos, servicios y documentos comparten esta forma).
class _SkeletonListItem extends StatelessWidget {
  const _SkeletonListItem({this.height = 64});

  final double height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: BlueprintColors.surfaceContainerLow),
    ),
    child: const Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 0.6,
                child: SkeletonBox(height: 14),
              ),
              SizedBox(height: 8),
              FractionallySizedBox(
                widthFactor: 0.4,
                child: SkeletonBox(height: 10),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        SkeletonBox(width: 72, height: 14),
      ],
    ),
  );
}

/// Contenedor común: sin scroll propio (es un placeholder) pero sin
/// desbordar en pantallas bajas.
class _SkeletonScroll extends StatelessWidget {
  const _SkeletonScroll({required this.padding, required this.children});

  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => BlueprintShimmer(
    child: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );
}

/// Dashboard: tarjeta del vehículo, Odómetro, pico y placa y semáforo de
/// documentos, con el mismo layout adaptativo que `DashboardScreen`.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    WindowSize windowSize = Breakpoints.windowSizeOf(context);
    bool wide = windowSize != WindowSize.compact;
    const Widget odometerCard = SkeletonBox(height: 88);
    const Widget picoYPlacaCard = SkeletonBox(height: 120);

    return _SkeletonScroll(
      padding: wide
          ? const EdgeInsets.all(32)
          : const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: <Widget>[
        if (windowSize == WindowSize.expanded)
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 3, child: SkeletonBox(height: 280)),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    odometerCard,
                    SizedBox(height: 16),
                    picoYPlacaCard,
                  ],
                ),
              ),
            ],
          )
        else ...<Widget>[
          SkeletonBox(height: windowSize == WindowSize.compact ? 220 : 320),
          const SizedBox(height: 16),
          odometerCard,
          const SizedBox(height: 16),
          picoYPlacaCard,
        ],
        const SizedBox(height: 16),
        const Row(
          children: <Widget>[
            Expanded(child: SkeletonBox(height: 72)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 72)),
          ],
        ),
      ],
    );
  }
}

/// Gasolina: gráfica de rendimiento, KPIs 2x2 e historial.
class FuelMetricsSkeleton extends StatelessWidget {
  const FuelMetricsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const _SkeletonScroll(
    padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
    children: <Widget>[
      SkeletonBox(width: 180, height: 18),
      SizedBox(height: 8),
      SkeletonBox(height: 180),
      SizedBox(height: 16),
      _SkeletonKpiRow(),
      SizedBox(height: 12),
      _SkeletonKpiRow(),
      SizedBox(height: 24),
      SkeletonBox(width: 96, height: 18),
      SizedBox(height: 16),
      _SkeletonListItem(),
      _SkeletonListItem(),
      _SkeletonListItem(),
      _SkeletonListItem(),
    ],
  );
}

class _SkeletonKpiRow extends StatelessWidget {
  const _SkeletonKpiRow();

  @override
  Widget build(BuildContext context) => const Row(
    children: <Widget>[
      Expanded(child: SkeletonBox(height: 64)),
      SizedBox(width: 12),
      Expanded(child: SkeletonBox(height: 64)),
    ],
  );
}

/// Legal: lista de documentos del tab activo (el `TabBar` de arriba sigue
/// siendo el real).
class LegalDocumentsSkeleton extends StatelessWidget {
  const LegalDocumentsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const _SkeletonScroll(
    padding: EdgeInsets.all(16),
    children: <Widget>[
      _SkeletonListItem(height: 84),
      _SkeletonListItem(height: 84),
      _SkeletonListItem(height: 84),
    ],
  );
}

/// Taller: barras de vida útil, filtro segmentado e historial de servicios.
class MaintenanceSkeleton extends StatelessWidget {
  const MaintenanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const _SkeletonScroll(
    padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
    children: <Widget>[
      _SkeletonLifespanBar(),
      _SkeletonLifespanBar(),
      _SkeletonLifespanBar(),
      SkeletonBox(width: 200, height: 18),
      SizedBox(height: 16),
      SkeletonBox(height: 40),
      SizedBox(height: 12),
      _SkeletonListItem(),
      _SkeletonListItem(),
      _SkeletonListItem(),
    ],
  );
}

class _SkeletonLifespanBar extends StatelessWidget {
  const _SkeletonLifespanBar();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            SkeletonBox(width: 88, height: 12),
            Spacer(),
            SkeletonBox(width: 40, height: 12),
          ],
        ),
        SizedBox(height: 8),
        SkeletonBox(height: 10),
      ],
    ),
  );
}
