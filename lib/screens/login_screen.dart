import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Añadido
import 'dart:async';
import 'register_screen.dart';
import 'home_screen.dart'; // Añadido para poder navegar

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  int _colorIndex = 0;
  final List<List<Color>> _auroraColors = [
    [const Color(0xFF000000), const Color(0xFF110000), const Color(0xFF4D0000)],
    [const Color(0xFF110000), const Color(0xFF4D0000), const Color(0xFF110000)],
    [const Color(0xFF4D0000), const Color(0xFF110000), const Color(0xFF000000)],
    [const Color(0xFF110000), const Color(0xFF330000), const Color(0xFF110000)],
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) setState(() => _colorIndex = (_colorIndex + 1) % _auroraColors.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      String userInput = _userController.text.trim();
      String password = _passwordController.text.trim();
      String loginEmail = "";

      // Si tiene '@', es correo. Si no, es DNI.
      if (userInput.contains('@')) {
        loginEmail = userInput;
      } else {
        String dni = userInput.toUpperCase();

        // --- AQUÍ ESTÁ EL PUNTO CRÍTICO ---
        final snapshot = await FirebaseDatabase.instance.ref("MapeoDNI").child(dni).get();

        if (snapshot.exists) {
          loginEmail = snapshot.value.toString();
        } else {
          loginEmail = '${dni.toLowerCase()}@thering.local';
        }
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

    } catch (e) {
      // ¡AHORA EL ERROR NOS DIRÁ LA VERDAD!
      print("ERROR DETALLADO: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error real: $e'), // Te mostrará si es "Permission Denied" o "User not found"
            backgroundColor: const Color(0xFFA30000),
            duration: const Duration(seconds: 5), // Lo dejamos más tiempo para que puedas leerlo
          )
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoRecuperacion() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1111),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFA30000), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Recuperar contraseña', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Introduce el correo electrónico vinculado a tu cuenta.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 24),
                _buildRingInput(emailController, 'Correo Electrónico', false),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      onPressed: () async {
                        if (emailController.text.contains('@')) {
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace enviado. Revisa tu bandeja.'), backgroundColor: Colors.green));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar. Comprueba el correo.'), backgroundColor: Color(0xFFA30000)));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Introduce un correo válido.'), backgroundColor: Color(0xFFA30000)));
                        }
                      },
                      child: const Text('ENVIAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 4),
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: _auroraColors[_colorIndex]),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(bottom: 32, child: Text('? FAQ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1111),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6))],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRingInput(_userController, 'DNI / Correo', false),
                            const SizedBox(height: 16),
                            _buildRingInput(_passwordController, 'Contraseña', true),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _mostrarDialogoRecuperacion,
                                child: const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Olvidé la contraseña', style: TextStyle(color: Color(0xFFCCCCCC), fontWeight: FontWeight.bold))),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                onPressed: _isLoading ? null : _signIn,
                                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('INICIAR SESIÓN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                              child: const Padding(padding: EdgeInsets.all(8.0), child: Text('¿No tienes cuenta? Regístrate', style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 15, fontWeight: FontWeight.bold))),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 160, height: 100,
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFA30000), width: 2)),
                          child: const Center(child: Icon(Icons.whatshot, color: Color(0xFFA30000), size: 50)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRingInput(TextEditingController controller, String hint, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
        filled: true,
        fillColor: const Color(0xFF2A1C1C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFA30000))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFA30000), width: 2)),
      ),
    );
  }
}