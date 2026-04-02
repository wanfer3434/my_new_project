import 'package:flutter/material.dart';
import 'package:my_new_project/screens/admin/banner_admin_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text('Centro de negocio'),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildSectionTitle('Acciones rápidas'),
            const SizedBox(height: 10),
            _buildActionCard(
              context,
              icon: Icons.campaign,
              title: 'Administrar banners',
              subtitle:
              'Sube imágenes, pega videos y organiza el banner rotativo de cámaras y accesorios.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BannerAdminPage(),
                  ),
                );
              },
            ),
            _buildActionCard(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Inventario y referencias',
              subtitle:
              'Consulta y organiza referencias de cámaras, estuches, vidrios, cargadores y accesorios.',
              onTap: () {
                _showComingSoon(context, 'Inventario y referencias');
              },
            ),
            _buildActionCard(
              context,
              icon: Icons.bar_chart,
              title: 'Métricas del negocio',
              subtitle:
              'Revisa clics en banners, productos con poco stock y rendimiento general.',
              onTap: () {
                _showComingSoon(context, 'Métricas del negocio');
              },
            ),
            _buildActionCard(
              context,
              icon: Icons.people_alt_outlined,
              title: 'Leads y clientes',
              subtitle:
              'Visualiza contactos interesados en cámaras y accesorios para darles seguimiento.',
              onTap: () {
                _showComingSoon(context, 'Leads y clientes');
              },
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Recordatorios útiles'),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.info_outline,
              title: 'Consejo para vender más',
              description:
              'Mantén los primeros banners con tus cámaras más llamativas, precio visible y video de demostración.',
            ),
            _buildInfoCard(
              icon: Icons.image_outlined,
              title: 'Imágenes recomendadas',
              description:
              'Usa fotos claras, fondo limpio y nombres bien organizados para que el banner cargue sin errores.',
            ),
            _buildInfoCard(
              icon: Icons.smartphone,
              title: 'Promociona accesorios',
              description:
              'Puedes combinar banner de cámara con promoción de estuche, vidrio y cargador para aumentar preguntas.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xff4A148C),
            Color(0xff7B1FA2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel rápido de tu tienda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Gestiona banners, promociones y herramientas clave para vender cámaras y accesorios móviles.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.deepPurple,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$moduleName estará disponible en la siguiente mejora'),
      ),
    );
  }
}