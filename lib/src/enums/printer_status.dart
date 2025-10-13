/// Estados de la impresora KOZEN.
enum PrinterStatus {
  /// Impresora lista para operar
  idle,

  /// Impresora ocupada/imprimiendo
  busy,

  /// Estado desconocido
  unknown,
}

/// Extensión para manejar estados de la impresora
extension PrinterStatusExtension on PrinterStatus {
  /// Obtiene el código de estado numérico usado por la librería nativa
  int get code {
    switch (this) {
      case PrinterStatus.idle:
        return 0;
      case PrinterStatus.busy:
        return 1;
      case PrinterStatus.unknown:
        return -1;
    }
  }

  /// Crea un PrinterStatus desde un código numérico
  static PrinterStatus fromCode(int code) {
    switch (code) {
      case 0:
        return PrinterStatus.idle;
      case 1:
        return PrinterStatus.busy;
      default:
        return PrinterStatus.unknown;
    }
  }

  /// Obtiene una descripción en español del estado
  String get description {
    switch (this) {
      case PrinterStatus.idle:
        return 'Impresora lista';
      case PrinterStatus.busy:
        return 'Impresora ocupada';
      case PrinterStatus.unknown:
        return 'Estado desconocido';
    }
  }
}
