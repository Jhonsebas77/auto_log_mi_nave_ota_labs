part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Curva de rendimiento Km/Gal (design_spec: Tanqueos y Consumo).
class PerformanceCurveChart extends StatefulWidget {
  const PerformanceCurveChart({required this.curve, super.key});

  final List<FuelMetricsPoint> curve;

  @override
  State<PerformanceCurveChart> createState() => _PerformanceCurveChartState();
}

/// Los `FlSpot`s y el `LineChartData` se arman solo cuando cambia la curva,
/// no en cada rebuild del padre (evita que fl_chart vuelva a interpolar
/// datos idénticos).
class _PerformanceCurveChartState extends State<PerformanceCurveChart> {
  late _CurveSummary _summary;
  late LineChartData _chartData;

  /// Índice del tanqueo tocado en la gráfica (null = ninguno → se muestra el
  /// último). Es un notifier y no `setState` para que tocar la gráfica solo
  /// reconstruya el encabezado, no el `LineChart`.
  final ValueNotifier<int?> _selected = ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void didUpdateWidget(covariant PerformanceCurveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.curve, widget.curve)) {
      _selected.value = null;
      _rebuild();
    }
  }

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (widget.curve.length < 2) return;
    _summary = _CurveSummary.from(widget.curve);
    _chartData = _buildChartData(widget.curve, _summary, _selected);
  }

  static const String _explanation =
      'Cada punto es el rendimiento (Km/Gal) logrado entre dos tanqueos '
      'llenos consecutivos. Si la curva sube, tu carro está rindiendo más '
      'por galón; si baja, el consumo empeoró. La línea punteada es tu '
      'promedio. Toca la gráfica para ver el valor de cada tanqueo.';

  /// Arriba de este número de puntos los marcadores se vuelven ruido: solo
  /// se dibuja el del último tanqueo (el tooltip sigue mostrando todos).
  static const int _maxPointsWithMarkers = 20;

  static const double _xPadding = 0.25;

  static String _shortDate(DateTime date) =>
      '${date.day} ${monthsInSpanishShort[date.month - 1]}';

  static String _longDate(DateTime date) =>
      '${date.day} ${monthsInSpanishShort[date.month - 1]} ${date.year}';

  static String _formatValue(double v) => v.toStringAsFixed(1);

  static LineChartData _buildChartData(
    List<FuelMetricsPoint> curve,
    _CurveSummary summary,
    ValueNotifier<int?> selected,
  ) {
    int lastIndex = curve.length - 1;
    bool showAllMarkers = curve.length <= _maxPointsWithMarkers;
    // Etiquetas del eje X: máximo ~4 fechas para que no se pisen en móvil;
    // el último tanqueo siempre se etiqueta.
    int labelStep = math.max(1, (lastIndex / 3).ceil());

    return LineChartData(
      // Un poco de aire a los lados para que el primer y último punto no
      // queden montados sobre los ejes.
      minX: -_xPadding,
      maxX: lastIndex + _xPadding,
      minY: summary.axisMin,
      maxY: summary.axisMax,
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: summary.axisStep,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: BlueprintColors.gridLine, strokeWidth: 1),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: BlueprintColors.outlineVariant),
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: summary.axisStep,
            getTitlesWidget: (double value, TitleMeta meta) => SideTitleWidget(
              meta: meta,
              child: Text(
                value.toStringAsFixed(summary.axisStep < 1 ? 1 : 0),
                style: AppTextStyles.labelSmall,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              int i = value.round();
              bool isLabeled =
                  value == i &&
                  i >= 0 &&
                  i <= lastIndex &&
                  (i == lastIndex ||
                      // Se salta la marca regular si queda pegada a la
                      // última fecha, para que no colisionen.
                      (i % labelStep == 0 && lastIndex - i >= labelStep / 2));
              if (!isLabeled) return const SizedBox.shrink();
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  _shortDate(curve[i].date),
                  style: AppTextStyles.labelSmall,
                ),
              );
            },
          ),
        ),
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: <HorizontalLine>[
          HorizontalLine(
            y: summary.average,
            color: BlueprintColors.textMuted,
            strokeWidth: 1,
            dashArray: <int>[4, 4],
          ),
        ],
      ),
      lineTouchData: LineTouchData(
        // Umbral amplio + distancia solo en X (default de fl_chart): el
        // tooltip se engancha al tanqueo más cercano a lo largo del eje,
        // sin tener que atinarle al punto.
        touchSpotThreshold: 48,
        getTouchedSpotIndicator: (LineChartBarData bar, List<int> indexes) =>
            indexes
                .map(
                  (_) => TouchedSpotIndicatorData(
                    const FlLine(
                      color: BlueprintColors.outline,
                      strokeWidth: 1,
                    ),
                    FlDotData(
                      getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                        radius: 6,
                        color: BlueprintColors.accentOrange,
                        strokeWidth: 2,
                        strokeColor: BlueprintColors.background,
                      ),
                    ),
                  ),
                )
                .toList(),
        // Sin globo flotante: tapaba los puntos altos. El valor tocado se
        // muestra en la cifra del encabezado (ver _Readout).
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> spots) =>
              List<LineTooltipItem?>.filled(spots.length, null),
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
          List<TouchLineBarSpot>? spots = response?.lineBarSpots;
          selected.value =
              event.isInterestedForInteractions &&
                  spots != null &&
                  spots.isNotEmpty
              ? spots.first.spotIndex
              : null;
        },
      ),
      lineBarsData: <LineChartBarData>[
        LineChartBarData(
          spots: <FlSpot>[
            for (int i = 0; i < curve.length; i++)
              FlSpot(i.toDouble(), curve[i].kmPerGallon),
          ],
          // Recta entre tanqueos: una curva suavizada inventa valores
          // intermedios (y puede pasarse de los extremos reales).
          color: BlueprintColors.accentOrange,
          barWidth: 2,
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
          // Sin área rellena: el eje Y no arranca en 0, así que un relleno
          // exageraría visualmente las diferencias entre tanqueos.
          dotData: FlDotData(
            checkToShowDot: (FlSpot spot, _) =>
                showAllMarkers || spot.x == lastIndex,
            getDotPainter: (FlSpot spot, _, _, _) => FlDotCirclePainter(
              radius: spot.x == lastIndex ? 5 : 4,
              color: BlueprintColors.accentOrange,
              strokeWidth: 2,
              strokeColor: BlueprintColors.background,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.curve.length < 2) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: BlueprintColors.outlineVariant),
        ),
        child: const Text(
          'Registra al menos 3 tanqueos llenos para ver la curva.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      );
    }

    _CurveSummary s = _summary;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        border: Border.all(color: BlueprintColors.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Text('Rendimiento', style: AppTextStyles.titleMedium),
              SizedBox(width: 4),
              Tooltip(
                message: _explanation,
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: BlueprintColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ValueListenableBuilder<int?>(
            valueListenable: _selected,
            builder: (BuildContext context, int? index, _) => _Readout(
              summary: s,
              value: index == null ? s.latest : widget.curve[index].kmPerGallon,
              caption: index == null
                  ? 'último'
                  : _longDate(widget.curve[index].date),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label:
                'Gráfica de rendimiento: ${s.count} mediciones. '
                'Último ${_formatValue(s.latest)} km por galón, '
                'promedio ${_formatValue(s.average)}, '
                'mínimo ${_formatValue(s.min)}, '
                'máximo ${_formatValue(s.max)}.',
            child: ExcludeSemantics(
              child: SizedBox(
                height: 200,
                // Margen derecho para que la última fecha y el tooltip no
                // se corten contra el borde.
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: LineChart(_chartData),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // La etiqueta del promedio va acá y no sobre la línea punteada:
          // dentro del área de la gráfica termina chocando con la curva.
          Row(
            children: <Widget>[
              for (int i = 0; i < 3; i++)
                Container(
                  width: 4,
                  height: 1,
                  margin: const EdgeInsets.only(right: 3),
                  color: BlueprintColors.textMuted,
                ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  'Prom. ${_formatValue(s.average)} · '
                  'Mín. ${_formatValue(s.min)} · '
                  'Máx. ${_formatValue(s.max)} km/gal',
                  style: AppTextStyles.labelSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rendimiento del tanqueo tocado (o el último) como cifra principal, con su
/// variación frente al promedio (subir es bueno: más km por galón).
class _Readout extends StatelessWidget {
  const _Readout({
    required this.summary,
    required this.value,
    required this.caption,
  });

  final _CurveSummary summary;
  final double value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    double delta = summary.average == 0
        ? 0
        : (value - summary.average) / summary.average * 100;
    // Variaciones menores a 1% se consideran "en tu promedio" para no
    // pintar de rojo/verde ruido de medición.
    bool flat = delta.abs() < 1;
    bool up = delta > 0;
    Color color = flat
        ? BlueprintColors.textMuted
        : up
        ? BlueprintColors.successGreen
        : BlueprintColors.danger;
    IconData icon = flat
        ? Icons.trending_flat_rounded
        : up
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    String deltaText = flat
        ? 'En tu promedio'
        : '${up ? '+' : '−'}${delta.abs().toStringAsFixed(0)}% vs. promedio';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(value.toStringAsFixed(1), style: AppTextStyles.titleLarge),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'km/gal · $caption',
                style: AppTextStyles.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: <Widget>[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              deltaText,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }
}

/// Estadísticas de la curva + escala "redonda" del eje Y (marcas cada 1, 2,
/// 2.5 o 5 × 10^n) para que las etiquetas sean números limpios.
class _CurveSummary {
  const _CurveSummary({
    required this.count,
    required this.latest,
    required this.average,
    required this.min,
    required this.max,
    required this.axisMin,
    required this.axisMax,
    required this.axisStep,
  });

  factory _CurveSummary.from(List<FuelMetricsPoint> curve) {
    List<double> values = curve
        .map((FuelMetricsPoint p) => p.kmPerGallon)
        .toList(growable: false);
    double minV = values.reduce(math.min);
    double maxV = values.reduce(math.max);
    double average =
        values.reduce((double a, double b) => a + b) / values.length;

    // Con todos los valores iguales (o casi) se abre un rango mínimo para
    // que la línea no quede pegada a un borde.
    double range = math.max(maxV - minV, math.max(1, maxV * 0.1));
    double step = _niceStep(range / 4);
    double axisMin = math.max(0, ((minV - step * 0.5) / step).floor() * step);
    double axisMax = ((maxV + step * 0.5) / step).ceil() * step;

    return _CurveSummary(
      count: values.length,
      latest: values.last,
      average: average,
      min: minV,
      max: maxV,
      axisMin: axisMin,
      axisMax: axisMax,
      axisStep: step,
    );
  }

  final int count;
  final double latest;
  final double average;
  final double min;
  final double max;
  final double axisMin;
  final double axisMax;
  final double axisStep;

  static double _niceStep(double rough) {
    double magnitude = math
        .pow(10, (math.log(rough) / math.ln10).floor())
        .toDouble();
    double normalized = rough / magnitude;
    double nice = normalized <= 1
        ? 1
        : normalized <= 2
        ? 2
        : normalized <= 2.5
        ? 2.5
        : normalized <= 5
        ? 5
        : 10;
    return nice * magnitude;
  }
}
