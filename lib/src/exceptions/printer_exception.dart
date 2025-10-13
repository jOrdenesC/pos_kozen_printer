import '../enums/printer_error.dart';

/// Excepción lanzada cuando ocurre un error en la impresora.
class PrinterException implements Exception {
  /// El tipo de error que ocurrió
  final PrinterError error;

  /// Mensaje adicional del error
  final String? message;

  /// Crea una nueva PrinterException
  const PrinterException(this.error, [this.message]);

  @override
  String toString() {
    final errorMsg = error.description;
    if (message != null && message!.isNotEmpty) {
      return 'PrinterException: $errorMsg - $message';
    }
    return 'PrinterException: $errorMsg';
  }
}
