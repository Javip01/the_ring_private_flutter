import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() => _isProcessing = true);
      _validateQR(barcodes.first.rawValue ?? "");
    }
  }

  void _validateQR(String code) {
    // Formato esperado: UID_TIMESTAMP
    final parts = code.split('_');

    if (parts.length != 2) {
      _showResultModal(false, "Código QR inválido o corrupto.");
      return;
    }

    final String uid = parts[0];
    final int? qrTimestamp = int.tryParse(parts[1]);

    if (qrTimestamp == null) {
      _showResultModal(false, "Error de lectura.");
      return;
    }

    // Lógica Anti-Captura de pantalla (Comprueba el tiempo)
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final int timeDifference = currentTimestamp - qrTimestamp;

    // 15000 milisegundos = 15 segundos + 3 seg de margen de latencia
    if (timeDifference > 18000) {
      _showResultModal(false, "CÓDIGO CADUCADO.\nPosible captura de pantalla.");
    } else if (timeDifference < -5000) {
      _showResultModal(false, "Error de sincronización de hora.");
    } else {
      // AQUÍ: Si el tiempo es correcto, podrías hacer una llamada a Firestore
      // para ver si el UID está baneado o ha pagado la cuota.
      _showResultModal(true, "ACCESO PERMITIDO\nUID: ${uid.substring(0, 5)}...");
    }
  }

  void _showResultModal(bool isValid, String message) {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: const Color(0xFF1E1E1E),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    isValid ? Icons.check_circle : Icons.cancel,
                    color: isValid ? Colors.greenAccent : Colors.redAccent,
                    size: 80
                ),
                const SizedBox(height: 20),
                Text(
                    isValid ? 'ACCESO APROBADO' : 'ACCESO DENEGADO',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isValid ? Colors.greenAccent : Colors.redAccent, letterSpacing: 2)
                ),
                const SizedBox(height: 15),
                Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Damos 2 segundos de respiro antes de volver a escanear
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _isProcessing = false);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValid ? Colors.greenAccent : Colors.redAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('ESCANEAR SIGUIENTE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESCÁNER VIP', style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),
          // Diseño Premium del visor del escáner
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFD700), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Text('Apunta al código QR del cliente', style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}