/// Códigos de error de la impresora KOZEN.
enum PrinterError {
  /// Error al inicializar la impresora
  init,

  /// Error durante el proceso de impresión
  print,

  /// Error por sobrecalentamiento de la impresora
  overheat,

  /// Error por falta de papel
  noPaper,

  /// Error no especificado
  other,
}

/// Extensión para obtener descripciones de los errores
extension PrinterErrorExtension on PrinterError {
  /// Obtiene el código de error numérico usado por la librería nativa
  int get code {
    switch (this) {
      case PrinterError.init:
        return -1;
      case PrinterError.print:
        return -2;
      case PrinterError.overheat:
        return -3;
      case PrinterError.noPaper:
        return -4;
      case PrinterError.other:
        return -5;
    }
  }

  /// Obtiene una descripción en español del error
  String get description {
    switch (this) {
      case PrinterError.init:
        return 'No se logró iniciar la impresora';
      case PrinterError.print:
        return 'Ocurrió un error al imprimir';
      case PrinterError.overheat:
        return 'La impresora se sobrecalentó';
      case PrinterError.noPaper:
        return 'La impresora no tiene papel';
      case PrinterError.other:
        return 'La impresora falló por un error no especificado';
    }
  }

  /// Crea un PrinterError desde un código numérico
  static PrinterError fromCode(int code) {
    switch (code) {
      case -1:
        return PrinterError.init;
      case -2:
        return PrinterError.print;
      case -3:
        return PrinterError.overheat;
      case -4:
        return PrinterError.noPaper;
      default:
        return PrinterError.other;
    }
  }
}
