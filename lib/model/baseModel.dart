import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/utils/log_output.dart';
import 'package:logger/logger.dart';

class BaseModel extends ChangeNotifier{
  Logger logger;
  BaseModel(){
    logger=Logger(
        printer: PrettyPrinter(),
        output: ConsoleLogOutput()
    );
  }

}