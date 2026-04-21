The Ring Private App
The Ring Private es la aplicación móvil exclusiva para los socios del club. Diseñada con un enfoque premium en la experiencia de usuario (UX) y la seguridad, esta app permite a los miembros gestionar su acceso al recinto, comunicarse con soporte en tiempo real y personalizar su entorno digital.

📑 Índice
Características Principales

Tecnologías Utilizadas

Manual de Usuario

Inicio de Sesión y Registro

Acceso Seguro al Club (Pase QR VIP)

Soporte Inmediato (WhatsApp Premium)

Personalización Inmersiva (Menú Superior)

Navegación Principal (Home)

Detalles Técnicos y UX/UI Avanzada

Instalación (Para Desarrolladores)

✨ Características Principales
Autenticación Dual: Acceso seguro mediante DNI o Correo Electrónico.

Pase Dinámico Anti-Fraude: Código QR de acceso que se regenera cada 60 segundos automáticamente.

Botón de Soporte "Flotante e Inteligente": Un botón de WhatsApp arrastrable con físicas personalizadas (Aura repelente) para no solaparse con elementos clave.

UI Reactiva al 100%: Cambio de Tema (Claro/Oscuro) y de Idioma (ES/EN) instantáneo sin necesidad de reiniciar la app ni recargar pantallas.

🛠 Tecnologías Utilizadas
Framework: Flutter (Dart)

Backend y Base de Datos: Firebase Auth, Firebase Realtime Database

Integraciones: url_launcher (Para comunicación con WhatsApp), qr_flutter (Generación de códigos).

Gestión de Estado: ValueNotifier para animaciones y cambios de estado de alto rendimiento (60 FPS).

📖 Manual de Usuario (Cómo usar la app)
Este apartado detalla el funcionamiento de cada sección de la aplicación para garantizar que cualquier socio o miembro del staff sepa utilizarla en su totalidad.

1. Inicio de Sesión y Registro
   Al abrir la aplicación, el socio se encontrará con la pantalla de bienvenida.

Login: El sistema permite iniciar sesión ingresando el DNI o el Correo Electrónico. El sistema detecta automáticamente el formato y lo vincula con la base de datos segura.

Registro: Si un usuario aún no tiene cuenta, puede pulsar en "¿No tienes cuenta? Regístrate" para crear sus credenciales.

Ajustes Rápidos: Desde la misma pantalla de login, se puede cambiar el idioma y el tema antes de entrar, para adaptar la vista a las condiciones de luz del usuario.

2. Acceso Seguro al Club (Pase QR VIP)
   El elemento central de la aplicación es el acceso físico al club.

¿Cómo acceder? En la pantalla principal (Home), el socio encontrará un botón circular rojo prominente fijado en la parte inferior central.

El Código: Al pulsarlo, se desplegará una tarjeta inferior (Bottom Sheet) oscureciendo el fondo. Aquí se mostrará un código QR único para el socio.

Seguridad (Anti-Capturas): Debajo del QR hay un temporizador rojo. Por seguridad del club, el QR caduca y se regenera cada 1 minuto. El personal de puerta no aceptará capturas de pantalla antiguas.

3. Soporte Inmediato (WhatsApp Premium)
   Para resolver dudas o gestionar reservas, la app cuenta con una línea directa con el club.

Botón Libre: Verás el icono de WhatsApp flotando en la pantalla. Este botón no está fijo; puedes mantener pulsado y arrastrarlo con tu dedo a cualquier rincón de la pantalla para que no te tape información importante.

Inteligencia del botón: Si intentas soltar el botón de WhatsApp encima del botón rojo del QR, notarás que tiene un "campo de fuerza" (Aura repelente). El botón de WhatsApp se deslizará suavemente hacia un lado para asegurar que el botón de acceso al club siempre pueda ser pulsado.

Contacto: Con solo tocar el icono de WhatsApp, la app te redirigirá automáticamente al chat oficial de soporte del club.

