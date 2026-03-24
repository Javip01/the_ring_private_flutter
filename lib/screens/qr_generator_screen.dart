import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  Timer? _timer;
  String _currentQrData = "";
  int _secondsLeft = 15; // Lógica maestra Anti-Capturas de 15s

  @override
  void initState() {
    super.initState();
    _generateNewCode();
    _startTimer();
  }

  void _generateNewCode() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Mantenemos la lógica de seguridad: UID_TIMESTAMP
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        _currentQrData = "${user.uid}_$timestamp";
        _secondsLeft = 15;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _generateNewCode(); // Regenerar QR a los 15s
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco absoluto de captura
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Fondo blanco principal
          Column(
            children: [
              // --- CABECERA ROJA GRANDE (Captura) ---
              Container(
                width: double.infinity,
                height: 180,
                color: const Color(0xFFE53935),
                padding: const EdgeInsets.only(top: 50, left: 10),
                child: Column(
                  children: [
                    // Botón back falso y título
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'CLIENTE VIP',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                          ),
                        ),
                        const SizedBox(width: 40), // Balance
                      ],
                    ),
                  ],
                ),
              ),

              // --- SECCIÓN QR (Fondo Blanco) ---
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- TARJETA "CÓDIGO ACTIVO" (Captura) ---
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE53935), width: 1)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(backgroundColor: Color(0xFFE53935), radius: 10, child: Icon(Icons.check, color: Colors.white, size: 14)),
                                      const SizedBox(width: 10),
                                      const Text('TU CÓDIGO ESTÁ ACTIVO', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  const Divider(height: 20, color: Colors.black12),
                                  const Text('Mantenlo visible para el acceso. ¡Diviértete!', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          // --- FOTO PERFIL REDONDA CON BORDE ROJO PISANDO EL BORDE ---
                          _buildOverlappingProfileImage(),
                        ],
                      ),

                      const Spacer(),

                      // --- SECCIÓN QR Y TIMER (Captura) ---
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey<String>(_currentQrData),
                          padding: const EdgeInsets.all(10),
                          color: Colors.white,
                          child: QrImageView(
                            data: _currentQrData,
                            version: QrVersions.auto,
                            size: 280.0, // Grande exacto
                            foregroundColor: Colors.black, // QR Negro sobre fondo blanco
                            backgroundColor: Colors.white,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Barrita de estado final
                      const Text('Validez: ACTIVO', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Caduca en: ', style: TextStyle(color: Colors.black54, fontSize: 16)),
                          // Timer rojo grande y bold exacto
                          Text('$_secondsLeft s', style: TextStyle(color: const Color(0xFFE53935), fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        ],
                      ),

                      const Spacer(flex: 2),

                      // Botón "¿No funciona?" con borde rojo (Captura)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE53935)),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: _generateNewCode,
                          child: const Text('¿No funciona? Generar otro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  // Widget complejo para la foto de perfil que pisa el borde de la cabecera roja
  Widget _buildOverlappingProfileImage() {
    return Positioned(
      // Este Stack pisa la cabecera roja, no podemos usar Column directo
      top: 130, // Posicionado para que la mitad esté arriba y la mitad abajo
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE53935), width: 1.5)),
        child: const CircleAvatar(radius: 40, backgroundColor: Color(0xFF1E1E1E), child: Icon(Icons.person, color: Colors.white54, size: 40)),
      ),
    );
  }
}