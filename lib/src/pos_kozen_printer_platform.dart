import 'package:flutter/services.dart';
import 'enums/printer_error.dart';
import 'enums/printer_status.dart';
import 'models/bitmap_print_line.dart';
import 'models/printer_listener.dart';
import 'models/text_print_line.dart';
import 'exceptions/printer_exception.dart';

/// Clase principal para manejar la impresora KOZEN en dispositivos POS PRO2.
class PosKozenPrinter {
  static const MethodChannel _channel = MethodChannel('pos_kozen_printer');

  PrinterListener? _currentListener;

  /// Constructor
  PosKozenPrinter() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Maneja las llamadas desde el código nativo
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onPrintStart':
        _currentListener?.onStart();
        break;
      case 'onPrintFinish':
        _currentListener?.onFinish();
        _currentListener = null;
        break;
      case 'onPrintError':
        final int errorCode = call.arguments['errorCode'] as int;
        final String? message = call.arguments['message'] as String?;
        final error = PrinterErrorExtension.fromCode(errorCode);
        _currentListener?.onError(error, message);
        _currentListener = null;
        break;
    }
  }

  /// Abre la conexión con la impresora.
  ///
  /// Debe llamarse antes de cualquier operación de impresión.
  /// Lanza [PrinterException] si falla la conexión.
  Future<void> open() async {
    try {
      await _channel.invokeMethod('open');
    } on PlatformException catch (e) {
      throw PrinterException(PrinterError.init, e.message);
    }
  }

  /// Cierra la conexión con la impresora.
  ///
  /// Debe llamarse cuando ya no se necesite la impresora.
  Future<void> close() async {
    try {
      await _channel.invokeMethod('close');
    } on PlatformException catch (e) {
      throw PrinterException(PrinterError.other, e.message);
    }
  }

  /// Agrega una línea de texto a la cola de impresión.
  ///
  /// [line] - La línea de texto a imprimir.
  Future<void> addTextLine(TextPrintLine line) async {
    try {
      await _channel.invokeMethod('addTextLine', line.toMap());
    } on PlatformException catch (e) {
      throw PrinterException(PrinterError.other, e.message);
    }
  }

  /// Agrega múltiples líneas de texto como columnas.
  ///
  /// Permite imprimir 2 o 3 columnas de texto en una sola línea.
  /// [columns] - Lista de 2 o 3 TextPrintLine que se imprimirán como columnas.
  Future<void> addTextColumns(List<TextPrintLine> columns) async {
    if (columns.length < 2 || columns.length > 3) {
      throw ArgumentError('Debe proporcionar 2 o 3 columnas');
    }

    try {
      final columnsData = columns.map((c) => c.toMap()).toList();
      await _channel.invokeMethod('addTextColumns', {'columns': columnsData});
    } on PlatformException catch (e) {
      throw PrinterException(PrinterError.other, e.message);
    }
  }

  /// Agrega una imagen a la cola de impresión.
  ///
  /// [line] - La imagen a imprimir.
  Future<void> addBitmapLine(BitmapPrintLine line) async {
    try {
      await _channel.invokeMethod('addBitmapLine', line.toMap());
    } on PlatformException catch (e) {
      throw PrinterException(PrinterError.other, e.message);
    }
  }

  /// Agrega líneas en blanco a la impresión.
  ///
  /// [count] - Número de líneas en blanco a agregar.
  Future<void> addBlankLines(int count) async {
    if (count <= 0) return;

    try {
      await _channel.invokeMethod('addBlankLines', {'count': count});
    } on PlatformException catch (e) {
      throw PrinterException(PrinterError.other, e.message);
    }
  }

  /// Inicia la impresión de todas las líneas agregadas.
  ///
  /// [listener] - Listener para recibir eventos de impresión.
  ///
  /// **Importante**: No se soporta la impresión con pantalla bloqueada.
  /// La impresión puede fallar por sobrecalentamiento de la impresora.
  Future<void> beginPrint(PrinterListener listener) async {
    _currentListener = listener;

    try {
      await _channel.invokeMethod('beginPrint');
    } on PlatformException catch (e) {
      _currentListener = null;
      throw PrinterException(PrinterError.print, e.message);
    }
  }

  /// Limpia la cola de impresión.
  ///
  /// Debe llamarse después de [beginPrint] para limpiar el caché.
  Future<void> cleanCache() async {
    try {
      await _channel.invokeMethod('cleanCache');
    } on PlatformException catch (e) {
      throw PrinterException(PrinterError.other, e.message);
    }
  }

  /// Obtiene el estado actual de la impresora.
  ///
  /// Retorna [PrinterStatus] indicando si está lista, ocupada o desconocido.
  Future<PrinterStatus> getStatus() async {
    try {
      final int statusCode = await _channel.invokeMethod('getStatus');
      return PrinterStatusExtension.fromCode(statusCode);
    } on PlatformException catch (e) {
      throw PrinterException(PrinterError.other, e.message);
    }
  }

  /// Método de conveniencia para imprimir texto simple.
  ///
  /// Abre la impresora, agrega el texto, imprime y limpia.
  /// [text] - Texto a imprimir.
  /// [listener] - Listener para eventos de impresión.
  Future<void> printSimpleText(String text, {PrinterListener? listener}) async {
    await open();
    await addTextLine(TextPrintLine.simple(text));
    await addBlankLines(3);

    final printListener =
        listener ??
        SimplePrinterListener(
          onFinish: () async {
            await cleanCache();
            await close();
          },
          onError: (error, message) async {
            await cleanCache();
            await close();
          },
        );

    await beginPrint(printListener);
  }
}
