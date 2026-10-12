part of com.auto_log_mi_nave_ota_labs.app.core.providers;

/// Índice del tab activo (Inicio/Gasolina/Legal/Taller/Acciones). Vive fuera
/// de la pila de páginas del router porque estos 5 destinos no tienen
/// historial propio: el AppShell solo muestra el tab activo en un IndexedStack.
class SelectedTabIndexController extends Notifier<int> {
  @override
  int build() => 0;

  int get current => state;
  set current(int index) => state = index;
}

final NotifierProvider<SelectedTabIndexController, int>
selectedTabIndexProvider = NotifierProvider<SelectedTabIndexController, int>(
  SelectedTabIndexController.new,
);

/// "Ahora" para lo que depende del día calendario (Pico y Placa, semáforo
/// de documentos). Se recalcula solo al llegar la medianoche: AppShell
/// mantiene los tabs montados en un IndexedStack, así que un
/// `DateTime.now()` en el build se quedaba con el día anterior si la app
/// seguía abierta (o en segundo plano) al cambiar la fecha. Si el timer
/// vence con la app suspendida, dispara al reanudarla.
///
/// Solo es exacto a nivel de día: no usarlo para comparar horas.
final Provider<DateTime> todayProvider = Provider<DateTime>((Ref ref) {
  DateTime now = DateTime.now();
  DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
  Timer timer = Timer(nextMidnight.difference(now), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return now;
});
