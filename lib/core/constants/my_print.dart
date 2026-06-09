import 'dart:developer' as developer;

String _logData = "";
bool? _isRecordLog;

class MyPrint {
  static void printOnConsole(Object s, {String? tag}) {
    String logMessage = "${(tag?.isNotEmpty ?? false) ? "$tag " : ""}${s.toString()}";
    appendLogData(logMessage: logMessage);
    print(logMessage);
  }

  static void logOnConsole(Object s, {String? tag}) {
    String logMessage = "${(tag?.isNotEmpty ?? false) ? "$tag " : ""}${s.toString()}";
    appendLogData(logMessage: logMessage);
    developer.log(logMessage);
  }

  static void appendLogData({required String logMessage}) {
    if (_isRecordLog ?? false) _logData += "\n$logMessage";
  }

  static bool? get isRecordLog => _isRecordLog;

  static void setIsRecordLog(bool isRecord) => _isRecordLog = isRecord;

  static String getLog() {
    String log = _logData;
    developer.log("log length:${log.length}");

    _logData = "";

    return log;
  }
}
