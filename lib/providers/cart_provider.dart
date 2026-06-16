import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  CartProvider() {
    loadCart();
  }

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    final cartData = _items.map((item) {
      return {
        'id': item.product.id,
        'name': item.product.name,
        'image': item.product.image,
        'price': item.product.price,
        'stock': item.product.stock,
        'description': item.product.description,
        'category': item.product.category,
        'quantity': item.quantity,
      };
    }).toList();

    await prefs.setString('cart', jsonEncode(cartData));
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();

    final cartString = prefs.getString('cart');

    if (cartString == null) return;

    final List decoded = jsonDecode(cartString);

    _items.clear();

    for (var item in decoded) {
      _items.add(
        CartItemModel(
          quantity: item['quantity'],
          product: ProductModel(
            id: item['id'],
            name: item['name'],
            image: item['image'],
            price: item['price'],
            stock: item['stock'],
            description: item['description'],
            category: item['category'],
          ),
        ),
      );
    }

    notifyListeners();
  }

  void addToCart(ProductModel product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItemModel(product: product));
    }

    saveCart();
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    final item = _items.firstWhere((item) => item.product.id == productId);

    item.quantity++;

    saveCart();
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final item = _items.firstWhere((item) => item.product.id == productId);

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }

    saveCart();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);

    saveCart();
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

    saveCart();
    notifyListeners();
  }
}
