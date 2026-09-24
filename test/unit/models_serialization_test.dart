import 'package:auto_log_mi_nave_ota_labs/core/enums/enums.dart';
import 'package:auto_log_mi_nave_ota_labs/core/models/models.dart';
import 'package:auto_log_mi_nave_ota_labs/core/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void expectVehicleEquals(Vehicle a, Vehicle b) {
  expect(b.id, a.id);
  expect(b.userId, a.userId);
  expect(b.licensePlate, a.licensePlate);
  expect(b.brand, a.brand);
  expect(b.model, a.model);
  expect(b.year, a.year);
  expect(b.fuelType, a.fuelType);
  expect(b.currentOdometer, a.currentOdometer);
  expect(b.createdAt, a.createdAt);
  expect(b.updatedAt, a.updatedAt);
  expect(b.color, a.color);
  expect(b.photoUrl, a.photoUrl);
  expect(b.nickname, a.nickname);
  expect(b.tankCapacityGallons, a.tankCapacityGallons);
}

void expectFuelLogEquals(FuelLog a, FuelLog b) {
  expect(b.id, a.id);
  expect(b.vehicleId, a.vehicleId);
  expect(b.date, a.date);
  expect(b.odometer, a.odometer);
  expect(b.gallons, a.gallons);
  expect(b.pricePerGallon, a.pricePerGallon);
  expect(b.totalCost, a.totalCost);
  expect(b.isFullTank, a.isFullTank);
  expect(b.isExtraFuel, a.isExtraFuel);
  expect(b.stationName, a.stationName);
}

void expectLegalDocumentEquals(LegalDocument a, LegalDocument b) {
  expect(b.id, a.id);
  expect(b.vehicleId, a.vehicleId);
  expect(b.documentType, a.documentType);
  expect(b.issueDate, a.issueDate);
  expect(b.expirationDate, a.expirationDate);
  expect(b.cost, a.cost);
  expect(b.entityName, a.entityName);
  expect(b.documentUrl, a.documentUrl);
  expect(b.notes, a.notes);
  expect(b.documentNumber, a.documentNumber);
}

void expectMaintenanceRecordEquals(MaintenanceRecord a, MaintenanceRecord b) {
  expect(b.id, a.id);
  expect(b.vehicleId, a.vehicleId);
  expect(b.serviceType, a.serviceType);
  expect(b.category, a.category);
  expect(b.date, a.date);
  expect(b.odometer, a.odometer);
  expect(b.totalCost, a.totalCost);
  expect(b.workshopName, a.workshopName);
  expect(b.invoiceUrl, a.invoiceUrl);
  expect(b.notes, a.notes);
}

