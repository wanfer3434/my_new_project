import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'product/product_response.dart';
import 'service/rust_api_chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RustApiChatService _chatService = RustApiChatService();

  final List<_ChatItem> _chatHistory = [];
  final Map<String, int> _carouselIndexes = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _chatHistory.add(
      _ChatItem.botText(
        'Hola 👋\n'
            'Puedo ayudarte a encontrar cámaras digitales, estuches para celular y otras referencias.\n\n'
            'Ejemplos:\n'
            '• “Muéstrame una Sony rosada”\n'
            '• “Busco cámara Samsung ES95”\n'
            '• “Necesito estuche para iPhone 13 Pro Max”',
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  List<String> _parseImages(String? imageValue) {
    if (imageValue == null || imageValue.trim().isEmpty) return [];

    return imageValue
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  bool _isLegalMessage(String text) {
    final lower = text.toLowerCase();
    return lower.contains("abogado") ||
        lower.contains("asesoría") ||
        lower.contains("asesoria") ||
        lower.contains("legal");
  }

  Future<void> sendMessage(String userMessage) async {
    final message = userMessage.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _chatHistory.add(_ChatItem.user(message));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      if (_isLegalMessage(message)) {
        final respuesta = await _chatService.getChatbotResponse(message);

        setState(() {
          _chatHistory.add(_ChatItem.botText(respuesta));
        });

        await _scrollToBottom();
        return;
      }

      final List<ProductResponse> products =
      await _chatService.getProductMatch(message);

      setState(() {
        if (products.isNotEmpty) {
          for (final product in products) {
            final images = _parseImages(product.imagen);

            final cardId =
                '${product.referencia}_${DateTime.now().microsecondsSinceEpoch}';

            _carouselIndexes[cardId] = 0;

            _chatHistory.add(
              _ChatItem.botProduct(
                id: cardId,
                referencia: (product.referencia ?? '').trim(),
                precio: product.precio ?? 0,
                imagenes: images,
              ),
            );
          }
        } else {
          _chatHistory.add(
            _ChatItem.botText(
              'No encontré una coincidencia exacta.\n'
                  'Intenta escribiendo algo más específico, por ejemplo:\n'
                  '• marca\n'
                  '• color\n'
                  '• megapíxeles\n'
                  '• referencia del celular',
            ),
          );
        }
      });

      await _scrollToBottom();
    } catch (e) {
      setState(() {
        _chatHistory.add(
          _ChatItem.botText(
            'Ocurrió un error consultando el catálogo. Intenta nuevamente.',
          ),
        );
      });
      await _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImageGallery(List<String> imageUrls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Imágenes del producto'),
            backgroundColor: Colors.black,
          ),
          body: PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            pageController: PageController(initialPage: initialIndex),
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatPrice(double? price) {
    if (price == null || price <= 0) return 'Consultar precio';
    return '\$${price.toStringAsFixed(0)}';
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _QuickAskChip(
            label: 'Cámaras Samsung',
            onTap: () => sendMessage('Muéstrame cámaras Samsung'),
          ),
          _QuickAskChip(
            label: 'Sony rosada',
            onTap: () => sendMessage('Busco cámara Sony rosada'),
          ),
          _QuickAskChip(
            label: 'Canon',
            onTap: () => sendMessage('Muéstrame cámaras Canon'),
          ),
          _QuickAskChip(
            label: 'Estuche celular',
            onTap: () => sendMessage('Necesito estuche para celular'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatItem item) {
    final isUser = item.type == _MessageType.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.84,
          ),
          child: isUser ? _buildUserBubble(item) : _buildBotMessage(item),
        ),
      ),
    );
  }

  Widget _buildUserBubble(_ChatItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        item.message ?? '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildBotMessage(_ChatItem item) {
    if (item.product != null) {
      return _ProductCard(
        product: item.product!,
        currentIndex: _carouselIndexes[item.product!.id] ?? 0,
        onPageChanged: (index) {
          setState(() {
            _carouselIndexes[item.product!.id] = index;
          });
        },
        onImageTap: (index) {
          _showImageGallery(item.product!.imagenes, index);
        },
        formatPrice: _formatPrice,
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SelectableText(
          item.message ?? '',
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catálogo Asistente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildQuickActions(),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _chatHistory.length) {
                    return const _TypingBubble();
                  }
                  return _buildMessage(_chatHistory[index]);
                },
              ),
            ),
            _Composer(
              controller: _controller,
              isLoading: _isLoading,
              onSend: () => sendMessage(_controller.text),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MessageType { user, bot }

class _ChatItem {
  final _MessageType type;
  final String? message;
  final _ProductCardData? product;

  _ChatItem({
    required this.type,
    this.message,
    this.product,
  });

  factory _ChatItem.user(String text) {
    return _ChatItem(
      type: _MessageType.user,
      message: text,
    );
  }

  factory _ChatItem.botText(String text) {
    return _ChatItem(
      type: _MessageType.bot,
      message: text,
    );
  }

  factory _ChatItem.botProduct({
    required String id,
    required String referencia,
    required double precio,
    required List<String> imagenes,
  }) {
    return _ChatItem(
      type: _MessageType.bot,
      product: _ProductCardData(
        id: id,
        referencia: referencia,
        precio: precio,
        imagenes: imagenes,
      ),
    );
  }
}

class _ProductCardData {
  final String id;
  final String referencia;
  final double precio;
  final List<String> imagenes;

  _ProductCardData({
    required this.id,
    required this.referencia,
    required this.precio,
    required this.imagenes,
  });
}

class _ProductCard extends StatelessWidget {
  final _ProductCardData product;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onImageTap;
  final String Function(double?) formatPrice;

  const _ProductCard({
    required this.product,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onImageTap,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = product.imagenes.isNotEmpty;
    final hasRef = product.referencia.trim().isNotEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImages) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CarouselSlider.builder(
                  itemCount: product.imagenes.length,
                  itemBuilder: (context, index, realIndex) {
                    final imageUrl = product.imagenes[index];

                    return GestureDetector(
                      onTap: () => onImageTap(index),
                      child: Hero(
                        tag: imageUrl,
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('Imagen no disponible'),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 220,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    autoPlay: product.imagenes.length > 1,
                    onPageChanged: (index, reason) => onPageChanged(index),
                  ),
                ),
              ),
              if (product.imagenes.length > 1) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(product.imagenes.length, (index) {
                    final isActive = index == currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isActive ? 18 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.deepPurple : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
                ),
              ],
              const SizedBox(height: 12),
            ],
            Text(
              hasRef ? product.referencia : 'Producto disponible',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatPrice(product.precio),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: product.precio > 0 ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: hasRef
                      ? () async {
                    await Clipboard.setData(
                      ClipboardData(text: product.referencia),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Referencia copiada'),
                        ),
                      );
                    }
                  }
                      : null,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copiar referencia'),
                ),
                ElevatedButton.icon(
                  onPressed: hasRef
                      ? () async {
                    final texto = 'Hola, estoy interesado en: ${product.referencia}'
                        '${product.precio > 0 ? ' por ${formatPrice(product.precio)}' : ''}';
                    await Clipboard.setData(ClipboardData(text: texto));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mensaje copiado'),
                        ),
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('Copiar mensaje'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Escribe una cámara, color o referencia...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: isLoading ? null : onSend,
              child: SizedBox(
                width: 52,
                height: 52,
                child: isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('Buscando en el catálogo...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAskChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAskChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.deepPurple.withOpacity(0.08),
      labelStyle: const TextStyle(
        color: Colors.deepPurple,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}