import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_kozen_printer/pos_kozen_printer.dart';

void main() {
  group('TextPrintLine', () {
    test('debería crear línea de texto simple correctamente', () {
      final line = TextPrintLine.simple('Hola Mundo');

      expect(line.text, 'Hola Mundo');
      expect(line.alignment, PrintAlignment.left);
      expect(line.fontSize, 24.0);
      expect(line.isBold, false);
    });

    test('debería crear línea de texto en negrita correctamente', () {
      final line = TextPrintLine.bold(
        'Texto Negrita',
        alignment: PrintAlignment.center,
        fontSize: 32.0,
      );

      expect(line.text, 'Texto Negrita');
      expect(line.alignment, PrintAlignment.center);
      expect(line.fontSize, 32.0);
      expect(line.isBold, true);
    });

    test('debería convertir a Map correctamente', () {
      final line = TextPrintLine(
        text: 'Test',
        alignment: PrintAlignment.right,
        fontSize: 20.0,
        isBold: true,
        isItalic: true,
      );

      final map = line.toMap();

      expect(map['text'], 'Test');
      expect(map['alignment'], 2); // RIGHT = 2
      expect(map['fontSize'], 20.0);
      expect(map['isBold'], true);
      expect(map['isItalic'], true);
    });
  });

  group('PrintAlignment', () {
    test('debería retornar códigos correctos', () {
      expect(PrintAlignment.left.code, 0);
      expect(PrintAlignment.center.code, 1);
      expect(PrintAlignment.right.code, 2);
    });

    test('debería crear desde código correctamente', () {
      expect(PrintAlignmentExtension.fromCode(0), PrintAlignment.left);
      expect(PrintAlignmentExtension.fromCode(1), PrintAlignment.center);
      expect(PrintAlignmentExtension.fromCode(2), PrintAlignment.right);
      expect(
        PrintAlignmentExtension.fromCode(99),
        PrintAlignment.left,
      ); // default
    });
  });

  group('PrinterError', () {
    test('debería tener códigos correctos', () {
      expect(PrinterError.init.code, -1);
      expect(PrinterError.print.code, -2);
      expect(PrinterError.overheat.code, -3);
      expect(PrinterError.noPaper.code, -4);
      expect(PrinterError.other.code, -5);
    });

    test('debería tener descripciones en español', () {
      expect(PrinterError.init.description, 'No se logró iniciar la impresora');
      expect(PrinterError.overheat.description, 'La impresora se sobrecalentó');
      expect(PrinterError.noPaper.description, 'La impresora no tiene papel');
    });

    test('debería crear desde código correctamente', () {
      expect(PrinterErrorExtension.fromCode(-1), PrinterError.init);
      expect(PrinterErrorExtension.fromCode(-2), PrinterError.print);
      expect(PrinterErrorExtension.fromCode(-3), PrinterError.overheat);
      expect(PrinterErrorExtension.fromCode(-4), PrinterError.noPaper);
      expect(
        PrinterErrorExtension.fromCode(-99),
        PrinterError.other,
      ); // default
    });
  });

  group('PrinterStatus', () {
    test('debería tener códigos correctos', () {
      expect(PrinterStatus.idle.code, 0);
      expect(PrinterStatus.busy.code, 1);
      expect(PrinterStatus.unknown.code, -1);
    });

    test('debería tener descripciones en español', () {
      expect(PrinterStatus.idle.description, 'Impresora lista');
      expect(PrinterStatus.busy.description, 'Impresora ocupada');
      expect(PrinterStatus.unknown.description, 'Estado desconocido');
    });
  });

  group('PrinterException', () {
    test('debería crear excepción correctamente', () {
      final exception = PrinterException(PrinterError.noPaper);

      expect(exception.error, PrinterError.noPaper);
      expect(exception.message, null);
      expect(exception.toString(), contains('no tiene papel'));
    });

    test('debería incluir mensaje adicional en toString', () {
      final exception = PrinterException(
        PrinterError.print,
        'Error de conexión',
      );

      expect(exception.toString(), contains('Error de conexión'));
    });
  });

  group('BitmapPrintLine', () {
    test('debería crear línea de imagen correctamente', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3, 4]);
      final line = BitmapPrintLine(
        imageBytes: bytes,
        alignment: PrintAlignment.center,
      );

      expect(line.imageBytes, bytes);
      expect(line.alignment, PrintAlignment.center);
      expect(line.paddingLeft, 0);
      expect(line.paddingRight, 0);
    });

    test('debería convertir a Map correctamente', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3, 4]);
      final line = BitmapPrintLine(
        imageBytes: bytes,
        alignment: PrintAlignment.right,
        paddingLeft: 10,
        paddingRight: 20,
      );

      final map = line.toMap();

      expect(map['imageBytes'], bytes);
      expect(map['alignment'], 2); // RIGHT = 2
      expect(map['paddingLeft'], 10);
      expect(map['paddingRight'], 20);
    });
  });

  group('SimplePrinterListener', () {
    test('debería ejecutar callbacks correctamente', () {
      bool startCalled = false;
      bool finishCalled = false;
      PrinterError? errorReceived;

      final listener = SimplePrinterListener(
        onStart: () => startCalled = true,
        onFinish: () => finishCalled = true,
        onError: (error, msg) => errorReceived = error,
      );

      listener.onStart();
      expect(startCalled, true);

      listener.onFinish();
      expect(finishCalled, true);

      listener.onError(PrinterError.overheat, null);
      expect(errorReceived, PrinterError.overheat);
    });

    test('debería manejar callbacks nulos', () {
      final listener = SimplePrinterListener();

      // No debería lanzar error si los callbacks son null
      expect(() => listener.onStart(), returnsNormally);
      expect(() => listener.onFinish(), returnsNormally);
      expect(() => listener.onError(PrinterError.init, null), returnsNormally);
    });
  });
}
