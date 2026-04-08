import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_new_project/providers/cart_provider.dart';

import '../service/checkout_service.dart';


class CartPage extends StatelessWidget {
  const CartPage({super.key});

  List<Map<String, dynamic>> _buildCartItems(CartProvider cart) {
    return cart.itemsList.map((item) {
      return {
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
        'image_url': item.imageUrl,
      };
    }).toList();
  }

  Future<void> _checkout(
      BuildContext context,
      CartProvider cart,
      String paymentMethod,
      ) async {
    try {
      final cartItems = _buildCartItems(cart);

      await CheckoutService().createCheckout(
        cartItems: cartItems,
        total: cart.totalAmount,
        paymentMethod: paymentMethod,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redirigiendo a pago con $paymentMethod...'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar pago: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
      ),
      body: cart.itemsList.isEmpty
          ? const Center(
        child: Text('Tu carrito está vacío'),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemsList.length,
              itemBuilder: (context, index) {
                final item = cart.itemsList[index];

                return ListTile(
                  leading: item.imageUrl.isNotEmpty
                      ? Image.network(
                    item.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image),
                  title: Text(item.name),
                  subtitle: Text(
                    'Cantidad: ${item.quantity} | \$${item.price.toStringAsFixed(0)}',
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          cart.decreaseQuantity(item.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          cart.increaseQuantity(item.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          cart.removeItem(item.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Total: \$${cart.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _checkout(context, cart, 'nequi'),
                    child: const Text('Pagar con Nequi'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _checkout(context, cart, 'pse'),
                    child: const Text('Pagar con PSE'),
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