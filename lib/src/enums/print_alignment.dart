/// Alineación del texto o imagen en la impresión.
enum PrintAlignment {
  /// Alinear a la izquierda
  left,

  /// Alinear al centro
  center,

  /// Alinear a la derecha
  right,
}

/// Extensión para manejar la alineación
extension PrintAlignmentExtension on PrintAlignment {
  /// Obtiene el código de alineación usado por la librería nativa
  int get code {
    switch (this) {
      case PrintAlignment.left:
        return 0;
      case PrintAlignment.center:
        return 1;
      case PrintAlignment.right:
        return 2;
    }
  }

  /// Crea un PrintAlignment desde un código numérico
  static PrintAlignment fromCode(int code) {
    switch (code) {
      case 0:
        return PrintAlignment.left;
      case 1:
        return PrintAlignment.center;
      case 2:
        return PrintAlignment.right;
      default:
        return PrintAlignment.left;
    }
  }
}
