import 'package:auto_log_mi_nave_ota_labs/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  const Map<String, Widget> skeletons = <String, Widget>{
    'DashboardSkeleton': DashboardSkeleton(),
    'FuelMetricsSkeleton': FuelMetricsSkeleton(),
    'LegalDocumentsSkeleton': LegalDocumentsSkeleton(),
    'MaintenanceSkeleton': MaintenanceSkeleton(),
  };
  // Móvil, tablet y escritorio (ver Breakpoints).
  const List<Size> sizes = <Size>[
    Size(390, 700),
    Size(800, 900),
    Size(1400, 900),
  ];

  for (MapEntry<String, Widget> entry in skeletons.entries) {
    for (Size size in sizes) {
      testWidgets(
        '${entry.key} se pinta sin overflow en ${size.width.toInt()}px',
        (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            MaterialApp(home: Scaffold(body: entry.value)),
          );
          // Unos frames de la animación del shimmer.
          await tester.pump(const Duration(milliseconds: 500));

          expect(tester.takeException(), isNull);
          expect(find.byType(Shimmer), findsOneWidget);
          expect(find.bySemanticsLabel('Cargando…'), findsOneWidget);
        },
      );
    }
  }
}
