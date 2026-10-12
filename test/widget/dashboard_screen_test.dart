import 'package:auto_log_mi_nave_ota_labs/core/data/repositories/repositories.dart';
import 'package:auto_log_mi_nave_ota_labs/core/enums/enums.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/providers/providers.dart';
import 'package:auto_log_mi_nave_ota_labs/ui/views/views.dart';
import 'package:auto_log_mi_nave_ota_labs/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

final DateTime _today = DateTime(2026, 10, 11);

final Vehicle _vehicle = Vehicle(
  id: 'v1',
  userId: 'user-1',
  licensePlate: 'ABC123',
  brand: 'Mazda',
  model: 'CX-5',
  year: 2021,
  fuelType: FuelType.gasolinaCorriente,
  currentOdometer: 1000,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
  color: 'Rojo',
);

LegalDocument _doc(String id, DocumentType type, DateTime expiration) =>
    LegalDocument(
      id: id,
      vehicleId: _vehicle.id,
      documentType: type,
      expirationDate: expiration,
    );

/// Falla en la primera carga y responde bien en las siguientes.
class _FlakyVehiclesNotifier extends VehiclesNotifier {
  _FlakyVehiclesNotifier(this.calls);
  final List<int> calls;

  @override
  Future<List<Vehicle>> build() async {
    calls.add(calls.length);
    if (calls.length == 1) throw Exception('SocketException: sin red');
    return <Vehicle>[_vehicle];
  }
}

class _FakeVehiclesNotifier extends VehiclesNotifier {
  @override
  Future<List<Vehicle>> build() async => <Vehicle>[_vehicle];
}

class _FlakyLegalDocumentRepository extends FakeLegalDocumentRepository {
  _FlakyLegalDocumentRepository({super.seed});
  int getByVehicleCalls = 0;

  @override
  Future<List<LegalDocument>> getByVehicle(String vehicleId) {
    getByVehicleCalls++;
    if (getByVehicleCalls == 1) throw Exception('SocketException: sin red');
    return super.getByVehicle(vehicleId);
  }
}

class _FuelLogRepository implements FuelLogRepository {
  _FuelLogRepository([this._logs = const <FuelLog>[]]);
  final List<FuelLog> _logs;

  @override
  Future<List<FuelLog>> getByVehicle(String vehicleId) async => _logs;

  @override
  Future<FuelLog> create(FuelLog log) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

/// Como hoy en producción: la tabla `maintenances` aún no existe.
class _UnavailableMaintenanceRepository implements MaintenanceRepository {
  @override
  Future<List<MaintenanceRecord>> getByVehicle(String vehicleId) async =>
      throw Exception('relation "auto_log.maintenances" does not exist');

  @override
  Future<MaintenanceRecord> create(MaintenanceRecord record) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

class _AvailableMaintenanceRepository implements MaintenanceRepository {
  @override
  Future<List<MaintenanceRecord>> getByVehicle(String vehicleId) async =>
      const <MaintenanceRecord>[];

  @override
  Future<MaintenanceRecord> create(MaintenanceRecord record) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required LegalDocumentRepository documents,
  VehiclesNotifier Function()? vehicles,
  FuelLogRepository? fuelLogs,
  MaintenanceRepository? maintenance,
  // Por defecto móvil (WindowSize.compact) con alto de sobra para ver todo
  // sin scroll.
  Size size = const Size(390, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      // Sin los reintentos automáticos de Riverpod: el test los controla.
      retry: (int retryCount, Object error) => null,
      // ignore: always_specify_types
      overrides: [
        vehiclesProvider.overrideWith(vehicles ?? _FakeVehiclesNotifier.new),
        legalDocumentRepositoryProvider.overrideWithValue(documents),
        fuelLogRepositoryProvider.overrideWithValue(
          fuelLogs ?? _FuelLogRepository(),
        ),
        maintenanceRepositoryProvider.overrideWithValue(
          maintenance ?? _UnavailableMaintenanceRepository(),
        ),
        // Fijo (y sin el timer de medianoche) para que el semáforo no
        // dependa del reloj real.
        todayProvider.overrideWithValue(_today),
      ],
      child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('si fallan los vehículos muestra un mensaje amigable (sin la '
      'excepción) y "Reintentar" vuelve a consultar', (
    WidgetTester tester,
  ) async {
    List<int> calls = <int>[];
    await _pumpDashboard(
      tester,
      documents: FakeLegalDocumentRepository(),
      vehicles: () => _FlakyVehiclesNotifier(calls),
    );

    expect(find.text('No pudimos cargar tu vehículo.'), findsOneWidget);
    expect(find.textContaining('SocketException'), findsNothing);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(calls, hasLength(2));
    expect(find.text('No pudimos cargar tu vehículo.'), findsNothing);
    expect(find.text('Odómetro actual'), findsOneWidget);
  });

  testWidgets('si fallan los documentos no los muestra como "sin registro" '
      'y permite reintentar', (WidgetTester tester) async {
    _FlakyLegalDocumentRepository repository = _FlakyLegalDocumentRepository(
      seed: <LegalDocument>[
        _doc('soat', DocumentType.soat, DateTime(2027, 1, 1)),
      ],
    );
    await _pumpDashboard(tester, documents: repository);

    expect(find.text('No se pudieron cargar tus documentos.'), findsOneWidget);
    expect(find.text('SOAT: sin registro'), findsNothing);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repository.getByVehicleCalls, 2);
    expect(find.text('No se pudieron cargar tus documentos.'), findsNothing);
    expect(find.text('SOAT'), findsOneWidget);
    expect(find.text('RTM: sin registro'), findsOneWidget);
  });

