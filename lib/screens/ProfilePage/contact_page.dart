import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  final String phone = "573209120172";
  final String email = "wanfer2121@gmail.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("Contacto"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contáctanos",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),

            // WHATSAPP
            ListTile(
              leading: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
              title: Text("WhatsApp"),
              subtitle: Text("+57 320 912 0172"),
              onTap: () async {
                final url = 'https://wa.me/573209120172?text=Hola%20quiero%20más%20info%20de%20tu%20tienda%20tecnológica';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
            ),

            // EMAIL
            ListTile(
              leading: Icon(Icons.email, color: Colors.red, size: 32),
              title: Text("Correo Electrónico"),
              subtitle: Text(email),
              onTap: () async {
                final url = "mailto:$email";
                launchUrl(Uri.parse(url));
              },
            ),

            // FACEBOOK
            ListTile(
              leading: Icon(Icons.facebook, color: Colors.blue, size: 32),
              title: Text("Facebook"),
              subtitle: Text("Síguenos en Facebook"),
              onTap: () async {
                final url = "https://www.facebook.com/profile.php?id=61571004556866";
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
            ),

            Spacer(),

            Center(
              child: Text(
                "© ${DateTime.now().year} Tu Tienda Tecnológica",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
