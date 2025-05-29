class DataParsingException implements Exception {
  final String message;
  final dynamic data;

  DataParsingException(this.message, {this.data});

  @override
  String toString() {
    return 'DataParsingException: $message' + (data != null ? ', Data: $data' : '');
  }
}