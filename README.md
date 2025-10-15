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

// 1. Open printer connection
await printer.open();

// 2. Add content
await printer.addTextLine(
  TextPrintLine.bold(
    'Hello World!',
    alignment: PrintAlignment.center,
    fontSize: 28,
  ),
);
await printer.addBlankLines(3);

// 3. Print with listener
await printer.beginPrint(
  SimplePrinterListener(
    onStart: () => print('Printing started'),
    onFinish: () async {
      await printer.cleanCache();
      await printer.close();
      print('Print complete');
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

// Header
await printer.addTextLine(
  TextPrintLine.bold('MY STORE', alignment: PrintAlignment.center, fontSize: 32),
);
await printer.addTextLine(
  TextPrintLine.simple('123 Main Street', alignment: PrintAlignment.center),
);
await printer.addBlankLines(2);

// Items in columns
await printer.addTextColumns([
  TextPrintLine.simple('Product 1', alignment: PrintAlignment.left),
  TextPrintLine.simple('\$10.00', alignment: PrintAlignment.right),
]);
await printer.addTextColumns([
  TextPrintLine.simple('Product 2', alignment: PrintAlignment.left),
  TextPrintLine.simple('\$25.50', alignment: PrintAlignment.right),
]);

await printer.addBlankLines(1);

// Total
await printer.addTextColumns([
  TextPrintLine.bold('TOTAL:', alignment: PrintAlignment.left, fontSize: 28),
  TextPrintLine.bold('\$35.50', alignment: PrintAlignment.right, fontSize: 28),
]);

await printer.addBlankLines(5);

// Print
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

// Load image from assets
final ByteData data = await rootBundle.load('assets/logo.png');
final Uint8List bytes = data.buffer.asUint8List();

// Add centered image
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
// Full constructor
TextPrintLine(
  text: 'Hello',
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

// Convenience constructors
TextPrintLine.simple('Simple text')
TextPrintLine.bold('Bold text', fontSize: 28)
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
PrintAlignment.left    // Left
PrintAlignment.center  // Center
PrintAlignment.right   // Right
```

### PrinterError

```dart
PrinterError.init       // Initialization error
PrinterError.print      // Print error
PrinterError.overheat   // Overheating
PrinterError.noPaper    // Out of paper
PrinterError.other      // Unspecified error
```

## Important notes

⚠️ **Screen lock not supported**: Printing will fail if attempted with the screen locked.

⚠️ **Overheating**: The printer may overheat with continuous use. The listener will receive `PrinterError.overheat` if this occurs.

⚠️ **Cache cleanup**: Always call `cleanCache()` after `beginPrint()`, both on success and error.

## Complete example

Check the [example/](example/) folder for a complete application demonstrating all plugin features.

## Compatibility

Tested in TUU POS PRO2

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or pull request on the repository.

## Support

If you encounter any problems or have questions, please open an issue on the GitHub repository.
