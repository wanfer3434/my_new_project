import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_new_project/models/category.dart';

class MarketCategoryCard extends StatelessWidget {
  final Category category;

  const MarketCategoryCard({Key? key, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: LinearGradient(
          colors: [category.begin, category.end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: category.imageUrls.first,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.black12),
              ),
            ),
          ),
          // Información
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // importante
              children: [
                // Nombre
                Text(
                  category.name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 2),
                // Descripción
                Text(
                  category.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Rating
                if (category.averageRating != null)
                  RatingBarIndicator(
                    rating: category.averageRating!,
                    itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Colors.yellow),
                    itemCount: 5,
                    itemSize: 18,
                    direction: Axis.horizontal,
                  ),
                const SizedBox(height: 4),
                // Botón WhatsApp
                if (category.whatsappUrl != null)
                  GestureDetector(
                    onTap: () async {
                      final url = category.whatsappUrl!;
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade700,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          "Contactar",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
