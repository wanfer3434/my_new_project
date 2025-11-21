import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("Política de Privacidad"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Política de Privacidad",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "En nuestra tienda tecnológica valoramos y respetamos tu privacidad. "
                  "La información que recopilemos será utilizada únicamente para mejorar "
                  "tu experiencia y facilitar tus compras.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              "📌 Información que recolectamos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              "- Información básica de contacto (si el cliente decide escribirnos).\n"
                  "- No almacenamos datos personales en la aplicación.\n"
                  "- No realizamos seguimiento individual de usuarios.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),
            Text(
              "🔒 Seguridad",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              "Tomamos medidas de seguridad para proteger tu información. "
                  "Ningún dato se comparte con terceros sin tu consentimiento.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),
            Text(
              "© ${DateTime.now().year} Tu Tienda Tecnológica",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
