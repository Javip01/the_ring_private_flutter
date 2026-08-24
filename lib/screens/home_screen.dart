import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'dart:math' as math;
import 'settings_screen.dart';
import 'profile_screen.dart';
import '../main.dart';

// --- MODELO DE DATOS RESILIENTE ---
class Notificacion {
  String id;
  String titulo;
  String mensaje;
  String tipo;
  int timestamp;
  bool leida;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.timestamp,
    required this.leida,
  });

  factory Notificacion.fromMap(String id, dynamic mapData) {
    if (mapData is! Map) {
      return Notificacion(id: id, titulo: 'Aviso', mensaje: 'Mensaje entrante', tipo: 'alerta', timestamp: DateTime.now().millisecondsSinceEpoch, leida: false);
    }
    Map<dynamic, dynamic> map = mapData as Map<dynamic, dynamic>;
    return Notificacion(
      id: id,
      titulo: map['titulo']?.toString() ?? 'Nueva Notificación',
      mensaje: map['mensaje']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? 'alerta',
      timestamp: int.tryParse(map['timestamp'].toString()) ?? DateTime.now().millisecondsSinceEpoch,
      leida: map['leida'] == true || map['leida'] == 'true',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: "https://laasociacion-57649-default-rtdb.firebaseio.com",
  );

  String _currentQrData = "CARGANDO";
  int _secondsLeft = 900; // 15 minutos por defecto
  Timer? _qrTimer;

  Map<String, dynamic>? _userProfileData;
  String _qrSessionNonce = "";

  // Variables de Notificaciones
  List<Notificacion> _notifGlobales = [];
  List<Notificacion> _notifPersonales = [];
  List<Notificacion> _todasLasNotificaciones = [];
  List<Notificacion> _notificacionesVisibles = [];
  Set<String> _notificacionesEliminadas = {};
  Set<String> _notificacionesLeidas = {};
  bool _isExpanded = false;

  StreamSubscription? _globalSubscription;
  StreamSubscription? _personalSubscription;
  StreamSubscription? _delSubscription;
  StreamSubscription? _leidasSubscription;
  String _emailSafe = "";

  late AnimationController _menuController;
  late Animation<double> _menuAnimation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _configurarEscuchaNotificaciones();
    _configurarPushNotifications();
    _menuController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _menuAnimation = CurvedAnimation(parent: _menuController, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
  }

  // --- CONFIGURACIÓN PUSH ---
  void _configurarPushNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await messaging.subscribeToTopic('notificaciones_globales');
    }
  }

  Future<void> _cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseEvent event = await _db.ref("usuarios").child(user.uid).once();
      if (event.snapshot.exists && mounted) {
        setState(() {
          final data = event.snapshot.value;
          if (data is Map) {
            _userProfileData = Map<String, dynamic>.from(data);
          }
        });
      }
    }
  }

  // --- LÓGICA DE NOTIFICACIONES ---
  void _configurarEscuchaNotificaciones() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _emailSafe = user.email!.replaceAll('.', '_');

      final userRef = _db.ref("Usuarios").child(_emailSafe);
      final globalRef = _db.ref("NotificacionesGlobal");

      _delSubscription = userRef.child("notificacionesEliminadas").onValue.listen((event) {
        Set<String> eliminadasTemp = {};
        final value = event.snapshot.value;
        if (value != null) {
          if (value is Map) {
            eliminadasTemp = value.keys.map((k) => k.toString()).toSet();
          } else if (value is List) {
            for (int i = 0; i < value.length; i++) {
              if (value[i] != null) eliminadasTemp.add(i.toString());
            }
          }
        }
        setState(() {
          _notificacionesEliminadas = eliminadasTemp;
          _actualizarListaCombinada();
        });
      });

      _leidasSubscription = userRef.child("notificacionesLeidas").onValue.listen((event) {
        Set<String> leidasTemp = {};
        final value = event.snapshot.value;
        if (value is Map) {
          leidasTemp = value.keys.map((k) => k.toString()).toSet();
        }
        setState(() {
          _notificacionesLeidas = leidasTemp;
          _actualizarListaCombinada();
        });
      });

      _globalSubscription = globalRef.onValue.listen((event) {
        _notifGlobales = _parseNotificaciones(event.snapshot.value);
        setState(() => _actualizarListaCombinada());
      });

      _personalSubscription = userRef.child("notificaciones").onValue.listen((event) {
        _notifPersonales = _parseNotificaciones(event.snapshot.value);
        setState(() => _actualizarListaCombinada());
      });
    }
  }

  List<Notificacion> _parseNotificaciones(dynamic value) {
    List<Notificacion> temporal = [];
    if (value != null) {
      if (value is Map) {
        value.forEach((key, val) {
          if (val != null) temporal.add(Notificacion.fromMap(key.toString(), val));
        });
      } else if (value is List) {
        for (int i = 0; i < value.length; i++) {
          if (value[i] != null) temporal.add(Notificacion.fromMap(i.toString(), value[i]));
        }
      }
    }
    return temporal;
  }

  void _actualizarListaCombinada() {
    _todasLasNotificaciones = [..._notifGlobales, ..._notifPersonales];

    Map<String, Notificacion> mapaUnicas = {};
    for (var n in _todasLasNotificaciones) {
      if (!_notificacionesEliminadas.contains(n.id)) {
        if (_notificacionesLeidas.contains(n.id)) n.leida = true;
        mapaUnicas[n.id] = n;
      }
    }

    _notificacionesVisibles = mapaUnicas.values.toList();
    _notificacionesVisibles.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _mostrarDetalleNotificacion(Notificacion notif, bool isDark) {
    _db.ref("Usuarios").child(_emailSafe).child("notificacionesLeidas").child(notif.id).set(true);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(notif.titulo, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text(notif.mensaje, style: TextStyle(color: isDark ? const Color(0xFFAAAAAA) : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Color(0xFFA30000), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    _qrTimer?.cancel();
    _globalSubscription?.cancel();
    _personalSubscription?.cancel();
    _delSubscription?.cancel();
    _leidasSubscription?.cancel();
    super.dispose();
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isEng ? 'QUICK MENU' : 'MENÚ RÁPIDO', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
                          InkWell(onTap: _toggleMenu, child: Icon(Icons.close, color: Colors.grey[500], size: 20))
                        ],
                      ),
                      const SizedBox(height: 12),
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

  void _mostrarNormas(bool isEng, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF9F9F9),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(isEng ? 'RULES' : 'NORMAS', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold))),
                  IconButton(icon: Icon(Icons.close, color: Colors.grey[500]), onPressed: () => Navigator.pop(context))
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          isEng
                              ? 'You agree to comply with these rules. For the benefit of everyone, be advised that any transgression of the following rules will be considered a VERY SERIOUS offense and will be grounds for immediate expulsion.'
                              : 'Te comprometes a cumplir estas normas. En beneficio de todos, se advierte que cualquier transgresión de las siguientes reglas se considerará una falta MUY GRAVE y será motivo de expulsión inmediata.',
                          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87, fontSize: 15, height: 1.5)
                      ),
                      const SizedBox(height: 24),
                      Divider(color: isDark ? Colors.grey[800] : Colors.grey[300], thickness: 1),
                      const SizedBox(height: 12),
                      Text(isEng ? 'LIST OF RULES' : 'LISTADO DE REGLAS', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 12),
                      Divider(color: isDark ? Colors.grey[800] : Colors.grey[300], thickness: 1),
                      const SizedBox(height: 16),

                      _buildRuleItem(isEng ? 'RESPECT: Our main rule.' : 'RESPETO: Nuestra norma principal.', isDark),
                      _buildRuleItem(isEng ? 'GAMES: You cannot join a game started by others if they do not want you to.' : 'JUEGOS: No puedes formar parte de un juego iniciado por otros si estos no quieren.', isDark),
                      _buildRuleItem(isEng ? 'ATTITUDE: Disrespectful behavior towards others is not allowed.' : 'ACTITUD: No está permitida ninguna actitud irrespetuosa hacia los demás.', isDark),
                      _buildRuleItem(isEng ? 'DEVICES: The use of mobile phones, video, or photo cameras is not allowed.' : 'DISPOSITIVOS: No está permitido el uso de teléfonos móviles, cámaras de filmación o fotográficas.', isDark),
                      _buildRuleItem(isEng ? 'PROHIBITED PRACTICES: Scat, blood, or extreme pain practices are not allowed.' : 'PRÁCTICAS PROHIBIDAS: No está permitida la práctica del scat, sangre o dolor extremo.', isDark),
                      _buildRuleItem(isEng ? 'SUSTANCIAS: No está permitida la venta o consumo de cualquier tipo de drogas o estupefacientes.' : 'SUSTANCIAS: No está permitida la venta o consumo de cualquier tipo de drogas o estupefacientes.', isDark),

                      const SizedBox(height: 24),
                      Divider(color: isDark ? Colors.grey[800] : Colors.grey[300], thickness: 1),
                      const SizedBox(height: 12),
                      Text(isEng ? 'ADDITIONAL REMINDERS' : 'RECORDATORIOS ADICIONALES', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 12),
                      Divider(color: isDark ? Colors.grey[800] : Colors.grey[300], thickness: 1),
                      const SizedBox(height: 16),

                      _buildRuleItem(isEng ? 'VOLUNTARINESS: You are not obliged to do anything you do not want to.' : 'VOLUNTARIEDAD: No estás obligado a hacer nada que no desees.', isDark),
                      _buildRuleItem(isEng ? 'FACILITIES: Please leave them as you would like to find them.' : 'INSTALACIONES: Rogamos mantenerlas como desearías encontrarlas.', isDark),
                      _buildRuleItem(isEng ? 'HEALTH: The club strongly recommends safe sex (free condoms available).' : 'SALUD: El club recomienda encarecidamente el sexo seguro (preservativos gratuitos disponibles).', isDark),
                      _buildRuleItem(isEng ? 'HYGIENE: Cleaning and hygiene supplies are available for your use.' : 'HIGIENE: Existen elementos de limpieza e higiene para su uso.', isDark),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(context),
                child: Text(isEng ? 'ACCEPT' : 'ACEPTAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87, fontSize: 15, height: 1.4))),
        ],
      ),
    );
  }

  // --- NUEVA LÓGICA DE CÓDIGO QR SEGURO ---
  void _mostrarBottomSheetQR() {
    _qrSessionNonce = "session_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(100000)}";
    _cerrarQR();

    bool isLoading = true;
    bool hasError = false;
    StateSetter? modalSetState;

    // Función asíncrona que genera y valida con el servidor
    Future<void> generar() async {
      if (modalSetState != null) modalSetState!(() { isLoading = true; hasError = false; });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return;

      String email = user.email!;
      String uid = user.uid;
      String emailSafe = email.replaceAll('.', '_');
      int issuedAt = DateTime.now().millisecondsSinceEpoch;
      int expiresAt = issuedAt + 900000; // 15 Minutos en milisegundos (15 * 60 * 1000)
      String qrToken = "token_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(100000)}";

      Map<String, dynamic> datosPerfilParaQR = _userProfileData ?? {};
      datosPerfilParaQR["codeUser"] = uid;

      Map<String, dynamic> qrData = {
        "token": qrToken,
        "session": _qrSessionNonce,
        "issuedAt": issuedAt,
        "expiresAt": expiresAt,
        "emailSafe": emailSafe,
        "perfil": datosPerfilParaQR,
      };

      try {
        // VALIDACIÓN DE SERVIDOR: Subimos el Token a Firebase y esperamos confirmación
        await _db.ref("SesionesQR_Activas").child(emailSafe).set({
          "token": qrToken,
          "timestamp": ServerValue.timestamp,
        }).timeout(const Duration(seconds: 8));

        // El servidor ha respondido correctamente, preparamos la UI
        _currentQrData = jsonEncode(qrData);
        _secondsLeft = 900;

        if (modalSetState != null) {
          modalSetState!(() {
            isLoading = false;
            hasError = false;
          });
        }

        // Arrancamos el temporizador solo cuando el servidor nos da el OK
        _qrTimer?.cancel();
        _qrTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (modalSetState != null) {
            modalSetState!(() {
              if (_secondsLeft > 1) {
                _secondsLeft--;
              } else {
                timer.cancel();
                generar(); // Regeneración automática al agotarse los 15 minutos
              }
            });
          }
        });
      } catch (e) {
        // Error de conexión
        if (modalSetState != null) {
          modalSetState!(() {
            isLoading = false;
            hasError = true;
          });
        }
      }
    }

    // Disparamos la función asíncrona justo antes de abrir la pantalla
    generar();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateModal) {
          modalSetState = setStateModal;
          bool isEng = TheRingPrivateApp.isEnglishNotifier.value;

          // Cálculo del formato MM:SS
          String minutesStr = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
          String secondsStr = (_secondsLeft % 60).toString().padLeft(2, '0');

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24.0, top: 24.0, left: 24.0, right: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF444444), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  Text(isEng ? 'Dynamic Secure Access' : 'Acceso Seguro Dinámico', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // LÓGICA VISUAL CONDICIONAL
                  if (isLoading) ...[
                    const SizedBox(height: 48),
                    const CircularProgressIndicator(color: Color(0xFFA30000)),
                    const SizedBox(height: 16),
                    Text(isEng ? 'Validating securely...' : 'Validando con el servidor...', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 48),
                  ] else if (hasError) ...[
                    const SizedBox(height: 48),
                    const Icon(Icons.wifi_off, color: Color(0xFFFF4C4C), size: 48),
                    const SizedBox(height: 16),
                    Text(isEng ? 'Connection error' : 'Error de conexión', style: const TextStyle(color: Color(0xFFFF4C4C), fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF333333), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                      onPressed: () => generar(),
                      child: Text(isEng ? 'RETRY' : 'REINTENTAR', style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    Text(isEng ? 'This code expires in $minutesStr:$secondsStr' : 'Este código caduca en $minutesStr:$secondsStr', style: const TextStyle(color: Color(0xFFFF4C4C), fontSize: 14)),
                    const SizedBox(height: 24),
                    Card(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16.0), child: QrImageView(data: _currentQrData, size: 250.0))),
                    const SizedBox(height: 32),
                  ],

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                    onPressed: () {
                      modalSetState = null;
                      _cerrarQR();
                      Navigator.pop(context);
                    },
                    child: Text(isEng ? 'CLOSE' : 'CERRAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          );
        });
      },
    ).then((_) {
      modalSetState = null;
      _cerrarQR();
    });
  }

  void _cerrarQR() {
    _qrTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    const Color rojoRing = Color(0xFFA30000);
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;

    // VARIABLES RESPONSIVE BASADAS EN LA PANTALLA DEL DISPOSITIVO
    final size = MediaQuery.of(context).size;
    final double topPadding = MediaQuery.of(context).padding.top;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA);
    final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final String logoPath = isDark
        ? 'lib/assets/logo_the_ring_transparente.png'
        : 'lib/assets/logo_the_ring_transparente_negro.png';

    // Alturas relativas (proporcionales a la pantalla pero con límites para no romper el diseño)
    final double logoHeight = size.height * 0.23;
    final double buttonHeight = size.height * 0.14 > 120 ? 120 : size.height * 0.14;

    // Alturas colapsadas/expandidas de las notificaciones
    final double maxCollapsedHeight = math.max(130.0, size.height * 0.15); // Un poco más de la mitad
    final double maxExpandedHeight = math.max(320.0, size.height * 0.38);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: size.height * 0.15), // Padding dinámico inferior
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, topPadding + 20, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFA30000), Color(0xFF500000)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: const Text(
                            "THE RING",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.menu, color: rojoRing, size: 30), onPressed: _toggleMenu)
                      ],
                    ),
                  ),

                  // LOGO RESPONSIVE
                  Container(
                    height: logoHeight,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161616) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(logoPath, height: logoHeight * 0.75, fit: BoxFit.contain, errorBuilder: (_,__,___) => Icon(Icons.image, color: isDark ? Colors.white : Colors.black, size: 50)),
                  ),

                  SizedBox(height: size.height * 0.02),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(isEng ? 'NOTIFICATIONS' : 'NOTIFICACIONES', style: const TextStyle(color: rojoRing, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.8)),
                  ),

                  // CAJA DE NOTIFICACIONES
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      gradient: isDark ? null : LinearGradient(
                        colors: [Colors.white, Colors.white.withOpacity(0.96)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: isDark ? Border.all(color: const Color(0xFF2A2A2A), width: 1.5) : Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                      boxShadow: isDark ? [] : [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
                        BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 2, offset: const Offset(-2, -2))
                      ],
                    ),
                    // PADDING REDUCIDO Y MÁS COMPACTO
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: _notificacionesVisibles.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text(isEng ? 'No pending notifications' : 'No tienes notificaciones pendientes', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14))),
                    )
                        : Column(
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Container(
                            // Altura dinámica: Colapsado (pequeño) vs Expandido
                            constraints: BoxConstraints(
                              maxHeight: _isExpanded ? maxExpandedHeight : maxCollapsedHeight,
                            ),
                            child: ListView.separated(
                              // ELIMINA EL HUECO SUPERIOR AUTOMÁTICO DE LISTVIEW
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _notificacionesVisibles.length,
                              // SEPARADOR MÁS FINO PARA QUE ESTÉN MÁS JUNTAS
                              separatorBuilder: (context, index) => Divider(color: isDark ? Colors.grey[800] : const Color(0xFFF1F1F1), height: 8),
                              itemBuilder: (context, index) {
                                final notif = _notificacionesVisibles[index];
                                return InkWell(
                                  onTap: () => _mostrarDetalleNotificacion(notif, isDark),
                                  child: Opacity(
                                    opacity: notif.leida ? 0.6 : 1.0,
                                    child: Padding(
                                      // Padding interno muy fino
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        children: [
                                          Icon(notif.tipo == 'mensaje' ? Icons.chat_bubble_outline : Icons.info_outline, color: notif.tipo == 'mensaje' ? const Color(0xFF4287F5) : const Color(0xFFA30000), size: 22),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(notif.titulo, style: TextStyle(fontWeight: notif.leida ? FontWeight.normal : FontWeight.bold, fontSize: 14, color: textColor)),
                                                const SizedBox(height: 2),
                                                Text(notif.mensaje, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // BOTÓN EXPANDIR (Aparece si hay más de 1 notificación)
                        if (_notificacionesVisibles.length > 1 || _isExpanded) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Divider(color: isDark ? Colors.grey[800] : const Color(0xFFF1F1F1), height: 4),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isExpanded = !_isExpanded),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      _isExpanded
                                          ? (isEng ? "Collapse" : "Contraer")
                                          : (isEng ? "Expand" : "Expandir"),
                                      style: const TextStyle(color: Color(0xFFA30000), fontWeight: FontWeight.bold, fontSize: 13)
                                  ),
                                  Icon(
                                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: const Color(0xFFA30000),
                                      size: 18
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // BOTONES INFERIORES RESPONSIVE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(child: _buildHomeSquareButton(isEng ? 'PROFILE' : 'PERFIL', Icons.person, cardBgColor, textColor, isDark, buttonHeight, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())))),
                        Expanded(child: _buildHomeSquareButton(isEng ? 'RULES' : 'NORMAS', Icons.assignment, cardBgColor, textColor, isDark, buttonHeight, () => _mostrarNormas(isEng, isDark))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleMenu,
                child: Container(),
              ),
            ),

          Positioned(
            top: topPadding + 65,
            right: 16,
            child: IgnorePointer(
              ignoring: !_isMenuOpen,
              child: FadeTransition(
                opacity: _menuAnimation,
                child: ScaleTransition(
                  scale: _menuAnimation,
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: _buildMenuContent(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          backgroundColor: rojoRing,
          elevation: 8,
          shape: const CircleBorder(),
          onPressed: _mostrarBottomSheetQR,
          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 42),
        ),
      ),
    );
  }

  Widget _buildHomeSquareButton(String title, IconData icon, Color bgColor, Color textColor, bool isDark, double height, VoidCallback onTap) {
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
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 38, color: textColor),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}