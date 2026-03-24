import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'dart:ui';

import 'settings_screen.dart';
import 'profile_screen.dart';
import 'news_screen.dart';
import 'global_chat_screen.dart';
import 'staff_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRulesExpanded = false;

  // --- VARIABLES PARA EL QR OVERLAY ---
  bool _isQrVisible = false;
  String _currentQrData = "CARGANDO";
  int _secondsLeft = 15;
  Timer? _qrTimer;

  @override
  void dispose() {
    _qrTimer?.cancel();
    super.dispose();
  }

  void _iniciarGeneracionQR() {
    setState(() => _isQrVisible = true);
    _generarNuevoQR();
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 1) {
            _secondsLeft--;
          } else {
            _generarNuevoQR();
          }
        });
      }
    });
  }

  void _generarNuevoQR() {
    final user = FirebaseAuth.instance.currentUser;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _currentQrData = "${user?.uid ?? 'SOCIO'}_$timestamp";
      _secondsLeft = 15;
    });
  }

  void _cerrarQR() {
    _qrTimer?.cancel();
    setState(() => _isQrVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ==========================================
          // CAPA 1: CONTENIDO PRINCIPAL DE LA HOME
          // ==========================================
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                // --- CABECERA SUPERIOR ---
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 40, 16, 18),
                      height: 240,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(24),
                        // Aquí iría tu imagen: image: DecorationImage(image: AssetImage('assets/the_ring_private_menu.png'), fit: BoxFit.cover),
                      ),
                      child: const Center(child: Text('FOTO CABECERA', style: TextStyle(color: Colors.white38))),
                    ),
                    // BOTÓN AJUSTES
                    Positioned(
                      top: 40,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white, size: 30),
                        onPressed: () => Navigator.push(context, _crearRutaAnimada(const SettingsScreen())),
                      ),
                    ),
                  ],
                ),

                // --- CUADRÍCULA 2x2 ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      // BOTÓN PERFIL
                      _buildGridButton('Perfil', Icons.person, () => Navigator.push(context, _crearRutaAnimada(const ProfileScreen()))),

                      // BOTÓN NOTICIAS
                      _buildGridButton('Tablón Noticias', Icons.notifications_active, () => Navigator.push(context, _crearRutaAnimada(const NewsScreen())), badge: 'NUEVO'),

                      // BOTÓN GLOBAL
                      _buildGridButton('Chat Global', Icons.public, () => Navigator.push(context, _crearRutaAnimada(const GlobalChatScreen()))),

                      // BOTÓN STAFF
                      _buildGridButton('Chat STAFF', Icons.support_agent, () => Navigator.push(context, _crearRutaAnimada(const StaffChatScreen()))),
                    ],
                  ),
                ),

                // --- NORMAS DEL CLUB ---
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      onExpansionChanged: (expanded) => setState(() => _isRulesExpanded = expanded),
                      tilePadding: const EdgeInsets.all(16),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('NORMAS DEL CLUB', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Debes leer las normas antes de empezar.', style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 13)),
                        ],
                      ),
                      trailing: Icon(_isRulesExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFFA30000), size: 30),
                      children: [
                        Container(height: 1, color: const Color(0xFF424242), margin: const EdgeInsets.symmetric(horizontal: 16)),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildRuleCard('#1A1A1A', 'Te comprometes a cumplir estas normas. En beneficio de todos, se advierte que cualquier transgresión se considerará una falta MUY GRAVE y será motivo de expulsión.'),
                              const SizedBox(height: 12),
                              _buildRuleCard('#660000', '1. Nuestra norma principal es el RESPETO.\n\n2. No puedes formar parte de un juego iniciado por otro/os si este/os no quiere/en\n\n3. No está permitida ninguna actitud irrespetuosa.\n\n4. Prohibido el uso de teléfonos o cámaras.\n\n5. Prohibido scat, sangre, o dolor extremo.\n\n6. Prohibida la venta o consumo de drogas.', isBold: true),
                              const SizedBox(height: 12),
                              _buildRuleCard('#1A1A1A', 'El club THE RING PRIVATE recomienda el sexo seguro. Hay distribuidores de preservativos gratuitos por todo el local.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- BOTONES FLOTANTES (Cámara y QR) ---
          Positioned(
            left: 20,
            bottom: 30,
            child: FloatingActionButton(
              heroTag: 'scan',
              backgroundColor: const Color(0xFF2A2A2A),
              onPressed: () {},
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 30,
            child: FloatingActionButton(
              heroTag: 'qr',
              backgroundColor: const Color(0xFFA30000),
              onPressed: _iniciarGeneracionQR,
              child: const Icon(Icons.qr_code, color: Colors.white, size: 30),
            ),
          ),

          // ==========================================
          // CAPA 2: EL OVERLAY DEL QR (TIPO BOTTOM SHEET)
          // ==========================================
          if (_isQrVisible)
            GestureDetector(
              onTap: _cerrarQR,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10 * value, sigmaY: 10 * value),
                    child: Container(
                      color: Colors.black.withOpacity(0.85 * value),
                      child: child,
                    ),
                  );
                },
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF444444), borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 24),
                          const Text('Acceso Seguro Dinámico', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Este código caduca cada 15 segundos', style: TextStyle(color: Color(0xFFFF4C4C), fontSize: 14)),
                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: QrImageView(
                                key: ValueKey(_currentQrData),
                                data: _currentQrData,
                                version: QrVersions.auto,
                                size: 220.0,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('$_secondsLeft s', style: const TextStyle(color: Color(0xFFA30000), fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          const SizedBox(height: 16),

                          const Text(
                            'El QR cambia automáticamente.\nLos QR dejarán de funcionar pasados estos 15 segundos o al cerrar esta ventana.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: _cerrarQR,
                              child: const Text('CERRAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridButton(String title, IconData icon, VoidCallback onTap, {String? badge}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)]),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            if (badge != null)
              Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFFA30000), shape: BoxShape.circle), child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(String hexColor, String text, {bool isBold = false}) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Color(int.parse(hexColor.replaceFirst('#', '0xFF'))), borderRadius: BorderRadius.circular(8)), child: Text(text, style: TextStyle(color: isBold ? Colors.white : const Color(0xFFE0E0E0), fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, height: 1.3)));
  }

  Route _crearRutaAnimada(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}