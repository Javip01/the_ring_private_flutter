import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Negro absoluto
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // --- TÍTULO BLANCO EXACTO ---
              const Text(
                'THE RING',
                style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const Text(
                'PRIVATE CLUB',
                style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 4),
              ),
              const Spacer(flex: 1),
              // --- ICONO PUÑO/ANILLO (Captura) ---
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.whatshot, size: 80, color: Colors.white), // Usamos fuego como placeholder del anillo
              ),
              const Spacer(flex: 3),

              // --- BOTONES INFERIORES (HOLA blanco, ENTRAR rojo) ---
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        icon: const Icon(Icons.close), // Icono X de HOLA
                        label: const Text('HOLA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935), // Rojo captura
                          elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                        child: const Text('ENTRAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}