4. Personalización Inmersiva (Menú Superior)
   En la esquina superior derecha de la pantalla principal verás un icono de tres líneas (Menú).

Al tocarlo, se desplegará un menú elegante con una animación fluida.

Idioma: Permite alternar entre Español (🇪🇸) e Inglés (🇬🇧). El texto de toda la aplicación cambiará al instante.

Apariencia: Permite cambiar entre el Modo Claro (ideal para el día) y el Modo Oscuro (ideal para cuando estás dentro del club y no quieres que la pantalla brille demasiado).

Más Opciones (Ajustes): Un botón inferior te llevará a la pantalla completa de configuración de tu cuenta.

5. Navegación Principal (Home)
   La pantalla principal actúa como el tablón digital del socio:

Notificaciones: Un panel central donde el club avisará de eventos VIP, cambios de normas o alertas importantes.

Perfil: Un botón grande para acceder a los datos personales, gestionar la membresía o actualizar la foto de perfil.

Normas: Acceso rápido al reglamento interno de The Ring.

🧠 Detalles Técnicos y UX/UI Avanzada
Para los desarrolladores y diseñadores involucrados, la app incluye implementaciones destacadas a nivel de código:

Físicas de Arrastre (Spring Physics): El botón de WhatsApp utiliza lecturas directas del hardware del táctil junto con cálculos trigonométricos (math.atan2, math.cos, math.sin) para detectar colisiones con el botón QR y calcular una repulsión radial matemática.

Animaciones por GPU: El menú desplegable no utiliza recargas de rutas, sino que está pre-cargado en un Stack y utiliza ScaleTransition y FadeTransition para garantizar una animación de entrada/salida a 60/120 FPS sin tirones de procesador.

Estado Reactivo Global: Se han utilizado ValueNotifier en la raíz de la app (main.dart) para inyectar cambios de Tema e Idioma que la aplicación escucha y aplica en tiempo real sin estado intermedio.

💻 Instalación (Para Desarrolladores)
Clona este repositorio. Al ser un repositorio privado, asegúrate de tener los permisos necesarios en tu cuenta de GitHub y/o usar tu token/clave SSH:

Bash
git clone https://github.com/Javip01/the_ring_private_flutter.git
Entra en el directorio del proyecto:

Bash
cd the_ring_private_flutter
Asegúrate de tener instalado el SDK de Flutter (>=3.0.0).

Ejecuta el comando para descargar las dependencias:

Bash
flutter pub get
Configura Firebase:

Asegúrate de tener los archivos google-services.json (Android) y GoogleService-Info.plist (iOS) proporcionados por el administrador del proyecto en sus carpetas respectivas.

Ejecuta la aplicación:

Bash
flutter run
(Nota: Para experimentar la fluidez real de las animaciones personalizadas del botón flotante y el menú a 60 FPS, se recomienda compilar usando flutter run --release).


HAY QUE ORGANIZAR AMBAS PARTES


# 📖 Documentación del Proyecto: The Ring Private

## 1. ¿Qué es la app y de qué va?
**The Ring Private** es una aplicación móvil exclusiva diseñada para la gestión integral de acceso, comunicación y experiencia de usuario de un club privado. Su objetivo principal es digitalizar y asegurar el ecosistema del club, sustituyendo los carnets físicos tradicionales por un sistema de acceso dinámico y cifrado, al mismo tiempo que centraliza las notificaciones y el soporte en tiempo real para los usuarios.

## 2. ¿Para quién está dirigida?
La plataforma está diseñada para dos perfiles principales:
* **Socios / Miembros VIP:** Usuarios que han adquirido una membresía en el club. Utilizan la app para identificarse en puerta, leer las normativas, recibir notificaciones de eventos y contactar con el staff.
* **Staff y Personal de Seguridad:** Aunque la app principal es para el socio, el personal de seguridad interactúa con ella validando visual o digitalmente los códigos de acceso generados.

