import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco para leer bien
      appBar: AppBar(
        title: const Text('NORMAS DEL CLUB', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(25.0),
        children: [
          const Text('BIENVENIDO A THE RING', style: TextStyle(color: Color(0xFFE53935), fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildRuleItem('1. Derecho de Admisión', 'El club se reserva el derecho de admisión en todo momento. La membresía no garantiza el acceso si se incumple el código de vestimenta o comportamiento.'),
          _buildRuleItem('2. Código de Vestimenta', 'Se requiere vestimenta elegante. No se permite ropa deportiva, gorras, ni calzado abierto en el caso de los caballeros.'),
          _buildRuleItem('3. Uso del QR', 'El código QR es personal e intransferible. Cualquier intento de cesión o captura de pantalla resultará en la suspensión inmediata de la cuenta.'),
          _buildRuleItem('4. Privacidad', 'Total prohibición de grabar vídeos o tomar fotografías a otros socios sin su consentimiento explícito.'),
          _buildRuleItem('5. Pagos y Membresía', 'La cuota se renueva automáticamente el día 1 de cada mes. Las cancelaciones deben notificarse con 15 días de antelación.'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}