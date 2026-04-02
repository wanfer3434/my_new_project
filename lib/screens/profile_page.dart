import 'package:flutter/material.dart';
import 'package:my_new_project/app_properties.dart';
import 'package:my_new_project/screens/faq_page.dart';
import 'package:my_new_project/screens/payment/payment_page.dart';
import 'package:my_new_project/screens/settings/settings_page.dart';
import 'package:my_new_project/screens/tracking_page.dart';

import 'chat_page.dart';

/// A modernized profile page that displays user information and quick
/// actions in a way that better supports Spanish‑speaking shoppers.
///
/// This version accepts a user name and avatar URL, so you can supply
/// real account data from Firebase or your backend. It also localizes
/// all strings to Spanish and adds new menu items relevant for a
/// commerce application (pedidos, direcciones, métodos de pago, etc.).
class ProfilePage extends StatelessWidget {
  /// The display name of the signed‑in user. Defaults to "Usuario" if
  /// unknown.
  final String userName;

  /// An optional URL or asset path for the user's avatar image. If
  /// empty, a generic avatar icon will be displayed.
  final String avatarUrl;

  const ProfilePage({Key? key, this.userName = 'Usuario', this.avatarUrl = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: <Widget>[
              // Avatar and user name
              CircleAvatar(
                radius: 48,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl) as ImageProvider
                    : const AssetImage('assets/icons/profile_default.png'),
              ),
              const SizedBox(height: 8),
              Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 24),
              // Quick actions row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: transparentYellow,
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _QuickAction(
                      icon: 'assets/icons/truck.png',
                      label: 'Mis pedidos',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TrackingPage()),
                      ),
                    ),
                    _QuickAction(
                      icon: 'assets/icons/wallet.png',
                      label: 'Billetera',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ChatScreen()),
                      ),
                    ),
                    _QuickAction(
                      icon: 'assets/icons/card.png',
                      label: 'Tarjetas',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PaymentPage()),
                      ),
                    ),
                    _QuickAction(
                      icon: 'assets/icons/contact_us.png',
                      label: 'Soporte',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Menu items
              _ProfileMenuItem(
                title: 'Direcciones',
                subtitle: 'Gestiona tus direcciones de envío',
                iconAsset: 'assets/icons/address.png',
                onTap: () {
                  // TODO: navigate to address list page
                },
              ),
              _ProfileMenuItem(
                title: 'Historial de pedidos',
                subtitle: 'Revisa tus compras anteriores',
                iconAsset: 'assets/icons/order_history.png',
                onTap: () {
                  // TODO: navigate to order history page
                },
              ),
              _ProfileMenuItem(
                title: 'Métodos de pago',
                subtitle: 'Añade o elimina tarjetas',
                iconAsset: 'assets/icons/payment_method.png',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PaymentPage()),
                ),
              ),
              _ProfileMenuItem(
                title: 'Configuración',
                subtitle: 'Privacidad y cuenta',
                iconAsset: 'assets/icons/settings_icon.png',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SettingsPage()),
                ),
              ),
              _ProfileMenuItem(
                title: 'Ayuda y soporte',
                subtitle: 'Centro de ayuda y legal',
                iconAsset: 'assets/icons/support.png',
                onTap: () {},
              ),
              _ProfileMenuItem(
                title: 'Preguntas frecuentes',
                subtitle: 'Respuestas a dudas comunes',
                iconAsset: 'assets/icons/faq.png',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FaqPage()),
                ),
              ),
              _ProfileMenuItem(
                title: 'Cerrar sesión',
                subtitle: 'Salir de tu cuenta',
                iconAsset: 'assets/icons/logout.png',
                onTap: () {
                  // TODO: implement sign‑out logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A helper widget that displays an icon and label for the quick actions
/// across the top of the profile page.
class _QuickAction extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, width: 32, height: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// A helper widget representing an individual menu item in the profile
/// page. Each item consists of an icon, a title, a subtitle, and a
/// trailing arrow indicating navigation.
class _ProfileMenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Image.asset(
            iconAsset,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.chevron_right, color: yellow),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }
}