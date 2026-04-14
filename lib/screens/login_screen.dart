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

  // BOTTOM SHEET DE AJUSTES EN LOGIN (SIN EL BOTÓN DE "MÁS OPCIONES")
  void _mostrarDropdownAjustes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: TheRingPrivateApp.themeNotifier,
          builder: (context, currentTheme, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: TheRingPrivateApp.isEnglishNotifier,
              builder: (context, isEng, _) {
                final bgColor = currentTheme == ThemeMode.dark ? const Color(0xFF1E1E1E) : Colors.white;
                final textColor = currentTheme == ThemeMode.dark ? Colors.white : Colors.black87;

                return Container(
                  decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SECCIÓN IDIOMA
                      Row(
                        children: [
                          const Icon(Icons.language, color: Color(0xFFA30000)),
                          const SizedBox(width: 8),
                          Text(isEng ? 'Language' : 'Idioma', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildOption(isEng, '🇪🇸 ESPAÑOL', !isEng, () => TheRingPrivateApp.isEnglishNotifier.value = false),
                          _buildOption(isEng, '🇬🇧 ENGLISH', isEng, () => TheRingPrivateApp.isEnglishNotifier.value = true),
                        ],
                      ),
                      const Divider(height: 32),
                      // SECCIÓN APARIENCIA
                      Row(
                        children: [
                          const Icon(Icons.palette, color: Color(0xFFA30000)),
                          const SizedBox(width: 8),
                          Text(isEng ? 'Appearance' : 'Apariencia', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildOption(isEng, isEng ? 'Light' : 'Claro', currentTheme == ThemeMode.light, () => TheRingPrivateApp.themeNotifier.value = ThemeMode.light),
                          _buildOption(isEng, isEng ? 'Dark' : 'Oscuro', currentTheme == ThemeMode.dark, () => TheRingPrivateApp.themeNotifier.value = ThemeMode.dark),
                        ],
                      ),
                      const SizedBox(height: 20), // Pequeño espacio al final
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOption(bool isEng, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFA30000).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? const Color(0xFFA30000) : Colors.grey))),
        ),
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
                final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
                final textColor = isDarkMode ? Colors.white : Colors.black87;

                return Scaffold(
                  backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 120),
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              Card(
                                margin: const EdgeInsets.only(top: 50, bottom: 40),
                                elevation: 12, color: cardBgColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildInput(_userController, isEng ? 'User or DNI' : 'Usuario o DNI', false, textColor),
                                      const SizedBox(height: 8),
                                      _buildInput(_passwordController, isEng ? 'Password' : 'Contraseña', true, textColor),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000), minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                        onPressed: _isLoading ? null : () => _signIn(isEng),
                                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEng ? 'LOGIN' : 'INICIAR SESIÓN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(height: 24),
                                      Center(child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())), child: Text(isEng ? 'No account? Register' : '¿No tienes cuenta? Regístrate', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))),
                                      const SizedBox(height: 20),
                                      InkWell(
                                        onTap: _mostrarDropdownAjustes,
                                        child: Padding(padding: const EdgeInsets.all(8.0), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.language, color: Colors.grey, size: 20), const SizedBox(width: 8), Text(isEng ? '🇬🇧 EN / THEME' : '🇪🇸 ES / TEMA', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))])),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(top: 0, child: Image.asset('assets/images/logo.png', width: 160, height: 100, errorBuilder: (context, error, stackTrace) => Container(width: 160, height: 100, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.image, color: Colors.white)))),
                            ],
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

  Widget _buildInput(TextEditingController controller, String hint, bool isPassword, Color textColor) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFA30000))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFA30000), width: 2)),
        suffixIcon: isPassword ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) : null,
      ),
    );
  }
}