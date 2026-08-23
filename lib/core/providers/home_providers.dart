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
