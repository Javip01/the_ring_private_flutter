import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class GlobalChatScreen extends StatefulWidget {
  const GlobalChatScreen({super.key});

  @override
  State<GlobalChatScreen> createState() => _GlobalChatScreenState();
}

class _GlobalChatScreenState extends State<GlobalChatScreen> {
  final _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("ChatGlobal");

  String _miEmailSafe = "";
  String _miNombre = "Socio";

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _miEmailSafe = user.email?.replaceAll('.', '_') ?? "";
      _miNombre = user.displayName ?? "Socio";

      // Lógica de "En línea"
      final onlineRef = FirebaseDatabase.instance.ref("ChatGlobalOnline").child(_miEmailSafe);
      onlineRef.set(_miNombre);
      onlineRef.onDisconnect().remove();
    }
  }

  @override
  void dispose() {
    if (_miEmailSafe.isNotEmpty) FirebaseDatabase.instance.ref("ChatGlobalOnline").child(_miEmailSafe).remove();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _enviarMensaje() {
    final texto = _msgController.text.trim();
    if (texto.isEmpty) return;

    final nuevoMsgRef = _dbRef.push();
    nuevoMsgRef.set({
      'id': nuevoMsgRef.key,
      'texto': texto,
      'remitente': _miNombre,
      'emailRemitente': _miEmailSafe,
      'timestamp': ServerValue.timestamp,
    });

    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // --- CABECERA PÍLDORA (XML) ---
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)]),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const Expanded(child: Text('Chat Global', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                  // Contador Online (StreamBuilder)
                  StreamBuilder(
                    stream: FirebaseDatabase.instance.ref("ChatGlobalOnline").onValue,
                    builder: (context, snapshot) {
                      int count = 0;
                      if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                        count = (snapshot.data!.snapshot.value as Map).length;
                      }
                      return Text('$count online', style: const TextStyle(color: Color(0xFF00FF00), fontSize: 13, fontWeight: FontWeight.bold));
                    },
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.info_outline, color: Colors.white, size: 28),
                ],
              ),
            ),

            // --- LISTA DE MENSAJES ---
            Expanded(
              child: StreamBuilder(
                stream: _dbRef.orderByChild('timestamp').onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Error al cargar', style: TextStyle(color: Colors.white)));
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFA30000)));

                  final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                  if (data == null) return const Center(child: Text('Sé el primero en escribir...', style: TextStyle(color: Colors.white54)));

                  final List<Map<dynamic, dynamic>> mensajes = [];
                  data.forEach((key, value) => mensajes.add(value));
                  mensajes.sort((a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));

                  // Auto-scroll al final
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: mensajes.length,
                    itemBuilder: (context, index) {
                      final msg = mensajes[index];
                      bool esMio = msg['emailRemitente'] == _miEmailSafe;

                      // Formato de hora simple (HH:mm)
                      DateTime fecha = DateTime.fromMillisecondsSinceEpoch(msg['timestamp'] ?? 0);
                      String horaStr = "${fecha.hour.toString().padLeft(2,'0')}:${fecha.minute.toString().padLeft(2,'0')}";

                      return Align(
                        alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          child: Column(
                            crossAxisAlignment: esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (!esMio) Padding(padding: const EdgeInsets.only(left: 4, bottom: 2), child: Text(msg['remitente'] ?? 'Socio', style: const TextStyle(color: Color(0xFFA30000), fontSize: 13, fontWeight: FontWeight.bold))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: esMio ? const Color(0xFFA30000) : const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(child: Text(msg['texto'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16))),
                                    const SizedBox(width: 12),
                                    Text(horaStr, style: TextStyle(color: esMio ? const Color(0xFFFFCCCC) : const Color(0xFF999999), fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // --- BARRA DE INPUT FLOTANTE (XML) ---
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)]),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: TextStyle(color: Color(0xFF666666)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFA30000), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _enviarMensaje,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}