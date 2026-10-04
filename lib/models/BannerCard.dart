import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerCard extends StatefulWidget {
  final String imageUrl;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? videoButtonText;
  final int clicks;
  final double imageHeight;
  final VoidCallback? onVideoClick;
  final String? referencia;
  final double? costo;
  final String fallbackAsset;
  final VoidCallback? onAddToCart;

  const BannerCard({
    Key? key,
    required this.imageUrl,
    required this.fallbackAsset,
    this.imageUrls = const [],
    this.videoUrl,
    this.videoButtonText,
    this.clicks = 0,
    this.imageHeight = 250.0,
    this.onVideoClick,
    this.referencia,
    this.costo,
    this.onAddToCart,
  }) : super(key: key);

  @override
  State<BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<BannerCard> {
  late List<String> _images;
  int _currentImage = 0;
  Timer? _imageTimer;

  // ESTA ES LA DIRECCIÓN QUE FALTABA - PON TU API PUBLICA AQUI
  static const String _baseUrl = 'https://javier-1.tail33d395.ts.net';
  // Cuando despliegues en Render cambia a: https://montitech-api.onrender.com

  // ============================================================
  // FUNCIÓN QUE FALTABA - AHORA SI ESTA DEFINIDA AQUI
  // ============================================================
  Future<int> fetchYoutubeViews(String? videoUrl) async {
    if (videoUrl == null || videoUrl.trim().isEmpty) {
      return widget.clicks;
    }

    String videoId = videoUrl.trim();

    try {
      // Extrae ID de shorts: /shorts/VIDEOID
      if (videoId.contains('/shorts/')) {
        videoId = videoId.split('/shorts/').last.split('?').first.split('&').first.split('/').first;
      }
      // Extrae ID de: watch?v=VIDEOID
      else if (videoId.contains('v=')) {
        videoId = videoId.split('v=').last.split('&').first;
      }
      // Extrae ID de: youtu.be/VIDEOID
      else if (videoId.contains('youtu.be/')) {
        videoId = videoId.split('youtu.be/').last.split('?').first;
      }

      // Limpia si queda si= o cosas extra y deja solo 11 caracteres
      videoId = videoId.split('?').first.split('&').first.trim();
      if (videoId.length > 11) {
        // Por si acaso, extrae los primeros 11 que es lo que mide un ID de YouTube
        final match = RegExp(r'[A-Za-z0-9_-]{11}').firstMatch(videoId);
        if (match != null) videoId = match.group(0)!;
      }

      if (videoId.isEmpty) return widget.clicks;

      final res = await http
          .get(Uri.parse('$_baseUrl/youtube/views?videoId=$videoId'))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final count = data['viewCount'];
        if (count is int) return count;
        if (count is String) return int.tryParse(count) ?? widget.clicks;
        return (count as num?)?.toInt() ?? widget.clicks;
      }
    } catch (e) {
      debugPrint('Error youtube views $videoUrl: $e');
    }
    return widget.clicks;
  }

  @override
  void initState() {
    super.initState();
    _prepareImages();
    _startImageAutoPlay();
  }

  @override
  void didUpdateWidget(covariant BannerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.imageUrls != widget.imageUrls) {
      _prepareImages();
    }
  }

  void _prepareImages() {
    final List<String> images = [];
    for (final image in widget.imageUrls) {
      final String url = image.trim();
      if (url.isNotEmpty && !images.contains(url)) {
        images.add(url);
      }
    }
    final String principal = widget.imageUrl.trim();
    if (principal.isNotEmpty && !images.contains(principal)) {
      images.insert(0, principal);
    }
    if (images.isEmpty) {
      images.add('');
    }
    _images = images;
    if (_currentImage >= _images.length) {
      _currentImage = 0;
    }
  }

  void _startImageAutoPlay() {
    _imageTimer?.cancel();
    if (_images.length <= 1) return;
    _imageTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _images.length <= 1) return;
      setState(() {
        _currentImage++;
        if (_currentImage >= _images.length) _currentImage = 0;
      });
    });
  }

  void _nextImage() {
    if (_images.length <= 1) return;
    setState(() {
      _currentImage++;
      if (_currentImage >= _images.length) _currentImage = 0;
    });
    _restartImageTimer();
  }

  void _previousImage() {
    if (_images.length <= 1) return;
    setState(() {
      _currentImage--;
      if (_currentImage < 0) _currentImage = _images.length - 1;
    });
    _restartImageTimer();
  }

  void _restartImageTimer() => _startImageAutoPlay();

  Future<void> _openVideo() async {
    if (widget.videoUrl == null || widget.videoUrl!.trim().isEmpty) return;
    final uri = Uri.parse(widget.videoUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      widget.onVideoClick?.call();
    }
  }

  Widget _buildImage() {
    final String currentUrl = _images[_currentImage];
    if (currentUrl.isEmpty) {
      return Image.asset(widget.fallbackAsset, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      key: ValueKey(currentUrl),
      imageUrl: currentUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Image.asset(widget.fallbackAsset, fit: BoxFit.cover),
      errorWidget: (context, url, error) => Image.asset(widget.fallbackAsset, fit: BoxFit.cover),
    );
  }

  Widget _buildImageIndicators() {
    if (_images.length <= 1) return const SizedBox.shrink();
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_images.length, (index) {
          final bool selected = index == _currentImage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: selected ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.white54,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildImageNavigation() {
    if (_images.length <= 1) return const SizedBox.shrink();
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32), onPressed: _previousImage),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white, size: 32), onPressed: _nextImage),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: SizedBox(
        height: widget.imageHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _buildImage(),
            ),
            _buildImageNavigation(),
            Positioned(
              left: 16,
              top: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.referencia != null && widget.referencia!.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                      child: Text(widget.referencia!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(height: 8),
                  if (widget.costo != null && widget.costo! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                      child: Text('\$${widget.costo!.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            if (widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty)
              Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<int>(
                      future: fetchYoutubeViews(widget.videoUrl),
                      builder: (context, snap) {
                        final views = snap.data ?? widget.clicks;
                        if (views == 0) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.visibility, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text('$views vistas', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: Text(widget.videoButtonText ?? 'Ver demostración'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white70, foregroundColor: Colors.black87),
                      onPressed: _openVideo,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Agregar al carrito'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                      onPressed: widget.onAddToCart,
                    ),
                  ],
                ),
              ),
            _buildImageIndicators(),
          ],
        ),
      ),
    );
  }
}
