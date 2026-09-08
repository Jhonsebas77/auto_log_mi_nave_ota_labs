part of com.auto_log_mi_nave_ota_labs.app.core.utils;

class Logger {
  const Logger(this.name);

  final String? name;

  String get formattedName => ReCase(name ?? '').titleCase;

  String get formattedDate => DateFormat.yMd().add_jm().format(DateTime.now());

  void info(String msg) {
    debugPrint('\x1B[32m$formattedDate [$formattedName]: $msg\x1B[0m');
  }

  void error(String msg) {
    debugPrint('\x1B[31m$formattedDate [$formattedName]: $msg\x1B[0m');
  }

  void warning(String msg) {
    debugPrint('\x1B[33m$formattedDate [$formattedName]: $msg\x1B[0m');
  }
}
