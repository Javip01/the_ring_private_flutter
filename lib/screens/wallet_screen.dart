import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MI CAJA'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Saldo Premium
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD50000), Color(0xFF8E0000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: const Color(0xFFD50000).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('SALDO ACTUAL', style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 2)),
                  SizedBox(height: 10),
                  Text('1,250.00 €', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text('**** **** **** 4092', style: TextStyle(color: Colors.white54, fontSize: 18, letterSpacing: 4)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text('ÚLTIMOS MOVIMIENTOS', style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 2)),
            const SizedBox(height: 15),

            // Lista de movimientos de prueba
            Expanded(
              child: ListView(
                children: [
                  _buildTransaction('Reserva Mesa VIP', 'Hoy, 22:30', '-150.00 €', true),
                  _buildTransaction('Recarga de Saldo', 'Ayer, 18:00', '+500.00 €', false),
                  _buildTransaction('Consumición Barra', '15 Mar, 02:15', '-24.00 €', true),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTransaction(String title, String date, String amount, bool isNegative) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF151515),
        child: Icon(isNegative ? Icons.arrow_upward : Icons.arrow_downward, color: isNegative ? Colors.white : const Color(0xFFD50000)),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(date, style: const TextStyle(color: Colors.white54)),
      trailing: Text(amount, style: TextStyle(color: isNegative ? Colors.white : const Color(0xFFD50000), fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}