import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

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

  // Animación Aurora Boreal
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

  Future<void> _register() async {
    String nombre = _nombreController.text.trim();
    String dni = _dniController.text.trim().toUpperCase();
    String correo = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (nombre.isEmpty || dni.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rellena los campos obligatorios'), backgroundColor: Color(0xFFA30000)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String signupEmail = correo.isNotEmpty ? correo : '${dni.toLowerCase()}@thering.local';

      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: signupEmail,
        password: password,
      );

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al crear cuenta. Quizás el DNI o correo ya existen.'), backgroundColor: Color(0xFFA30000)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // LÓGICA DE LOGO DINÁMICO
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String logoPath = isDark
        ? 'lib/assets/logo_the_ring_transparente.png'
        : 'lib/assets/logo_the_ring_transparente_negro.png';

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 4),
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _auroraColors[_colorIndex],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Tarjeta Registro
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
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                            const Expanded(child: Center(child: Text('Crea tu cuenta', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)))),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildRingInput(_nombreController, 'Nombre (Obligatorio)', false),
                        const SizedBox(height: 16),
                        _buildRingInput(_apellidosController, 'Apellidos (Obligatorio)', false),
                        const SizedBox(height: 16),
                        _buildRingInput(_dniController, 'DNI / NIE (Obligatorio)', false),
                        const SizedBox(height: 16),
                        _buildRingInput(_emailController, 'Correo Electrónico (Opcional)', false),
                        const SizedBox(height: 16),
                        _buildRingInput(_passwordController, 'Contraseña (Obligatorio)', true),

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA30000),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: _isLoading ? null : _register,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('REGISTRARSE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // LOGO FLOTANTE SUSTITUYENDO AL ICONO
                  Positioned(
                    top: 0,
                    child: Image.asset(
                      logoPath,
                      width: 160,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50, color: Colors.white)
                    ),
                  ),
                ],
              ),
            ),
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
