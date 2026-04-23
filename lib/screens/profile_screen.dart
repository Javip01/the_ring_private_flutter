import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _mostrarDialogoPassword(BuildContext context, bool isEng, ThemeMode currentTheme) {
    final isDark = currentTheme == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  isEng ? 'Change Password' : 'Cambiar Contraseña',
                  style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8),
              Text(
                  isEng ? 'Enter your new password (Min 6 chars).' : 'Introduce tu nueva contraseña (Mínimo 6 caracteres).',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: isEng ? 'New password' : 'Nueva contraseña',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFA30000))),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(isEng ? 'Cancel' : 'Cancelar', style: const TextStyle(color: Colors.grey))
                      )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA30000),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(isEng ? 'Update' : 'Actualizar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? "No vinculado";
    final userName = user?.displayName ?? "Cargando...";

    return ValueListenableBuilder<ThemeMode>(
        valueListenable: TheRingPrivateApp.themeNotifier,
        builder: (context, currentTheme, _) {
          return ValueListenableBuilder<bool>(
              valueListenable: TheRingPrivateApp.isEnglishNotifier,
              builder: (context, isEng, _) {

                final isDarkMode = currentTheme == ThemeMode.dark;
                final scaffoldBgColor = isDarkMode ? const Color(0xFF000000) : const Color(0xFFF5F5F5);
                final cardBgColor = isDarkMode ? const Color(0xFF161616) : Colors.white;
                final textColorPrimary = isDarkMode ? Colors.white : Colors.black87;
                final textColorSecondary = Colors.grey;

                return Scaffold(
                  backgroundColor: scaffoldBgColor,
                  // SAFEAREA PROTEGE DEL NOTCH O ISLA DINÁMICA
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- CABECERA ROJA DEGRADADA (Idéntica a Ajustes) ---
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 32),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFA30000), Color(0xFF4A0000)], // Degradado rojo a granate
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.2), blurRadius: 10, offset: const Offset(0, 4))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                                        onPressed: () => Navigator.pop(context)
                                    ),
                                    Expanded(
                                        child: Center(
                                            child: Text(
                                                isEng ? 'MY PROFILE' : 'MI PERFIL',
                                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                                            )
                                        )
                                    ),
                                    const SizedBox(width: 48),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(userName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(isEng ? 'MEMBER' : 'SOCI@', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 8),
                            child: Text(
                                isEng ? 'PRIVATE CREDENTIALS' : 'CREDENCIALES PRIVADAS',
                                style: const TextStyle(color: Color(0xFFA30000), fontSize: 13, fontWeight: FontWeight.bold)
                            ),
                          ),

                          Card(
                            color: cardBgColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: isDarkMode ? 0 : 2,
                            margin: const EdgeInsets.only(bottom: 40),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  title: Text(isEng ? 'Email' : 'Correo electrónico', style: TextStyle(color: textColorSecondary, fontSize: 14)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(userEmail, style: TextStyle(color: textColorPrimary, fontSize: 16)),
                                  ),
                                ),
                                Divider(
                                    height: 1,
                                    indent: 20,
                                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100]
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  title: Text(isEng ? 'Password' : 'Contraseña', style: TextStyle(color: textColorSecondary, fontSize: 14)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('••••••••••••', style: TextStyle(color: textColorPrimary, fontSize: 16)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFA30000),
                                      minimumSize: const Size(double.infinity, 55),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => _mostrarDialogoPassword(context, isEng, currentTheme),
                                    child: Text(
                                        isEng ? 'CHANGE PASSWORD' : 'CAMBIAR CONTRASEÑA',
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                )
                              ],
                            ),
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
}