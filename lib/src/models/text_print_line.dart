import '../enums/print_alignment.dart';

/// Representa una línea de texto para imprimir.
class TextPrintLine {
  /// Texto a imprimir
  final String text;

  /// Alineación del texto
  final PrintAlignment alignment;

  /// Tamaño de la fuente (en puntos)
  final double fontSize;

  /// Si el texto está en negrita
  final bool isBold;

  /// Si el texto está en cursiva
  final bool isItalic;

  /// Si el texto está subrayado
  final bool isUnderlined;

  /// Si los colores están invertidos (fondo negro, texto blanco)
  final bool isInverted;

  /// Espaciado entre palabras
  final double wordSpacing;

  /// Espaciado entre letras
  final double letterSpacing;

  /// Escala horizontal del texto
  final double textScaleX;

  /// Padding a la izquierda (en píxeles)
  final int paddingLeft;

  /// Padding a la derecha (en píxeles)
  final int paddingRight;

  /// Constructor completo
  const TextPrintLine({
    required this.text,
    this.alignment = PrintAlignment.left,
    this.fontSize = 24.0,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderlined = false,
    this.isInverted = false,
    this.wordSpacing = 0.0,
    this.letterSpacing = 0.0,
    this.textScaleX = 1.0,
    this.paddingLeft = 0,
    this.paddingRight = 0,
  });

  /// Constructor simplificado para texto básico
  factory TextPrintLine.simple(
    String text, {
    PrintAlignment alignment = PrintAlignment.left,
    double fontSize = 24.0,
  }) {
    return TextPrintLine(text: text, alignment: alignment, fontSize: fontSize);
  }

  /// Constructor para texto en negrita
  factory TextPrintLine.bold(
    String text, {
    PrintAlignment alignment = PrintAlignment.left,
    double fontSize = 24.0,
  }) {
    return TextPrintLine(
      text: text,
      alignment: alignment,
      fontSize: fontSize,
      isBold: true,
    );
  }

  /// Convierte a Map para enviar por platform channel
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'alignment': alignment.code,
      'fontSize': fontSize,
      'isBold': isBold,
      'isItalic': isItalic,
      'isUnderlined': isUnderlined,
      'isInverted': isInverted,
      'wordSpacing': wordSpacing,
      'letterSpacing': letterSpacing,
      'textScaleX': textScaleX,
      'paddingLeft': paddingLeft,
      'paddingRight': paddingRight,
    };
  }
}
