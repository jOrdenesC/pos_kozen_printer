# Librería KOZEN

Coloque aquí el archivo `com.pos.sdk-print.jar` de la librería de impresión KOZEN.

Puede descargar la librería desde:
https://developers.tuu.cl/docs/librer%C3%ADa-de-impresi%C3%B3n-dispositivos-kozen

Una vez colocado, el archivo será automáticamente incluido en el proyecto gracias a la configuración en `build.gradle`:

```gradle
implementation fileTree(dir: 'libs', include: ['*.jar', '*.aar'])
```

