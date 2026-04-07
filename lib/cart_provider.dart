import 'package:flutter/material.dart';

class CartItem {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  List<CartItem> get itemsList => _items.values.toList();

  int get itemCount {
    int total = 0;
    for (final item in _items.values) {
      total += item.quantity;
    }
    return total;
  }

  double get totalAmount {
    double total = 0;
    for (final item in _items.values) {
      total += item.total;
    }
    return total;
  }

  void addItem({
    required int id,
    required String name,
    required double price,
    required String imageUrl,
  }) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
      );
    }
    notifyListeners();
  }

  void removeItem(int id) {
    _items.remove(id);
    notifyListeners();
  }

  void increaseQuantity(int id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(int id) {
    if (_items.containsKey(id)) {
      if (_items[id]!.quantity > 1) {
        _items[id]!.quantity -= 1;
      } else {
        _items.remove(id);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}