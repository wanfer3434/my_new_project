import 'package:flutter/material.dart';
import 'service/rust_api_chat_service.dart'; // Tu clase de API
import 'product/product_response.dart'; // Modelo del producto
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

  void sendMessage(String userMessage) async {
    if (userMessage.isEmpty) return;

    setState(() {
      chatHistory.add({'type': 'user', 'message': userMessage});
    });

    _controller.clear();

    final List<ProductResponse> products = await _chatService.getProductMatch(userMessage);

    print('Productos recibidos: $products');

    setState(() {
      if (products.isNotEmpty) {
        final product = products[0];

        // CORREGIDO: Acceder a lista de imágenes, no a una sola imagen
        List<String> imageUrls = product.imagenUrls ?? [];

        chatHistory.add({
          'type': 'bot',
          'message':
          'Producto: ${product.nombre}\nTipo: ${product.tipo}\nColor: ${product.color}\nPrecio: \$${product.precio}\nFecha agregado: ${product.fechaAgregado}',
          'image': imageUrls,
        });
      } else {
        chatHistory.add({
          'type': 'bot',
          'message': 'Lo siento, no encontré ese producto.',
          'image': [],
        });
      }
    });
    ;
  }

  void _showImageGallery(List<String> imageUrls, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Imágenes del producto')),
          body: PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrls[index]),
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
                // Mostrar las imágenes solo si están disponibles
              if (message['image'] != null && message['image'].isNotEmpty) ...[
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: message['image'].length,
                    separatorBuilder: (context, index) => SizedBox(width: 8),
                    itemBuilder: (context, imgIndex) {
                        return GestureDetector(
                           onTap: () => _showImageGallery(message['image'], imgIndex),
                           child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                              message['image'][imgIndex],
                              width: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                Text('Imagen no disponible'),
                              ),
                           ),
                        );
                        },
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
