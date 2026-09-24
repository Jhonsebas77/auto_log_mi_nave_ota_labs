part of com.auto_log_mi_nave_ota_labs.app.core.utils;

/// Envoltorio usado por los `copyWith` de este library en campos Nullable,
/// para distinguir "parámetro no pasado" (se conserva el valor actual) de
/// "pasado explícitamente como `null`" (se debe vaciar el campo). Con el
/// patrón `campo ?? this.campo` de Dart, pasar `null` explícito es
/// indistinguible de no pasar nada, así que nunca se podría vaciar un campo
/// opcional a través de `copyWith`.
///
/// - `copyWith()` → el parámetro llega `null`: se conserva el valor.
/// - `copyWith(campo: const ValueWrapper(null))` → se vacía el campo.
/// - `copyWith(campo: ValueWrapper(valor))` → se asigna `valor`.
class ValueWrapper<T> {
  const ValueWrapper([this._value]);

  final T? _value;

  T? get value => _value;
}
