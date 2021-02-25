import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';

class ConsoleLogOutput extends ConsoleOutput {
  @override
  void output(OutputEvent event) {
    super.output(event);
    LogConsole.add(event);
  }
}

class ReleaseFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    var shouldLog = false;
    if (event.level.index >= level.index) {
      shouldLog = true;
    }
    return shouldLog;
  }
}
