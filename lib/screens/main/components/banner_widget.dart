import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
      final response = await http.get(
        Uri.parse('https://javier.tail33d395.ts.net/banners'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        return [];
      }
    } catch (e) {
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
        Uri.parse('https://javier.tail33d395.ts.net/banners/click/$bannerId'),
      );
    } catch (e) {
      debugPrint('Error actualizando clicks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackImage = Image.asset(
      'assets/samsun_roja_16mp.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 280,
    );

    return FutureBuilder<List<dynamic>>(
      future: banners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 280,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 280,
            child: Stack(
              children: [
                Positioned.fill(child: fallbackImage),
                _buildOverlayButtons(context),
              ],
            ),
          );
        }

        final bannerList = snapshot.data!;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          startAutoPlay(bannerList);
        });

        return SizedBox(
          height: 280,
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
                  final costo = (banner['costo'] ?? 0).toDouble();
                  final imageUrl =
                      'https://javier.tail33d395.ts.net/static/images/${banner['archivo_imagen']}';
                  final videoUrl = banner['video_url'];
                  final buttonText =
                      banner['button_text'] ?? 'Ver demostración';
                  final clicks = banner['clicks'] ?? 0;

                  return BannerCard(
                    imageUrl: imageUrl,
                    videoUrl: videoUrl,
                    videoButtonText: buttonText,
                    clicks: clicks,
                    onVideoClick: () => incrementClick(banner['id']),
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
                    builder: (_) => NotificationsPage(),
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