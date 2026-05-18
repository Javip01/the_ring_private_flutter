import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'tarifas_screen.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _deletePasswordController = TextEditingController();
  bool _isDeleting = false;

  void _cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  // --- SOLUCIÓN AL CORREO EN iOS ---
  void _abrirGmailContacto() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'theringprivate@gmail.com',
    );
    try {
      // Usamos launchUrl directo sin validarlo con canLaunchUrl, para evitar bloqueos del sistema en iOS
      await launchUrl(emailUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se pudo abrir tu app de correo. Escríbenos a theringprivate@gmail.com"))
        );
      }
    }
  }

  // --- POPUP CONTRASEÑA CON REAUTENTICACIÓN ---
  void _mostrarDialogoPassword() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;

    final _oldPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    bool _isUpdating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isEng ? 'Change Password' : 'Cambiar Contraseña', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _oldPasswordController,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: isEng ? 'Current password' : 'Contraseña actual',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide.none),
                          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide(color: Color(0xFFA30000))),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: isEng ? 'New password' : 'Nueva contraseña',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide.none),
                          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide(color: Color(0xFFA30000))),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: isEng ? 'Confirm new password' : 'Confirmar nueva contraseña',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide.none),
                          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide(color: Color(0xFFA30000))),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null && user.email != null) {
                              Navigator.pop(context);
                              try {
                                await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Recovery email sent.' : 'Correo de recuperación enviado.'), backgroundColor: Colors.green));
                              } catch (e) {
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Error sending email.' : 'Error al enviar el correo.'), backgroundColor: const Color(0xFFA30000)));
                              }
                            }
                          },
                          child: Text(isEng ? 'Forgot your password?' : '¿Olvidaste tu contraseña?', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(isEng ? 'Cancel' : 'Cancelar', style: const TextStyle(color: Colors.grey)))),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                              onPressed: _isUpdating ? null : () async {
                                String oldPass = _oldPasswordController.text.trim();
                                String newPass = _newPasswordController.text.trim();
                                String confirmPass = _confirmPasswordController.text.trim();

                                if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Fill in all fields.' : 'Rellena todos los campos.'), backgroundColor: const Color(0xFFA30000)));
                                  return;
                                }

                                if (newPass != confirmPass) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'New passwords do not match.' : 'Las nuevas contraseñas no coinciden.'), backgroundColor: const Color(0xFFA30000)));
                                  return;
                                }

                                bool hasMinLength = newPass.length >= 6;
                                bool hasUppercase = newPass.contains(RegExp(r'[A-Z]'));
                                bool hasSpecialChar = newPass.contains(RegExp(r'[^a-zA-Z0-9]'));

                                if (!hasMinLength || !hasUppercase || !hasSpecialChar) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'New password must have 6 chars, 1 uppercase and 1 special char.' : 'La nueva contraseña debe tener 6 caracteres, 1 mayúscula y 1 símbolo.'), backgroundColor: const Color(0xFFA30000)));
                                  return;
                                }

                                setStateModal(() => _isUpdating = true);

                                try {
                                  User? user = FirebaseAuth.instance.currentUser;
                                  if (user != null && user.email != null) {
                                    AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: oldPass);
                                    await user.reauthenticateWithCredential(credential);
                                    await user.updatePassword(newPass);

                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Password updated successfully!' : '¡Contraseña actualizada con éxito!'), backgroundColor: Colors.green));
                                    }
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (mounted) {
                                    if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Incorrect current password.' : 'La contraseña actual es incorrecta.'), backgroundColor: const Color(0xFFA30000)));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Error updating password.' : 'Error al actualizar contraseña.'), backgroundColor: const Color(0xFFA30000)));
                                    }
                                  }
                                } finally {
                                  if (mounted) setStateModal(() => _isUpdating = false);
                                }
                              },
                              child: _isUpdating
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(isEng ? 'Update' : 'Actualizar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  // --- POPUP IDIOMA ---
  void _mostrarDialogoIdioma() {
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<ThemeMode>(
          valueListenable: TheRingPrivateApp.themeNotifier,
          builder: (context, currentTheme, _) {
            return ValueListenableBuilder<bool>(
                valueListenable: TheRingPrivateApp.isEnglishNotifier,
                builder: (context, isEng, _) {
                  bool isDark = currentTheme == ThemeMode.dark;

                  return Dialog(
                    backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.translate, color: Color(0xFFA30000), size: 20),
                                  const SizedBox(width: 8),
                                  Text(isEng ? 'LANGUAGE' : 'IDIOMA', style: const TextStyle(color: Color(0xFFA30000), fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              IconButton(icon: Icon(Icons.close, color: Colors.grey[500]), onPressed: () => Navigator.pop(context))
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => TheRingPrivateApp.isEnglishNotifier.value = false,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !isEng ? const Color(0xFFA30000).withOpacity(0.1) : Colors.transparent,
                                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: Center(child: Text('🇪🇸 ES', style: TextStyle(color: !isEng ? const Color(0xFFA30000) : (isDark ? Colors.white : Colors.black), fontSize: 16, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ),
                              Container(height: 30, width: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                              Expanded(
                                child: InkWell(
                                  onTap: () => TheRingPrivateApp.isEnglishNotifier.value = true,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isEng ? const Color(0xFFA30000).withOpacity(0.1) : Colors.transparent,
                                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: Center(child: Text('🇬🇧 EN', style: TextStyle(color: isEng ? const Color(0xFFA30000) : (isDark ? Colors.white : Colors.black), fontSize: 16, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }
            );
          }
      ),
    );
  }

  // --- POPUP APARIENCIA ---
  void _mostrarDialogoApariencia() {
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<ThemeMode>(
          valueListenable: TheRingPrivateApp.themeNotifier,
          builder: (context, currentTheme, _) {
            return ValueListenableBuilder<bool>(
                valueListenable: TheRingPrivateApp.isEnglishNotifier,
                builder: (context, isEng, _) {
                  bool isDark = currentTheme == ThemeMode.dark;

                  return Dialog(
                    backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.contrast, color: Color(0xFFA30000), size: 20),
                                  const SizedBox(width: 8),
                                  Text(isEng ? 'APPEARANCE' : 'APARIENCIA', style: const TextStyle(color: Color(0xFFA30000), fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              IconButton(icon: Icon(Icons.close, color: Colors.grey[500]), onPressed: () => Navigator.pop(context))
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => TheRingPrivateApp.themeNotifier.value = ThemeMode.light,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !isDark ? const Color(0xFFA30000).withOpacity(0.1) : Colors.transparent,
                                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: Center(child: Text(isEng ? 'Light' : 'Claro', style: TextStyle(color: !isDark ? const Color(0xFFA30000) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ),
                              Container(height: 30, width: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                              Expanded(
                                child: InkWell(
                                  onTap: () => TheRingPrivateApp.themeNotifier.value = ThemeMode.dark,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFFA30000).withOpacity(0.1) : Colors.transparent,
                                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: Center(child: Text(isEng ? 'Dark' : 'Oscuro', style: TextStyle(color: isDark ? const Color(0xFFA30000) : Colors.black, fontSize: 16, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }
            );
          }
      ),
    );
  }

  // --- POPUP ELIMINAR CUENTA ---
  void _mostrarDialogoEliminar() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;
    _deletePasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4C4C), size: 48),
                    const SizedBox(height: 16),
                    Text(isEng ? 'Delete Account' : 'Eliminar cuenta', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                        isEng
                            ? 'Verify your identity to proceed. This action is irreversible.'
                            : 'Introduce tu contraseña para verificar tu identidad. Esta acción es irreversible.',
                        textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _deletePasswordController,
                      obscureText: true,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: isEng ? 'Password' : 'Contraseña',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide.none),
                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide(color: Color(0xFFFF4C4C))),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                            child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(isEng ? 'Cancel' : 'Cancelar', style: const TextStyle(color: Colors.grey))
                            )
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4C4C),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))
                            ),
                            onPressed: _isDeleting ? null : () async {
                              String pass = _deletePasswordController.text.trim();
                              if (pass.isEmpty) return;

                              setStateModal(() => _isDeleting = true);

                              try {
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null && user.email != null) {
                                  AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: pass);
                                  await user.reauthenticateWithCredential(credential);

                                  String safeEmail = user.email!.replaceAll('.', '_');
                                  await FirebaseDatabase.instance.ref("usuarios").child(safeEmail).remove();
                                  await user.delete();

                                  if (mounted) {
                                    Navigator.pop(context);
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Account deleted forever.' : 'Cuenta eliminada para siempre.'), backgroundColor: Colors.green));
                                  }
                                }
                              } on FirebaseAuthException catch (e) {
                                if (mounted) {
                                  if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Incorrect password.' : 'Contraseña incorrecta.'), backgroundColor: const Color(0xFFA30000)));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Error deleting account.' : 'Error al eliminar cuenta.'), backgroundColor: const Color(0xFFA30000)));
                                  }
                                }
                              } finally {
                                if (mounted) setStateModal(() => _isDeleting = false);
                              }
                            },
                            child: _isDeleting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(isEng ? 'DELETE' : 'ELIMINAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  void _mostrarBottomSheetLegal(String titulo, String contenido) {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF9F9F9),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 24, left: 24, right: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(titulo, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold))),
                  IconButton(icon: Icon(Icons.close, color: Colors.grey[500]), onPressed: () => Navigator.pop(context))
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: SingleChildScrollView(
                  child: Text(contenido, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87, fontSize: 15, height: 1.5)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA30000),
                  minimumSize: const Size(double.infinity, 55),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(isEng ? 'ACCEPT' : 'ACEPTAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarManual() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF161616) : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: bgColor,
        insetPadding: const EdgeInsets.all(20),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      isEng ? 'User Manual - The Ring Private' : 'Manual de Usuario - The Ring Private',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[500]),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: isEng ? _buildManualTextEN(textColor) : _buildManualTextES(textColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA30000),
                  minimumSize: const Size(double.infinity, 55),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  elevation: 4,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(isEng ? 'ACCEPT' : 'ACEPTAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualTextES(Color textColor) {
    return Text.rich(
      TextSpan(
        style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
        children: const [
          TextSpan(text: 'Bienvenido a la aplicación oficial de '),
          TextSpan(text: 'The Ring Private', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '. Esta guía explica cada paso para que puedas usar la app sin dudas.\n\n'),
          TextSpan(text: '1. Registro de cuenta\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Pulsa '), TextSpan(text: 'Registrarse', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' en la pantalla inicial.\n'),
          TextSpan(text: '2. Introduce: nombre, apellidos, DNI/NIE/Pasaporte, correo electrónico y contraseña.\n'),
          TextSpan(text: '3. La contraseña debe tener mínimo 6 caracteres, 1 mayúscula y 1 símbolo especial.\n'),
          TextSpan(text: '4. Marca la casilla de aceptación de términos y condiciones.\n'),
          TextSpan(text: '5. Pulsa '), TextSpan(text: 'Registrarse', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' para completar el alta.\n\n'),
          TextSpan(text: '2. Inicio de sesión\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Introduce tu correo o DNI y tu contraseña.\n'),
          TextSpan(text: '2. Pulsa '), TextSpan(text: 'Iniciar sesión', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: '.\n'),
          TextSpan(text: '3. Si olvidaste tu contraseña, pulsa '), TextSpan(text: '¿Olvidaste tu contraseña?', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' y sigue el proceso de recuperación dentro de la app.\n\n'),
          TextSpan(text: '3. Pantalla principal (Home)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: 'En Home verás dos bloques principales:\n'),
          TextSpan(text: '• Notificaciones: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'avisos activos del club.\n'),
          TextSpan(text: '• Botón QR: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'acceso al código identificativo personal.\n\n'),
          TextSpan(text: '4. Uso del código QR\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Pulsa el botón QR desde Home.\n'),
          TextSpan(text: '2. Se abre tu código identificativo para recepción.\n'),
          TextSpan(text: '3. El QR se actualiza automáticamente y cambia al cerrar y volver a abrir la pantalla.\n'),
          TextSpan(text: '4. Muestra el QR en recepción para validar tu acceso.\n\n'),
          TextSpan(text: '5. Notificaciones\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Cada usuario gestiona sus notificaciones de forma independiente.\n'),
          TextSpan(text: '2. Si eliminas una notificación con la cruz, desaparece de tu cuenta.\n'),
          TextSpan(text: '3. Solo volverás a ver nuevas notificaciones publicadas por administración.\n\n'),
          TextSpan(text: '6. Navegación principal\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '• Inicio: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'QR y notificaciones.\n'),
          TextSpan(text: '• Perfil: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'puedes ver tu nombre, tu correo y cambiar tu contraseña.\n'),
          TextSpan(text: '• Normas: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'reglas de obligado cumplimiento.\n'),
          TextSpan(text: '• Ajustes: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'idioma, apariencia, legal y acciones de cuenta.\n\n'),
          TextSpan(text: '7. Ajustes\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: 'Desde Ajustes puedes:\n- Cambiar contraseña.\n- Cambiar idioma (español/inglés).\n- Cambiar apariencia (modo claro/oscuro).\n- Consultar tarifas, términos, aviso legal, ayuda, FAQ y este manual.\n\n'),
          TextSpan(text: '8. Seguridad y cuenta\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '• Cerrar sesión: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'cierra tu sesión en este dispositivo.\n'),
          TextSpan(text: '• Eliminar cuenta: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'elimina tu acceso y datos asociados tras confirmación final. Esta acción es irreversible.\n\n'),
          TextSpan(text: '9. Soporte\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: 'Si tienes un problema técnico, contacta por email en: '),
          TextSpan(text: 'theringprivate@gmail.com\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '--- \n*The Ring Private - Privacidad y Respeto*', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildManualTextEN(Color textColor) {
    return Text.rich(
      TextSpan(
        style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
        children: const [
          TextSpan(text: 'Welcome to the official '),
          TextSpan(text: 'The Ring Private', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' app. This guide explains every step so you can use the app without any doubts.\n\n'),
          TextSpan(text: '1. Account Registration\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Tap '), TextSpan(text: 'Register', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' on the initial screen.\n'),
          TextSpan(text: '2. Enter: name, surnames, ID/Passport, email, and password.\n'),
          TextSpan(text: '3. Password must have a minimum of 6 characters, 1 uppercase, and 1 special symbol.\n'),
          TextSpan(text: '4. Check the terms and conditions acceptance box.\n'),
          TextSpan(text: '5. Tap '), TextSpan(text: 'Register', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' to complete the sign-up.\n\n'),
          TextSpan(text: '2. Login\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Enter your email or ID and your password.\n'),
          TextSpan(text: '2. Tap '), TextSpan(text: 'Login', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: '.\n'),
          TextSpan(text: '3. If you forgot your password, tap '), TextSpan(text: 'Forgot your password?', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' and follow the recovery process.\n\n'),
          TextSpan(text: '3. Main Screen (Home)\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: 'On the Home screen, you will see two main blocks:\n'),
          TextSpan(text: '• Notifications: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'active club notices.\n'),
          TextSpan(text: '• QR Button: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'access to your personal identification code.\n\n'),
          TextSpan(text: '4. Using the QR Code\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Tap the QR button from the Home screen.\n'),
          TextSpan(text: '2. Your identification code for reception opens.\n'),
          TextSpan(text: '3. The QR updates automatically and changes when you close and reopen the screen.\n'),
          TextSpan(text: '4. Show the QR at reception to validate your access.\n\n'),
          TextSpan(text: '5. Notifications\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Each user manages their notifications independently.\n'),
          TextSpan(text: '2. If you delete a notification with the cross, it disappears from your account.\n'),
          TextSpan(text: '3. You will only see new notifications published by administration.\n\n'),
          TextSpan(text: '6. Main Navigation\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '• Home: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'QR and notifications.\n'),
          TextSpan(text: '• Profile: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'view your name, email, and change password.\n'),
          TextSpan(text: '• Rules: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'mandatory rules.\n'),
          TextSpan(text: '• Settings: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'language, appearance, legal, and account actions.\n\n'),
          TextSpan(text: '7. Settings\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: 'From Settings you can:\n- Change password.\n- Change language (Spanish/English).\n- Change appearance (light/dark mode).\n- Check tariffs, terms, legal notice, help, FAQ, and this manual.\n\n'),
          TextSpan(text: '8. Security and Account\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '• Log out: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'close your session on this device.\n'),
          TextSpan(text: '• Delete account: ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'permanently delete your access and associated data. This action is irreversible.\n\n'),
          TextSpan(text: '9. Support\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: 'If you have a technical problem, contact us by email at: '),
          TextSpan(text: 'theringprivate@gmail.com\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '--- \n*The Ring Private - Privacy and Respect*', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // ================= TEXTOS LEGALES Y DE AYUDA =================
  void _abrirTarifas(bool isEng) {
    String titulo = isEng ? 'How to become a member and tariffs' : 'Cómo hacerse socio y tarifas';
    String contenido = isEng
        ? "How to become a member\n1. Go to reception and request membership.\n2. Fill out and sign the form with your real data.\n3. Expressly accept the club's internal rules.\n4. Download the app and complete registration with the same ID document.\n5. The first validation is done in person at reception.\n\nMembership Status\nOnly those who have paid the current fee are considered active members. If the fee expires, membership is suspended until renewed.\n\nAdvantages of being a member\n- Faster access via QR identification.\n- Personal account registration to manage notifications and settings.\n- Use of lockers subject to availability and club conditions.\n- Access to additional benefits at special events, when announced.\n\nCurrent tariffs\nOne-day member:\n- Friday: 15 EUR\n- Saturday: 15 EUR\n\nVIP Fees:\n- VIP Member 1 month: 90 EUR\n- VIP Member 6 months: 250 EUR\n\nTariffs may be updated. In case of change, the current version will be published at reception and in the application."
        : "Cómo hacerse socio\n1. Acude a recepción y solicita el alta de socio.\n2. Rellena y firma la hoja de alta con tus datos reales.\n3. Acepta expresamente las normas internas del club.\n4. Descarga la aplicación y completa tu registro con el mismo documento de identidad.\n5. La primera validación se realiza presencialmente en recepción.\n\nCondición de socio\nSolo se considera socio activo a quien haya abonado la cuota vigente. Si la cuota caduca, la condición de socio queda suspendida hasta la renovación.\n\nVentajas de ser socio\n- Acceso más ágil mediante identificación con QR.\n- Registro de cuenta personal para gestionar notificaciones y ajustes.\n- Uso de taquilla según disponibilidad y condiciones del club.\n- Acceso a ventajas adicionales en eventos especiales, cuando se anuncien.\n\nTarifas vigentes\nSocio por un día:\n- Viernes: 15 EUR\n- Sábado: 15 EUR\n\nCuotas VIP:\n- Socio VIP 1 mes: 90 EUR\n- Socio VIP 6 meses: 250 EUR\n\nLas tarifas pueden actualizarse. En caso de cambio, se publicará la versión vigente en recepción y en la aplicación.";
    _mostrarBottomSheetLegal(titulo, contenido);
  }

  void _abrirTerminos(bool isEng) {
    String titulo = isEng ? 'Terms and Conditions' : 'Términos y Condiciones';
    String contenido = isEng
        ? "These Terms and Conditions regulate the download, access, and use of the THE RING PRIVATE application (hereinafter, the Application). Access and use imply express acceptance of these conditions.\n\n1. Object\nThe Application aims to manage member identification, facilitate internal notices, and improve the club access experience. Its use is personal and non-transferable.\n\n2. User Registration\nTo create an account, the user must provide real and valid data (name, surname, ID, and email). The user is responsible for keeping their password safe and not sharing it.\n\n3. Rules of Use\nThe user agrees to use the Application lawfully and respectfully. It is prohibited to manipulate, copy, decompile, alter, or reuse the Application's content without express authorization.\n\n4. Intellectual Property\nAll intellectual and industrial property rights over the Application belong to THE RING PRIVATE or authorized third parties.\n\n5. Data Protection\nPersonal data will be processed according to the GDPR and current Spanish regulations. The user can exercise their rights of access, rectification, deletion, opposition, limitation, and portability by contacting the entity.\n\n6. Availability and Responsibility\nTHE RING PRIVATE may update, modify, or suspend the Application for technical or legal reasons. Absolute availability is not guaranteed.\n\n7. Account Deletion\nThe user can request account deletion from the settings section. This action eliminates access and associated data in enabled systems, except for legal retention obligations.\n\n8. Applicable Legislation\nThese conditions are governed by Spanish law. Any controversy will be submitted to the competent courts and tribunals of Madrid, unless a mandatory legal provision states otherwise."
        : "Estos Términos y Condiciones regulan la descarga, el acceso y el uso de la aplicación THE RING PRIVATE (en adelante, la Aplicación). El acceso y uso de la Aplicación implica la aceptación expresa de estas condiciones.\n\n1. Objeto\nLa Aplicación tiene como finalidad gestionar la identificación de socios, facilitar la comunicación de avisos internos y mejorar la experiencia de acceso al club. Su uso es personal e intransferible.\n\n2. Registro de usuario\nPara crear una cuenta, el usuario debe facilitar datos reales y vigentes (nombre, apellidos, documento de identidad y correo electrónico). El usuario es responsable de custodiar su contraseña y de no compartirla con terceros.\n\n3. Normas de uso\nEl usuario se compromete a utilizar la Aplicación de forma lícita, respetuosa y conforme a la normativa aplicable. Queda prohibido manipular, copiar, descompilar, alterar o reutilizar el contenido de la Aplicación sin autorización expresa.\n\n4. Propiedad intelectual\nTodos los derechos de propiedad intelectual e industrial sobre la Aplicación, su diseño, textos, marcas y elementos gráficos pertenecen a THE RING PRIVATE o a terceros autorizados.\n\n5. Protección de datos\nLos datos personales se tratarán conforme al Reglamento (UE) 2016/679 (RGPD) y la normativa española vigente. El tratamiento se realiza para gestionar la relación con el socio y el funcionamiento de la Aplicación. El usuario puede ejercer sus derechos de acceso, rectificación, supresión, oposición, limitación y portabilidad mediante contacto con la entidad.\n\n6. Disponibilidad y responsabilidad\nTHE RING PRIVATE podrá actualizar, modificar o suspender la Aplicación por motivos técnicos, legales o de mantenimiento. Aunque se aplican medidas de seguridad, no se garantiza la disponibilidad absoluta ni la ausencia total de errores técnicos.\n\n7. Baja y eliminación de cuenta\nEl usuario puede solicitar la eliminación de su cuenta desde la sección de ajustes. Esta acción elimina el acceso y los datos asociados en los sistemas habilitados, salvo obligación legal de conservación.\n\n8. Legislación aplicable\nEstas condiciones se rigen por la legislación española. Cualquier controversia se someterá a los juzgados y tribunales competentes de Madrid, salvo disposición legal imperativa en contrario.";
    _mostrarBottomSheetLegal(titulo, contenido);
  }

  void _abrirAvisoLegal(bool isEng) {
    String titulo = isEng ? 'Legal Notice' : 'Aviso legal';
    String contenido = isEng
        ? "1. Identification of the controller\nThe data controller is THE RING PRIVATE.\nAddress: C. del Amparo, 75, Centro, 28012 Madrid.\nContact email: ringasociacion@gmail.com\n\n2. Processed data\nWe process the necessary data to manage your registration and your access as a member: name, surnames, email and identity document.\n\n3. Purpose\nThe main purpose is to manage the relationship with the member, their access to the club and internal service communications.\n\n4. Legal basis\nThe legal basis of the processing is the consent of the user and the execution of the associative relationship.\n\n5. Retention\nThe data will be kept as long as there is an active relationship with the member or during the applicable legal periods.\n\n6. Rights\nYou can exercise your rights of access, rectification, deletion, opposition, limitation and portability upon request to the contact email.\n\n7. Security\nWe apply reasonable technical and organizational measures to prevent unauthorized access, loss or alteration of data.\n\n8. Changes to the legal notice\nThis notice may be updated due to regulatory changes or service improvements. The current version will always be available in the application.\n\nDate of last update: 17/04/2026"
        : "1. Identificación del responsable\nEl responsable del tratamiento es THE RING PRIVATE.\nDirección: C. del Amparo, 75, Centro, 28012 Madrid.\nCorreo de contacto: ringasociacion@gmail.com\n\n2. Datos tratados\nTratamos los datos necesarios para gestionar tu alta y tu acceso como socio: nombre, apellidos, correo electrónico y documento de identidad.\n\n3. Finalidad\nLa finalidad principal es gestionar la relación con el socio, su acceso al club y las comunicaciones internas de servicio.\n\n4. Base jurídica\nLa base legal del tratamiento es el consentimiento del usuario y la ejecución de la relación asociativa.\n\n5. Conservación\nLos datos se conservarán mientras exista relación activa con el socio o durante los plazos legales aplicables.\n\n6. Derechos\nPuedes ejercer tus derechos de acceso, rectificación, supresión, oposición, limitación y portabilidad mediante solicitud al correo de contacto.\n\n7. Seguridad\nAplicamos medidas técnicas y organizativas razonables para prevenir accesos no autorizados, pérdida o alteración de datos.\n\n8. Cambios en el aviso legal\nEste aviso puede actualizarse por cambios normativos o mejoras del servicio. La versión vigente estará siempre disponible en la aplicación.\n\nFecha de última actualización: 17/04/2026";
    _mostrarBottomSheetLegal(titulo, contenido);
  }

  void _abrirAyuda(bool isEng) {
    String titulo = isEng ? 'Help and Support' : 'Ayuda y soporte';
    String contenido = isEng
        ? "If you have a problem with the application, follow this order:\n\n1. Check the Frequently Asked Questions (FAQ) section first.\n2. If not resolved, write to ringasociacion@gmail.com indicating:\n- Account email\n- ID used in registration\n- Mobile model\n- OS Version\n- Exact description of the error\n\nSupport via email:\nringasociacion@gmail.com\n\nOfficial networks:\nFacebook: https://www.facebook.com/theringprivate\nInstagram: https://www.instagram.com/theringprivate\n\nIn-person assistance:\nC. del Amparo, 75, Centro, 28012 Madrid"
        : "Si tienes un problema con la aplicación, sigue este orden:\n\n1. Revisa primero la sección de Preguntas Frecuentes.\n2. Si no se resuelve, escribe a ringasociacion@gmail.com indicando:\n- Correo de tu cuenta\n- DNI usado en el registro\n- Modelo de móvil\n- Versión de Android/iOS\n- Descripción exacta del error\n\nSoporte por correo:\nringasociacion@gmail.com\n\nRedes oficiales:\nFacebook: https://www.facebook.com/theringprivate\nInstagram: https://www.instagram.com/theringprivate\n\nAtención presencial:\nC. del Amparo, 75, Centro, 28012 Madrid";
    _mostrarBottomSheetLegal(titulo, contenido);
  }

  void _abrirFAQ(bool isEng) {
    String titulo = isEng ? 'Frequently Asked Questions (FAQ)' : 'Preguntas frecuentes (FAQ)';
    String contenido = isEng
        ? "1. How do I register correctly?\nTap Register, fill in your name, surname, ID, email, and a secure password. You must accept the terms and conditions to finish.\n\n2. What documents are valid for registration?\nValid ID, NIE, or Passport are accepted.\n\n3. I forgot my password. What do I do?\nAt login, tap Forgot your password and follow the email recovery process.\n\n4. The QR is not showing. How do I fix it?\nCheck your internet connection, close and reopen the QR screen, and try again. If it persists, log out and log back in.\n\n5. Can I change my personal data?\nSensitive identification data is managed at reception to verify identity.\n\n6. How do I delete my account?\nIn Settings, go to Delete Account, verify your credentials, and confirm final deletion.\n\n7. What happens to my notifications if I delete them?\nIf you delete a notification in your profile, it stops showing in your account. Other users keep their own notifications independently."
        : "1. ¿Cómo me registro correctamente?\nPulsa en Registrarse, completa nombre, apellidos, DNI, correo y una contraseña segura. Debes aceptar los términos y condiciones para finalizar.\n\n2. ¿Qué documentos son válidos para el registro?\nSe aceptan DNI, NIE o pasaporte en vigor.\n\n3. He olvidado mi contraseña. ¿Qué hago?\nEn inicio de sesión, pulsa Olvidaste tu contraseña y sigue el proceso de recuperación por correo.\n\n4. El QR no se muestra. ¿Cómo lo soluciono?\nComprueba conexión a internet, cierra y abre la pantalla QR y vuelve a intentarlo. Si persiste, cierra sesión y entra de nuevo.\n\n5. ¿Puedo cambiar mis datos personales?\nLos datos sensibles de identificación se gestionan en recepción para verificar identidad.\n\n6. ¿Cómo elimino mi cuenta?\nEn Ajustes, entra en Eliminar cuenta, verifica tus credenciales y confirma la eliminación final.\n\n7. ¿Qué pasa con mis notificaciones si las elimino?\nSi eliminas una notificación en tu perfil, deja de mostrarse en tu cuenta. Otros usuarios mantienen sus propias notificaciones de forma independiente.";
    _mostrarBottomSheetLegal(titulo, contenido);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ValueListenableBuilder<ThemeMode>(
        valueListenable: TheRingPrivateApp.themeNotifier,
        builder: (context, currentTheme, _) {
          return ValueListenableBuilder<bool>(
              valueListenable: TheRingPrivateApp.isEnglishNotifier,
              builder: (context, isEng, _) {
                final isDark = currentTheme == ThemeMode.dark;

                final scaffoldBgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F5);
                final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
                final textColor = isDark ? Colors.white : Colors.black;
                final iconColor = isDark ? Colors.white : Colors.black;

                return Scaffold(
                  backgroundColor: scaffoldBgColor,
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFA30000), Color(0xFF4A0000)],
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isEng ? 'SETTINGS' : 'AJUSTES', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                    IconButton(icon: const Icon(Icons.home, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Image.asset(
                                  'lib/assets/guantes.png',
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_mma, size: 80, color: Colors.white),
                                ),
                              ],
                            ),
                          ),

                          Card(
                            elevation: isDark ? 0 : 2,
                            color: cardBgColor,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                            margin: const EdgeInsets.only(bottom: 24),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              title: Text(user?.displayName ?? 'Usuario', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(user?.email ?? '0@0.0', style: const TextStyle(color: Colors.grey)),
                              ),
                              trailing: Icon(Icons.edit, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                            ),
                          ),

                          Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(isEng ? 'CONFIGURATION' : 'CONFIGURACIÓN', style: const TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold))),
                          Card(
                            elevation: isDark ? 0 : 2,
                            color: cardBgColor,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              children: [
                                _buildRow(Icons.lock, isEng ? 'Change password' : 'Cambiar contraseña', iconColor, textColor, onTap: _mostrarDialogoPassword),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.translate, isEng ? 'Change language' : 'Cambiar idioma', iconColor, textColor, onTap: _mostrarDialogoIdioma),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.contrast, isEng ? 'Appearance' : 'Apariencia', iconColor, textColor, onTap: _mostrarDialogoApariencia),
                              ],
                            ),
                          ),

                          Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(isEng ? 'LEGAL INFO' : 'INFORMACIÓN LEGAL', style: const TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold))),
                          Card(
                            elevation: isDark ? 0 : 2,
                            color: cardBgColor,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              children: [
                                _buildRow(Icons.monetization_on, isEng ? 'Tariffs' : 'Tarifas', iconColor, textColor, onTap: () => _abrirTarifas(isEng)),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.description, isEng ? 'Terms and Conditions' : 'Términos y Condiciones', iconColor, textColor, onTap: () => _abrirTerminos(isEng)),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.gavel, isEng ? 'Legal Notice' : 'Aviso legal', iconColor, textColor, onTap: () => _abrirAvisoLegal(isEng)),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.help, isEng ? 'Help' : 'Ayuda', iconColor, textColor, onTap: () => _abrirAyuda(isEng)),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.search, isEng ? 'Frequently Asked Questions' : 'Preguntas frecuentes', iconColor, textColor, onTap: () => _abrirFAQ(isEng)),
                              ],
                            ),
                          ),

                          Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(isEng ? 'ACTIONS' : 'ACCIONES', style: const TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold))),
                          Card(
                            elevation: isDark ? 0 : 2,
                            color: cardBgColor,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                            margin: const EdgeInsets.only(bottom: 40),
                            child: Column(
                              children: [
                                _buildRow(Icons.power_settings_new, isEng ? 'Log out' : 'Cerrar sesión', iconColor, textColor, onTap: () => _cerrarSesion(context)),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.close, isEng ? 'DELETE ACCOUNT' : 'ELIMINAR CUENTA', const Color(0xFFFF4C4C), const Color(0xFFFF4C4C), isDestructive: true, onTap: _mostrarDialogoEliminar),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.menu_book, isEng ? 'User Manual' : 'Manual de usuario', iconColor, textColor, onTap: () => _mostrarManual()),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.mail_outline, 'Contacto: theringprivate@gmail.com', const Color(0xFFA30000), textColor, onTap: _abrirGmailContacto),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  Widget _buildRow(IconData icon, String text, Color iconColor, Color textColor, {bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: 16, fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal))),
            Icon(Icons.chevron_right, color: Colors.grey[500], size: 18),
          ],
        ),
      ),
    );
  }
}