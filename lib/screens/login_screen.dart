import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'home_screen.dart'; // <- ESTO ES VITAL PARA QUE SEPA A DÓNDE IR
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

  Future<void> _login(bool isEng) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEng ? 'Fill in all fields' : 'Rellena todos los campos'),
        backgroundColor: const Color(0xFFA30000),
      ));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Iniciamos sesión en la base de datos
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. ¡SOLUCIÓN! Navegación forzada al Home tras un inicio de sesión exitoso
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false, // Esto borra el login del historial
        );
      }

    } on FirebaseAuthException catch (e) {
      String errorMsg = isEng ? 'Invalid credentials' : 'Usuario o contraseña incorrectos';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-email') {
        errorMsg = isEng ? 'Invalid credentials' : 'Usuario o contraseña incorrectos';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFA30000),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEng ? 'An error occurred' : 'Ocurrió un error inesperado'),
          backgroundColor: const Color(0xFFA30000),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                                    Text(
                                      isEng ? 'Welcome' : 'Bienvenido',
                                      style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isEng ? 'Sign in to continue' : 'Inicia sesión para continuar',
                                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                    ),
                                    const SizedBox(height: 32),

                                    // Campo Email
                                    TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(color: textColor),
                                      decoration: InputDecoration(
                                        hintText: isEng ? 'Email' : 'Correo electrónico',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        filled: true,
                                        fillColor: cardBgColor,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: borderColor)),
                                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: const BorderSide(color: Color(0xFFA30000), width: 2)),
                                        prefixIcon: Icon(Icons.email, color: Colors.grey[500]),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Campo Contraseña
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      style: TextStyle(color: textColor),
                                      decoration: InputDecoration(
                                        hintText: isEng ? 'Password' : 'Contraseña',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        filled: true,
                                        fillColor: cardBgColor,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: borderColor)),
                                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: const BorderSide(color: Color(0xFFA30000), width: 2)),
                                        prefixIcon: Icon(Icons.lock, color: Colors.grey[500]),
                                        suffixIcon: IconButton(
                                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey[500]),
                                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),

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
                              ),
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