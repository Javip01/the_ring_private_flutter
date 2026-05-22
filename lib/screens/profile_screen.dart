import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // --- POPUP INFORMATIVO (ÉXITO O ERROR) ---
  void _mostrarDialogoMensaje(String titulo, String mensaje, bool isDark) {
    final bgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titulo, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(mensaje, style: TextStyle(color: Colors.grey[600], fontSize: 15), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA30000),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(isEng ? 'ACCEPT' : 'ACEPTAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNCIÓN SEGURA Y AVANZADA PARA CAMBIAR CONTRASEÑA ---
  void _mostrarDialogoPassword(BuildContext context, bool isEng, ThemeMode currentTheme) {
    final isDark = currentTheme == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final _oldPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    bool _isUpdating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              backgroundColor: bgColor,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          isEng ? 'Change Password' : 'Cambiar Contraseña',
                          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 16),

                      // CONTRASEÑA ANTIGUA
                      TextField(
                        controller: _oldPasswordController,
                        obscureText: true,
                        style: TextStyle(color: textColor),
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

                      // NUEVA CONTRASEÑA
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        style: TextStyle(color: textColor),
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

                      // CONFIRMAR NUEVA CONTRASEÑA
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: isEng ? 'Confirm new password' : 'Confirmar nueva contraseña',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide.none),
                          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide(color: Color(0xFFA30000))),
                        ),
                      ),

                      // BOTÓN OLVIDÉ MI CONTRASEÑA
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null && user.email != null) {
                              Navigator.pop(context); // Cerramos el dialogo de cambiar contraseña
                              try {
                                // Enviamos directamente el correo de recuperación porque ya sabemos cuál es su email
                                await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                                if (mounted) {
                                  _mostrarDialogoMensaje(
                                      isEng ? 'Email Sent' : 'Correo Enviado',
                                      isEng ? 'An email has just been sent to your account ${user.email} with the information to follow for the password change.' : 'Se acaba de enviar un correo a tu cuenta ${user.email} con la información a seguir para el cambio de contraseña.',
                                      isDark
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Error sending email.' : 'Error al enviar el correo.'), backgroundColor: const Color(0xFFA30000)));
                                }
                              }
                            }
                          },
                          child: Text(isEng ? 'Forgot your password?' : '¿Olvidaste tu contraseña?', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 12),

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
                                  backgroundColor: const Color(0xFFA30000),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))
                              ),
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
                                    // 1. Reautenticar con contraseña antigua
                                    AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: oldPass);
                                    await user.reauthenticateWithCredential(credential);

                                    // 2. Actualizar a la nueva
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? "No vinculado";
    final userName = user?.displayName ?? "Cargando...";

    return ValueListenableBuilder<ThemeMode>(
        valueListenable: TheRingPrivateApp.themeNotifier,
        builder: (context, currentTheme, _) {
          return ValueListenableBuilder<bool>(
              valueListenable: TheRingPrivateApp.isEnglishNotifier,
              builder: (context, isEng, _) {

                final isDarkMode = currentTheme == ThemeMode.dark;
                final scaffoldBgColor = isDarkMode ? const Color(0xFF000000) : const Color(0xFFF5F5F5);
                final cardBgColor = isDarkMode ? const Color(0xFF161616) : Colors.white;
                final textColorPrimary = isDarkMode ? Colors.white : Colors.black87;
                final textColorSecondary = Colors.grey;

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
                            margin: const EdgeInsets.only(bottom: 32),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                                        onPressed: () => Navigator.pop(context)
                                    ),
                                    Expanded(
                                        child: Center(
                                            child: Text(
                                                isEng ? 'MY PROFILE' : 'MI PERFIL',
                                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                                            )
                                        )
                                    ),
                                    const SizedBox(width: 48),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(userName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(isEng ? 'MEMBER' : 'SOCI@', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 8),
                            child: Text(
                                isEng ? 'PRIVATE CREDENTIALS' : 'CREDENCIALES PRIVADAS',
                                style: const TextStyle(color: Color(0xFFA30000), fontSize: 13, fontWeight: FontWeight.bold)
                            ),
                          ),

                          Card(
                            color: cardBgColor,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                            elevation: isDarkMode ? 0 : 2,
                            margin: const EdgeInsets.only(bottom: 40),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  title: Text(isEng ? 'Email' : 'Correo electrónico', style: TextStyle(color: textColorSecondary, fontSize: 14)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(userEmail, style: TextStyle(color: textColorPrimary, fontSize: 16)),
                                  ),
                                ),
                                Divider(
                                    height: 1,
                                    indent: 20,
                                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100]
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  title: Text(isEng ? 'Password' : 'Contraseña', style: TextStyle(color: textColorSecondary, fontSize: 14)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('••••••••••••', style: TextStyle(color: textColorPrimary, fontSize: 16)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFA30000),
                                      minimumSize: const Size(double.infinity, 55),
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                                    ),
                                    onPressed: () => _mostrarDialogoPassword(context, isEng, currentTheme),
                                    child: Text(
                                        isEng ? 'CHANGE PASSWORD' : 'CAMBIAR CONTRASEÑA',
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                )
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
}