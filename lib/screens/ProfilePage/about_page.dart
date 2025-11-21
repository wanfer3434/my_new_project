import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("Quiénes Somos"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quiénes Somos",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Somos una tienda especializada en accesorios móviles, estuches, "
                  "cámaras digitales, audífonos, cargadores y más. "
                  "Nacimos con la misión de ofrecer tecnología de calidad a precios accesibles.",
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            SizedBox(height: 20),
            Text(
              "💡 Nuestro Compromiso",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "- Productos 100% nuevos.\n"
                  "- Atención personalizada.\n"
                  "- Envíos rápidos y seguros.\n"
                  "- Precios competitivos y ofertas reales.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              "📍 Dónde estamos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "Atendemos en Colombia y hacemos envíos a nivel nacional.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 25),
            Center(
              child: Icon(
                Icons.store_mall_directory,
                color: Colors.black,
                size: 60,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Tu Tienda Tecnológica",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
