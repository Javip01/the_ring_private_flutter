import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class StaffChatScreen extends StatefulWidget {
  const StaffChatScreen({super.key});

  @override
  State<StaffChatScreen> createState() => _StaffChatScreenState();
}

class _StaffChatScreenState extends State<StaffChatScreen> {
  final _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _miEmailSafe = "";
  late DatabaseReference _dbRef;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _miEmailSafe = user.email?.replaceAll('.', '_') ?? "anonimo";
      // El chat se guarda en una sala exclusiva para este usuario
      _dbRef = FirebaseDatabase.instance.ref("ChatStaff").child(_miEmailSafe);
    }
  }

  @override
  void dispose() {
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
      'remitente': 'user', // Identificador de quién lo envía
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
            // --- CABECERA PÍLDORA STAFF ---
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)]),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Soporte / STAFF', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Te responderemos pronto', style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12)),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    backgroundColor: Color(0xFFA30000),
                    child: Icon(Icons.support_agent, color: Colors.white),
                  )
                ],
              ),
            ),

            // --- LISTA DE MENSAJES (1 a 1) ---
            Expanded(
              child: StreamBuilder(
                stream: _dbRef.orderByChild('timestamp').onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFA30000)));

                  final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                  if (data == null) {
                    return const Center(child: Text('Hola, ¿en qué podemos ayudarte?', style: TextStyle(color: Colors.white54, fontSize: 16)));
                  }

                  final List<Map<dynamic, dynamic>> mensajes = [];
                  data.forEach((key, value) => mensajes.add(value));
                  mensajes.sort((a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: mensajes.length,
                    itemBuilder: (context, index) {
                      final msg = mensajes[index];
                      // Si el remitente es "user", el mensaje es tuyo. Si es "staff", es de la app.
                      bool esMio = msg['remitente'] == 'user';

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
                              if (!esMio) const Padding(padding: EdgeInsets.only(left: 4, bottom: 2), child: Text('STAFF The Ring', style: TextStyle(color: Color(0xFFA30000), fontSize: 13, fontWeight: FontWeight.bold))),
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

            // --- BARRA INPUT FLOTANTE ---
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
                        hintText: 'Mensaje para el STAFF...',
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