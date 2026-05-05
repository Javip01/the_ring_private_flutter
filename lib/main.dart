import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Asegura que los cimientos de Flutter están listos
  WidgetsFlutterBinding.ensureInitialized();

  // Bloque a prueba de balas para inicializar Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  // Arranca tu app (Asegúrate de que TheRingPrivateApp() es el nombre de tu clase principal)
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