## 3. ¿Quién la desarrolló?
El diseño, la arquitectura de software y el desarrollo completo de la aplicación han sido llevados a cabo por **Mauricio Javier Pérez Gavilanes**.

## 4. ¿Cómo funciona? (Resumen de Flujo)
El funcionamiento de la app es directo y seguro:
1.  **Autenticación:** Al abrir la aplicación, el usuario debe identificarse mediante DNI o Correo y contraseña contra una base de datos segura.
2.  **Dashboard:** Una vez dentro, la pantalla principal (**Home**) actúa como un panel de control donde el usuario visualiza notificaciones y accede a su perfil.
3.  **Acciones Críticas:** Desde la Home, el usuario puede realizar las dos funciones principales: generar su pase de acceso inmediato o solicitar soporte técnico mediante el botón flotante.

## 5. Funciones Relevantes ("Funciones Tochas")
El software ha sido desarrollado utilizando **Flutter (Dart)** para el frontend móvil y **Firebase (Google)** para la autenticación y base de datos en la nube.

* **Sistema de Acceso Seguro Dinámico (QR):** Para evitar suplantaciones de identidad y el uso de capturas de pantalla, la app genera un código QR único vinculado al ID del usuario. Este código cuenta con un temporizador de seguridad que se destruye y **regenera automáticamente cada 60 segundos**.
* **Motor de Físicas Personalizado (Aura Repelente):** El botón de soporte (WhatsApp) es un elemento flotante que el usuario puede arrastrar libremente por toda la pantalla (optimizado mediante GPU). Incluye un algoritmo matemático (`math.atan2`) que detecta la cercanía con el botón principal del QR y lo **repele magnéticamente**, garantizando que los elementos vitales de la interfaz nunca se solapen.
* **UI Reactiva en Tiempo Real (Estado Global):** Mediante el uso de `ValueNotifier`, la aplicación permite cambiar el idioma (Inglés/Español) y el tema de apariencia (Modo Claro/Oscuro) de forma instantánea. No requiere pantallas de carga ni reiniciar la app para aplicar los cambios.
* **Autenticación Inteligente:** El sistema de Login detecta automáticamente si el usuario ingresa un correo electrónico o un DNI, mapeando el DNI a su registro interno correspondiente en Firebase de forma transparente para el usuario.

## 6. Casos de Uso (Estructura para Diagramas)

### Caso de Uso 1: Validación en Puerta (Control de Acceso)
* **Actor:** Socio VIP.
* **Flujo:** El socio llega al club → Abre la app → Pulsa el botón central (QR) → El sistema genera un token temporal → Se muestra el código con cuenta atrás de 60s → El personal de seguridad valida el código → Acceso concedido.

### Caso de Uso 2: Asistencia Inmediata (Soporte)
* **Actor:** Socio VIP.
* **Flujo:** El socio requiere asistencia → Localiza el icono flotante de WhatsApp → Lo pulsa → El sistema inyecta un mensaje predefinido → Se abre la app nativa de WhatsApp redirigiendo al contacto oficial de la empresa.

### Caso de Uso 3: Autenticación de Usuario (Login)
* **Actor:** Socio.
* **Flujo:** El usuario introduce credenciales (DNI/Password) → La app cifra los datos → Firebase valida el token → El sistema carga el perfil y redirige a la Home.

## 7. Versiones y Especificaciones de Hardware/Software
Para un rendimiento óptimo de las animaciones y la conexión en tiempo real:

* **Versión Actual:** `1.0.0+1`
* **Requisitos Android:** Android 6.0 (API 23) o superior. Recomendado dispositivos de 64 bits (ARM64).
* **Requisitos iOS:** iOS 12.0 o superior (iPhone 6s en adelante).
* **Hardware Común:** * Conexión a Internet activa (4G/5G/Wi-Fi).
   * Pantalla táctil capacitiva.
   * Cámara funcional (para futuras implementaciones de foto de perfil).
