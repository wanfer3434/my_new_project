import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../chat_page.dart';
import '../../notifications_page.dart';
import 'banner_upload.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({Key? key}) : super(key: key);

  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  late Future<List<String>> banners;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    banners = fetchBanners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // Función para obtener banners de la API
  Future<List<String>> fetchBanners() async {
    try {
      final response = await http.get(
        Uri.parse('https://javier.tail33d395.ts.net/banners'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map((banner) =>
        'https://javier.tail33d395.ts.net/static/images/${banner['archivo_imagen']}')
            .toList();
      } else {
        return []; // Vacío para activar fallback
      }
    } catch (e) {
      return []; // Error → fallback
    }
  }

  void startAutoPlay(List<String> bannerList) {
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

  @override
  Widget build(BuildContext context) {
    Widget fallbackImage = Image.asset(
      'assets/samsun_roja_16mp.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
    );

    return FutureBuilder<List<String>>(
      future: banners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Si hay error o no hay data → mostrar imagen por defecto
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return Center(child: fallbackImage);
        }

        // Comenzar autoplay después de cargar los banners
        WidgetsBinding.instance.addPostFrameCallback((_) {
          startAutoPlay(snapshot.data!);
        });

        return Stack(
          children: [
            // Fondo con degradado
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white70,
                    Colors.white60,
                    Colors.white70,
                  ],
                ),
              ),
            ),

            // Carrusel de banners
            PageView.builder(
              controller: _pageController,
              itemCount: snapshot.data!.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final imageUrl = snapshot.data![index];

                return GestureDetector(
                  onTap: () {},
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },

                      // 🔥 Fallback si la imagen remota falla
                      errorBuilder: (context, error, stackTrace) {
                        return fallbackImage;
                      },
                    ),
                  ),
                );
              },
            ),

            // Botón flotante para subir banners
           /* BannerUpload.uploadButton(context, () {
              setState(() {
                banners = fetchBanners();
              });
            }),
*/
            // Botones de notificación y chat
            Positioned(
              top: 10,
              right: 5,
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Colors.deepPurple),
                    iconSize: 40,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => NotificationsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/icono_mensaje.png',
                      height: 40,
                      width: 40,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ChatScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
