import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../chat_page.dart';
import '../../notifications_page.dart';

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
    final response = await http.get(
      Uri.parse('https://javier.tail1d9055.ts.net/banners'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((banner) =>
      'https://javier.tail1d9055.ts.net/static/images/${banner['archivo_imagen']}'
      ).toList();
    } else {
      throw Exception('Error al cargar los banners');
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
    return FutureBuilder<List<String>>(
      future: banners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los banners'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay banners disponibles'));
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
                    Colors.orange.shade900,
                    Colors.orange.shade600,
                    Colors.orange.shade300,
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
                return GestureDetector(
                  onTap: () {
                    // Acción al tocar el banner (opcional)
                  },
                  child: Container(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      child: Image.network(
                        snapshot.data![index],
                        width: double.infinity,
  height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.cover,
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
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 50, color: Colors.red),
                              SizedBox(height: 10),
                              Text('Error al cargar la imagen', style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Botones de notificación y chat
            Positioned(
              top: 40,
              right: 16,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.deepPurple),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => NotificationsPage()),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/icono_mensaje.png',
                      height: 32,
                      width: 32,
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
