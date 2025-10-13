import 'dart:typed_data';
import '../enums/print_alignment.dart';

/// Representa una imagen (bitmap) para imprimir.
class BitmapPrintLine {
  /// Bytes de la imagen en formato PNG o JPEG
  final Uint8List imageBytes;

  /// Alineación de la imagen
  final PrintAlignment alignment;

  /// Padding a la izquierda (en píxeles)
  final int paddingLeft;

  /// Padding a la derecha (en píxeles)
  final int paddingRight;

  /// Constructor
  const BitmapPrintLine({
    required this.imageBytes,
    this.alignment = PrintAlignment.center,
    this.paddingLeft = 0,
    this.paddingRight = 0,
  });

  /// Convierte a Map para enviar por platform channel
  Map<String, dynamic> toMap() {
    return {
      'imageBytes': imageBytes,
      'alignment': alignment.code,
      'paddingLeft': paddingLeft,
      'paddingRight': paddingRight,
    };
  }
}
