import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodService {
  // Appel direct à l'API publique OpenFoodFacts
  static Future<Map<String, dynamic>?> scanBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 0) {
          return null; // Produit non trouvé
        }

        final p = data['product'];
        final nutriments = p['nutriments'] ?? {};

        return {
          'name': p['product_name'] ?? p['generic_name'] ?? 'Nom inconnu',
          'brand': p['brands'] ?? 'Marque inconnue',
          'image': p['image_url'] ?? '',
          'quantity': p['quantity'] ?? '',
          'nutriscore': p['nutriscore_grade'] ?? '',
          'per100g': {
            'calories': nutriments['energy-kcal_100g']?.toDouble() ?? 0.0,
            'proteins': nutriments['proteins_100g']?.toDouble() ?? 0.0,
            'carbs': nutriments['carbohydrates_100g']?.toDouble() ?? 0.0,
            'fat': nutriments['fat_100g']?.toDouble() ?? 0.0,
            'fiber': nutriments['fiber_100g']?.toDouble() ?? 0.0,
            'sugar': nutriments['sugars_100g']?.toDouble() ?? 0.0,
            'salt': nutriments['salt_100g']?.toDouble() ?? 0.0,
          },
        };
      }
      
      throw Exception('Erreur HTTP: ${response.statusCode}');
    } catch (e) {
      print('Erreur FoodService: $e');
      rethrow;
    }
  }
}