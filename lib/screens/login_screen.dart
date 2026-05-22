import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // NECESARIO PARA COMPROBAR EL CORREO EN LA BD
import 'register_screen.dart';
import 'home_screen.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Variables para los errores visuales en línea (borde y texto rojo)
  String? _emailError;
  String? _passwordError;

  Future<void> _login(bool isEng) async {
    // 1. Limpiamos errores previos al intentar entrar
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    bool hasError = false;

    // 2. Comprobamos campos obligatorios vacíos
    if (email.isEmpty) {
      setState(() => _emailError = isEng ? 'Required field' : 'Campo obligatorio');
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = isEng ? 'Required field' : 'Campo obligatorio');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      // 3. COMPROBACIÓN DEL CORREO EN LA BASE DE DATOS
      final snapshot = await FirebaseDatabase.instance.ref("usuarios").get();
      bool existeEnBD = false;

      if (snapshot.exists) {
        final usersMap = snapshot.value as Map<dynamic, dynamic>;
        usersMap.forEach((key, value) {
          if (value is Map && value['email']?.toString().trim().toLowerCase() == email.toLowerCase()) {
            existeEnBD = true;
          }
        });
      }

      // 4. Si el correo no existe, mostramos el error SOLO en el correo y cortamos el proceso
      if (!existeEnBD) {
        setState(() {
          _emailError = isEng ? 'This email does not exist in the app.' : 'Este correo no existe en la app.';
          _isLoading = false;
        });
        return;
      }

      // 5. EL CORREO EXISTE -> Intentamos iniciar sesión con la contraseña
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // 6. SI FALLA EL AUTH, COMO SABEMOS QUE EL CORREO EXISTE, EL ERROR ES LA CONTRASEÑA
      setState(() {
        _passwordError = isEng ? 'Incorrect password' : 'Contraseña incorrecta';
      });
    } catch (e) {
      setState(() {
        _emailError = isEng ? 'An unexpected error occurred' : 'Ocurrió un error inesperado';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

  // --- POPUP RECUPERAR CONTRASEÑA ---
  void _mostrarDialogoRecuperarPassword(bool isEng, bool isDark) {
    final _recuperarEmailController = TextEditingController();
    final bgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

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
              Text(isEng ? 'Recover Password' : 'Recuperar contraseña', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                isEng ? 'Enter your email to receive a recovery link.' : 'Introduce tu correo para recibir un enlace de recuperación.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _recuperarEmailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: isEng ? 'Email' : 'Correo electrónico',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA30000),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      onPressed: () async {
                        String email = _recuperarEmailController.text.trim();
                        if (email.isEmpty) return;

                        Navigator.pop(context); // Cerramos el cuadro de texto de inmediato

                        try {
                          // 1. Comprobamos si el correo existe físicamente en la Realtime Database
                          final snapshot = await FirebaseDatabase.instance.ref("usuarios").get();
                          bool existeEnBD = false;

                          if (snapshot.exists) {
                            final usersMap = snapshot.value as Map<dynamic, dynamic>;
                            usersMap.forEach((key, value) {
                              if (value is Map && value['email']?.toString().trim().toLowerCase() == email.toLowerCase()) {
                                existeEnBD = true;
                              }
                            });
                          }

                          // 2. Si no existe en la base de datos, mostramos el pop-up de error solicitado
                          if (!existeEnBD) {
                            if (mounted) {
                              _mostrarDialogoMensaje(
                                  isEng ? 'Error' : 'Error',
                                  isEng ? 'The email $email does not exist in the application.' : 'El correo $email no existe en la app.',
                                  isDark
                              );
                            }
                            return; // Detenemos la ejecución aquí
                          }

                          // 3. Si el correo sí existe, procedemos a enviar el enlace de recuperación oficial
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

                          if (mounted) {
                            _mostrarDialogoMensaje(
                                isEng ? 'Email Sent' : 'Correo Enviado',
                                isEng ? 'An email has just been sent to your account $email with the information to follow for the password change.' : 'Se acaba de enviar un correo a tu cuenta $email con la información a seguir para el cambio de contraseña.',
                                isDark
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(isEng ? 'Error processing request.' : 'Error al procesar la solicitud.'),
                                backgroundColor: const Color(0xFFA30000)
                            ));
                          }
                        }
                      },
                      child: Text(isEng ? 'Send' : 'Enviar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                                    decoration: BoxDecoration(color: !isEng ? const Color(0xFFA30000).withOpacity(0.1) : Colors.transparent, borderRadius: const BorderRadius.all(Radius.circular(12))),
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
                                    decoration: BoxDecoration(color: isEng ? const Color(0xFFA30000).withOpacity(0.1) : Colors.transparent, borderRadius: const BorderRadius.all(Radius.circular(12))),
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

  // --- POPUP MANUAL ---
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
                  Expanded(child: Text(isEng ? 'User Manual' : 'Manual de Usuario', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor))),
                  IconButton(icon: Icon(Icons.close, color: Colors.grey[500]), onPressed: () => Navigator.pop(context))
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
          TextSpan(text: '3. Soporte\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: 'Si tienes un problema técnico, contacta por email en: '),
          TextSpan(text: 'theringprivate@gmail.com\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
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
          TextSpan(text: '3. Support\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: 'If you have a technical problem, contact us by email at: '),
          TextSpan(text: 'theringprivate@gmail.com\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Card(
                              margin: const EdgeInsets.only(top: 50),
                              elevation: isDarkMode ? 0 : 10,
                              shadowColor: Colors.black26,
                              color: cardBgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(24)),
                                side: isDarkMode ? const BorderSide(color: Color(0xFF2A2A2A)) : BorderSide.none,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(isEng ? 'Welcome' : 'Bienvenido', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(isEng ? 'Sign in to continue' : 'Inicia sesión para continuar', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                                    const SizedBox(height: 32),

                                    // Campo Email
                                    TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(color: textColor),
                                      onChanged: (_) {
                                        if (_emailError != null) setState(() => _emailError = null);
                                      },
                                      decoration: InputDecoration(
                                        hintText: isEng ? 'Email' : 'Correo electrónico',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        filled: true,
                                        fillColor: cardBgColor,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        errorText: _emailError,
                                        errorStyle: const TextStyle(color: Color(0xFFFF4C4C), fontWeight: FontWeight.bold),
                                        enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: borderColor)),
                                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: const BorderSide(color: Color(0xFFA30000), width: 2)),
                                        errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: const BorderSide(color: Color(0xFFFF4C4C), width: 2)),
                                        focusedErrorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: const BorderSide(color: Color(0xFFFF4C4C), width: 2)),
                                        prefixIcon: Icon(Icons.email, color: _emailError != null ? const Color(0xFFFF4C4C) : Colors.grey[500]),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Campo Contraseña
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      style: TextStyle(color: textColor),
                                      onChanged: (_) {
                                        if (_passwordError != null) setState(() => _passwordError = null);
                                      },
                                      decoration: InputDecoration(
                                        hintText: isEng ? 'Password' : 'Contraseña',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        filled: true,
                                        fillColor: cardBgColor,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        errorText: _passwordError,
                                        errorStyle: const TextStyle(color: Color(0xFFFF4C4C), fontWeight: FontWeight.bold),
                                        enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: borderColor)),
                                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: const BorderSide(color: Color(0xFFA30000), width: 2)),
                                        errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: const BorderSide(color: Color(0xFFFF4C4C), width: 2)),
                                        focusedErrorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: const BorderSide(color: Color(0xFFFF4C4C), width: 2)),
                                        prefixIcon: Icon(Icons.lock, color: _passwordError != null ? const Color(0xFFFF4C4C) : Colors.grey[500]),
                                        suffixIcon: IconButton(
                                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey[500]),
                                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                        ),
                                      ),
                                    ),

                                    // Botón ¿Olvidaste tu contraseña?
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => _mostrarDialogoRecuperarPassword(isEng, isDarkMode),
                                        child: Text(
                                          isEng ? 'Forgot your password?' : '¿Olvidaste tu contraseña?',
                                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Botón de Inicio de Sesión
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFA30000),
                                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                            elevation: 4,
                                            shadowColor: const Color(0xFFA30000).withOpacity(0.5)
                                        ),
                                        onPressed: _isLoading ? null : () => _login(isEng),
                                        child: _isLoading
                                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                            : Text(isEng ? 'LOGIN' : 'INICIAR SESIÓN', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Botón para ir al Registro
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                                      },
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(text: isEng ? "Don't have an account? " : '¿No tienes cuenta? ', style: TextStyle(color: Colors.grey[500])),
                                            TextSpan(text: isEng ? 'Register' : 'Regístrate', style: const TextStyle(color: Color(0xFFA30000), fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // FILA INFERIOR: IDIOMA Y MANUAL
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: _mostrarDialogoIdioma,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.translate, color: Color(0xFFA30000), size: 18),
                                              const SizedBox(width: 6),
                                              Text(isEng ? '🇬🇧 EN' : '🇪🇸 ES', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        Container(width: 1, height: 20, color: borderColor),
                                        InkWell(
                                          onTap: _mostrarManual,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.menu_book, color: Colors.grey, size: 18),
                                              const SizedBox(width: 6),
                                              Text(isEng ? 'Manual' : 'Manual', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: -10,
                              child: Image.asset(logoPath, width: 150, height: 100, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50)),
                            ),
                          ],
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
}