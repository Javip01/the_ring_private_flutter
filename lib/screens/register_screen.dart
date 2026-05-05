import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../main.dart';

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
  bool _isPasswordVisible = false;
  bool _aceptaTerminos = false;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasSpecialChar = false;
  String _tipoDocumento = 'DNI/NIE';

  bool _validarDNIoNIE(String dnioNie) {
    String dni = dnioNie.toUpperCase().trim();
    final regex = RegExp(r'^[XYZ]?\d{7,8}[A-Z]$');
    if (!regex.hasMatch(dni)) return false;

    const String letrasDNI = "TRWAGMYFPDXBNJZSQVHLCKE";
    String prefijo = dni.substring(0, 1);
    String numeros = dni.substring(0, dni.length - 1);
    String letraFinal = dni.substring(dni.length - 1);

    if (prefijo == 'X') {
      numeros = numeros.replaceFirst('X', '0');
    } else if (prefijo == 'Y') {
      numeros = numeros.replaceFirst('Y', '1');
    } else if (prefijo == 'Z') {
      numeros = numeros.replaceFirst('Z', '2');
    }

    int? numeroEntero = int.tryParse(numeros);
    if (numeroEntero == null) return false;

    int indiceLetra = numeroEntero % 23;
    return letrasDNI[indiceLetra] == letraFinal;
  }

  bool _validarEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email.trim());
  }

  Future<void> _register(bool isEng) async {
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'You must accept the terms and conditions' : 'Debes aceptar los términos y condiciones'), backgroundColor: const Color(0xFFA30000)));
      return;
    }

    String nombre = _nombreController.text.trim();
    String apellidos = _apellidosController.text.trim();
    String documento = _dniController.text.trim().toUpperCase();
    String correo = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (nombre.isEmpty || documento.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Fill in all mandatory fields' : 'Rellena los campos obligatorios'), backgroundColor: const Color(0xFFA30000)));
      return;
    }

    if (_tipoDocumento == 'DNI/NIE' && !_validarDNIoNIE(documento)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Invalid DNI/NIE' : 'El DNI o NIE introducido no es válido'), backgroundColor: const Color(0xFFA30000)));
      return;
    } else if (_tipoDocumento == 'PASAPORTE' && documento.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Invalid Passport' : 'El Pasaporte introducido no es válido'), backgroundColor: const Color(0xFFA30000)));
      return;
    }

    if (correo.isNotEmpty && !_validarEmail(correo)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Invalid email format' : 'El formato del correo no es válido'), backgroundColor: const Color(0xFFA30000)));
      return;
    }

    if (!_hasMinLength || !_hasUppercase || !_hasSpecialChar) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Password does not meet security requirements' : 'La contraseña no cumple los requisitos de seguridad'), backgroundColor: const Color(0xFFA30000)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String signupEmail = correo.isNotEmpty ? correo : '${documento.toLowerCase()}@thering.local';
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: signupEmail, password: password);
      await cred.user?.updateDisplayName(nombre);

      // Mantenemos MapeoDNI para el Login de Flutter
      await FirebaseDatabase.instance.ref("MapeoDNI").child(documento).set(signupEmail);

      // GUARDAMOS EN LA BD EXACTAMENTE COMO KOTLIN ESPERA
      await FirebaseDatabase.instance.ref("usuarios").child(signupEmail.replaceAll('.', '_')).set({
        "name": nombre,
        "surname": apellidos,
        "documento": documento,
        "email": signupEmail,
        "tipoDocumento": _tipoDocumento, // Dato extra, no molesta a Kotlin
        "bloqueado": false,
        "taquilla_actual": "",
        "fecha_asignacion_taquilla": "",
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEng ? 'Error. DNI or Email might exist.' : 'Error al crear cuenta. Quizás el documento o correo ya existen.'), backgroundColor: const Color(0xFFA30000)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarTerminos(bool isEng, bool isDark) {
    String titulo = isEng ? 'Terms and Conditions' : 'Términos y Condiciones';
    String contenido = isEng
        ? "These Terms and Conditions regulate the download, access, and use of the THE RING PRIVATE application (hereinafter, the Application). Access and use imply express acceptance of these conditions.\n\n1. Object\nThe Application aims to manage member identification, facilitate internal notices, and improve the club access experience. Its use is personal and non-transferable.\n\n2. User Registration\nTo create an account, the user must provide real and valid data (name, surname, ID, and email). The user is responsible for keeping their password safe and not sharing it.\n\n3. Rules of Use\nThe user agrees to use the Application lawfully and respectfully. It is prohibited to manipulate, copy, decompile, alter, or reuse the Application's content without express authorization.\n\n4. Intellectual Property\nAll intellectual and industrial property rights over the Application belong to THE RING PRIVATE or authorized third parties.\n\n5. Data Protection\nPersonal data will be processed according to the GDPR and current Spanish regulations. The user can exercise their rights of access, rectification, deletion, opposition, limitation, and portability by contacting the entity.\n\n6. Availability and Responsibility\nTHE RING PRIVATE may update, modify, or suspend the Application for technical or legal reasons. Absolute availability is not guaranteed.\n\n7. Account Deletion\nThe user can request account deletion from the settings section. This action eliminates access and associated data in enabled systems, except for legal retention obligations.\n\n8. Applicable Legislation\nThese conditions are governed by Spanish law. Any controversy will be submitted to the competent courts and tribunals of Madrid, unless a mandatory legal provision states otherwise."
        : "Estos Términos y Condiciones regulan la descarga, el acceso y el uso de la aplicación THE RING PRIVATE (en adelante, la Aplicación). El acceso y uso de la Aplicación implica la aceptación expresa de estas condiciones.\n\n1. Objeto\nLa Aplicación tiene como finalidad gestionar la identificación de socios, facilitar la comunicación de avisos internos y mejorar la experiencia de acceso al club. Su uso es personal e intransferible.\n\n2. Registro de usuario\nPara crear una cuenta, el usuario debe facilitar datos reales y vigentes (nombre, apellidos, documento de identidad y correo electrónico). El usuario es responsable de custodiar su contraseña y de no compartirla con terceros.\n\n3. Normas de uso\nEl usuario se compromete a utilizar la Aplicación de forma lícita, respetuosa y conforme a la normativa aplicable. Queda prohibido manipular, copiar, descompilar, alterar o reutilizar el contenido de la Aplicación sin autorización expresa.\n\n4. Propiedad intelectual\nTodos los derechos de propiedad intelectual e industrial sobre la Aplicación, su diseño, textos, marcas y elementos gráficos pertenecen a THE RING PRIVATE o a terceros autorizados.\n\n5. Protección de datos\nLos datos personales se tratarán conforme al Reglamento (UE) 2016/679 (RGPD) y la normativa española vigente. El tratamiento se realiza para gestionar la relación con el socio y el funcionamiento de la Aplicación. El usuario puede ejercer sus derechos de acceso, rectificación, supresión, oposición, limitación y portabilidad mediante contacto con la entidad.\n\n6. Disponibilidad y responsabilidad\nTHE RING PRIVATE podrá actualizar, modificar o suspender la Aplicación por motivos técnicos, legales o de mantenimiento. Aunque se aplican medidas de seguridad, no se garantiza la disponibilidad absoluta ni la ausencia total de errores técnicos.\n\n7. Baja y eliminación de cuenta\nEl usuario puede solicitar la eliminación de su cuenta desde la sección de ajustes. Esta acción elimina el acceso y los datos asociados en los sistemas habilitados, salvo obligación legal de conservación.\n\n8. Legislación aplicable\nEstas condiciones se rigen por la legislación española. Cualquier controversia se someterá a los juzgados y tribunales competentes de Madrid, salvo disposición legal imperativa en contrario.";

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
                height: MediaQuery.of(context).size.height * 0.65,
                child: SingleChildScrollView(
                  child: Text(contenido, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87, fontSize: 15, height: 1.5)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA30000),
                  minimumSize: const Size(double.infinity, 55),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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

  Widget _buildPassRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(isMet ? Icons.check_circle : Icons.radio_button_unchecked, color: isMet ? Colors.green : Colors.grey[500], size: 16),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: isMet ? Colors.green : Colors.grey[500], fontSize: 13, fontWeight: isMet ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: TheRingPrivateApp.themeNotifier,
        builder: (context, currentTheme, _) {
          return ValueListenableBuilder<bool>(
              valueListenable: TheRingPrivateApp.isEnglishNotifier,
              builder: (context, isEng, _) {
                final isDarkMode = currentTheme == ThemeMode.dark;
                final scaffoldBgColor = isDarkMode ? const Color(0xFF000000) : const Color(0xFFF0F0F0);
                final cardBgColor = isDarkMode ? const Color(0xFF161616) : Colors.white;
                final textColor = isDarkMode ? Colors.white : Colors.black87;
                final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[400]!;

                final String logoPath = isDarkMode
                    ? 'lib/assets/logo_the_ring_transparente.png'
                    : 'lib/assets/logo_the_ring_transparente_negro.png';

                return Scaffold(
                  backgroundColor: scaffoldBgColor,
                  body: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Card(
                              margin: const EdgeInsets.only(top: 50, bottom: 20),
                              elevation: isDarkMode ? 0 : 10,
                              shadowColor: Colors.black26,
                              color: cardBgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(24)),
                                side: isDarkMode ? const BorderSide(color: Color(0xFF2A2A2A)) : BorderSide.none,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
                                        Expanded(child: Center(child: Text(isEng ? 'Create Account' : 'Crea tu cuenta', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)))),
                                        const SizedBox(width: 48),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    _buildRingInput(_nombreController, isEng ? 'Name' : 'Nombre', false, textColor, borderColor, cardBgColor),
                                    const SizedBox(height: 16),
                                    _buildRingInput(_apellidosController, isEng ? 'Surnames' : 'Apellidos', false, textColor, borderColor, cardBgColor),
                                    const SizedBox(height: 16),

                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cardBgColor,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _tipoDocumento,
                                          isExpanded: true,
                                          dropdownColor: cardBgColor,
                                          style: TextStyle(color: textColor, fontSize: 16),
                                          icon: Icon(Icons.arrow_drop_down, color: textColor),
                                          items: ['DNI/NIE', 'PASAPORTE'].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value == 'PASAPORTE' ? (isEng ? 'Passport' : 'Pasaporte') : value),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              _tipoDocumento = newValue!;
                                              _dniController.clear();
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    TextField(
                                      controller: _dniController,
                                      style: TextStyle(color: textColor),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(_tipoDocumento == 'DNI/NIE' ? 9 : 15),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: _tipoDocumento == 'DNI/NIE' ? 'DNI/NIE' : (isEng ? 'Passport Number' : 'Número de Pasaporte'),
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        filled: true,
                                        fillColor: cardBgColor,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: borderColor)),
                                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: Color(0xFFA30000), width: 2)),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    _buildRingInput(_emailController, isEng ? 'Email' : 'Correo Electrónico', false, textColor, borderColor, cardBgColor),
                                    const SizedBox(height: 16),

                                    TextField(
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      style: TextStyle(color: textColor),
                                      onChanged: (value) {
                                        setState(() {
                                          _hasMinLength = value.length >= 6;
                                          _hasUppercase = value.contains(RegExp(r'[A-Z]'));
                                          _hasSpecialChar = value.contains(RegExp(r'[^a-zA-Z0-9]'));
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: isEng ? 'Password' : 'Contraseña',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        filled: true,
                                        fillColor: cardBgColor,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: borderColor)),
                                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: const BorderSide(color: Color(0xFFA30000), width: 2)),
                                        suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(top: 12, left: 12, bottom: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildPassRequirement(isEng ? 'At least 6 characters' : 'Mínimo 6 caracteres', _hasMinLength),
                                          const SizedBox(height: 4),
                                          _buildPassRequirement(isEng ? 'At least 1 uppercase letter' : 'Al menos 1 letra mayúscula', _hasUppercase),
                                          const SizedBox(height: 4),
                                          _buildPassRequirement(isEng ? 'At least 1 special character' : 'Al menos 1 carácter especial', _hasSpecialChar),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _aceptaTerminos,
                                          activeColor: const Color(0xFFA30000),
                                          onChanged: (val) => setState(() => _aceptaTerminos = val!),
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () => _mostrarTerminos(isEng, isDarkMode),
                                                child: Text.rich(
                                                    TextSpan(
                                                        children: [
                                                          TextSpan(text: isEng ? 'I accept the ' : 'Acepto los ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                                          TextSpan(text: isEng ? 'terms and conditions' : 'términos y condiciones', style: const TextStyle(color: Color(0xFFA30000), fontSize: 13, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                                        ]
                                                    )
                                                )
                                            )
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFA30000),
                                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                            elevation: 4,
                                            shadowColor: const Color(0xFFA30000).withOpacity(0.5)
                                        ),
                                        onPressed: _isLoading ? null : () => _register(isEng),
                                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEng ? 'REGISTER' : 'REGISTRARSE', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Text(isEng ? 'Already have an account? Login' : '¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: -10,
                              child: Image.asset(
                                  logoPath,
                                  width: 150,
                                  height: 100,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  Widget _buildRingInput(TextEditingController controller, String hint, bool isPassword, Color textColor, Color borderColor, Color fillColor) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: borderColor)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: const BorderSide(color: Color(0xFFA30000), width: 2)),
        suffixIcon: isPassword ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) : null,
      ),
    );
  }
}