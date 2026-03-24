import 'package:flutter/material.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MEMBRESÍA', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de Estado
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: const [
                  Icon(Icons.verified, color: Color(0xFFE53935), size: 60),
                  SizedBox(height: 15),
                  Text('SUSCRIPCIÓN ACTIVA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  SizedBox(height: 5),
                  Text('Socio VIP - The Ring', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Detalles
            const Text('DETALLES DE FACTURACIÓN', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, letterSpacing: 1)),
            const Divider(color: Colors.black26),
            const SizedBox(height: 10),

            _buildDetailRow('Mes de Facturación:', 'Marzo 2026'),
            _buildDetailRow('Válido hasta:', '01/04/2026'),
            _buildDetailRow('Precio Mensual:', '50.00 €'),
            _buildDetailRow('Próximo Cobro:', '01 de Abril de 2026'),
            _buildDetailRow('Método de pago:', 'Visa terminada en 4092'),

            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE53935),
                  side: const BorderSide(color: Color(0xFFE53935)),
                  padding: const EdgeInsets.symmetric(vertical: 15)
              ),
              onPressed: () {},
              child: const Text('GESTIONAR SUSCRIPCIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}