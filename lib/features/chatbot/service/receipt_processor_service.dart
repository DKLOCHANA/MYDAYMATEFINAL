import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReceiptProcessorService {
  final textRecognizer = GoogleMlKit.vision.textRecognizer();

  // Process receipt and extract items, prices, and categories
  Future<List<Map<String, dynamic>>> processReceipt(String imagePath) async {
    try {
      // Step 1: Use ML Kit to extract text from the receipt image
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        return [];
      }

      // Step 2: Analyze the text to identify items and prices
      return await _analyzeReceiptText(recognizedText.text);
    } catch (e) {
      print('Error in receipt processing: $e');
      return [];
    } finally {
      textRecognizer.close();
    }
  }

  // Analyze the receipt text to extract items, prices, and categories
  Future<List<Map<String, dynamic>>> _analyzeReceiptText(String text) async {
    // Initialize result list
    List<Map<String, dynamic>> receiptItems = [];

    // Split the text by lines
    final lines = text.split('\n');

    // Regular expressions for price patterns
    final priceRegex = RegExp(r'\$?\s*(\d+\.\d{2})');
    final itemPriceRegex = RegExp(r'(.+?)\s+\$?(\d+\.\d{2})');

    // Process each line
    for (var line in lines) {
      // Skip very short lines or lines that are likely headers/footers
      if (line.length < 4 ||
          line.toLowerCase().contains('total') ||
          line.toLowerCase().contains('subtotal') ||
          line.toLowerCase().contains('tax') ||
          line.toLowerCase().contains('receipt') ||
          line.toLowerCase().contains('thank you') ||
          line.toLowerCase().contains('cashier')) {
        continue;
      }

      // Try to match item and price pattern
      final match = itemPriceRegex.firstMatch(line);
      if (match != null && match.groupCount >= 2) {
        String itemName = match.group(1)?.trim() ?? "";
        double price = double.tryParse(match.group(2) ?? "0") ?? 0.0;

        // Skip if item name is too short or price is unreasonably high or low
        if (itemName.length < 2 || price <= 0 || price > 1000) {
          continue;
        }

        // Categorize the item
        String category = await _categorizeItem(itemName);

        receiptItems
            .add({'name': itemName, 'price': price, 'category': category});
      }
    }

    return receiptItems;
  }

  // Improved categorize an item based on its name
  Future<String> _categorizeItem(String itemName) async {
    // Clean the item name and convert to lowercase
    itemName = itemName.toLowerCase().trim();

    // Common food category patterns with improved detection
    Map<String, List<String>> foodCategories = {
      'Dairy': [
        'milk',
        'cheese',
        'yogurt',
        'butter',
        'cream',
        'dairy',
        'ice cream',
        'curd',
        'ghee',
        'paneer',
        'whip'
      ],
      'Meat': [
        'meat',
        'chicken',
        'beef',
        'pork',
        'fish',
        'seafood',
        'lamb',
        'turkey',
        'bacon',
        'sausage',
        'ham',
        'steak',
        'prawn',
        'shrimp'
      ],
      'Fruits': [
        'fruit',
        'apple',
        'banana',
        'berry',
        'orange',
        'grape',
        'melon',
        'pear',
        'mango',
        'peach',
        'plum',
        'kiwi',
        'pineapple',
        'strawberry',
        'blueberry'
      ],
      'Vegetables': [
        'veg',
        'vegetable',
        'potato',
        'onion',
        'tomato',
        'carrot',
        'broccoli',
        'spinach',
        'lettuce',
        'cucumber',
        'pepper',
        'capsicum',
        'beans',
        'corn'
      ],
      'Bakery': [
        'bread',
        'bun',
        'cake',
        'pastry',
        'pie',
        'muffin',
        'donut',
        'croissant',
        'roll',
        'bagel',
        'baguette',
        'cookie',
        'biscuit'
      ],
      'Beverages': [
        'drink',
        'juice',
        'soda',
        'water',
        'coffee',
        'tea',
        'beer',
        'wine',
        'alcohol',
        'milk',
        'smoothie',
        'shake',
        'cola',
        'lemonade'
      ],
      'Snacks': [
        'chips',
        'crisp',
        'popcorn',
        'nuts',
        'pretzel',
        'cracker',
        'snack',
        'chocolate',
        'candy',
        'sweet',
        'bar',
        'gum'
      ],
      'Condiments': [
        'sauce',
        'ketchup',
        'mustard',
        'mayo',
        'dressing',
        'oil',
        'vinegar',
        'spice',
        'herb',
        'salt',
        'pepper',
        'seasoning',
        'syrup',
        'jam',
        'honey'
      ],
      'Canned & Packaged': [
        'can',
        'tin',
        'soup',
        'noodle',
        'pasta',
        'rice',
        'cereal',
        'granola',
        'oatmeal',
        'flour',
        'sugar',
        'bean',
        'tuna',
        'packet',
        'mix'
      ],
    };

    // Non-food categories
    Map<String, List<String>> nonFoodCategories = {
      'Electronics': [
        'phone',
        'charger',
        'cable',
        'battery',
        'computer',
        'laptop',
        'tv',
        'headphone',
        'speaker',
        'device',
        'memory',
        'card',
        'usb'
      ],
      'Clothing': [
        'shirt',
        'pant',
        'dress',
        'sock',
        'underwear',
        'jacket',
        'coat',
        'shoe',
        'boot',
        'hat',
        'cap',
        'scarf',
        'glove',
        'clothing',
        'apparel'
      ],
      'Household': [
        'cleaner',
        'soap',
        'detergent',
        'paper',
        'tissue',
        'towel',
        'trash',
        'bag',
        'candle',
        'light',
        'bulb',
        'battery',
        'bleach',
        'brush'
      ],
      'Personal Care': [
        'shampoo',
        'conditioner',
        'toothpaste',
        'toothbrush',
        'deodorant',
        'razor',
        'lotion',
        'cream',
        'makeup',
        'cosmetic',
        'toilet',
        'hygiene'
      ],
      'Services & Fees': [
        'service',
        'fee',
        'tax',
        'charge',
        'delivery',
        'shipping',
        'handling',
        'subscription',
        'payment',
        'tip',
        'surcharge'
      ],
    };

    // First check if it's a food item
    for (var category in foodCategories.keys) {
      for (var keyword in foodCategories[category]!) {
        if (itemName.contains(keyword)) {
          return category;
        }
      }
    }

    // Then check if it's a non-food item
    for (var category in nonFoodCategories.keys) {
      for (var keyword in nonFoodCategories[category]!) {
        if (itemName.contains(keyword)) {
          return category;
        }
      }
    }

    // Check if the item looks like a food item based on common patterns
    if (_looksProbablyLikeFood(itemName)) {
      return 'Food & Grocery';
    }

    // For items that don't match any category
    return 'Other';
  }

  // Helper method to determine if an item is likely food
  bool _looksProbablyLikeFood(String itemName) {
    // Common food item endings and patterns
    List<String> foodPatterns = [
      'fresh',
      'organic',
      'roasted',
      'baked',
      'fried',
      'grilled',
      'frozen',
      'diet',
      'salad',
      'soup',
      'stew',
      'meal',
      'breakfast',
      'lunch',
      'dinner',
      'snack',
      'treat',
      'dessert',
      'produce'
    ];

    for (var pattern in foodPatterns) {
      if (itemName.contains(pattern)) {
        return true;
      }
    }

    // Check for common food measurement units
    if (RegExp(r'(oz|lb|g|kg|ml|l)\b').hasMatch(itemName)) {
      return true;
    }

    return false;
  }
}
