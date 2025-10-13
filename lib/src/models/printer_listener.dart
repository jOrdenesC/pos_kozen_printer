import '../enums/printer_error.dart';

/// Listener para eventos de impresión.
abstract class PrinterListener {
  /// Se llama cuando comienza la impresión
  void onStart();

  /// Se llama cuando termina exitosamente la impresión
  void onFinish();

  /// Se llama cuando ocurre un error durante la impresión
  void onError(PrinterError error, String? message);
}

/// Implementación simple de PrinterListener usando callbacks
class SimplePrinterListener implements PrinterListener {
  final void Function()? _onStart;
  final void Function()? _onFinish;
  final void Function(PrinterError error, String? message)? _onError;

  SimplePrinterListener({
    void Function()? onStart,
    void Function()? onFinish,
    void Function(PrinterError error, String? message)? onError,
  }) : _onStart = onStart,
       _onFinish = onFinish,
       _onError = onError;

  @override
  void onStart() {
    _onStart?.call();
  }

  @override
  void onFinish() {
    _onFinish?.call();
  }

  @override
  void onError(PrinterError error, String? message) {
    _onError?.call(error, message);
  }
}
