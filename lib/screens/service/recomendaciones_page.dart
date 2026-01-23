import 'package:flutter/material.dart';
import 'package:my_new_project/screens/service/rust_api_chat_service.dart'; // Tu clase de API
import 'package:my_new_project/models/recomendacion_stock_response.dart';

class RecomendacionesPage extends StatefulWidget {
  const RecomendacionesPage({super.key});

  @override
  State<RecomendacionesPage> createState() => _RecomendacionesPageState();
}

class _RecomendacionesPageState extends State<RecomendacionesPage> {
  final api = RustApiChatService();
  bool cargando = true;
  List<RecomendacionStockResponse> recomendaciones = [];

  @override
  void initState() {
    super.initState();
    cargarRecomendaciones(); // 👈 AQUÍ se llama
  }

  Future<void> cargarRecomendaciones() async {
    final data = await api.getRecomendacionStock();

    setState(() {
      recomendaciones = data;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📦 Recomendado para surtir')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: recomendaciones.length,
        itemBuilder: (context, index) {
          final r = recomendaciones[index];

          return ListTile(
            leading: const Icon(Icons.trending_up, color: Colors.green),
            title: Text(r.producto),
            subtitle: Text(
                'Vendidos últimos 7 días: ${r.vendidos7Dias}'),
            trailing: Text(
              'Stock: ${r.stock}',
              style: TextStyle(
                color: r.stock <= 5 ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
