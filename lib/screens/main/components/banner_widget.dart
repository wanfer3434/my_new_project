import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../cart_provider.dart';
import '../../../models/BannerCard.dart';
import '../../chat_page.dart';
import '../../notifications_page.dart';

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

  static const String _baseUrl = 'https://javier-1.tail33d395.ts.net';

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

// ============================================================
// CARGAR BANNERS DESDE RUST
// ============================================================

  // AGREGA esta función arriba de tu clase
  Future<int> fetchYoutubeViews(String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) return 0;

    // Extrae ID: https://www.youtube.com/watch?v=ABC123 o https://youtu.be/ABC123
    String videoId = videoUrl;
    if (videoUrl.contains('v=')) {
      videoId = videoUrl.split('v=').last.split('&').first;
    } else if (videoUrl.contains('youtu.be/')) {
      videoId = videoUrl.split('youtu.be/').last.split('?').first;
    }
    videoId = videoId.trim();
    if (videoId.isEmpty) return 0;

    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/youtube/views?videoId=$videoId'),
      ).timeout(Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return (data['viewCount']?? 0) as int;
      }
    } catch (e) {
      debugPrint('Error youtube views: $e');
    }
    return 0;
  }

  Future<List<dynamic>> fetchBanners() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/banners'),
          )
          .timeout(
            const Duration(seconds: 6),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data;
      }

      debugPrint(
        'Error HTTP banners: ${response.statusCode}',
      );

      return [];
    } catch (e) {
      debugPrint(
        'Error cargando banners: $e',
      );

      return [];
    }
  }

// ============================================================
// AUTOPLAY DE BANNERS
// ============================================================

  void startAutoPlay(List<dynamic> bannerList) {
    if (bannerList.isEmpty) {
      return;
    }

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (Timer timer) {
        if (!_pageController.hasClients) {
          return;
        }

        int nextPage = _currentPage + 1;

        if (nextPage >= bannerList.length) {
          nextPage = 0;
        }

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(
            milliseconds: 500,
          ),
          curve: Curves.easeInOut,
        );

        _currentPage = nextPage;
      },
    );
  }

// ============================================================
// REGISTRAR CLICK DEL VIDEO
// ============================================================

  Future<void> incrementClick(int bannerId) async {
    try {
      await http.post(
        Uri.parse(
          '$_baseUrl/banners/click/$bannerId',
        ),
      );
    } catch (e) {
      debugPrint(
        'Error actualizando clicks: $e',
      );
    }
  }

// ============================================================
// AGREGAR PRODUCTO DEL BANNER AL CARRITO
// ============================================================

  void _addBannerToCart(
    BuildContext context,
    dynamic banner,
  ) {
    final cart = Provider.of<CartProvider>(
      context,
      listen: false,
    );

    final int id = ((banner['id'] ?? 0) as num).toInt();

    final String referencia =
        (banner['referencia'] ?? banner['nombre'] ?? 'Cámara').toString();

    final double costo = ((banner['costo'] ?? 0) as num).toDouble();

    final String archivoImagen = (banner['archivo_imagen'] ?? '').toString();

// ----------------------------------------------------------
// LA IMAGEN PRINCIPAL SIGUE USANDO LA URL PÚBLICA
// ----------------------------------------------------------

    final String imageUrl = '$_baseUrl/static/images/$archivoImagen';

    cart.addItem(
      id: id,
      name: referencia,
      price: costo,
      imageUrl: imageUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$referencia agregado al carrito',
        ),
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }

// ============================================================
// OBTENER MÚLTIPLES IMÁGENES DEL BANNER
// ============================================================

  List<String> _getBannerImages(dynamic banner) {
    final List<String> imageUrls = [];

// ----------------------------------------------------------
// IMÁGENES DEVUELTAS POR RUST
// ----------------------------------------------------------

    if (banner['imagenes'] is List) {
      for (final image in banner['imagenes']) {
        final String url = image.toString().trim();

        if (url.isNotEmpty && !imageUrls.contains(url)) {
          imageUrls.add(url);
        }
      }
    }

// ----------------------------------------------------------
// ASEGURAR QUE archivo_imagen TAMBIÉN ESTÉ
// ----------------------------------------------------------

    final String archivoImagen =
        (banner['archivo_imagen'] ?? '').toString().trim();

    if (archivoImagen.isNotEmpty) {
      final String principalUrl = '$_baseUrl/static/images/$archivoImagen';

      if (!imageUrls.contains(principalUrl)) {
        imageUrls.insert(
          0,
          principalUrl,
        );
      }
    }

    return imageUrls;
  }

