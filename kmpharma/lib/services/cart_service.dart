import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'medicine_cart';

  // Get all cart items
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson == null || cartJson.isEmpty) {
      return [];
    }
    final List<dynamic> decoded = jsonDecode(cartJson);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Add item to cart
  static Future<bool> addToCart(Map<String, dynamic> medicineInfo) async {
    final prefs = await SharedPreferences.getInstance();
    final cartItems = await getCartItems();
    
    final medicineName = medicineInfo['corrected_name'] ?? medicineInfo['name'] ?? '';
    
    // Check if medicine already exists in cart
    final existingIndex = cartItems.indexWhere(
      (item) => item['name'] == medicineName,
    );
    
    if (existingIndex != -1) {
      // Medicine already in cart, increment quantity
      cartItems[existingIndex]['quantity'] = 
          (cartItems[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      // Add new medicine with only name and quantity
      cartItems.add({
        'name': medicineName,
        'quantity': 1,
      });
    }
    
    return await prefs.setString(_cartKey, jsonEncode(cartItems));
  }

  // Remove item from cart
  static Future<bool> removeFromCart(String medicineName) async {
    final prefs = await SharedPreferences.getInstance();
    final cartItems = await getCartItems();
    
    cartItems.removeWhere((item) => item['name'] == medicineName);
    
    return await prefs.setString(_cartKey, jsonEncode(cartItems));
  }

  // Update quantity
  static Future<bool> updateQuantity(String medicineName, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final cartItems = await getCartItems();
    
    final index = cartItems.indexWhere(
      (item) => item['name'] == medicineName,
    );
    
    if (index != -1) {
      if (quantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index]['quantity'] = quantity;
      }
    }
    
    return await prefs.setString(_cartKey, jsonEncode(cartItems));
  }

  // Clear cart
  static Future<bool> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_cartKey);
  }

  // Get cart count
  static Future<int> getCartCount() async {
    final cartItems = await getCartItems();
    return cartItems.length;
  }
}
