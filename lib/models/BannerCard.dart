import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerCard extends StatelessWidget {
  final String imageUrl;
  final String? videoUrl;
  final String? videoButtonText;
  final int clicks;
  final double imageHeight;
  final VoidCallback? onVideoClick;
  final String? referencia;
  final double? costo;

  const BannerCard({
    Key? key,
    required this.imageUrl,
    this.videoUrl,
    this.videoButtonText,
    this.clicks = 0,
    this.imageHeight = 250.0,
    this.onVideoClick,
    this.referencia,
    this.costo,
  }) : super(key: key);

  Future<void> _openVideo() async {
    if (videoUrl == null || videoUrl!.trim().isEmpty) return;

    final uri = Uri.parse(videoUrl!);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      onVideoClick?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => SizedBox(
              height: imageHeight,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: imageHeight,
              color: Colors.amberAccent[300],
              child: const Center(child: Icon(Icons.error)),
            ),
          ),

          Positioned(
            left: 16,
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (referencia != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      referencia!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (costo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '\$${costo!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (videoUrl != null && videoUrl!.trim().isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$clicks ${clicks == 1 ? "vista" : "vistas"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: Text(videoButtonText ?? 'Ver demostración'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: _openVideo,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}