/// Plugin de Flutter para impresoras KOZEN en dispositivos POS PRO2.
///
/// Este plugin permite imprimir texto e imágenes de manera sencilla
/// en impresoras KOZEN integradas en dispositivos POS PRO2.
///
/// Ejemplo de uso básico:
/// ```dart
/// final printer = PosKozenPrinter();
///
/// // Abrir conexión
/// await printer.open();
///
/// // Agregar contenido
/// await printer.addTextLine(TextPrintLine.bold('Hola Mundo!'));
/// await printer.addBlankLines(3);
///
/// // Imprimir
/// await printer.beginPrint(SimplePrinterListener(
///   onFinish: () => print('Impresión completa'),
///   onError: (error, msg) => print('Error: $error - $msg'),
/// ));
///
/// // Limpiar y cerrar
/// await printer.cleanCache();
/// await printer.close();
/// ```
library;

// Exportar la clase principal
export 'src/pos_kozen_printer_platform.dart';

// Exportar modelos
export 'src/models/text_print_line.dart';
export 'src/models/bitmap_print_line.dart';
export 'src/models/printer_listener.dart';

// Exportar enums
export 'src/enums/printer_error.dart';
export 'src/enums/printer_status.dart';
export 'src/enums/print_alignment.dart';

// Exportar excepciones
export 'src/exceptions/printer_exception.dart';
