import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../chat_page.dart';
import '../../notifications_page.dart';
import 'chat_page.dart';

class BannerPage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const BannerPage({
    Key? key,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 📌 **FONDO CON DEGRADADO**
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.3, // 40% de la pantalla
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

        /// 📌 **BANNER IMAGEN**
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Image.network(
                imageUrl,
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
                errorBuilder: (context, error, stackTrace) => Center(
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
        ),

        /// 📌 **BOTONES DE NOTIFICACIÓN Y CHAT**
        Positioned(
          top: 40, // Ajusta la altura según el diseño
          right: 16,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.deepPurple),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => NotificationsPage()),
                  );
                },
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Image.asset(
                  'assets/icons/icono_mensaje.png',
                  height: 32,
                  width: 32, // Si quieres darle un color al icono
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
  }
}
