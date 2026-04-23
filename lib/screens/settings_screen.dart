import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'tarifas_screen.dart';
import '../main.dart'; // Para controlar Idioma y Tema

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  void _mostrarDialogoPassword() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEng ? 'Change Password' : 'Cambiar Contraseña', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(isEng ? 'Enter your new password (Min 6 chars).' : 'Introduce tu nueva contraseña (Mínimo 6 caracteres).', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: isEng ? 'New password' : 'Nueva contraseña',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFA30000))),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(isEng ? 'Cancel' : 'Cancelar', style: const TextStyle(color: Colors.grey)))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000)),
                      onPressed: () => Navigator.pop(context),
                      child: Text(isEng ? 'Update' : 'Actualizar', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete, color: Color(0xFFFF4C4C), size: 48),
              const SizedBox(height: 16),
              Text(isEng ? 'Delete Account' : 'Eliminar cuenta', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(isEng ? 'Verify your identity to proceed.' : 'Para proceder, verifica tu identidad.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: isEng ? 'Email or DNI' : 'Correo o DNI',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFFF4C4C))),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(isEng ? 'Cancel' : 'Cancelar', style: const TextStyle(color: Colors.grey)))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4C4C)),
                      onPressed: () => Navigator.pop(context),
                      child: Text(isEng ? 'DELETE' : 'ELIMINAR', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarBottomSheetLegal(String titulo, String contenido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SingleChildScrollView(
                child: Text(contenido, style: const TextStyle(fontSize: 16, height: 1.4)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA30000),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('CERRAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera Roja
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFA30000),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEng ? 'Settings' : 'Ajustes', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.home, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // AQUÍ ESTÁN LOS GUANTES SUSTITUYENDO AL PUÑO
                  Image.asset(
                    'lib/assets/guantes.png',
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_mma, size: 80, color: Colors.white54),
                  ),
                ],
              ),
            ),

            // Tarjeta Perfil
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 24),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                title: Text(user?.displayName ?? 'Socio', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                subtitle: Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
                trailing: const Icon(Icons.edit, color: Colors.grey),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              ),
            ),

            Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(isEng ? 'CONFIGURATION' : 'CONFIGURACIÓN', style: const TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold))),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _buildRow(Icons.lock, isEng ? 'Change Password' : 'Cambiar Contraseña', onTap: _mostrarDialogoPassword),
                  const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                  _buildRow(Icons.language, isEng ? 'Language (Switch to ES)' : 'Idioma (Cambiar a EN)', onTap: () {
                    setState(() {
                      TheRingPrivateApp.isEnglishNotifier.value = !isEng;
                    });
                  }),
                  const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                  _buildRow(isDark ? Icons.light_mode : Icons.dark_mode, isEng ? 'Appearance (Toggle)' : 'Apariencia (Modo Claro/Oscuro)', onTap: () {
                    setState(() {
                      TheRingPrivateApp.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                    });
                  }),
                ],
              ),
            ),

            Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(isEng ? 'LEGAL & INFO' : 'INFORMACIÓN LEGAL', style: const TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold))),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _buildRow(Icons.today, isEng ? 'Tariffs' : 'Tarifas', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TarifasScreen()));
                  }),
                  const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                  _buildRow(Icons.sort_by_alpha, isEng ? 'Terms and Conditions' : 'Términos y condiciones', onTap: () {
                    _mostrarBottomSheetLegal(isEng ? 'Terms' : 'Términos y condiciones', 'Aquí va el texto legal de los términos de uso del club The Ring Private...');
                  }),
                  const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                  _buildRow(Icons.info_outline, isEng ? 'Legal Notice' : 'Aviso Legal', onTap: () {
                    _mostrarBottomSheetLegal(isEng ? 'Legal Notice' : 'Aviso Legal', 'Aquí va la información fiscal y legal de la empresa responsable de The Ring...');
                  }),
                  const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                  _buildRow(Icons.help_outline, isEng ? 'Help & Support' : 'Ayuda y Soporte', onTap: () {
                    _mostrarBottomSheetLegal(isEng ? 'Support' : 'Soporte', 'Contacta con nosotros en soporte@thering.local para cualquier duda.');
                  }),
                ],
              ),
            ),

            Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(isEng ? 'ACTIONS' : 'ACCIONES', style: const TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold))),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  _buildRow(Icons.power_settings_new, isEng ? 'Log out' : 'Cerrar Sesión', onTap: () => _cerrarSesion(context)),
                  const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                  _buildRow(Icons.delete, isEng ? 'Delete Account' : 'Eliminar Cuenta', isDestructive: true, onTap: _mostrarDialogoEliminar),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String text, {bool isDestructive = false, VoidCallback? onTap}) {
    Color color = isDestructive ? const Color(0xFFFF4C4C) : Theme.of(context).textTheme.bodyLarge!.color!;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