// ============================================================
// BANNER DE RESPALDO
// ============================================================

  Widget _buildFallbackBanner(
    BuildContext context,
  ) {
    return SizedBox(
      height: _bannerHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
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

// ============================================================
// BUILD PRINCIPAL
// ============================================================

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: banners,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<dynamic>> snapshot,
      ) {
// --------------------------------------------------------
// CARGANDO
// --------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildFallbackBanner(context);
        }

// --------------------------------------------------------
// ERROR O SIN BANNERS
// --------------------------------------------------------

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildFallbackBanner(context);
        }

// --------------------------------------------------------
// BANNERS RECIBIDOS
// --------------------------------------------------------

        final List<dynamic> bannerList = snapshot.data!;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            startAutoPlay(bannerList);
          }
        });

        return SizedBox(
          height: _bannerHeight,
          child: Stack(
            children: [
// ==================================================
// PAGE VIEW PRINCIPAL DE BANNERS
// ==================================================

              PageView.builder(
                controller: _pageController,
                itemCount: bannerList.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (
                  BuildContext context,
                  int index,
                ) {
                  final dynamic banner = bannerList[index];

// ------------------------------------------------
// REFERENCIA
// ------------------------------------------------

                  final String referencia =
                      (banner['referencia'] ?? banner['nombre'] ?? 'Cámara')
                          .toString();

// ------------------------------------------------
// PRECIO
// ------------------------------------------------

                  final double costo =
                      ((banner['costo'] ?? 0) as num).toDouble();

// ------------------------------------------------
// IMAGEN PRINCIPAL
// ------------------------------------------------

                  final String archivoImagen =
                      (banner['archivo_imagen'] ?? '').toString();

                  final String imageUrl =
                      '$_baseUrl/static/images/$archivoImagen';

// ------------------------------------------------
// MÚLTIPLES IMÁGENES
// ------------------------------------------------

                  final List<String> imageUrls = _getBannerImages(banner);

// ------------------------------------------------
// VIDEO YOUTUBE
// ------------------------------------------------

                  final dynamic videoUrl = banner['video_url'];

// ------------------------------------------------
// TEXTO DEL BOTÓN
// ------------------------------------------------

                  final String buttonText =
                      (banner['button_text'] ?? 'Ver demostración').toString();

// ------------------------------------------------
// CLICKS
// ------------------------------------------------

                  final int clicks = ((banner['clicks'] ?? 0) as num).toInt();

// ------------------------------------------------
// ID DEL BANNER
// ------------------------------------------------

                  final int bannerId = ((banner['id'] ?? 0) as num).toInt();

// =================================================
// BANNER CARD
// =================================================

                  return BannerCard(
// Imagen principal
                    imageUrl: imageUrl,

// Todas las imágenes
                    imageUrls: imageUrls,

// Video YouTube
                    videoUrl: videoUrl,

                    videoButtonText: buttonText,

// Clicks
                    clicks: clicks,

// Producto
                    referencia: referencia,

                    costo: costo,

// Imagen de respaldo
                    fallbackAsset: _fallbackAsset,

// =================================================
// VER DEMOSTRACIÓN
// =================================================

                    onVideoClick: () {
                      incrementClick(
                        bannerId,
                      );
                    },

// =================================================
// AGREGAR AL CARRITO
// =================================================

                    onAddToCart: () {
                      _addBannerToCart(
                        context,
                        banner,
                      );
                    },
                  );
                },
              ),

// ====================================================
// BOTONES SUPERIORES
// ====================================================

              _buildOverlayButtons(context),

// ====================================================
// INDICADORES DE BANNERS
// ====================================================

              if (bannerList.length > 1)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      bannerList.length,
                      (index) {
                        return AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 200,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 3,
                          ),
                          width: _currentPage == index ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

// ============================================================
// BOTONES NOTIFICACIONES + CHAT
// ============================================================

  Widget _buildOverlayButtons(
    BuildContext context,
  ) {
    return Positioned(
      top: 10,
      right: 10,
      child: Column(
        children: [
// ======================================================
// NOTIFICACIONES
// ======================================================

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

// ======================================================
// CHAT
// ======================================================

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
