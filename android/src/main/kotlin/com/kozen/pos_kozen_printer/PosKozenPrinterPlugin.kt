package com.kozen.pos_kozen_printer

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.pos.sdk.printer.POIPrinterManager
import com.pos.sdk.printer.models.TextPrintLine
import com.pos.sdk.printer.models.BitmapPrintLine

class PosKozenPrinterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    
    // Referencia al printer manager de KOZEN
    private var printerManager: POIPrinterManager? = null
    
    companion object {
        private const val TAG = "PosKozenPrinter"
        private const val CHANNEL_NAME = "pos_kozen_printer"
        
        // Códigos de error
        private const val ERROR_INIT = -1
        private const val ERROR_PRINT = -2
        private const val ERROR_OVERHEAT = -3
        private const val ERROR_NO_PAPER = -4
        private const val ERROR_OTHER = -5
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "open" -> openPrinter(result)
            "close" -> closePrinter(result)
            "addTextLine" -> addTextLine(call, result)
            "addTextColumns" -> addTextColumns(call, result)
            "addBitmapLine" -> addBitmapLine(call, result)
            "addBlankLines" -> addBlankLines(call, result)
            "beginPrint" -> beginPrint(result)
            "cleanCache" -> cleanCache(result)
            "getStatus" -> getStatus(result)
            else -> result.notImplemented()
        }
    }

    private fun openPrinter(result: Result) {
        try {
            printerManager = POIPrinterManager(context)
            printerManager?.open()
            
            Log.d(TAG, "Impresora abierta")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error al abrir impresora", e)
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun closePrinter(result: Result) {
        try {
            printerManager?.close()
            printerManager = null
            
            Log.d(TAG, "Impresora cerrada")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error al cerrar impresora", e)
            result.error("CLOSE_ERROR", e.message, null)
        }
    }

    private fun addTextLine(call: MethodCall, result: Result) {
        try {
            val text = call.argument<String>("text") ?: ""
            val alignment = call.argument<Int>("alignment") ?: 0
            val fontSize = call.argument<Double>("fontSize")?.toFloat() ?: 24f
            val isBold = call.argument<Boolean>("isBold") ?: false
            val isItalic = call.argument<Boolean>("isItalic") ?: false
            val isUnderlined = call.argument<Boolean>("isUnderlined") ?: false
            val isInverted = call.argument<Boolean>("isInverted") ?: false
            val wordSpacing = call.argument<Double>("wordSpacing")?.toFloat() ?: 0f
            val letterSpacing = call.argument<Double>("letterSpacing")?.toFloat() ?: 0f
            val textScaleX = call.argument<Double>("textScaleX")?.toFloat() ?: 1f
            val paddingLeft = call.argument<Int>("paddingLeft") ?: 0
            val paddingRight = call.argument<Int>("paddingRight") ?: 0

            val textLine = TextPrintLine(text, alignment, fontSize, isBold, isItalic)
            textLine.isUnderLineText = isUnderlined
            textLine.isInvert = isInverted
            textLine.wordSpacing = wordSpacing
            textLine.letterSpacing = letterSpacing
            textLine.textScaleX = textScaleX
            textLine.paddingLeft = paddingLeft
            textLine.paddingRight = paddingRight
            printerManager?.addPrintLine(textLine)

            Log.d(TAG, "Línea de texto agregada: $text")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error al agregar línea de texto", e)
            result.error("ADD_TEXT_ERROR", e.message, null)
        }
    }

    private fun addTextColumns(call: MethodCall, result: Result) {
        try {
            val columns = call.argument<List<Map<String, Any>>>("columns") ?: emptyList()
            
            if (columns.size < 2 || columns.size > 3) {
                result.error("INVALID_COLUMNS", "Debe proporcionar 2 o 3 columnas", null)
                return
            }

            val textLines = columns.map { col ->
                val text = col["text"] as? String ?: ""
                val alignment = col["alignment"] as? Int ?: 0
                val fontSize = (col["fontSize"] as? Double)?.toFloat() ?: 24f
                val isBold = col["isBold"] as? Boolean ?: false
                val isItalic = col["isItalic"] as? Boolean ?: false
                TextPrintLine(text, alignment, fontSize, isBold, isItalic)
            }
            printerManager?.addPrintLine(textLines)

            Log.d(TAG, "Columnas de texto agregadas: ${columns.size}")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error al agregar columnas de texto", e)
            result.error("ADD_COLUMNS_ERROR", e.message, null)
        }
    }

    private fun addBitmapLine(call: MethodCall, result: Result) {
        try {
            val imageBytes = call.argument<ByteArray>("imageBytes")
            val alignment = call.argument<Int>("alignment") ?: 1
            val paddingLeft = call.argument<Int>("paddingLeft") ?: 0
            val paddingRight = call.argument<Int>("paddingRight") ?: 0

            if (imageBytes == null) {
                result.error("INVALID_IMAGE", "No se proporcionaron bytes de imagen", null)
                return
            }

            // Decode bitmap
            var bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            
            // Scale bitmap to fit thermal printer paper (max width: 384px for 80mm paper)
            val maxWidth = 384
            if (bitmap.width > maxWidth) {
                val scale = maxWidth.toFloat() / bitmap.width.toFloat()
                val newHeight = (bitmap.height * scale).toInt()
                bitmap = Bitmap.createScaledBitmap(bitmap, maxWidth, newHeight, true)
            }
            
            val bitmapLine = BitmapPrintLine(bitmap, alignment)
            bitmapLine.paddingLeft = paddingLeft
            bitmapLine.paddingRight = paddingRight
            printerManager?.addPrintLine(bitmapLine)

            Log.d(TAG, "Imagen agregada: ${bitmap.width}x${bitmap.height}")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error al agregar imagen", e)
            result.error("ADD_BITMAP_ERROR", e.message, null)
        }
    }

    private fun addBlankLines(call: MethodCall, result: Result) {
        try {
            val count = call.argument<Int>("count") ?: 1
            
            printerManager?.lineWrap(count)

            Log.d(TAG, "Líneas en blanco agregadas: $count")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error al agregar líneas en blanco", e)
            result.error("ADD_BLANK_ERROR", e.message, null)
        }
    }

           private fun beginPrint(result: Result) {
               try {
                   // Eliminar cualquier avance predefinido antes de imprimir
                   printerManager?.lineWrap(0)
                   
                   val listener = object : POIPrinterManager.IPrinterListener {
                       override fun onStart() {
                           channel.invokeMethod("onPrintStart", null)
                       }

                       override fun onFinish() {
                           channel.invokeMethod("onPrintFinish", null)
                       }

                       override fun onError(errorCode: Int, msg: String?) {
                           val args = mapOf(
                               "errorCode" to errorCode,
                               "message" to msg
                           )
                           channel.invokeMethod("onPrintError", args)
                       }
                   }
                   printerManager?.beginPrint(listener)
            
            Log.d(TAG, "Impresión iniciada")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error al iniciar impresión", e)
            result.error("PRINT_ERROR", e.message, null)
        }
    }

    private fun cleanCache(result: Result) {
        try {
            printerManager?.cleanCache()
            
            Log.d(TAG, "Caché limpiado")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error al limpiar caché", e)
            result.error("CLEAN_ERROR", e.message, null)
        }
    }

    private fun getStatus(result: Result) {
        try {
            val status = printerManager?.printerState ?: POIPrinterManager.STATUS_IDLE
            result.success(status)
        } catch (e: Exception) {
            Log.e(TAG, "Error al obtener estado", e)
            result.error("STATUS_ERROR", e.message, null)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        printerManager?.close()
        printerManager = null
    }
}

