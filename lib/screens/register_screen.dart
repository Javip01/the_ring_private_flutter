import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _aceptaTerminos = false;

  Future<void> _register(bool isEng) async {
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'You must accept the terms and conditions' : 'Debes aceptar los términos y condiciones'), backgroundColor: const Color(0xFFA30000)));
      return;
    }

    String nombre = _nombreController.text.trim();
    String dni = _dniController.text.trim().toUpperCase();
    String correo = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (nombre.isEmpty || dni.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Fill in all mandatory fields' : 'Rellena los campos obligatorios'), backgroundColor: const Color(0xFFA30000)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String signupEmail = correo.isNotEmpty ? correo : '${dni.toLowerCase()}@thering.local';
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: signupEmail, password: password);
      await cred.user?.updateDisplayName(nombre);
      await FirebaseDatabase.instance.ref("MapeoDNI").child(dni).set(signupEmail);
      await FirebaseDatabase.instance.ref("Usuarios").child(signupEmail.replaceAll('.', '_')).child("perfil").set({
        "nombreReal": nombre,
        "dni": dni,
        "correo": correo,
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Error. DNI or Email might exist.' : 'Error al crear cuenta. Quizás el DNI o correo ya existen.'), backgroundColor: const Color(0xFFA30000)));
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
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Card(
                              margin: const EdgeInsets.only(top: 50, bottom: 20),
                              elevation: isDarkMode ? 0 : 10,
                              shadowColor: Colors.black26,
                              color: cardBgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: isDarkMode ? const BorderSide(color: Color(0xFF2A2A2A)) : BorderSide.none,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
                                        Expanded(child: Center(child: Text(isEng ? 'Create Account' : 'Crea tu cuenta', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)))),
                                        const SizedBox(width: 48),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    _buildRingInput(_nombreController, isEng ? 'Name' : 'Nombre', false, textColor, borderColor, cardBgColor),
                                    const SizedBox(height: 16),
                                    _buildRingInput(_apellidosController, isEng ? 'Surnames' : 'Apellidos', false, textColor, borderColor, cardBgColor),
                                    const SizedBox(height: 16),
                                    _buildRingInput(_dniController, isEng ? 'ID/Passport' : 'DNI', false, textColor, borderColor, cardBgColor),
                                    const SizedBox(height: 16),
                                    _buildRingInput(_emailController, isEng ? 'Email' : 'Correo Electrónico', false, textColor, borderColor, cardBgColor),
                                    const SizedBox(height: 16),
                                    _buildRingInput(_passwordController, isEng ? 'Password' : 'Contraseña', true, textColor, borderColor, cardBgColor),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _aceptaTerminos,
                                          activeColor: const Color(0xFFA30000),
                                          onChanged: (val) => setState(() => _aceptaTerminos = val!),
                                        ),
                                        Expanded(child: Text(isEng ? 'I accept terms and conditions' : 'Acepto los términos y condiciones', style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFA30000),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                            elevation: 4,
                                            shadowColor: const Color(0xFFA30000).withOpacity(0.5)
                                        ),
                                        onPressed: _isLoading ? null : () => _register(isEng),
                                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEng ? 'REGISTER' : 'REGISTRARSE', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Text(isEng ? 'Already have an account? Login' : '¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
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

  Widget _buildRingInput(TextEditingController controller, String hint, bool isPassword, Color textColor, Color borderColor, Color fillColor) {
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
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFA30000), width: 2)),
        suffixIcon: isPassword ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) : null,
      ),
    );
  }
}