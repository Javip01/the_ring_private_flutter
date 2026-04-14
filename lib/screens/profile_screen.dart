import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Importante para acceder a los Notifiers de Tema e Idioma

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // POP-UP: CAMBIAR CONTRASEÑA (Adaptable a tema e idioma)
  void _mostrarDialogoPassword(BuildContext context, bool isEng, ThemeMode currentTheme) {
    final bgColor = currentTheme == ThemeMode.dark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = currentTheme == ThemeMode.dark ? Colors.white : Colors.black87;

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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
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
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000)),
                      onPressed: () => Navigator.pop(context), // Lógica de actualizar en Firebase iría aquí
                      child: Text(isEng ? 'Update' : 'Actualizar', style: const TextStyle(color: Colors.white)),
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

    // Envolvemos todo en los ValueListenableBuilder para que sea reactivo en tiempo real
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: TheRingPrivateApp.themeNotifier,
        builder: (context, currentTheme, _) {
          return ValueListenableBuilder<bool>(
              valueListenable: TheRingPrivateApp.isEnglishNotifier,
              builder: (context, isEng, _) {

                // Colores dinámicos basados en el tema
                final isDarkMode = currentTheme == ThemeMode.dark;
                final scaffoldBgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
                final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
                final textColorPrimary = isDarkMode ? Colors.white : Colors.black87;
                final textColorSecondary = Colors.grey;

                return Scaffold(
                  backgroundColor: scaffoldBgColor,
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Tarjeta Superior Gradient (Esta se mantiene oscura por diseño de marca) ---
                        Card(
                          color: const Color(0xFF333333),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                          margin: const EdgeInsets.only(top: 8, bottom: 32),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(23),
                              gradient: const LinearGradient(
                                  colors: [Color(0xFF444444), Color(0xFF222222)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 27),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.arrow_back, color: Color(0xFFCCCCCC)),
                                        onPressed: () => Navigator.pop(context)
                                    ),
                                    Expanded(
                                        child: Center(
                                            child: Text(
                                                isEng ? 'MY PROFILE' : 'MI PERFIL',
                                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                                            )
                                        )
                                    ),
                                    const SizedBox(width: 48), // Balance para centrar el texto
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(userName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(isEng ? 'MEMBER' : 'SOCI@', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),

                        // --- Título Credenciales ---
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                              isEng ? 'PRIVATE CREDENTIALS' : 'CREDENCIALES PRIVADAS',
                              style: const TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold)
                          ),
                        ),

                        // --- Tarjeta Credenciales ---
                        Card(
                          color: cardBgColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2, // Añadido un poco de elevación para que destaque en modo oscuro
                          margin: const EdgeInsets.only(bottom: 40),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                title: Text(isEng ? 'Email' : 'Correo electrónico', style: TextStyle(color: textColorSecondary, fontSize: 14)),
                                subtitle: Text(userEmail, style: TextStyle(color: textColorPrimary, fontSize: 16)),
                              ),
                              Divider(
                                  height: 1,
                                  indent: 20,
                                  color: isDarkMode ? const Color(0xFF333333) : const Color(0xFFEEEEEE)
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                title: Text(isEng ? 'Password' : 'Contraseña', style: TextStyle(color: textColorSecondary, fontSize: 14)),
                                subtitle: Text('••••••••••••', style: TextStyle(color: textColorPrimary, fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
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
                );
              }
          );
        }
    );
  }
}