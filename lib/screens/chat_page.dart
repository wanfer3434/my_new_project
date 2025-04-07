import 'package:flutter/material.dart';
import 'service/rust_api_chat_service.dart'; // Asegúrate de tener esta clase
import 'product/product_response.dart'; // Clase que representa un producto

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final RustApiChatService _chatService = RustApiChatService();

  List<Map<String, dynamic>> chatHistory = [];

  void sendMessage(String userMessage) async {
    if (userMessage.isEmpty) return;

    setState(() {
      chatHistory.add({'type': 'user', 'message': userMessage});
    });

    _controller.clear();

    final product = await _chatService.getProductMatch(userMessage);

    setState(() {
      if (product != null) {
        chatHistory.add({
          'type': 'bot',
          'message':
              'Producto: ${product.nombre}\nTipo: ${product.tipo}\nColor: ${product.color}\nPrecio: \$${product.precio}\nFecha agregado: ${product.fechaAgregado}',
          'image': product.imagenUrl,
        });
      } else {
        chatHistory.add({
          'type': 'bot',
          'message': 'Lo siento, no encontré ese producto.',
          'image': null,
        });
      }
    });
  }

  Widget buildMessage(Map<String, dynamic> message) {
    final isUser = message['type'] == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isUser ? Icons.person : Icons.smart_toy),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.start : CrossAxisAlignment.start,
              children: [
                Text(message['message']),
                if (message['image'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message['image'],
                        height: 160,
                        width: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Text('Imagen no disponible'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatbot Productos")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                return buildMessage(chatHistory[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        InputDecoration(labelText: 'Escribe una referencia...'),
                    onSubmitted: sendMessage,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
