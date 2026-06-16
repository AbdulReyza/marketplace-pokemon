import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  void addToCart(ProductModel product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItemModel(product: product));
    }

    notifyListeners();
  }

  void increaseQuantity(String productId) {
    final item = _items.firstWhere((item) => item.product.id == productId);

    item.quantity++;

    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final item = _items.firstWhere((item) => item.product.id == productId);

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);

    notifyListeners();
  }

  int get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
