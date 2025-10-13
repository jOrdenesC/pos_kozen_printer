# pos_kozen_printer

Flutter plugin for KOZEN printers on TUU/Haulmer POS PRO2 devices. Easily print text and images on thermal printers.

[![pub package](https://img.shields.io/pub/v/pos_kozen_printer.svg)](https://pub.dev/packages/pos_kozen_printer)

## Features

✅ Print text with multiple styles (bold, italic, underline, inverted)  
✅ Print images (PNG, JPEG)  
✅ Support for text columns (2 or 3 columns)  
✅ Alignment control (left, center, right)  
✅ Print event management (start, finish, errors)  
✅ Printer status verification  
✅ Simple and well-documented API  

## Requirements

- Flutter SDK: >=3.0.0
- Dart SDK: ^3.8.0
- Android: minSdk 21 (Android 5.0)
- TUU/Haulmer POS PRO2 device with KOZEN printer

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  pos_kozen_printer: ^0.0.1
```

Then run:

```bash
flutter pub get
```

**Note:** The KOZEN library is already included in the plugin. You don't need to add any additional files to your app.

## Basic usage

### Import the package

```dart
import 'package:pos_kozen_printer/pos_kozen_printer.dart';
```

### Simple example

```dart
final printer = PosKozenPrinter();

// 1. Abrir conexión con la impresora
await printer.open();

// 2. Agregar contenido
await printer.addTextLine(
  TextPrintLine.bold(
    '¡Hola Mundo!',
    alignment: PrintAlignment.center,
    fontSize: 28,
  ),
);
await printer.addBlankLines(3);

// 3. Imprimir con listener
await printer.beginPrint(
  SimplePrinterListener(
    onStart: () => print('Impresión iniciada'),
    onFinish: () async {
      await printer.cleanCache();
      await printer.close();
      print('Impresión completa');
    },
    onError: (error, message) async {
      await printer.cleanCache();
      await printer.close();
      print('Error: ${error.description}');
    },
  ),
);
```

### Print complete receipt

```dart
final printer = PosKozenPrinter();
await printer.open();

// Encabezado
await printer.addTextLine(
  TextPrintLine.bold('MI TIENDA', alignment: PrintAlignment.center, fontSize: 32),
);
await printer.addTextLine(
  TextPrintLine.simple('Dirección de la tienda', alignment: PrintAlignment.center),
);
await printer.addBlankLines(2);

// Productos en columnas
await printer.addTextColumns([
  TextPrintLine.simple('Producto 1', alignment: PrintAlignment.left),
  TextPrintLine.simple('\$10.00', alignment: PrintAlignment.right),
]);
await printer.addTextColumns([
  TextPrintLine.simple('Producto 2', alignment: PrintAlignment.left),
  TextPrintLine.simple('\$25.50', alignment: PrintAlignment.right),
]);

await printer.addBlankLines(1);

// Total
await printer.addTextColumns([
  TextPrintLine.bold('TOTAL:', alignment: PrintAlignment.left, fontSize: 28),
  TextPrintLine.bold('\$35.50', alignment: PrintAlignment.right, fontSize: 28),
]);

await printer.addBlankLines(5);

// Imprimir
await printer.beginPrint(
  SimplePrinterListener(
    onFinish: () async {
      await printer.cleanCache();
      await printer.close();
    },
    onError: (error, msg) async {
      await printer.cleanCache();
      await printer.close();
    },
  ),
);
```

### Print images

```dart
import 'dart:typed_data';
import 'package:flutter/services.dart';

final printer = PosKozenPrinter();
await printer.open();

// Cargar imagen desde assets
final ByteData data = await rootBundle.load('assets/logo.png');
final Uint8List bytes = data.buffer.asUint8List();

// Agregar imagen centrada
await printer.addBitmapLine(
  BitmapPrintLine(
    imageBytes: bytes,
    alignment: PrintAlignment.center,
  ),
);

await printer.addBlankLines(3);
await printer.beginPrint(/* ... */);
```

## Main API

### PosKozenPrinter

| Method | Description |
|--------|-------------|
| `open()` | Opens connection to the printer |
| `close()` | Closes connection to the printer |
| `addTextLine(TextPrintLine)` | Adds a text line |
| `addTextColumns(List<TextPrintLine>)` | Adds 2 or 3 text columns |
| `addBitmapLine(BitmapPrintLine)` | Adds an image |
| `addBlankLines(int)` | Adds blank lines |
| `beginPrint(PrinterListener)` | Starts printing |
| `cleanCache()` | Cleans print queue |
| `getStatus()` | Gets printer status |

### TextPrintLine

```dart
// Constructor completo
TextPrintLine(
  text: 'Hola',
  alignment: PrintAlignment.left,
  fontSize: 24.0,
  isBold: false,
  isItalic: false,
  isUnderlined: false,
  isInverted: false,
  wordSpacing: 0.0,
  letterSpacing: 0.0,
  textScaleX: 1.0,
  paddingLeft: 0,
  paddingRight: 0,
)

// Constructores de conveniencia
TextPrintLine.simple('Texto simple')
TextPrintLine.bold('Texto en negrita', fontSize: 28)
```

### BitmapPrintLine

```dart
BitmapPrintLine(
  imageBytes: bytes,
  alignment: PrintAlignment.center,
  paddingLeft: 0,
  paddingRight: 0,
)
```

### PrintAlignment

```dart
PrintAlignment.left    // Izquierda
PrintAlignment.center  // Centro
PrintAlignment.right   // Derecha
```

### PrinterError

```dart
PrinterError.init       // Error al inicializar
PrinterError.print      // Error durante impresión
PrinterError.overheat   // Sobrecalentamiento
PrinterError.noPaper    // Sin papel
PrinterError.other      // Error no especificado
```

## Important notes

⚠️ **Screen lock not supported**: Printing will fail if attempted with the screen locked.

⚠️ **Overheating**: The printer may overheat with continuous use. The listener will receive `PrinterError.overheat` if this occurs.

⚠️ **Cache cleanup**: Always call `cleanCache()` after `beginPrint()`, both on success and error.

## Complete example

Check the [example/](example/) folder for a complete application demonstrating all plugin features.

## Additional documentation

- [Official KOZEN Documentation](https://developers.tuu.cl/docs/librer%C3%ADa-de-impresi%C3%B3n-dispositivos-kozen)
- [API Reference](https://pub.dev/documentation/pos_kozen_printer/latest/)

## Compatibility

This plugin works with:
- TUU POS PRO2 devices
- Haulmer POS PRO2 devices
- Any device using KOZEN thermal printers

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or pull request on the repository.

## Support

If you encounter any problems or have questions, please open an issue on the GitHub repository.