  testWidgets('con un SOAT renovado usa el vigente; el aviso solo lista lo '
      'vencido o por vencer', (WidgetTester tester) async {
    await _pumpDashboard(
      tester,
      documents: FakeLegalDocumentRepository(
        seed: <LegalDocument>[
          // SOAT anterior (vencido) y el renovado.
          _doc('soat-old', DocumentType.soat, DateTime(2025, 10, 1)),
          _doc('soat-new', DocumentType.soat, DateTime(2027, 10, 1)),
          // RTM vencida hace 3 días.
          _doc('rtm', DocumentType.rtm, DateTime(2026, 10, 8)),
        ],
      ),
    );

    expect(find.text('REQUIERE ATENCIÓN'), findsOneWidget);
    expect(find.text('Revisión Técnico-Mecánica'), findsOneWidget);
    expect(find.text('Vencido hace 3d'), findsOneWidget);
    // Un solo "vencido": el SOAT viejo no aparece en el aviso.
    expect(find.textContaining('Vencido hace'), findsOneWidget);
  });

  testWidgets('sin documentos por vencer no se muestra el aviso', (
    WidgetTester tester,
  ) async {
    await _pumpDashboard(
      tester,
      documents: FakeLegalDocumentRepository(
        seed: <LegalDocument>[
          _doc('soat', DocumentType.soat, DateTime(2027, 1, 1)),
        ],
      ),
    );

    expect(find.text('REQUIERE ATENCIÓN'), findsNothing);
  });

  for (Size size in const <Size>[
    Size(390, 2400),
    Size(800, 2400),
    Size(1400, 2400),
  ]) {
    testWidgets('con todas las secciones se pinta sin overflow en '
        '${size.width.toInt()}px', (WidgetTester tester) async {
      await _pumpDashboard(
        tester,
        size: size,
        documents: FakeLegalDocumentRepository(
          seed: <LegalDocument>[
            _doc('rtm', DocumentType.rtm, DateTime(2026, 10, 8)),
            _doc('soat', DocumentType.soat, DateTime(2026, 10, 20)),
          ],
        ),
        fuelLogs: _FuelLogRepository(<FuelLog>[
          FuelLog(
            id: 'f1',
            vehicleId: _vehicle.id,
            date: DateTime(2026, 9, 1),
            odometer: 500,
            gallons: 10,
            totalCost: 160000,
          ),
          FuelLog(
            id: 'f2',
            vehicleId: _vehicle.id,
            date: DateTime(2026, 10, 1),
            odometer: 1000,
            gallons: 12,
            totalCost: 190000,
          ),
        ]),
        maintenance: _AvailableMaintenanceRepository(),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('REQUIERE ATENCIÓN'), findsOneWidget);
      expect(find.text('VIDA ÚTIL'), findsOneWidget);
      expect(find.text('GASOLINA'), findsOneWidget);
    });
  }

  testWidgets('"VER TALLER" cambia al tab de Taller', (
    WidgetTester tester,
  ) async {
    await _pumpDashboard(
      tester,
      documents: FakeLegalDocumentRepository(),
      maintenance: _AvailableMaintenanceRepository(),
    );
    ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(DashboardScreen)),
    );

    await tester.tap(find.text('VER TALLER'));
    await tester.pump();

    expect(container.read(selectedTabIndexProvider), AppShell.maintenanceIndex);
    // Sin tanqueos no se muestra el resumen de gasolina.
    expect(find.text('GASOLINA'), findsNothing);
  });

  group('OdometerUpdateDialog', () {
    Future<List<int?>> pumpDialog(WidgetTester tester) async {
      List<int?> results = <int?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () async => results.add(
                await showDialog<int>(
                  context: context,
                  builder: (_) =>
                      const OdometerUpdateDialog(currentOdometer: 12000),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('no deja guardar un valor menor al actual y lo explica', (
      WidgetTester tester,
    ) async {
      List<int?> results = await pumpDialog(tester);

      await tester.enterText(find.byType(TextFormField), '11000');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Debe ser mayor o igual a 12.000 km.'), findsOneWidget);
      expect(find.byType(OdometerUpdateDialog), findsOneWidget);
      expect(results, isEmpty);
    });

    testWidgets('solo acepta dígitos y devuelve el nuevo valor', (
      WidgetTester tester,
    ) async {
      List<int?> results = await pumpDialog(tester);

      // El formatter descarta todo lo que no sea dígito.
      await tester.enterText(find.byType(TextFormField), '12.5a00');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.byType(OdometerUpdateDialog), findsNothing);
      expect(results, <int?>[12500]);
      // Sin excepciones por usar el controlador ya liberado durante la
      // animación de salida.
      expect(tester.takeException(), isNull);
    });
  });
}
