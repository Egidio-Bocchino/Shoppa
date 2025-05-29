///TODO importare tutte le gestioni per le eccezioni
class DataParsingException implements Exception {
  final String message;
  final dynamic data;

  DataParsingException(this.message, {this.data});

  @override
  String toString() {
    return 'DataParsingException: $message, Data: $data';
  }
}