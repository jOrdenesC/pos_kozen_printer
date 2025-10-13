import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_kozen_printer/pos_kozen_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KOZEN Printer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PrinterDemoPage(),
    );
  }
}

class PrinterDemoPage extends StatefulWidget {
  const PrinterDemoPage({super.key});

  @override
  State<PrinterDemoPage> createState() => _PrinterDemoPageState();
}

class _PrinterDemoPageState extends State<PrinterDemoPage> {
  final _printer = PosKozenPrinter();

  String _statusMessage = 'Ready';
  bool _isPrinting = false;
  bool _isConnected = false;

  @override
  void dispose() {
    _closePrinter();
    super.dispose();
  }

  Future<Uint8List> _loadLogo() async {
    // Load logo from assets - Android side will scale it to fit paper
    final ByteData data = await rootBundle.load('assets/flutter.png');
    return data.buffer.asUint8List();
  }

  Future<void> _openPrinter() async {
    try {
      setState(() => _statusMessage = 'Connecting...');
      await _printer.open();
      setState(() {
        _isConnected = true;
        _statusMessage = 'Connected';
      });
      _showSnackBar('Printer connected successfully', Colors.green);
    } catch (e) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Connection error';
      });
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _closePrinter() async {
    try {
      await _printer.close();
      setState(() {
        _isConnected = false;
        _statusMessage = 'Disconnected';
      });
    } catch (e) {
      _showSnackBar('Close error: $e', Colors.orange);
    }
  }

  Future<void> _printReceipt() async {
    if (!_isConnected) {
      _showSnackBar('Please connect the printer first', Colors.orange);
      return;
    }

    setState(() {
      _isPrinting = true;
      _statusMessage = 'Printing receipt...';
    });

    try {
      // Logo
      final logoBytes = await _loadLogo();
      await _printer.addBitmapLine(
        BitmapPrintLine(
          imageBytes: logoBytes,
          alignment: PrintAlignment.center,
        ),
      );

      // Header
      await _printer.addTextLine(
        TextPrintLine.bold(
          'MY STORE',
          alignment: PrintAlignment.center,
          fontSize: 32,
        ),
      );
      await _printer.addTextLine(
        TextPrintLine.simple(
          '123 Main Street',
          alignment: PrintAlignment.center,
          fontSize: 20,
        ),
      );
      await _printer.addTextLine(
        TextPrintLine.simple(
          'Tel: (123) 456-7890',
          alignment: PrintAlignment.center,
          fontSize: 20,
        ),
      );
      await _printer.addBlankLines(1);

      // Separator
      await _printer.addTextLine(TextPrintLine.simple('━' * 32, fontSize: 20));

      // Receipt details
      await _printer.addTextColumns([
        TextPrintLine.simple('Date:', alignment: PrintAlignment.left),
        TextPrintLine.simple('10/13/2025', alignment: PrintAlignment.right),
      ]);
      await _printer.addTextColumns([
        TextPrintLine.simple('Time:', alignment: PrintAlignment.left),
        TextPrintLine.simple('2:30 PM', alignment: PrintAlignment.right),
      ]);
      await _printer.addBlankLines(1);

      // Products
      await _printer.addTextLine(TextPrintLine.bold('ITEMS', fontSize: 24));

      await _printer.addTextColumns([
        TextPrintLine.simple('Product 1', alignment: PrintAlignment.left),
        TextPrintLine.simple('\$10.00', alignment: PrintAlignment.right),
      ]);
      await _printer.addTextColumns([
        TextPrintLine.simple('Product 2', alignment: PrintAlignment.left),
        TextPrintLine.simple('\$25.50', alignment: PrintAlignment.right),
      ]);
      await _printer.addTextColumns([
        TextPrintLine.simple('Product 3', alignment: PrintAlignment.left),
        TextPrintLine.simple('\$8.75', alignment: PrintAlignment.right),
      ]);

      await _printer.addTextLine(TextPrintLine.simple('━' * 32, fontSize: 20));

      // Total
      await _printer.addTextColumns([
        TextPrintLine.bold(
          'TOTAL:',
          alignment: PrintAlignment.left,
          fontSize: 28,
        ),
        TextPrintLine.bold(
          '\$44.25',
          alignment: PrintAlignment.right,
          fontSize: 28,
        ),
      ]);

      await _printer.addBlankLines(1);
      await _printer.addTextLine(
        TextPrintLine.simple(
          'Thank you for your purchase!',
          alignment: PrintAlignment.center,
          fontSize: 22,
        ),
      );
      await _printer.addBlankLines(20);

      await _printer.beginPrint(
        SimplePrinterListener(
          onFinish: () async {
            await _printer.cleanCache();
            setState(() {
              _isPrinting = false;
              _statusMessage = 'Receipt printed';
            });
            _showSnackBar('Receipt printed successfully!', Colors.green);
          },
          onError: (error, message) async {
            await _printer.cleanCache();
            setState(() {
              _isPrinting = false;
              _statusMessage = 'Error: ${error.description}';
            });
            _showSnackBar('Error: ${error.description}', Colors.red);
          },
        ),
      );
    } catch (e) {
      setState(() {
        _isPrinting = false;
        _statusMessage = 'Error';
      });
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _checkStatus() async {
    try {
      final status = await _printer.getStatus();
      setState(() => _statusMessage = status.description);
      _showSnackBar('Status: ${status.description}', Colors.blue);
    } catch (e) {
      _showSnackBar('Error getting status: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KOZEN Printer Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _isConnected
                                    ? Colors.green
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _statusMessage,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isConnected ? null : _openPrinter,
                            icon: const Icon(Icons.power),
                            label: const Text('Connect'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: !_isConnected ? null : _closePrinter,
                            icon: const Icon(Icons.power_off),
                            label: const Text('Disconnect'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _checkStatus,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Check status',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sample receipt
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Print sample receipt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Prints a receipt with logo, header, items and total',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isPrinting ? null : _printReceipt,
                        icon: _isPrinting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.receipt_long),
                        label: Text(
                          _isPrinting ? 'Printing...' : 'Print receipt',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Important information
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Important information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Printing not supported with locked screen\n'
                      '• Printer may overheat with continuous use\n'
                      '• Make sure you have enough paper',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
