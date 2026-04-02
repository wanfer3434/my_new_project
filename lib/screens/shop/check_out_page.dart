import 'package:card_swiper/card_swiper.dart';
import 'package:my_new_project/app_properties.dart';
import 'package:my_new_project/models/product.dart';
import 'package:my_new_project/screens/address/add_address_page.dart';
import 'package:my_new_project/screens/payment/unpaid_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/credit_card.dart';
import 'components/shop_item_list.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({Key? key}) : super(key: key);

  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  final SwiperController _swiperController = SwiperController();

  final String mercadoPagoUrl = 'https://link.mercadopago.com.co/montitech';
  final String whatsappUrl =
      'https://wa.me/573209120172?text=Hola%20vengo%20de%20la%20app%20Montitech%20y%20quiero%20confirmar%20mi%20pedido';

  List<Product> products = [
    Product(
      id: 'roackerz 400',
      imageUrls: ['assets/headphones.png'],
      name: 'Audífonos Bluetooth On-Ear Boat Roackerz 400',
      description: 'Una experiencia sonora envolvente con hasta 8 horas de batería.',
      price: 45300,
      category: 'Wireless',
    ),
    Product(
      id: 'roackerz 100',
      imageUrls: ['assets/headphones_2.png'],
      name: 'Audífonos Bluetooth On-Ear Boat Roackerz 100',
      description: 'Diseño ligero y sonido nítido para el día a día.',
      price: 22300,
      category: 'Wireless',
    ),
    Product(
      id: 'roackerz 300',
      imageUrls: ['assets/headphones_3.png'],
      name: 'Audífonos Bluetooth On-Ear Boat Roackerz 300',
      description: 'Graves potentes y almohadillas ultrasuaves.',
      price: 58300,
      category: 'Wireless',
    ),
  ];

  double get _subtotal => products.fold(0.0, (sum, item) => sum + item.price);
  double get _tax => _subtotal * 0.19;
  double get _total => _subtotal + _tax;

  Future<void> _openMercadoPago() async {
    final Uri url = Uri.parse(mercadoPagoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showError('No se pudo abrir el link de pago.');
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri url = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showError('No se pudo abrir WhatsApp.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String formatCOP(double value) {
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final Widget mercadoPagoButton = InkWell(
      onTap: _openMercadoPago,
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          gradient: mainButton,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              offset: Offset(0, 5),
              blurRadius: 10.0,
            ),
          ],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Center(
          child: Text(
            'Pagar con Mercado Pago',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );

    final Widget whatsappButton = InkWell(
      onTap: _openWhatsApp,
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: Colors.green,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              offset: Offset(0, 5),
              blurRadius: 10.0,
            ),
          ],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Center(
          child: Text(
            'Pedir por WhatsApp',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: darkGrey),
        title: const Text(
          'Carrito de compras',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/icons/denied_wallet.png'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => UnpaidPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: yellow,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de compra',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${products.length} producto${products.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${formatCOP(_total)} COP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Scrollbar(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    return ShopItemList(
                      products[index],
                      onRemove: () {
                        setState(() {
                          products.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subtotal: \$${formatCOP(_subtotal)} COP',
                      style: TextStyle(
                        color: darkGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Impuestos (19% IVA): \$${formatCOP(_tax)} COP',
                      style: TextStyle(
                        color: darkGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total a pagar: \$${formatCOP(_total)} COP',
                      style: TextStyle(
                        color: darkGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Métodos de pago',
                      style: TextStyle(
                        fontSize: 20,
                        color: darkGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 220,
                      child: Swiper(
                        itemCount: 3,
                        itemBuilder: (_, index) {
                          return CreditCard();
                        },
                        scale: 0.8,
                        controller: _swiperController,
                        viewportFraction: 0.7,
                        loop: false,
                        fade: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: mercadoPagoButton,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: whatsappButton,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Pago seguro con Mercado Pago y atención directa por WhatsApp en Montitech.',
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}