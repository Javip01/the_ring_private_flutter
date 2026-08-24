import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // NUEVO IMPORT
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// NUEVO: Manejador de mensajes en segundo plano (Top-level)
// Esta función debe estar fuera de cualquier clase.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Mensaje en segundo plano recibido: ${message.messageId}");
}

void main() async {
  // Asegura que los cimientos de Flutter están listos
  WidgetsFlutterBinding.ensureInitialized();

  // Bloque a prueba de balas para inicializar Firebase dependiendo del sistema
  if (Firebase.apps.isEmpty) {
    if (!kIsWeb && Platform.isIOS) {
      // INICIALIZACIÓN PURA EN CÓDIGO PARA iOS (¡Adiós Xcode!)
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyB2DfMgcb476VwqJZFrO4Fgf0lT5HbszTQ',
          appId: '1:554282786135:ios:f2e0ee444989381eea3212',
          messagingSenderId: '554282786135',
          projectId: 'laasociacion-57649',
          databaseURL: 'https://laasociacion-57649-default-rtdb.firebaseio.com',
          storageBucket: 'laasociacion-57649.appspot.com',
          iosBundleId: 'theRingPrivate.theRing',
        ),
      );
    } else {
      // Android sigue funcionando de forma nativa porque ya lo configuraste bien
      await Firebase.initializeApp();
    }
  }

  // NUEVO: Registra el manejador de notificaciones en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Arranca tu app
  runApp(const TheRingPrivateApp());
}

class TheRingPrivateApp extends StatelessWidget {
  const TheRingPrivateApp({super.key});

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.light,
  );
  static final ValueNotifier<bool> isEnglishNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return ValueListenableBuilder<bool>(
          valueListenable: isEnglishNotifier,
          builder: (_, bool isEnglish, __) {
            return MaterialApp(
              title: 'The Ring Private',
              debugShowCheckedModeBanner: false,
              themeMode: currentMode,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFF5F5F5),
                cardColor: Colors.white,
                primaryColor: const Color(0xFFA30000),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF121212),
                cardColor: const Color(0xFF1E1E1E),
                primaryColor: const Color(0xFFA30000),
                useMaterial3: true,
              ),
              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFA30000),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    return const HomeScreen();
                  } else {
                    return const LoginScreen();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}