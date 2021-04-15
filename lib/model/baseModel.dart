import 'package:flutter/cupertino.dart';
import 'package:dcomic/utils/log_output.dart';
import 'package:logger/logger.dart';

class BaseModel extends ChangeNotifier {
  Logger logger;

  BaseModel() {
    logger = Logger(
        filter: ReleaseFilter(),
        printer: PrettyPrinter(),
        output: ConsoleLogOutput());
  }
}
