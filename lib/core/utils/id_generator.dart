part of com.auto_log_mi_nave_ota_labs.app.core.utils;

const Uuid _uuid = Uuid();

/// Genera un id mock equivalente a `gen_random_uuid()` del schema Postgres.
String generateId() => _uuid.v4();
