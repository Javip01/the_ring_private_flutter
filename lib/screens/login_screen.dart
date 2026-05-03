import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetController = TextEditingController(); // Controlador para recuperar password
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _signIn(bool isEng) async {
    setState(() => _isLoading = true);
    try {
      String userInput = _userController.text.trim();
      String loginEmail = userInput.contains('@') ? userInput : '';
      if (!userInput.contains('@')) {
        final snapshot = await FirebaseDatabase.instance.ref("MapeoDNI").child(userInput.toUpperCase()).get();
        loginEmail = snapshot.exists ? snapshot.value.toString() : '${userInput.toLowerCase()}@thering.local';
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: loginEmail, password: _passwordController.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Error checking credentials' : 'Error en credenciales'), backgroundColor: const Color(0xFFA30000)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- POP-UP PARA RECUPERAR CONTRASEÑA (FUNCIONAL) ---
  void _mostrarDialogoRecuperarPassword() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    _resetController.clear();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEng ? 'Recover Password' : 'Recuperar Contraseña', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(isEng ? 'Enter your email or DNI to receive a reset link.' : 'Introduce tu correo o DNI para recibir un enlace de recuperación.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              TextField(
                controller: _resetController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: isEng ? 'Email or DNI' : 'Correo o DNI',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide.none),
                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide(color: Color(0xFFA30000))),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(isEng ? 'Cancel' : 'Cancelar', style: const TextStyle(color: Colors.grey)))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                      onPressed: () async {
                        String input = _resetController.text.trim();
                        if (input.isEmpty) return;

                        Navigator.pop(context); // Cerramos el dialogo inmediatamente

                        try {
                          String emailToReset = input;
                          // Si es DNI, buscamos el correo asociado
                          if (!input.contains('@')) {
                            final snapshot = await FirebaseDatabase.instance.ref("MapeoDNI").child(input.toUpperCase()).get();
                            emailToReset = snapshot.exists ? snapshot.value.toString() : '${input.toLowerCase()}@thering.local';
                          }

                          await FirebaseAuth.instance.sendPasswordResetEmail(email: emailToReset);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Recovery email sent. Check your inbox.' : 'Correo de recuperación enviado. Revisa tu bandeja.'), backgroundColor: Colors.green));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Error sending recovery email.' : 'Error al enviar correo de recuperación.'), backgroundColor: const Color(0xFFA30000)));
                          }
                        }
                      },
                      child: Text(isEng ? 'SEND' : 'ENVIAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _mostrarDialogoIdioma() {
    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: TheRingPrivateApp.themeNotifier,
          builder: (context, currentTheme, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: TheRingPrivateApp.isEnglishNotifier,
              builder: (context, isEng, _) {
                final isDark = currentTheme == ThemeMode.dark;
                final bgColor = isDark ? const Color(0xFF161616) : Colors.white;
                final textColor = isDark ? Colors.white : Colors.black87;

                return Dialog(
                  backgroundColor: bgColor,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.translate, color: Color(0xFFA30000)),
                                const SizedBox(width: 8),
                                Text('IDIOMA / LANGUAGE', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            IconButton(icon: Icon(Icons.close, color: Colors.grey[500]), onPressed: () => Navigator.pop(context))
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
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
                                  child: Center(child: Text('🇪🇸 ES', style: TextStyle(color: !isEng ? const Color(0xFFA30000) : textColor, fontWeight: FontWeight.bold, fontSize: 16))),
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
                                  child: Center(child: Text('🇬🇧 EN', style: TextStyle(color: isEng ? const Color(0xFFA30000) : textColor, fontWeight: FontWeight.bold, fontSize: 16))),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _mostrarManual() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
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
          TextSpan(text: 'ringasociacion@gmail.com\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
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
          TextSpan(text: 'ringasociacion@gmail.com\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '--- \n*The Ring Private - Privacy and Respect*', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: TheRingPrivateApp.themeNotifier,
        builder: (context, currentTheme, _) {
          return ValueListenableBuilder<bool>(
              valueListenable: TheRingPrivateApp.isEnglishNotifier,
              builder: (context, isEng, _) {
                final isDarkMode = currentTheme == ThemeMode.dark;

                final scaffoldBgColor = isDarkMode ? const Color(0xFF000000) : const Color(0xFFF0F0F0);
                final cardBgColor = isDarkMode ? const Color(0xFF161616) : Colors.white;
                final textColor = isDarkMode ? Colors.white : Colors.black87;
                final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[400]!;

                final String logoPath = isDarkMode
                    ? 'lib/assets/logo_the_ring_transparente.png'
                    : 'lib/assets/logo_the_ring_transparente_negro.png';

                return Scaffold(
                  backgroundColor: scaffoldBgColor,
                  body: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topCenter,
                                children: [
                                  Card(
                                    margin: const EdgeInsets.only(top: 50, bottom: 20),
                                    elevation: isDarkMode ? 0 : 10,
                                    shadowColor: Colors.black26,
                                    color: cardBgColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                                      side: isDarkMode ? const BorderSide(color: Color(0xFF2A2A2A)) : BorderSide.none,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          _buildInput(_userController, isEng ? 'Email or DNI' : 'Correo o DNI', false, textColor, borderColor, cardBgColor),
                                          const SizedBox(height: 16),
                                          _buildInput(_passwordController, isEng ? 'Password' : 'Contraseña', true, textColor, borderColor, cardBgColor),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              // AHORA LLAMA A LA FUNCIÓN DE RECUPERAR
                                              onPressed: _mostrarDialogoRecuperarPassword,
                                              child: Text(isEng ? 'Forgot your password?' : '¿Olvidaste tu contraseña?', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFA30000),
                                                minimumSize: const Size(double.infinity, 55),
                                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                                elevation: 4,
                                                shadowColor: const Color(0xFFA30000).withOpacity(0.5)
                                            ),
                                            onPressed: _isLoading ? null : () => _signIn(isEng),
                                            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEng ? 'LOGIN' : 'INICIAR SESIÓN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                          ),
                                          const SizedBox(height: 30),
                                          Center(
                                              child: GestureDetector(
                                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                                                  child: Text(isEng ? 'No account? Register' : '¿No tienes cuenta? Regístrate', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold))
                                              )
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: _mostrarDialogoIdioma,
                                                child: Row(children: [const Icon(Icons.translate, size: 18), const SizedBox(width: 6), Text(isEng ? 'EN' : 'ES', style: const TextStyle(fontWeight: FontWeight.bold))]),
                                              ),
                                              const SizedBox(width: 40),
                                              InkWell(
                                                onTap: _mostrarManual,
                                                child: const Row(children: [Icon(Icons.menu_book, size: 18), SizedBox(width: 6), Text('Manual', style: TextStyle(fontWeight: FontWeight.bold))]),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      top: -10,
                                      child: Image.asset(
                                          logoPath,
                                          width: 150,
                                          height: 100,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50)
                                      )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, bool isPassword, Color textColor, Color borderColor, Color fillColor) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: borderColor)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: Color(0xFFA30000), width: 2)),
        suffixIcon: isPassword ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) : null,
      ),
    );
  }
}