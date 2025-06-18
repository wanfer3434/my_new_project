import 'package:flutter/material.dart';
import 'service/rust_api_chat_service.dart'; // Tu clase de API
import 'product/product_response.dart'; // Modelo del producto
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final RustApiChatService _chatService = RustApiChatService();
  List<Map<String, dynamic>> chatHistory = [];
  int _currentImgIndex = 0;

  void sendMessage(String userMessage) async {
    if (userMessage.isEmpty) return;

    setState(() {
      chatHistory.add({'type': 'user', 'message': userMessage});
    });

    _controller.clear();

    final String lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains("abogado") || lowerMessage.contains("asesoría") || lowerMessage.contains("legal")) {
      // Solicitar solo respuesta textual
      final respuesta = await _chatService.getChatbotResponse(userMessage);
      setState(() {
        chatHistory.add({
          'type': 'bot',
          'message': respuesta,
          'image': [], // Sin imágenes ni precios
        });
      });
      return;
    }

    // Para otros mensajes, obtener productos
    final List<ProductResponse> products = await _chatService.getProductMatch(userMessage);

    setState(() {
      if (products.isNotEmpty) {
        for (var product in products) {
          chatHistory.add({
            'type': 'bot',
            'message': 'Referencia: ${product.referencia}\nPrecio: \$${product.precio}',
            'image': product.imagen != null
                ? product.imagen!.split(',').map((e) => e.trim()).toList()
                : [],
          });
        }
      } else {
        chatHistory.add({
          'type': 'bot',
          'message': 'Lo siento, no encontré ese producto.',
          'image': [],
        });
      }
    });
  }

  void _showImageGallery(List<String> imageUrls, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Imágenes del producto')),
          body: PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: index),
          ),
        ),
      ),
    );
  }

  Widget buildMessage(Map<String, dynamic> message) {
    final isUser = message['type'] == 'user';

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(message['message']),
          ),
        ),
      );
    }

    final List<String> imageUrls = List<String>.from(message['image'] ?? []);
    final String content = message['message'];

    final RegExp referenciaRegex = RegExp(r"Referencia:\s*(.*)");
    final RegExp precioRegex = RegExp(r"Precio:\s*\$(.*)");

    final String referencia = referenciaRegex.firstMatch(content)?.group(1) ?? "";
    final String precio = precioRegex.firstMatch(content)?.group(1) ?? "";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrls.isNotEmpty) ...[
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: imageUrls.length,
                          itemBuilder: (context, imgIndex, realIndex) {
                            return GestureDetector(
                              onTap: () => _showImageGallery(imageUrls, imgIndex),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrls[imgIndex],
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Text('Imagen no disponible'),
                                ),
                              ),
                            );
                          },
                          options: CarouselOptions(
                            height: 200,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            onPageChanged: (index, reason) {
                              setState(() => _currentImgIndex = index);
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: imageUrls.asMap().entries.map((entry) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImgIndex == entry.key
                                    ? Colors.blueAccent
                                    : Colors.grey,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
              // Si no hay imagenes, mostramos solo el mensaje (como en el caso de asesoría legal)
              if (imageUrls.isEmpty) ...[
                Text(
                  content,
                  style: const TextStyle(fontSize: 16),
                ),
              ] else ...[
                Text(
                  'Referencia: $referencia',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Precio: \$$precio',
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Catálogo Asistente",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
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
                    decoration: const InputDecoration(
                      labelText: 'Escribe una referencia...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.deepPurple,
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
