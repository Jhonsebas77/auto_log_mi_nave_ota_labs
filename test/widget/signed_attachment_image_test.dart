import 'package:auto_log_mi_nave_ota_labs/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SignedAttachmentImage sin tamaño explícito funciona dentro de '
      'IntrinsicHeight (dashboard en escritorio)', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 280),
                      // URL pública vieja: no pasa por Supabase.
                      child: const SignedAttachmentImage(
                        path: 'https://example.com/photo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsOneWidget);
  });
}
