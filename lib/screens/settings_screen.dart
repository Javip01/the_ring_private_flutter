import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'tarifas_screen.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void _cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  // --- POPUP CONTRASEÑA (RESTUARADO) ---
  void _mostrarDialogoPassword() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEng ? 'Change Password' : 'Cambiar Contraseña', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(isEng ? 'Enter your new password (Min 6 chars).' : 'Introduce tu nueva contraseña (Mínimo 6 caracteres).', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
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
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(isEng ? 'Cancel' : 'Cancelar', style: const TextStyle(color: Colors.grey)))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA30000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () => Navigator.pop(context), // Lógica guardado aquí
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

  // --- POPUP IDIOMA ---
  void _mostrarDialogoIdioma() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.translate, color: Color(0xFFA30000), size: 20),
                  const SizedBox(width: 8),
                  Text(isEng ? 'LANGUAGE' : 'IDIOMA', style: const TextStyle(color: Color(0xFFA30000), fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        TheRingPrivateApp.isEnglishNotifier.value = false;
                        Navigator.pop(context);
                      },
                      child: Center(child: Text('🇪🇸 ES', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold))),
                    ),
                  ),
                  Container(height: 30, width: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        TheRingPrivateApp.isEnglishNotifier.value = true;
                        Navigator.pop(context);
                      },
                      child: Center(child: Text('🇬🇧 EN', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold))),
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

  // --- POPUP APARIENCIA ---
  void _mostrarDialogoApariencia() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.contrast, color: Color(0xFFA30000), size: 20),
                  const SizedBox(width: 8),
                  Text(isEng ? 'APPEARANCE' : 'APARIENCIA', style: const TextStyle(color: Color(0xFFA30000), fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        TheRingPrivateApp.themeNotifier.value = ThemeMode.light;
                        Navigator.pop(context);
                      },
                      child: Center(child: Text(isEng ? 'Light' : 'Claro', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold))),
                    ),
                  ),
                  Container(height: 30, width: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        TheRingPrivateApp.themeNotifier.value = ThemeMode.dark;
                        Navigator.pop(context);
                      },
                      child: Center(child: Text(isEng ? 'Dark' : 'Oscuro', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold))),
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

  // --- POPUP: ELIMINAR CUENTA ---
  void _mostrarDialogoEliminar() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.close, color: Color(0xFFFF4C4C), size: 48),
              const SizedBox(height: 16),
              Text(isEng ? 'Delete Account' : 'Eliminar cuenta', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(isEng ? 'Verify your identity to proceed.' : 'Para proceder, verifica tu identidad.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              TextField(
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: isEng ? 'Email or DNI' : 'Correo o DNI',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFFF4C4C))),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(isEng ? 'Cancel' : 'Cancelar', style: const TextStyle(color: Colors.grey)))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4C4C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () => Navigator.pop(context),
                      child: Text(isEng ? 'DELETE' : 'ELIMINAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // --- BOTTOM SHEET: TEXTOS LEGALES Y MANUALES ---
  void _mostrarBottomSheetLegal(String titulo, String contenido) {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF9F9F9),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 24, left: 24, right: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(titulo, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold))),
                  IconButton(icon: Icon(Icons.close, color: Colors.grey[500]), onPressed: () => Navigator.pop(context))
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.65, // Aprovecha bien la pantalla
                child: SingleChildScrollView(
                  child: Text(contenido, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87, fontSize: 15, height: 1.5)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA30000),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(isEng ? 'ACCEPT' : 'ACEPTAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================= TEXTOS LEGALES Y DE AYUDA (EXTRAIDOS DE CAPTURAS) =================
  void _abrirTarifas(bool isEng) {
    String titulo = isEng ? 'How to become a member and tariffs' : 'Cómo hacerse socio y tarifas';
    String contenido = isEng
        ? "How to become a member\n1. Go to reception and request membership.\n2. Fill out and sign the form with your real data.\n3. Expressly accept the club's internal rules.\n4. Download the app and complete registration with the same ID document.\n5. The first validation is done in person at reception.\n\nMembership Status\nOnly those who have paid the current fee are considered active members. If the fee expires, membership is suspended until renewed.\n\nAdvantages of being a member\n- Faster access via QR identification.\n- Personal account registration to manage notifications and settings.\n- Use of lockers subject to availability and club conditions.\n- Access to additional benefits at special events, when announced.\n\nCurrent tariffs\nOne-day member:\n- Friday: 15 EUR\n- Saturday: 15 EUR\n\nVIP Fees:\n- VIP Member 1 month: 90 EUR\n- VIP Member 6 months: 250 EUR\n\nTariffs may be updated. In case of change, the current version will be published at reception and in the application."
        : "Cómo hacerse socio\n1. Acude a recepción y solicita el alta de socio.\n2. Rellena y firma la hoja de alta con tus datos reales.\n3. Acepta expresamente las normas internas del club.\n4. Descarga la aplicación y completa tu registro con el mismo documento de identidad.\n5. La primera validación se realiza presencialmente en recepción.\n\nCondición de socio\nSolo se considera socio activo a quien haya abonado la cuota vigente. Si la cuota caduca, la condición de socio queda suspendida hasta la renovación.\n\nVentajas de ser socio\n- Acceso más ágil mediante identificación con QR.\n- Registro de cuenta personal para gestionar notificaciones y ajustes.\n- Uso de taquilla según disponibilidad y condiciones del club.\n- Acceso a ventajas adicionales en eventos especiales, cuando se anuncien.\n\nTarifas vigentes\nSocio por un día:\n- Viernes: 15 EUR\n- Sábado: 15 EUR\n\nCuotas VIP:\n- Socio VIP 1 mes: 90 EUR\n- Socio VIP 6 meses: 250 EUR\n\nLas tarifas pueden actualizarse. En caso de cambio, se publicará la versión vigente en recepción y en la aplicación.";
    _mostrarBottomSheetLegal(titulo, contenido);
  }

  void _abrirTerminos(bool isEng) {
    String titulo = isEng ? 'Terms and Conditions' : 'Términos y Condiciones';
    String contenido = isEng
        ? "These Terms and Conditions regulate the download, access, and use of the THE RING PRIVATE application (hereinafter, the Application). Access and use imply express acceptance of these conditions.\n\n1. Object\nThe Application aims to manage member identification, facilitate internal notices, and improve the club access experience. Its use is personal and non-transferable.\n\n2. User Registration\nTo create an account, the user must provide real and valid data (name, surname, ID, and email). The user is responsible for keeping their password safe and not sharing it.\n\n3. Rules of Use\nThe user agrees to use the Application lawfully and respectfully. It is prohibited to manipulate, copy, decompile, alter, or reuse the Application's content without express authorization.\n\n4. Intellectual Property\nAll intellectual and industrial property rights over the Application belong to THE RING PRIVATE or authorized third parties.\n\n5. Data Protection\nPersonal data will be processed according to the GDPR and current Spanish regulations. The user can exercise their rights of access, rectification, deletion, opposition, limitation, and portability by contacting the entity.\n\n6. Availability and Responsibility\nTHE RING PRIVATE may update, modify, or suspend the Application for technical or legal reasons. Absolute availability is not guaranteed.\n\n7. Account Deletion\nThe user can request account deletion from the settings section. This action eliminates access and associated data in enabled systems, except for legal retention obligations.\n\n8. Applicable Legislation\nThese conditions are governed by Spanish law. Any controversy will be submitted to the competent courts and tribunals of Madrid, unless a mandatory legal provision states otherwise."
        : "Estos Términos y Condiciones regulan la descarga, el acceso y el uso de la aplicación THE RING PRIVATE (en adelante, la Aplicación). El acceso y uso de la Aplicación implica la aceptación expresa de estas condiciones.\n\n1. Objeto\nLa Aplicación tiene como finalidad gestionar la identificación de socios, facilitar la comunicación de avisos internos y mejorar la experiencia de acceso al club. Su uso es personal e intransferible.\n\n2. Registro de usuario\nPara crear una cuenta, el usuario debe facilitar datos reales y vigentes (nombre, apellidos, documento de identidad y correo electrónico). El usuario es responsable de custodiar su contraseña y de no compartirla con terceros.\n\n3. Normas de uso\nEl usuario se compromete a utilizar la Aplicación de forma lícita, respetuosa y conforme a la normativa aplicable. Queda prohibido manipular, copiar, descompilar, alterar o reutilizar el contenido de la Aplicación sin autorización expresa.\n\n4. Propiedad intelectual\nTodos los derechos de propiedad intelectual e industrial sobre la Aplicación, su diseño, textos, marcas y elementos gráficos pertenecen a THE RING PRIVATE o a terceros autorizados.\n\n5. Protección de datos\nLos datos personales se tratarán conforme al Reglamento (UE) 2016/679 (RGPD) y la normativa española vigente. El tratamiento se realiza para gestionar la relación con el socio y el funcionamiento de la Aplicación. El usuario puede ejercer sus derechos de acceso, rectificación, supresión, oposición, limitación y portabilidad mediante contacto con la entidad.\n\n6. Disponibilidad y responsabilidad\nTHE RING PRIVATE podrá actualizar, modificar o suspender la Aplicación por motivos técnicos, legales o de mantenimiento. Aunque se aplican medidas de seguridad, no se garantiza la disponibilidad absoluta ni la ausencia total de errores técnicos.\n\n7. Baja y eliminación de cuenta\nEl usuario puede solicitar la eliminación de su cuenta desde la sección de ajustes. Esta acción elimina el acceso y los datos asociados en los sistemas habilitados, salvo obligación legal de conservación.\n\n8. Legislación aplicable\nEstas condiciones se rigen por la legislación española. Cualquier controversia se someterá a los juzgados y tribunales competentes de Madrid, salvo disposición legal imperativa en contrario.";
    _mostrarBottomSheetLegal(titulo, contenido);
  }

  void _abrirAyuda(bool isEng) {
    String titulo = isEng ? 'Help and Support' : 'Ayuda y soporte';
    String contenido = isEng
        ? "If you have a problem with the application, follow this order:\n\n1. Check the Frequently Asked Questions (FAQ) section first.\n2. If not resolved, write to ringasociacion@gmail.com indicating:\n- Account email\n- ID used in registration\n- Mobile model\n- OS Version\n- Exact description of the error\n\nSupport via email:\nringasociacion@gmail.com\n\nOfficial networks:\nFacebook: https://www.facebook.com/theringprivate\nInstagram: https://www.instagram.com/theringprivate\n\nIn-person assistance:\nC. del Amparo, 75, Centro, 28012 Madrid"
        : "Si tienes un problema con la aplicación, sigue este orden:\n\n1. Revisa primero la sección de Preguntas Frecuentes.\n2. Si no se resuelve, escribe a ringasociacion@gmail.com indicando:\n- Correo de tu cuenta\n- DNI usado en el registro\n- Modelo de móvil\n- Versión de Android/iOS\n- Descripción exacta del error\n\nSoporte por correo:\nringasociacion@gmail.com\n\nRedes oficiales:\nFacebook: https://www.facebook.com/theringprivate\nInstagram: https://www.instagram.com/theringprivate\n\nAtención presencial:\nC. del Amparo, 75, Centro, 28012 Madrid";
    _mostrarBottomSheetLegal(titulo, contenido);
  }

  void _abrirFAQ(bool isEng) {
    String titulo = isEng ? 'Frequently Asked Questions (FAQ)' : 'Preguntas frecuentes (FAQ)';
    String contenido = isEng
        ? "1. How do I register correctly?\nTap Register, fill in your name, surname, ID, email, and a secure password. You must accept the terms and conditions to finish.\n\n2. What documents are valid for registration?\nValid ID, NIE, or Passport are accepted.\n\n3. I forgot my password. What do I do?\nAt login, tap Forgot your password and follow the email recovery process.\n\n4. The QR is not showing. How do I fix it?\nCheck your internet connection, close and reopen the QR screen, and try again. If it persists, log out and log back in.\n\n5. Can I change my personal data?\nSensitive identification data is managed at reception to verify identity.\n\n6. How do I delete my account?\nIn Settings, go to Delete Account, verify your credentials, and confirm final deletion.\n\n7. What happens to my notifications if I delete them?\nIf you delete a notification in your profile, it stops showing in your account. Other users keep their own notifications independently."
        : "1. ¿Cómo me registro correctamente?\nPulsa en Registrarse, completa nombre, apellidos, DNI, correo y una contraseña segura. Debes aceptar los términos y condiciones para finalizar.\n\n2. ¿Qué documentos son válidos para el registro?\nSe aceptan DNI, NIE o pasaporte en vigor.\n\n3. He olvidado mi contraseña. ¿Qué hago?\nEn inicio de sesión, pulsa Olvidaste tu contraseña y sigue el proceso de recuperación por correo.\n\n4. El QR no se muestra. ¿Cómo lo soluciono?\nComprueba conexión a internet, cierra y abre la pantalla QR y vuelve a intentarlo. Si persiste, cierra sesión y entra de nuevo.\n\n5. ¿Puedo cambiar mis datos personales?\nLos datos sensibles de identificación se gestionan en recepción para verificar identidad.\n\n6. ¿Cómo elimino mi cuenta?\nEn Ajustes, entra en Eliminar cuenta, verifica tus credenciales y confirma la eliminación final.\n\n7. ¿Qué pasa con mis notificaciones si las elimino?\nSi eliminas una notificación en tu perfil, deja de mostrarse en tu cuenta. Otros usuarios mantienen sus propias notificaciones de forma independiente.";
    _mostrarBottomSheetLegal(titulo, contenido);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ValueListenableBuilder<ThemeMode>(
        valueListenable: TheRingPrivateApp.themeNotifier,
        builder: (context, currentTheme, _) {
          return ValueListenableBuilder<bool>(
              valueListenable: TheRingPrivateApp.isEnglishNotifier,
              builder: (context, isEng, _) {
                final isDark = currentTheme == ThemeMode.dark;

                // COLORES SÓLIDOS Y PUROS PARA LAS TARJETAS (Como en las capturas)
                final scaffoldBgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F5);
                final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
                final textColor = isDark ? Colors.white : Colors.black;
                final iconColor = isDark ? Colors.white : Colors.black;

                return Scaffold(
                  backgroundColor: scaffoldBgColor,
                  // EL SAFEAREA GARANTIZA QUE EL DISEÑO NUNCA TOQUE LA CÁMARA (NOTCH) NI LA BARRA DE BATERÍA
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CABECERA ROJA DEGRADADA (Estilo exacto de captura)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFA30000), Color(0xFF4A0000)], // Degradado profundo
                              ),
                              borderRadius: BorderRadius.circular(24), // Bordes más redondeados
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(isDark ? 0.5 : 0.2), blurRadius: 10, offset: const Offset(0, 4))
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isEng ? 'SETTINGS' : 'AJUSTES', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                    IconButton(icon: const Icon(Icons.home, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Image.asset(
                                  'lib/assets/guantes.png',
                                  height: 120, // Guantes más grandes como en el diseño
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_mma, size: 80, color: Colors.white),
                                ),
                              ],
                            ),
                          ),

                          // Tarjeta Usuario
                          Card(
                            elevation: isDark ? 0 : 2,
                            color: cardBgColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.only(bottom: 24),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              title: Text(user?.displayName ?? 'Usuario', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(user?.email ?? '0@0.0', style: const TextStyle(color: Colors.grey)),
                              ),
                              trailing: Icon(Icons.edit, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                            ),
                          ),

                          Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(isEng ? 'CONFIGURATION' : 'CONFIGURACIÓN', style: const TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold))),
                          Card(
                            elevation: isDark ? 0 : 2,
                            color: cardBgColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              children: [
                                _buildRow(Icons.lock, isEng ? 'Change password' : 'Cambiar contraseña', iconColor, textColor, onTap: _mostrarDialogoPassword),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.translate, isEng ? 'Change language' : 'Cambiar idioma', iconColor, textColor, onTap: _mostrarDialogoIdioma),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.contrast, isEng ? 'Appearance' : 'Apariencia', iconColor, textColor, onTap: _mostrarDialogoApariencia),
                              ],
                            ),
                          ),

                          Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(isEng ? 'LEGAL INFO' : 'INFORMACIÓN LEGAL', style: const TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold))),
                          Card(
                            elevation: isDark ? 0 : 2,
                            color: cardBgColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              children: [
                                _buildRow(Icons.monetization_on, isEng ? 'Tariffs' : 'Tarifas', iconColor, textColor, onTap: () => _abrirTarifas(isEng)),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.description, isEng ? 'Terms and Conditions' : 'Términos y Condiciones', iconColor, textColor, onTap: () => _abrirTerminos(isEng)),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.gavel, isEng ? 'Legal Notice' : 'Aviso legal', iconColor, textColor, onTap: () => _mostrarBottomSheetLegal(isEng ? 'Legal Notice' : 'Aviso legal', isEng ? 'Fiscal and legal information of the company responsible for The Ring Private...' : 'Información fiscal y legal de la empresa responsable de The Ring Private...')),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.help, isEng ? 'Help' : 'Ayuda', iconColor, textColor, onTap: () => _abrirAyuda(isEng)),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.search, isEng ? 'Frequently Asked Questions' : 'Preguntas frecuentes', iconColor, textColor, onTap: () => _abrirFAQ(isEng)),
                              ],
                            ),
                          ),

                          Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(isEng ? 'ACTIONS' : 'ACCIONES', style: const TextStyle(color: Color(0xFFA30000), fontSize: 12, fontWeight: FontWeight.bold))),
                          Card(
                            elevation: isDark ? 0 : 2,
                            color: cardBgColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.only(bottom: 40),
                            child: Column(
                              children: [
                                _buildRow(Icons.power_settings_new, isEng ? 'Log out' : 'Cerrar sesión', iconColor, textColor, onTap: () => _cerrarSesion(context)),
                                Divider(height: 1, indent: 56, color: isDark ? Colors.grey[900] : Colors.grey[100]),
                                _buildRow(Icons.close, isEng ? 'DELETE ACCOUNT' : 'ELIMINAR CUENTA', const Color(0xFFFF4C4C), const Color(0xFFFF4C4C), isDestructive: true, onTap: _mostrarDialogoEliminar),
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

  // --- COMPONENTE FILA CON ICONOS SÓLIDOS (NO FRÁGILES) ---
  Widget _buildRow(IconData icon, String text, Color iconColor, Color textColor, {bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Text(text, style: TextStyle(color: textColor, fontSize: 16, fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}