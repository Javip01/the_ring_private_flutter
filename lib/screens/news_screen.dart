import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _filtroActual = 'Todas';
  List<Map<dynamic, dynamic>> _noticias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Escucha el nodo "Noticias" de Firebase de forma global
    FirebaseDatabase.instance.ref("Noticias").onValue.listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final List<Map<dynamic, dynamic>> tempList = [];
        data.forEach((key, value) => tempList.add({...value, 'id': key}));
        // Ordenar por fecha (las más recientes primero)
        tempList.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
        setState(() {
          _noticias = tempList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _noticias = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Aplicar filtros locales
    final noticiasFiltradas = _filtroActual == 'Todas'
        ? _noticias
        : _noticias.where((n) => n['tipo'] == _filtroActual).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // --- CABECERA PÍLDORA (Como en tu XML) ---
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)]),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const Expanded(child: Text('Tablón de Noticias', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                ],
              ),
            ),

            // --- FILTROS (CHIPS) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFiltro('Todas'),
                  const SizedBox(width: 8),
                  _buildFiltro('Eventos'),
                  const SizedBox(width: 8),
                  _buildFiltro('Importante'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- LISTA DE NOTICIAS O ESTADO VACÍO ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFA30000)))
                  : noticiasFiltradas.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: noticiasFiltradas.length,
                itemBuilder: (context, index) {
                  final item = noticiasFiltradas[index];
                  return _buildNoticiaCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltro(String titulo) {
    bool activo = _filtroActual == titulo;
    return GestureDetector(
      onTap: () => setState(() => _filtroActual = titulo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? const Color(0xFFA30000) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: activo ? Border.all(color: Colors.white30, width: 1) : null,
        ),
        child: Text(titulo, style: TextStyle(color: activo ? Colors.white : const Color(0xFFAAAAAA), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNoticiaCard(Map item) {
    bool esImportante = item['tipo'] == 'Importante';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: esImportante ? Border.all(color: const Color(0xFFA30000), width: 1) : null),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(esImportante ? Icons.warning_rounded : Icons.info, color: esImportante ? const Color(0xFFA30000) : Colors.white54, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['titulo'] ?? 'Sin título', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item['mensaje'] ?? '', style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.notifications_off, size: 80, color: Color(0xFF333333)),
        SizedBox(height: 16),
        Text('Todo al día', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('No hay noticias nuevas del club.', style: TextStyle(color: Color(0xFF666666), fontSize: 16)),
      ],
    );
  }
}