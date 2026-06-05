import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Importe o pacote

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  // Flag para evitar que ele leia o mesmo QR Code 50 vezes em 1 segundo
  bool _isScanning = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escaneie a Rádio', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (!_isScanning) return; // Se já achou, ignora o resto
          
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              _isScanning = false; // Trava o leitor
              // Fecha a tela e devolve a string que estava no QR Code
              Navigator.pop(context, barcode.rawValue); 
              break;
            }
          }
        },
      ),
    );
  }
}