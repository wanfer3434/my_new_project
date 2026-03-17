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

  const BannerCard({
    Key? key,
    required this.imageUrl,
    this.videoUrl,
    this.videoButtonText,
    this.clicks = 0,
    this.imageHeight = 250.0,
    this.onVideoClick,
  }) : super(key: key);

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
            placeholder: (context, url) => Container(
              height: imageHeight,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: imageHeight,
              color: Colors.amberAccent[300],
              child: const Center(child: Icon(Icons.error)),
            ),
          ),
          if (videoUrl != null)
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
                      backgroundColor: Colors.white60,
                    ),
                    onPressed: () async {
                      if (await canLaunchUrl(Uri.parse(videoUrl!))) {
                        await launchUrl(Uri.parse(videoUrl!));
                        if (onVideoClick != null) onVideoClick!();
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}