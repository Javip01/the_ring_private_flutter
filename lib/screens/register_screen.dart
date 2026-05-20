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
  String? _paisPasaporte = 'España';

  // Lista Completa de Países en Español
  final List<String> _listaTodosLosPaises = [
    'Afganistán', 'Albania', 'Alemania', 'Andorra', 'Angola', 'Antigua y Barbuda', 'Arabia Saudita',
    'Argelia', 'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaiyán', 'Bahamas', 'Bangladés',
    'Barbados', 'Baréin', 'Bélgica', 'Belice', 'Benín', 'Bielorrusia', 'Birmania', 'Bolivia',
    'Bosnia y Herzegovina', 'Botsuana', 'Brasil', 'Brunéi', 'Bulgaria', 'Burkina Faso', 'Burundi',
    'Bután', 'Cabo Verde', 'Camboya', 'Camerún', 'Canadá', 'Catar', 'Chad', 'Chile', 'China', 'Chipre',
    'Colombia', 'Comoras', 'Corea del Norte', 'Corea del Sur', 'Costa de Marfil', 'Costa Rica', 'Croacia',
    'Cuba', 'Dinamarca', 'Dominica', 'Ecuador', 'Egipto', 'El Salvador', 'Emiratos Árabes Unidos',
    'Eritrea', 'Eslovaquia', 'Eslovenia', 'España', 'Estados Unidos', 'Estonia', 'Etiopía', 'Filipinas',
    'Finlandia', 'Fiyi', 'Francia', 'Gabón', 'Gambia', 'Georgia', 'Ghana', 'Granada', 'Grecia',
    'Guatemala', 'Guinea', 'Guinea Ecuatorial', 'Guinea-Bisáu', 'Guyana', 'Haití', 'Honduras', 'Hungría',
    'India', 'Indonesia', 'Irak', 'Irán', 'Irlanda', 'Islandia', 'Islas Marshall', 'Islas Salomón',
    'Israel', 'Italia', 'Jamaica', 'Japón', 'Jordania', 'Kazajistán', 'Kenia', 'Kirguistán', 'Kiribati',
    'Kuwait', 'Laos', 'Lesoto', 'Letonia', 'Líbano', 'Liberia', 'Libia', 'Liechtenstein', 'Lituania',
    'Luxemburgo', 'Macedonia del Norte', 'Madagascar', 'Malasia', 'Malaui', 'Maldivas', 'Malí', 'Malta',
    'Marruecos', 'Mauricio', 'Mauritania', 'México', 'Micronesia', 'Moldavia', 'Mónaco', 'Mongolia',
    'Montenegro', 'Mozambique', 'Namibia', 'Nauru', 'Nepal', 'Nicaragua', 'Níger', 'Nigeria', 'Noruega',
    'Nueva Zelanda', 'Omán', 'Países Bajos', 'Pakistán', 'Palaos', 'Panamá', 'Papúa Nueva Guinea',
    'Paraguay', 'Perú', 'Polonia', 'Portugal', 'Reino Unido', 'República Centroafricana', 'República Checa',
    'República del Congo', 'República Democrática del Congo', 'República Dominicana', 'Ruanda', 'Rumania',
    'Rusia', 'Samoa', 'San Cristóbal y Nieves', 'San Marino', 'San Vicente y las Granadinas', 'Santa Lucía',
    'Santo Tomé y Príncipe', 'Senegal', 'Serbia', 'Seychelles', 'Sierra Leona', 'Singapur', 'Siria',
    'Somalia', 'Sri Lanka', 'Suazilandia', 'Sudáfrica', 'Sudán', 'Sudán del Sur', 'Suecia', 'Suiza',
    'Surinam', 'Tailandia', 'Tanzania', 'Tayikistán', 'Timor Oriental', 'Togo', 'Tonga', 'Trinidad y Tobago',
    'Túnez', 'Turkmenistán', 'Turquía', 'Tuvalu', 'Ucrania', 'Uganda', 'Uruguay', 'Uzbekistán', 'Vanuatu',
    'Vaticano', 'Venezuela', 'Vietnam', 'Yemen', 'Yibuti', 'Zambia', 'Zimbabue'
  ];

  bool _validarDNIoNIE(String dnioNie) {
    String dni = dnioNie.toUpperCase().trim();
    final regex = RegExp(r'^[XYZ]?\d{7,8}[A-Z]$');
    if (!regex.hasMatch(dni)) return false;

    const String letrasDNI = "TRWAGMYFPDXBNJZSQVHLCKE";
    String prefijo = dni.substring(0, 1);
    String numeros = dni.substring(0, dni.length - 1);
    String letraFinal = dni.substring(dni.length - 1);

    if (prefijo == 'X') numeros = numeros.replaceFirst('X', '0');
    else if (prefijo == 'Y') numeros = numeros.replaceFirst('Y', '1');
    else if (prefijo == 'Z') numeros = numeros.replaceFirst('Z', '2');

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

      String uid = cred.user!.uid;

      await FirebaseDatabase.instance.ref("MapeoDNI").child(documento).set(signupEmail);

      await FirebaseDatabase.instance.ref("usuarios").child(uid).set({
        "acceptedTerms": _aceptaTerminos,
        "documento": documento,
        "email": signupEmail,
        "name": nombre,
        "surname": apellidos,
        "tipoDocumento": _tipoDocumento,
        "paisPasaporte": _tipoDocumento == 'PASAPORTE' ? _paisPasaporte : null,
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

  // --- POPUP BUSCADOR DE PAÍSES ---
  void _mostrarDialogoPaises(Color bgColor, Color textColor) {
    TextEditingController searchController = TextEditingController();
    List<String> paisesFiltrados = List.from(_listaTodosLosPaises);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: "Buscar país...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: bgColor == Colors.white ? Colors.grey[200] : const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) {
                        setStateModal(() {
                          paisesFiltrados = _listaTodosLosPaises
                              .where((pais) => pais.toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: paisesFiltrados.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(paisesFiltrados[index], style: TextStyle(color: textColor)),
                          onTap: () {
                            setState(() {
                              _paisPasaporte = paisesFiltrados[index];
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- POPUP IDIOMA ---
  void _mostrarDialogoIdioma() {
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<ThemeMode>(
          valueListenable: TheRingPrivateApp.themeNotifier,
          builder: (context, currentTheme, _) {
            return ValueListenableBuilder<bool>(
                valueListenable: TheRingPrivateApp.isEnglishNotifier,
                builder: (context, isEng, _) {
                  bool isDark = currentTheme == ThemeMode.dark;
                  return Dialog(
                    backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.translate, color: Color(0xFFA30000), size: 20),
                                  const SizedBox(width: 8),
                                  Text(isEng ? 'LANGUAGE' : 'IDIOMA', style: const TextStyle(color: Color(0xFFA30000), fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              IconButton(icon: Icon(Icons.close, color: Colors.grey[500]), onPressed: () => Navigator.pop(context))
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => TheRingPrivateApp.isEnglishNotifier.value = false,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(color: !isEng ? const Color(0xFFA30000).withOpacity(0.1) : Colors.transparent, borderRadius: const BorderRadius.all(Radius.circular(12))),
                                    child: Center(child: Text('🇪🇸 ES', style: TextStyle(color: !isEng ? const Color(0xFFA30000) : (isDark ? Colors.white : Colors.black), fontSize: 16, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ),
                              Container(height: 30, width: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                              Expanded(
                                child: InkWell(
                                  onTap: () => TheRingPrivateApp.isEnglishNotifier.value = true,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(color: isEng ? const Color(0xFFA30000).withOpacity(0.1) : Colors.transparent, borderRadius: const BorderRadius.all(Radius.circular(12))),
                                    child: Center(child: Text('🇬🇧 EN', style: TextStyle(color: isEng ? const Color(0xFFA30000) : (isDark ? Colors.white : Colors.black), fontSize: 16, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }
            );
          }
      ),
    );
  }

  // --- POPUP MANUAL ---
  void _mostrarManual() {
    bool isEng = TheRingPrivateApp.isEnglishNotifier.value;
    bool isDark = TheRingPrivateApp.themeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF161616) : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: bgColor,
        insetPadding: const EdgeInsets.all(20),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(isEng ? 'User Manual' : 'Manual de Usuario', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor))),
                  IconButton(icon: Icon(Icons.close, color: Colors.grey[500]), onPressed: () => Navigator.pop(context))
                ],
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: isEng ? _buildManualTextEN(textColor) : _buildManualTextES(textColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA30000),
                  minimumSize: const Size(double.infinity, 55),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(isEng ? 'ACCEPT' : 'ACEPTAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarTerminos(bool isEng, bool isDark) {
    String titulo =
    isEng ? 'Terms and Conditions' : 'Términos y Condiciones';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      isDark ? const Color(0xFF000000) : const Color(0xFFF9F9F9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[500]),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color:
                        isDark ? Colors.grey[300] : Colors.black87,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      children: isEng
                          ? const [

                        TextSpan(
                          text:
                          'These Terms and Conditions regulate the download, access, and use of the THE RING PRIVATE application (hereinafter, the Application). Access and use imply express acceptance of these conditions.\n\n',
                        ),

                        TextSpan(
                          text: '1. Object\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'The Application aims to manage member identification, facilitate internal notices, and improve the club access experience. Its use is personal and non-transferable.\n\n',
                        ),

                        TextSpan(
                          text: '2. User Registration\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'To create an account, the user must provide real and valid data (name, surname, ID, and email). The user is responsible for keeping their password safe and not sharing it.\n\n',
                        ),

                        TextSpan(
                          text: '3. Rules of Use\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'The user agrees to use the Application lawfully and respectfully. It is prohibited to manipulate, copy, decompile, alter, or reuse the Application\'s content without express authorization.\n\n',
                        ),

                        TextSpan(
                          text: '4. Intellectual Property\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'All intellectual and industrial property rights over the Application belong to THE RING PRIVATE or authorized third parties.\n\n',
                        ),

                        TextSpan(
                          text: '5. Data Protection\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'Personal data will be processed according to the GDPR and current Spanish regulations. The user can exercise their rights of access, rectification, deletion, opposition, limitation, and portability by contacting the entity.\n\n',
                        ),

                        TextSpan(
                          text:
                          '6. Availability and Responsibility\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'THE RING PRIVATE may update, modify, or suspend the Application for technical or legal reasons. Absolute availability is not guaranteed.\n\n',
                        ),

                        TextSpan(
                          text: '7. Account Deletion\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'The user can request account deletion from the settings section. This action eliminates access and associated data in enabled systems, except for legal retention obligations.\n\n',
                        ),

                        TextSpan(
                          text: '8. Applicable Legislation\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'These conditions are governed by Spanish law. Any controversy will be submitted to the competent courts and tribunals of Madrid, unless a mandatory legal provision states otherwise.',
                        ),
                      ]
                          : const [

                        TextSpan(
                          text:
                          'Estos Términos y Condiciones regulan la descarga, el acceso y el uso de la aplicación THE RING PRIVATE (en adelante, la Aplicación). El acceso y uso de la Aplicación implica la aceptación expresa de estas condiciones.\n\n',
                        ),

                        TextSpan(
                          text: '1. Objeto\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'La Aplicación tiene como finalidad gestionar la identificación de socios, facilitar la comunicación de avisos internos y mejorar la experiencia de acceso al club. Su uso es personal e intransferible.\n\n',
                        ),

                        TextSpan(
                          text: '2. Registro de usuario\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'Para crear una cuenta, el usuario debe facilitar datos reales y vigentes (nombre, apellidos, documento de identidad y correo electrónico). El usuario es responsable de custodiar su contraseña y de no compartirla con terceros.\n\n',
                        ),

                        TextSpan(
                          text: '3. Normas de uso\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'El usuario se compromete a utilizar la Aplicación de forma lícita, respetuosa y conforme a la normativa aplicable. Queda prohibido manipular, copiar, descompilar, alterar o reutilizar el contenido de la Aplicación sin autorización expresa.\n\n',
                        ),

                        TextSpan(
                          text: '4. Propiedad intelectual\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'Todos los derechos de propiedad intelectual e industrial sobre la Aplicación, su diseño, textos, marcas y elementos gráficos pertenecen a THE RING PRIVATE o a terceros autorizados.\n\n',
                        ),

                        TextSpan(
                          text: '5. Protección de datos\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'Los datos personales se tratarán conforme al Reglamento (UE) 2016/679 (RGPD) y la normativa española vigente. El tratamiento se realiza para gestionar la relación con el socio y el funcionamiento de la Aplicación.\n\n',
                        ),
                        TextSpan(
                          text:
                          'El usuario puede ejercer sus derechos de acceso, rectificación, supresión, oposición, limitación y portabilidad mediante contacto con la entidad.\n\n',
                        ),

                        TextSpan(
                          text:
                          '6. Disponibilidad y responsabilidad\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'THE RING PRIVATE podrá actualizar, modificar o suspender la Aplicación por motivos técnicos, legales o de mantenimiento. Aunque se aplican medidas de seguridad, no se garantiza la disponibilidad absoluta ni la ausencia total de errores técnicos.\n\n',
                        ),

                        TextSpan(
                          text:
                          '7. Baja y eliminación de cuenta\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'El usuario puede solicitar la eliminación de su cuenta desde la sección de ajustes. Esta acción elimina el acceso y los datos asociados en los sistemas habilitados, salvo obligación legal de conservación.\n\n',
                        ),

                        TextSpan(
                          text: '8. Legislación aplicable\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                          'Estas condiciones se rigen por la legislación española. Cualquier controversia se someterá a los juzgados y tribunales competentes de Madrid, salvo disposición legal imperativa en contrario.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA30000),
                  minimumSize: const Size(double.infinity, 55),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  isEng ? 'ACCEPT' : 'ACEPTAR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualTextES(Color textColor) {
    return Text.rich(
      TextSpan(
        style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
        children: const [
          TextSpan(text: 'Bienvenido a la aplicación oficial de '),
          TextSpan(text: 'The Ring Private', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '. Esta guía explica cada paso para que puedas usar la app sin dudas.\n\n'),
          TextSpan(text: '1. Registro de cuenta\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Pulsa '), TextSpan(text: 'Registrarse', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' en la pantalla inicial.\n'),
          TextSpan(text: '2. Introduce: nombre, apellidos, DNI/NIE/Pasaporte, correo electrónico y contraseña.\n'),
          TextSpan(text: '3. La contraseña debe tener mínimo 6 caracteres, 1 mayúscula y 1 símbolo especial.\n'),
          TextSpan(text: '4. Marca la casilla de aceptación de términos y condiciones.\n'),
          TextSpan(text: '5. Pulsa '), TextSpan(text: 'Registrarse', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' para completar el alta.\n\n'),
          TextSpan(text: '2. Inicio de sesión\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Introduce tu correo o DNI y tu contraseña.\n'),
          TextSpan(text: '2. Pulsa '), TextSpan(text: 'Iniciar sesión', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: '.\n'),
          TextSpan(text: '3. Si olvidaste tu contraseña, pulsa '), TextSpan(text: '¿Olvidaste tu contraseña?', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' y sigue el proceso de recuperación dentro de la app.\n\n'),
          TextSpan(text: '3. Soporte\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: 'Si tienes un problema técnico, contacta por email en: '),
          TextSpan(text: 'theringprivate@gmail.com\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildManualTextEN(Color textColor) {
    return Text.rich(
      TextSpan(
        style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
        children: const [
          TextSpan(text: 'Welcome to the official '),
          TextSpan(text: 'The Ring Private', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' app. This guide explains every step so you can use the app without any doubts.\n\n'),
          TextSpan(text: '1. Account Registration\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Tap '), TextSpan(text: 'Register', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' on the initial screen.\n'),
          TextSpan(text: '2. Enter: name, surnames, ID/Passport, email, and password.\n'),
          TextSpan(text: '3. Password must have a minimum of 6 characters, 1 uppercase, and 1 special symbol.\n'),
          TextSpan(text: '4. Check the terms and conditions acceptance box.\n'),
          TextSpan(text: '5. Tap '), TextSpan(text: 'Register', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' to complete the sign-up.\n\n'),
          TextSpan(text: '2. Login\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: '1. Enter your email or ID and your password.\n'),
          TextSpan(text: '2. Tap '), TextSpan(text: 'Login', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: '.\n'),
          TextSpan(text: '3. If you forgot your password, tap '), TextSpan(text: 'Forgot your password?', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' and follow the recovery process.\n\n'),
          TextSpan(text: '3. Support\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(text: 'If you have a technical problem, contact us by email at: '),
          TextSpan(text: 'theringprivate@gmail.com\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
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

                                    // SELECTOR DE DOCUMENTO
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

                                    // SELECTOR DE PAÍS CON POP-UP (Para Pasaporte)
                                    if (_tipoDocumento == 'PASAPORTE') ...[
                                      InkWell(
                                        onTap: () => _mostrarDialogoPaises(cardBgColor, textColor),
                                        borderRadius: BorderRadius.circular(30),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                          decoration: BoxDecoration(
                                            color: cardBgColor,
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(color: borderColor),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(_paisPasaporte ?? (isEng ? 'Select country' : 'Selecciona un país'), style: TextStyle(color: textColor, fontSize: 16)),
                                              Icon(Icons.arrow_drop_down, color: textColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],

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

                                    // FILA INFERIOR: IDIOMA Y MANUAL
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: _mostrarDialogoIdioma,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.translate, color: Color(0xFFA30000), size: 18),
                                              const SizedBox(width: 6),
                                              Text(isEng ? '🇬🇧 EN' : '🇪🇸 ES', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        Container(width: 1, height: 20, color: borderColor),
                                        InkWell(
                                          onTap: _mostrarManual,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.menu_book, color: Colors.grey, size: 18),
                                              const SizedBox(width: 6),
                                              Text(isEng ? 'Manual' : 'Manual', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: -10,
                              child: Image.asset(logoPath, width: 150, height: 100, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50)),
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