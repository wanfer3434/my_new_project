import 'package:flutter/material.dart';
import 'service/rust_api_chat_service.dart'; // Asegúrate de tener esta clase
import 'product/product_response.dart'; // Clase que representa un producto
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final RustApiChatService _chatService = RustApiChatService();

  List<Map<String, dynamic>> chatHistory = [];

  // Función para enviar un mensaje y obtener el producto
  // Función para enviar un mensaje y obtener el producto
  void sendMessage(String userMessage) async {
    if (userMessage.isEmpty) return;

    setState(() {
      chatHistory.add({'type': 'user', 'message': userMessage});
    });

    _controller.clear();

    final List<ProductResponse> products = await _chatService.getProductMatch(userMessage);

    // Agrega este print para depuración
    print('Productos recibidos: $products');

    setState(() {
      if (products.isNotEmpty) {
        // Selecciona el primer producto de la lista
        final product = products[0];

        chatHistory.add({
          'type': 'bot',
          'message':
          'Producto: ${product.nombre}\nTipo: ${product.tipo}\nColor: ${product.color}\nPrecio: \$${product.precio}\nFecha agregado: ${product.fechaAgregado}',
          'image': product.imagenUrl,  // Asegúrate de que la URL de la imagen esté aquí
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


  // Mostrar las imágenes del producto en una galería con zoom
  void _showImageGallery(List<ProductResponse> products, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Imágenes del producto')),
          body: PhotoViewGallery.builder(
            itemCount: products.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(products[index].imagenUrl ?? ''),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: index),
          ),
        ),
      ),
    );
  }

  // Construir el widget para mostrar cada mensaje
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
              crossAxisAlignment: isUser ? CrossAxisAlignment.start : CrossAxisAlignment.start,
              children: [
                Text(message['message']),
                if (message['image'] != null && message['image'].isNotEmpty) ...[
                  // Mostrar la imagen si existe
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: GestureDetector(
                      onTap: () => _showImageGallery([message['image']], 0),  // Muestra solo una imagen
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
                  ),
                ],
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
                    decoration: InputDecoration(labelText: 'Escribe una referencia...'),
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
