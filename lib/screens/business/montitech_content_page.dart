import 'package:flutter/material.dart';

class MontiTechContentPage extends StatefulWidget {
  const MontiTechContentPage({super.key});

  @override
  State<MontiTechContentPage> createState() =>
      _MontiTechContentPageState();
}

class _MontiTechContentPageState
    extends State<MontiTechContentPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        title: const Text("MontiTech YouTube"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ENCABEZADO
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Colors.black,
                  Colors.blueGrey,
                ],
              ),
            ),

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 45,
                ),

                SizedBox(height: 15),

                Text(
                  "MontiTech",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  "Centro de creación de contenido",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Crear contenido",
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),

              leading: const CircleAvatar(
                radius: 28,
                child: Icon(
                  Icons.camera_alt,
                  size: 28,
                ),
              ),

              title: const Text(
                "Crear contenido de una cámara",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                "Selecciona una cámara de tu inventario.",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),

              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Aquí conectaremos el inventario de cámaras.",
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Automatización",
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _buildAutomationCard(
            icon: Icons.title,
            title: "Título para YouTube",
            description: "Generar automáticamente.",
          ),

          _buildAutomationCard(
            icon: Icons.description,
            title: "Descripción",
            description: "Crear descripción basada en la cámara.",
          ),

          _buildAutomationCard(
            icon: Icons.video_library,
            title: "Shorts",
            description: "Preparar contenido corto.",
          ),

          _buildAutomationCard(
            icon: Icons.tag,
            title: "Hashtags",
            description: "Generar hashtags relacionados.",
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [

                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "Primero construiremos el generador de contenido. "
                        "Después conectaremos videos y YouTube.",
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),

      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(description),

        trailing: const Icon(
          Icons.lock_outline,
          size: 20,
        ),
      ),
    );
  }
}