void main() {
  group('Vehicle', () {
    Vehicle full = Vehicle(
      id: 'veh-1',
      userId: 'user-1',
      licensePlate: 'ABC123',
      brand: 'Mazda',
      model: 'CX-5',
      year: 2021,
      fuelType: FuelType.gasolinaExtra,
      currentOdometer: 45230,
      createdAt: DateTime.utc(2024, 1, 10, 8, 30),
      updatedAt: DateTime.utc(2024, 6, 2, 9, 15),
      color: '#FF0000',
      photoUrl: 'https://example.com/photo.jpg',
      nickname: 'La Nave',
      tankCapacityGallons: 14.5,
    );

    Vehicle minimal = Vehicle(
      id: 'veh-2',
      userId: 'user-2',
      licensePlate: 'XYZ987',
      brand: 'Renault',
      model: 'Logan',
      year: 2018,
      fuelType: FuelType.diesel,
      currentOdometer: 0,
      createdAt: DateTime.utc(2020, 1, 1),
      updatedAt: DateTime.utc(2020, 1, 1),
      color: '#000000',
    );

    test('round-trip con todos los campos poblados', () {
      Vehicle result = Vehicle.fromJson(full.toJson());
      expectVehicleEquals(full, result);
    });

    test('round-trip con opcionales en null', () {
      Vehicle result = Vehicle.fromJson(minimal.toJson());
      expectVehicleEquals(minimal, result);
      expect(result.photoUrl, isNull);
      expect(result.nickname, isNull);
      expect(result.tankCapacityGallons, isNull);
    });

    test('toJson usa exactamente las columnas de 0001_vehicles.sql', () {
      Set<String> expectedColumns = <String>{
        'id',
        'user_id',
        'license_plate',
        'brand',
        'model',
        'year',
        'fuel_type',
        'current_odometer',
        'color',
        'photo_url',
        'nickname',
        'tank_capacity_gallons',
        'created_at',
        'updated_at',
      };
      expect(full.toJson().keys.toSet(), expectedColumns);
    });

    test('copyWith() sin argumentos no cambia nada', () {
      Vehicle result = full.copyWith();
      expectVehicleEquals(full, result);
    });

    test('copyWith con null explícito vacía nickname, photoUrl y '
        'tankCapacityGallons (ValueWrapper)', () {
      Vehicle result = full.copyWith(
        nickname: const ValueWrapper<String>(null),
        photoUrl: const ValueWrapper<String>(null),
        tankCapacityGallons: const ValueWrapper<double>(null),
      );
      expect(result.nickname, isNull);
      expect(result.photoUrl, isNull);
      expect(result.tankCapacityGallons, isNull);
      // El resto de los campos no se toca.
      expect(result.id, full.id);
      expect(result.color, full.color);
    });
  });

  group('FuelLog', () {
    FuelLog full = FuelLog(
      id: 'log-1',
      vehicleId: 'veh-1',
      date: DateTime.utc(2024, 3, 5, 12, 0),
      odometer: 45230,
      gallons: 8.451,
      totalCost: 125000,
      pricePerGallon: 14790.5,
      isFullTank: false,
      isExtraFuel: true,
      stationName: 'Terpel Poblado',
    );

    FuelLog minimal = FuelLog(
      id: 'log-2',
      vehicleId: 'veh-2',
      date: DateTime.utc(2024, 3, 6),
      odometer: 100,
      gallons: 5,
      totalCost: 70000,
    );

    test('round-trip con todos los campos poblados', () {
      FuelLog result = FuelLog.fromJson(full.toJson());
      expectFuelLogEquals(full, result);
    });

    test('round-trip con opcionales en null (y defaults)', () {
      FuelLog result = FuelLog.fromJson(minimal.toJson());
      expectFuelLogEquals(minimal, result);
      expect(result.pricePerGallon, isNull);
      expect(result.stationName, isNull);
      // Defaults del constructor: isFullTank true, isExtraFuel false.
      expect(result.isFullTank, isTrue);
      expect(result.isExtraFuel, isFalse);
    });

    test('toJson usa exactamente las columnas de 0003_fuel_logs.sql + '
        '0005_fuel_logs_extra_fuel.sql', () {
      Set<String> expectedColumns = <String>{
        'id',
        'vehicle_id',
        'date',
        'odometer',
        'gallons',
        'price_per_gallon',
        'total_cost',
        'is_full_tank',
        'station_name',
        'is_extra_fuel',
      };
      expect(full.toJson().keys.toSet(), expectedColumns);
    });
  });

  group('LegalDocument', () {
    LegalDocument full = LegalDocument(
      id: 'doc-1',
      vehicleId: 'veh-1',
      documentType: DocumentType.soat,
      expirationDate: DateTime.utc(2026, 5, 20),
      issueDate: DateTime.utc(2025, 5, 20),
      cost: 450000,
      entityName: 'Seguros Bolívar',
      documentUrl: 'user-1/legal/abc.pdf',
      notes: 'Renovar con anticipación',
      documentNumber: 'SOAT-123456',
    );

    LegalDocument minimal = LegalDocument(
      id: 'doc-2',
      vehicleId: 'veh-2',
      documentType: DocumentType.rtm,
      expirationDate: DateTime.utc(2026, 8, 1),
    );

    test('round-trip con todos los campos poblados', () {
      LegalDocument result = LegalDocument.fromJson(full.toJson());
      expectLegalDocumentEquals(full, result);
    });

    test('round-trip con opcionales en null', () {
      LegalDocument result = LegalDocument.fromJson(minimal.toJson());
      expectLegalDocumentEquals(minimal, result);
      expect(result.issueDate, isNull);
      expect(result.cost, isNull);
      expect(result.entityName, isNull);
      expect(result.documentUrl, isNull);
      expect(result.notes, isNull);
      expect(result.documentNumber, isNull);
    });

    test('toJson usa exactamente las columnas de 0004_legal_documents.sql', () {
      Set<String> expectedColumns = <String>{
        'id',
        'vehicle_id',
        'document_type',
        'issue_date',
        'expiration_date',
        'cost',
        'entity_name',
        'document_url',
        'document_number',
        'notes',
      };
      expect(full.toJson().keys.toSet(), expectedColumns);
    });

    test('copyWith() sin argumentos no cambia nada', () {
      LegalDocument result = full.copyWith();
      expectLegalDocumentEquals(full, result);
    });

    test('copyWith con null explícito vacía cost, entityName, notes y '
        'documentNumber (ValueWrapper)', () {
      LegalDocument result = full.copyWith(
        cost: const ValueWrapper<double>(null),
        entityName: const ValueWrapper<String>(null),
        notes: const ValueWrapper<String>(null),
        documentNumber: const ValueWrapper<String>(null),
      );
      expect(result.cost, isNull);
      expect(result.entityName, isNull);
      expect(result.notes, isNull);
      expect(result.documentNumber, isNull);
      // El resto de los campos no se toca.
      expect(result.id, full.id);
      expect(result.issueDate, full.issueDate);
      expect(result.documentUrl, full.documentUrl);
      expect(result.expirationDate, full.expirationDate);
    });

    test('copyWith con issueDate y documentUrl en null también los vacía', () {
      LegalDocument result = full.copyWith(
        issueDate: const ValueWrapper<DateTime>(null),
        documentUrl: const ValueWrapper<String>(null),
      );
      expect(result.issueDate, isNull);
      expect(result.documentUrl, isNull);
    });
  });

  group('MaintenanceRecord', () {
    MaintenanceRecord full = MaintenanceRecord(
      id: 'maint-1',
      vehicleId: 'veh-1',
      serviceType: MaintenanceServiceType.correctivo,
      category: 'Cambio de pastillas de freno',
      date: DateTime.utc(2024, 4, 15),
      odometer: 45230,
      totalCost: 260000,
      workshopName: 'Taller Ruedas Libres',
      invoiceUrl: 'user-1/maintenance/abc.pdf',
      notes: 'Se cambiaron pastillas delanteras y traseras.',
    );

    MaintenanceRecord minimal = MaintenanceRecord(
      id: 'maint-2',
      vehicleId: 'veh-2',
      serviceType: MaintenanceServiceType.preventivo,
      category: 'Cambio de aceite',
      date: DateTime.utc(2024, 5, 1),
      odometer: 100,
      totalCost: 90000,
    );

    test('round-trip con todos los campos poblados', () {
      MaintenanceRecord result = MaintenanceRecord.fromJson(full.toJson());
      expectMaintenanceRecordEquals(full, result);
    });

    test('round-trip con opcionales en null', () {
      MaintenanceRecord result = MaintenanceRecord.fromJson(minimal.toJson());
      expectMaintenanceRecordEquals(minimal, result);
      expect(result.workshopName, isNull);
      expect(result.invoiceUrl, isNull);
      expect(result.notes, isNull);
    });

    test('toJson usa exactamente las columnas de 0008_maintenances.sql', () {
      Set<String> expectedColumns = <String>{
        'id',
        'vehicle_id',
        'service_type',
        'category',
        'date',
        'odometer',
        'total_cost',
        'workshop_name',
        'invoice_url',
        'notes',
      };
      expect(full.toJson().keys.toSet(), expectedColumns);
    });
  });
}
