import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';

class ConsoleLogOutput extends ConsoleOutput {
  @override
  void output(OutputEvent event) {
    super.output(event);
    LogConsole.add(event);
  }
}