import 'package:flutter/foundation.dart';

import 'data_parsing_exception.dart';

class ExceptionHandler {
  static void handle(dynamic error, StackTrace? stackTrace, {String? context, dynamic data}) {
    if (kDebugMode) {
      print('--- ECCEZIONE RILEVATA ---');
      print('Tipo Errore: ${error.runtimeType}');
      if (context != null) {
        print('Contesto: $context');
      }
      if (data != null) {
        print('Dati Correlati: $data');
      }
      print('Messaggio Errore: $error');
      if (stackTrace != null) {
        print('Stack Trace:');
        print(stackTrace);
      }
      print('-------------------------');
    }

  }

  static void handleDataParsingException(DataParsingException e, StackTrace? stackTrace, {String? context}) {
    handle(e, stackTrace, context: context ?? 'Parsing Dati', data: e.data);
  }
}