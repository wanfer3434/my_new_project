import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';

import '../../../cart_provider.dart';
import '../../chat_page.dart';
import '../../notifications_page.dart';
import '../../../models/BannerCard.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({Key? key}) : super(key: key);

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  late Future<List<dynamic>> banners;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  static const double _bannerHeight = 280;
  static const String _fallbackAsset = 'assets/camarasDigitales.jpeg';
  static const String _baseUrl = 'https://javier.tail33d395.ts.net';

  @override
  void initState() {
    super.initState();
    banners = fetchBanners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchBanners() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/banners'))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error cargando banners: $e');
      return [];
    }
  }

  void startAutoPlay(List<dynamic> bannerList) {
    if (bannerList.isEmpty) return;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= bannerList.length) {
          nextPage = 0;
        }

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        _currentPage = nextPage;
      }
    });
  }

  void incrementClick(int bannerId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/banners/click/$bannerId'),
      );
    } catch (e) {
      debugPrint('Error actualizando clicks: $e');
    }
  }

  void _addBannerToCart(BuildContext context, dynamic banner) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    final int id = banner['id'] ?? 0;
    final String referencia =
    (banner['referencia'] ?? banner['nombre'] ?? 'Cámara').toString();
    final double costo = ((banner['costo'] ?? 0) as num).toDouble();
    final String imageUrl =
        '$_baseUrl/static/images/${banner['archivo_imagen']}';

    cart.addItem(
      id: id,
      name: referencia,
      price: costo,
      imageUrl: imageUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$referencia agregado al carrito'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFallbackBanner(BuildContext context) {
    return SizedBox(
      height: _bannerHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Image.asset(
                _fallbackAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Cámaras y accesorios disponibles',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildOverlayButtons(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: banners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildFallbackBanner(context);
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildFallbackBanner(context);
        }

        final bannerList = snapshot.data!;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          startAutoPlay(bannerList);
        });

        return SizedBox(
          height: _bannerHeight,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: bannerList.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final banner = bannerList[index];
                  final referencia = banner['referencia'];
                  final double costo = ((banner['costo'] ?? 0) as num).toDouble();
                  final String imageUrl =
                      '$_baseUrl/static/images/${banner['archivo_imagen']}';
                  final videoUrl = banner['video_url'];
                  final buttonText =
                      banner['button_text'] ?? 'Ver demostración';
                  final clicks = banner['clicks'] ?? 0;

                  return BannerCard(
                    imageUrl: imageUrl,
                    videoUrl: videoUrl,
                    videoButtonText: buttonText,
                    clicks: clicks,
                    referencia: referencia,
                    costo: costo,
                    fallbackAsset: _fallbackAsset,
                    onVideoClick: () => incrementClick(banner['id']),
                    onAddToCart: () => _addBannerToCart(context, banner),
                  );
                },
              ),
              _buildOverlayButtons(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverlayButtons(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.deepPurple,
              ),
              iconSize: 32,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Image.asset(
                'assets/icons/icono_mensaje.png',
                height: 32,
                width: 32,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}