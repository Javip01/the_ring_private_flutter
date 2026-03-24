import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsPaused = false;

  void _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = (user?.email == null || user!.email!.contains('thering.local')) ? "No vinculado" : user.email!;

    return Scaffold(
      backgroundColor: Colors.black, // Color fondo ajustes
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABECERA (Marco Rojo y Guantes) ---
              Container(
                margin: const EdgeInsets.only(bottom: 24), // ¡CORREGIDO AQUÍ!
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFD31010), Color(0xFF8A0000), Color(0xFF4A0000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ajustes', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.home, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Icon(Icons.sports_mma, size: 80, color: Colors.white54), // Placeholder Guantes
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // --- TARJETA DE PERFIL RÁPIDO ---
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 30, backgroundColor: Color(0xFF2A2A2A), child: Icon(Icons.person, color: Colors.white, size: 30)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.displayName ?? 'Socio', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(userEmail, style: TextStyle(color: userEmail == "No vinculado" ? const Color(0xFFFF4C4C) : const Color(0xFFCCCCCC), fontSize: 14)),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit, color: Color(0xFF888888)),
                    ],
                  ),
                ),
              ),

              // --- SECCIÓN 1: CONFIGURACIÓN ---
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('CONFIGURACIÓN', style: TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildSettingsRow(Icons.lock, 'Cambiar Contraseña', onTap: () {}),
                    const Divider(height: 1, color: Color(0xFF2A2A2A), indent: 56),
                    _buildSettingsRow(Icons.notifications_off, 'Pausar notificaciones', trailing: Switch(
                      value: _notificationsPaused,
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFFA30000),
                      onChanged: (val) => setState(() => _notificationsPaused = val),
                    )),
                  ],
                ),
              ),

              // --- SECCIÓN 2: LEGAL ---
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('INFORMACIÓN Y LEGAL', style: TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildSettingsRow(Icons.description, 'Términos y Condiciones', onTap: () {}),
                    const Divider(height: 1, color: Color(0xFF2A2A2A), indent: 56),
                    _buildSettingsRow(Icons.info, 'Aviso Legal', onTap: () {}),
                    const Divider(height: 1, color: Color(0xFF2A2A2A), indent: 56),
                    _buildSettingsRow(Icons.help, 'Ayuda y Soporte', onTap: () {}),
                    const Divider(height: 1, color: Color(0xFF2A2A2A), indent: 56),
                    _buildSettingsRow(Icons.search, 'Preguntas Frecuentes (FAQ)', onTap: () {}),
                  ],
                ),
              ),

              // --- SECCIÓN 3: ACCIONES ---
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('ACCIONES', style: TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildSettingsRow(Icons.power_settings_new, 'Cerrar Sesión', onTap: _cerrarSesion),
                    const Divider(height: 1, color: Color(0xFF2A2A2A), indent: 56),
                    _buildSettingsRow(Icons.delete_forever, 'Eliminar Cuenta', textColor: const Color(0xFFFF4C4C), iconColor: const Color(0xFFFF4C4C), onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String text, {Color textColor = Colors.white, Color iconColor = Colors.white, Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: 16, fontWeight: textColor == Colors.white ? FontWeight.normal : FontWeight.bold))),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}