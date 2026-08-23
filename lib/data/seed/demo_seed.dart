import '../../core/enums/enums.dart';
import '../../core/models/models.dart';

/// Conjunto de datos demo para que la app sea usable inmediatamente tras
/// `flutter run`, sin configuración manual. Todas las fechas se calculan
/// relativas a `now` (ver [buildSeedData]) para que la demo siempre luzca
/// vigente.
class SeedData {
  const SeedData({
    required this.user,
    required this.vehicle,
    required this.fuelLogs,
    required this.legalDocuments,
    required this.maintenanceRecords,
  });

  final AppUser user;
  final Vehicle vehicle;
  final List<FuelLog> fuelLogs;
  final List<LegalDocument> legalDocuments;

  final List<MaintenanceRecord> maintenanceRecords;
}

const String seedUserId = 'seed-user-demo';
const String seedVehicleId = 'seed-vehicle-1';

SeedData buildSeedData(DateTime now) {
  AppUser user = AppUser(
    id: seedUserId,
    email: 'demo@minave.co',
    fullName: 'Conductor Demo',
    cityCode: 'MED',
    createdAt: now.subtract(const Duration(days: 400)),
  );

  // Placa terminada en 3: restringida los miércoles (dígitos 3 y 7) —
  // asegura que la demo muestre "restringido hoy" al menos un día de la
  // semana.
  Vehicle vehicle = Vehicle(
    id: seedVehicleId,
    userId: seedUserId,
    licensePlate: 'FZP453',
    brand: 'Mazda',
    model: 'CX-5',
    year: 2021,
    fuelType: FuelType.gasolinaCorriente,
    currentOdometer: 42180,
    createdAt: now.subtract(const Duration(days: 400)),
    color: 'Rojo',
  );

  List<FuelLog> fuelLogs = <FuelLog>[
    FuelLog(
      id: 'seed-fuel-1',
      vehicleId: seedVehicleId,
      date: now.subtract(const Duration(days: 55)),
      odometer: 40200,
      gallons: 9.2,
      pricePerGallon: 10500,
      totalCost: 96600,
      isFullTank: true,
      stationName: 'Terpel Poblado',
    ),
    FuelLog(
      id: 'seed-fuel-2',
      vehicleId: seedVehicleId,
      date: now.subtract(const Duration(days: 41)),
      odometer: 40950,
      gallons: 8.7,
      pricePerGallon: 10600,
      totalCost: 92220,
      isFullTank: true,
      stationName: 'Biomax Envigado',
    ),
    FuelLog(
      id: 'seed-fuel-3',
      vehicleId: seedVehicleId,
      date: now.subtract(const Duration(days: 30)),
      odometer: 41300,
      gallons: 5.4,
      pricePerGallon: 10600,
      totalCost: 57240,
      isFullTank: false,
      stationName: 'Terpel Poblado',
    ),
    FuelLog(
      id: 'seed-fuel-4',
      vehicleId: seedVehicleId,
      date: now.subtract(const Duration(days: 20)),
      odometer: 41600,
      gallons: 9,
      pricePerGallon: 10700,
      totalCost: 96300,
      isFullTank: true,
      stationName: 'Zeuss Sabaneta',
    ),
    FuelLog(
      id: 'seed-fuel-5',
      vehicleId: seedVehicleId,
      date: now.subtract(const Duration(days: 8)),
      odometer: 41980,
      gallons: 8.9,
      pricePerGallon: 10800,
      totalCost: 96120,
      isFullTank: true,
      stationName: 'Terpel Poblado',
    ),
    FuelLog(
      id: 'seed-fuel-6',
      vehicleId: seedVehicleId,
      date: now.subtract(const Duration(days: 1)),
      odometer: 42180,
      gallons: 4.1,
      pricePerGallon: 10800,
      totalCost: 44280,
      isFullTank: false,
      stationName: 'Biomax Envigado',
    ),
  ];

  List<LegalDocument> legalDocuments = <LegalDocument>[
    LegalDocument(
      id: 'seed-doc-soat',
      vehicleId: seedVehicleId,
      documentType: DocumentType.soat,
      issueDate: now.subtract(const Duration(days: 320)),
      expirationDate: now.add(const Duration(days: 45)),
      cost: 650000,
      entityName: 'Seguros Mundial',
    ),
    LegalDocument(
      id: 'seed-doc-rtm',
      vehicleId: seedVehicleId,
      documentType: DocumentType.rtm,
      issueDate: now.subtract(const Duration(days: 353)),
      expirationDate: now.add(const Duration(days: 12)),
      cost: 180000,
      entityName: 'CDA Sabaneta',
    ),
    LegalDocument(
      id: 'seed-doc-impuesto',
      vehicleId: seedVehicleId,
      documentType: DocumentType.impuestoVehicular,
      issueDate: now.subtract(const Duration(days: 362)),
      expirationDate: now.add(const Duration(days: 3)),
      cost: 420000,
      entityName: 'Gobernación de Antioquia',
    ),
    LegalDocument(
      id: 'seed-doc-poliza',
      vehicleId: seedVehicleId,
      documentType: DocumentType.polizaTodoRiesgo,
      issueDate: now.subtract(const Duration(days: 165)),
      expirationDate: now.add(const Duration(days: 200)),
      cost: 1200000,
      entityName: 'Sura',
    ),
    LegalDocument(
      id: 'seed-doc-licencia',
      vehicleId: seedVehicleId,
      documentType: DocumentType.licenciaConduccion,
      issueDate: now.subtract(const Duration(days: 700)),
      expirationDate: now.add(const Duration(days: 400)),
      entityName: 'RUNT',
    ),
    LegalDocument(
      id: 'seed-doc-extintor',
      vehicleId: seedVehicleId,
      documentType: DocumentType.extintor,
      issueDate: now.subtract(const Duration(days: 370)),
      expirationDate: now.subtract(const Duration(days: 5)),
      cost: 45000,
      entityName: 'Ferretería El Tornillo',
    ),
  ];

  List<MaintenanceRecord> maintenanceRecords = <MaintenanceRecord>[
    MaintenanceRecord(
      id: 'seed-maint-oil',
      vehicleId: seedVehicleId,
      serviceType: MaintenanceServiceType.preventivo,
      category: 'Cambio de aceite',
      date: now.subtract(const Duration(days: 60)),
      odometer: 38000,
      totalCost: 210000,
      workshopName: 'Taller Ruedas Libres',
    ),
    MaintenanceRecord(
      id: 'seed-maint-tires',
      vehicleId: seedVehicleId,
      serviceType: MaintenanceServiceType.preventivo,
      category: 'Rotación de llantas',
      date: now.subtract(const Duration(days: 200)),
      odometer: 10000,
      totalCost: 90000,
      workshopName: 'Llantas y Rines Medellín',
    ),
    MaintenanceRecord(
      id: 'seed-maint-brakes',
      vehicleId: seedVehicleId,
      serviceType: MaintenanceServiceType.correctivo,
      category: 'Cambio de pastillas de freno',
      date: now.subtract(const Duration(days: 180)),
      odometer: 15000,
      totalCost: 260000,
      workshopName: 'Taller Ruedas Libres',
      notes: 'Se cambiaron pastillas delanteras y traseras.',
    ),
  ];

  return SeedData(
    user: user,
    vehicle: vehicle,
    fuelLogs: fuelLogs,
    legalDocuments: legalDocuments,
    maintenanceRecords: maintenanceRecords,
  );
}
