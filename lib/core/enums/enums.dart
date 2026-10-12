library com.auto_log_mi_nave_ota_labs.app.core.enums;

/// Enums que mapean los `CHECK` constraints del schema SQL (claude/tech_spec.md).

enum FuelType {
  gasolinaCorriente,
  gasolinaExtra,
  diesel,
  hibrido,
  electrico,
  gas,
}

extension FuelTypeSql on FuelType {
  String get sqlValue {
    switch (this) {
      case FuelType.gasolinaCorriente:
        return 'GASOLINA_CORRIENTE';
      case FuelType.gasolinaExtra:
        return 'GASOLINA_EXTRA';
      case FuelType.diesel:
        return 'DIESEL';
      case FuelType.hibrido:
        return 'HIBRIDO';
      case FuelType.electrico:
        return 'ELECTRICO';
      case FuelType.gas:
        return 'GAS';
    }
  }

  String get label {
    switch (this) {
      case FuelType.gasolinaCorriente:
        return 'Gasolina corriente';
      case FuelType.gasolinaExtra:
        return 'Gasolina extra';
      case FuelType.diesel:
        return 'Diésel';
      case FuelType.hibrido:
        return 'Híbrido';
      case FuelType.electrico:
        return 'Eléctrico';
      case FuelType.gas:
        return 'Gas';
    }
  }

  static FuelType fromSqlValue(String value) =>
      FuelType.values.firstWhere((FuelType e) => e.sqlValue == value);
}

enum DocumentType {
  soat,
  rtm,
  impuestoVehicular,
  polizaTodoRiesgo,
  licenciaConduccion,
  extintor,
}

extension DocumentTypeSql on DocumentType {
  String get sqlValue {
    switch (this) {
      case DocumentType.soat:
        return 'SOAT';
      case DocumentType.rtm:
        return 'RTM';
      case DocumentType.impuestoVehicular:
        return 'IMPUESTO_VEHICULAR';
      case DocumentType.polizaTodoRiesgo:
        return 'POLIZA_TODO_RIESGO';
      case DocumentType.licenciaConduccion:
        return 'LICENCIA_CONDUCCION';
      case DocumentType.extintor:
        return 'EXTINTOR';
    }
  }

  String get label {
    switch (this) {
      case DocumentType.soat:
        return 'SOAT';
      case DocumentType.rtm:
        return 'Revisión Técnico-Mecánica';
      case DocumentType.impuestoVehicular:
        return 'Impuesto Vehicular';
      case DocumentType.polizaTodoRiesgo:
        return 'Póliza Todo Riesgo';
      case DocumentType.licenciaConduccion:
        return 'Licencia de Conducción';
      case DocumentType.extintor:
        return 'Extintor';
    }
  }

  /// Agrupación usada por las tabs de Garaje Legal (Vehículo/Impuestos/Conductor).
  String get garageTabGroup {
    switch (this) {
      case DocumentType.soat:
      case DocumentType.rtm:
      case DocumentType.polizaTodoRiesgo:
      case DocumentType.extintor:
        return 'Vehículo';
      case DocumentType.impuestoVehicular:
        return 'Impuestos';
      case DocumentType.licenciaConduccion:
        return 'Conductor';
    }
  }

  static DocumentType fromSqlValue(String value) =>
      DocumentType.values.firstWhere((DocumentType e) => e.sqlValue == value);
}

enum MaintenanceServiceType { preventivo, correctivo }

extension MaintenanceServiceTypeSql on MaintenanceServiceType {
  String get sqlValue {
    switch (this) {
      case MaintenanceServiceType.preventivo:
        return 'PREVENTIVO';
      case MaintenanceServiceType.correctivo:
        return 'CORRECTIVO';
    }
  }

  String get label {
    switch (this) {
      case MaintenanceServiceType.preventivo:
        return 'Preventivo';
      case MaintenanceServiceType.correctivo:
        return 'Correctivo';
    }
  }

  static MaintenanceServiceType fromSqlValue(String value) =>
      MaintenanceServiceType.values.firstWhere(
        (MaintenanceServiceType e) => e.sqlValue == value,
      );
}

enum MaintenanceLifespanCategory { oil, tires, brakes }

enum TrafficLightLevel { ok, warning, danger }

enum AuthStatus { unknown, unauthenticated, authenticated }

enum SnackbarType { information, success, error }

enum CustomNavigationAnimation {
  slideRight,
  slideBottom,
  fade,
  scale,
  scaleFade,
}

/// Clase de tamaño de ventana para el layout adaptativo (web/tablet/móvil).
enum WindowSize {
  /// Móvil: bottom nav bar + contenido a una columna.
  compact,

  /// Tablet / ventana angosta: riel lateral compacto + top app bar.
  medium,

  /// Escritorio: sidebar completo (logo, labels, ajustes) sin top app bar.
  expanded,
}

/// Esquina de un marco de `CornerBrackets` (pantalla de login).
enum BracketCorner { topLeft, topRight, bottomLeft, bottomRight }

/// Acción elegida en la hoja de adjuntos de los formularios (ver
/// `_AttachmentUploadMixin`).
enum AttachmentAction { camera, gallery, pdf, remove }
