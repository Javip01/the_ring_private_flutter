import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = (user?.email == null || user!.email!.contains('thering.local')) ? "No vinculado" : user.email!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABECERA GRADIENTE PERFIL ---
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4A0000), Color(0xFFA30000), Color(0xFFFF4500)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(23),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 27),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFFCCCCCC)), onPressed: () => Navigator.pop(context)),
                          const Expanded(child: Center(child: Text('Mi Perfil', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)))),
                          const SizedBox(width: 48), // Balance
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Avatar anidado para el borde rojo
                          Container(
                            width: 114, height: 114,
                            decoration: const BoxDecoration(color: Color(0xFFA30000), shape: BoxShape.circle),
                            child: Center(
                              child: Container(
                                width: 110, height: 110,
                                decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
                                child: const Icon(Icons.person, color: Colors.white, size: 50),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.displayName ?? 'Socio', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                const Text('SOCI@', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), // Aquí iría el DNI
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- DATOS PÚBLICOS ---
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('DATOS PÚBLICOS (Visibles en el chat)', style: TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Apodo:', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
                          SizedBox(height: 4),
                          Text('Socio_123', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.edit, color: Color(0xFFA30000)), onPressed: () {}),
                  ],
                ),
              ),

              // --- CREDENCIALES PRIVADAS ---
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('CREDENCIALES PRIVADAS', style: TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Correo Electrónico:', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(userEmail, style: const TextStyle(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.edit, color: Color(0xFFA30000)), onPressed: () {}),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF2A2A2A), indent: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Contraseña:', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
                                SizedBox(height: 4),
                                Text('••••••••••••', style: TextStyle(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.edit, color: Color(0xFFA30000)), onPressed: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}