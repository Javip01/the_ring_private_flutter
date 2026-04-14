import 'package:flutter/material.dart';
import '../main.dart'; // Para el idioma

class TarifasScreen extends StatelessWidget {
  const TarifasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    const Color rojoRing = Color(0xFFA30000);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isEng ? 'TARIFFS & MEMBERSHIP' : 'TARIFAS Y MEMBRESÍA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta Premium
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [rojoRing, Color(0xFF5A0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 50),
                  const SizedBox(height: 16),
                  Text(isEng ? 'VIP PASS - THE RING' : 'PASE VIP - THE RING', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text(isEng ? 'Active Subscription' : 'Suscripción Activa', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 24),
                  const Text('50.00 € / mes', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Text(isEng ? 'BILLING DETAILS' : 'DETALLES DE FACTURACIÓN', style: const TextStyle(color: rojoRing, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const Divider(height: 30),

            _buildDetailRow(isEng ? 'Valid until:' : 'Válido hasta:', '01/04/2026', context),
            _buildDetailRow(isEng ? 'Next charge:' : 'Próximo Cobro:', '01/04/2026', context),
            _buildDetailRow(isEng ? 'Payment method:' : 'Método de pago:', 'Visa **** 4092', context),
            _buildDetailRow(isEng ? 'Status:' : 'Estado:', isEng ? 'Verified' : 'Verificado', context),

            const SizedBox(height: 40),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: rojoRing,
                  side: const BorderSide(color: rojoRing, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
              onPressed: () {
                // Aquí abrirías la pasarela de pago o gestión
              },
              child: Text(isEng ? 'MANAGE SUBSCRIPTION' : 'GESTIONAR SUSCRIPCIÓN', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}