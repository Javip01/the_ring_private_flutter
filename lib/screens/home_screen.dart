import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math' as math;
import 'settings_screen.dart';
import 'profile_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _currentQrData = "CARGANDO";
  int _secondsLeft = 60;
  Timer? _qrTimer;

  final GlobalKey _qrButtonKey = GlobalKey();
  final double _qrRadius = 35.0; // Un poco más grande como en la captura

  final ValueNotifier<Offset?> _waPositionNotifier = ValueNotifier(null);
  final double _waDiameter = 60.0;
  final double _repulsionAuraPadding = 30.0;
  Offset _dragOffset = Offset.zero;

  late AnimationController _menuController;
  late Animation<double> _menuAnimation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _menuAnimation = CurvedAnimation(parent: _menuController, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_waPositionNotifier.value == null) {
      final size = MediaQuery.of(context).size;
      if (size.width > 0) {
        _waPositionNotifier.value = Offset(
            size.width - _waDiameter - 20,
            size.height - _waDiameter - 120
        );
      }
    }
  }

  @override
  void dispose() {
    _menuController.dispose();
    _qrTimer?.cancel();
    super.dispose();
  }

  void _abrirWhatsApp() async {
    const String telefono = "34123456789";
    final Uri url = Uri.parse("https://wa.me/$telefono?text=Hola, necesito asistencia.");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No se pudo abrir WhatsApp")));
    }
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _menuController.reverse().then((_) => setState(() => _isMenuOpen = false));
    } else {
      setState(() => _isMenuOpen = true);
      _menuController.forward();
    }
  }

  Widget _buildMenuContent() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: TheRingPrivateApp.themeNotifier,
      builder: (context, currentTheme, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: TheRingPrivateApp.isEnglishNotifier,
          builder: (context, isEng, _) {
            final isDark = currentTheme == ThemeMode.dark;
            final bgColor = isDark ? const Color(0xFF161616) : Colors.white;
            final textColor = isDark ? Colors.white : Colors.black87;

            return Material(
              color: bgColor,
              elevation: 15,
              shadowColor: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 260,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [
                        const Icon(Icons.language, color: Color(0xFFA30000), size: 20),
                        const SizedBox(width: 8),
                        Text(isEng ? 'Language' : 'Idioma', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                      ]),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildOption(isEng, '🇪🇸 ES', !isEng, () => TheRingPrivateApp.isEnglishNotifier.value = false),
                          const SizedBox(width: 8),
                          _buildOption(isEng, '🇬🇧 EN', isEng, () => TheRingPrivateApp.isEnglishNotifier.value = true),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(children: [
                        const Icon(Icons.palette, color: Color(0xFFA30000), size: 20),
                        const SizedBox(width: 8),
                        Text(isEng ? 'Appearance' : 'Apariencia', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                      ]),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildOption(isEng, isEng ? 'Light' : 'Claro', currentTheme == ThemeMode.light, () => TheRingPrivateApp.themeNotifier.value = ThemeMode.light),
                          const SizedBox(width: 8),
                          _buildOption(isEng, isEng ? 'Dark' : 'Oscuro', currentTheme == ThemeMode.dark, () => TheRingPrivateApp.themeNotifier.value = ThemeMode.dark),
                        ],
                      ),
                      const Divider(height: 32),
                      InkWell(
                        onTap: () {
                          _toggleMenu();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.settings, color: Color(0xFFA30000), size: 20),
                              const SizedBox(width: 8),
                              Text(isEng ? 'MORE OPTIONS' : 'MÁS OPCIONES', style: const TextStyle(color: Color(0xFFA30000), fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: isActive ? const Color(0xFFA30000).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isActive ? const Color(0xFFA30000).withOpacity(0.3) : Colors.transparent)
          ),
          child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? const Color(0xFFA30000) : Colors.grey))),
        ),
      ),
    );
  }

  void _mostrarBottomSheetQR() {
    _generarNuevoQR();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateModal) {
          _qrTimer?.cancel();
          _qrTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (mounted) setStateModal(() { if (_secondsLeft > 1) _secondsLeft--; else _generarNuevoQR(); });
          });
          bool isEng = TheRingPrivateApp.isEnglishNotifier.value;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
                  top: 24.0, left: 24.0, right: 24.0
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF444444), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  Text(isEng ? 'Dynamic Secure Access' : 'Acceso Seguro Dinámico', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(isEng ? 'This code expires in 1 minute' : 'Este código caduca en 1 minuto', style: const TextStyle(color: Color(0xFFFF4C4C), fontSize: 14)),
                  const SizedBox(height: 24),
                  Card(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16.0), child: QrImageView(data: _currentQrData, size: 250.0))),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                    onPressed: () { _qrTimer?.cancel(); Navigator.pop(context); },
                    child: Text(isEng ? 'CLOSE' : 'CERRAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          );
        });
      },
    ).then((_) => _qrTimer?.cancel());
  }

  void _generarNuevoQR() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentQrData = "${user?.uid ?? 'SOCIO'}_${DateTime.now().millisecondsSinceEpoch}";
      _secondsLeft = 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color rojoRing = Color(0xFFA30000);
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    final size = MediaQuery.of(context).size;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // COLORES EXACTOS CAPTURA HOME (NEGRO PURO, SIN VIOLETA)
    final scaffoldBgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F5);
    final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final String logoPath = isDark
        ? 'lib/assets/logo_the_ring_transparente.png'
        : 'lib/assets/logo_the_ring_transparente_negro.png';

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER THE RING
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('THE RING', style: TextStyle(color: rojoRing, fontWeight: FontWeight.bold, fontSize: 20)),
                        IconButton(icon: const Icon(Icons.menu, color: rojoRing, size: 30), onPressed: _toggleMenu)
                      ],
                    ),
                  ),

                  // CONTENEDOR LOGO ESTILO CAPTURA (GRADIENTE SUAVE EN CLARO, GRIS SÓLIDO EN OSCURO)
                  Container(
                    height: 220,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161616) : null,
                      gradient: isDark ? null : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE8E8E8), Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                        logoPath,
                        height: 160,
                        fit: BoxFit.contain,
                        errorBuilder: (_,__,___) => Icon(Icons.image, color: isDark ? Colors.white : Colors.black, size: 50)
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SECCIÓN NOTIFICACIONES
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(isEng ? 'NOTIFICATIONS' : 'NOTIFICACIONES', style: const TextStyle(color: rojoRing, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    elevation: isDark ? 0 : 4,
                    shadowColor: Colors.black26,
                    color: cardBgColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                        height: 110,
                        alignment: Alignment.center,
                        child: Text(
                            isEng ? 'No pending notifications' : 'No tienes notificaciones pendientes',
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 15)
                        )
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BOTONES PERFIL Y NORMAS (CUADRADOS)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(child: _buildHomeSquareButton(isEng ? 'PROFILE' : 'PERFIL', Icons.person, cardBgColor, textColor, isDark, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())))),
                        Expanded(child: _buildHomeSquareButton(isEng ? 'RULES' : 'NORMAS', Icons.assignment, cardBgColor, textColor, isDark, () {})),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTÓN QR CENTRAL ROJO
          Positioned(
            bottom: 40,
            left: (size.width / 2) - _qrRadius,
            child: SizedBox(
              width: _qrRadius * 2,
              height: _qrRadius * 2,
              child: FloatingActionButton(
                key: _qrButtonKey,
                heroTag: 'btn_qr_central',
                backgroundColor: rojoRing,
                elevation: 8,
                shape: const CircleBorder(),
                onPressed: _mostrarBottomSheetQR,
                child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 38),
              ),
            ),
          ),

          // BOTÓN WHATSAPP
          ValueListenableBuilder<Offset?>(
            valueListenable: _waPositionNotifier,
            builder: (context, position, child) {
              if (position == null) return const SizedBox.shrink();

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 50),
                curve: Curves.easeOut,
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onTap: _abrirWhatsApp,
                  onPanStart: (details) => _dragOffset = details.localPosition,
                  onPanUpdate: (details) {
                    double newX = details.globalPosition.dx - _dragOffset.dx;
                    double newY = details.globalPosition.dy - _dragOffset.dy;

                    newX = newX.clamp(0.0, size.width - _waDiameter);
                    newY = newY.clamp(0.0, size.height - _waDiameter);

                    RenderBox? qrBox = _qrButtonKey.currentContext?.findRenderObject() as RenderBox?;
                    if (qrBox != null && qrBox.hasSize) {
                      Offset qrGlobalPos = qrBox.localToGlobal(Offset.zero);
                      double qrCenterX = qrGlobalPos.dx + qrBox.size.width / 2;
                      double qrCenterY = qrGlobalPos.dy + qrBox.size.height / 2;

                      double waCenterX = newX + _waDiameter / 2;
                      double waCenterY = newY + _waDiameter / 2;

                      double dist = math.sqrt(math.pow(waCenterX - qrCenterX, 2) + math.pow(waCenterY - qrCenterY, 2));
                      double minSafe = _qrRadius + (_waDiameter / 2) + _repulsionAuraPadding;

                      if (dist < minSafe) {
                        double angle = math.atan2(waCenterY - qrCenterY, waCenterX - qrCenterX);
                        newX = qrCenterX + minSafe * math.cos(angle) - _waDiameter / 2;
                        newY = qrCenterY + minSafe * math.sin(angle) - _waDiameter / 2;

                        newX = newX.clamp(0.0, size.width - _waDiameter);
                        newY = newY.clamp(0.0, size.height - _waDiameter);
                      }
                    }

                    _waPositionNotifier.value = Offset(newX, newY);
                  },
                  child: child,
                ),
              );
            },
            child: SizedBox(
              width: _waDiameter,
              height: _waDiameter,
              child: Image.asset(
                'lib/assets/WhatsApp_icon.png',
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stackTrace) => Container(
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.chat, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),

          // MENÚ DESPLEGABLE OVERLAY
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleMenu,
                child: Container(),
              ),
            ),

          Positioned(
            top: 90,
            right: 16,
            child: IgnorePointer(
              ignoring: !_isMenuOpen,
              child: FadeTransition(
                opacity: _menuAnimation,
                child: ScaleTransition(
                  scale: _menuAnimation,
                  alignment: Alignment.topRight,
                  child: _buildMenuContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeSquareButton(String title, IconData icon, Color bgColor, Color textColor, bool isDark, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: bgColor,
      elevation: isDark ? 0 : 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 140, // Más cuadrado como en la captura
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 45, color: textColor),
              const SizedBox(height: 16),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}