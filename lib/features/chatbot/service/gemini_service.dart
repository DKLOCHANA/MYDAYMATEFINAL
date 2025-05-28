import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = 'AIzaSyCWIRedidV-LLs3uHi-qDrrb1fL1nlkAno';

  // Updated API endpoints to use the latest models
  static const String textApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String visionApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<String> generateResponse(String prompt,
      {String? context, String? imagePath}) async {
    try {
      final fullPrompt = context != null ? "$context\n\nUser: $prompt" : prompt;

      // If image is provided, use Vision API
      if (imagePath != null) {
        return await _generateImageBasedResponse(fullPrompt, imagePath);
      }

      // Otherwise use text-only API
      final response = await http.post(
        Uri.parse('$textApiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': fullPrompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 32,
            'topP': 0.95,
            'maxOutputTokens': 800,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _extractResponseText(data);
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return "I'm having trouble connecting right now. Please try again later.";
      }
    } catch (e) {
      print('Exception in Gemini API call: $e');
      return "Sorry, I encountered an error. Please try again.";
    }
  }

  // Generate response with image input - updated for Gemini 1.5
  Future<String> _generateImageBasedResponse(
      String prompt, String imagePath) async {
    try {
      // Read image file as bytes and encode as base64
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('$visionApiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1, // Lower temperature for more factual responses
            'topK': 32,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _extractResponseText(data);
      } else {
        print('Vision API Error: ${response.statusCode}, ${response.body}');
        return "I couldn't analyze this receipt. Please try again with a clearer image.";
      }
    } catch (e) {
      print('Exception in Vision API call: $e');
      return "I encountered an error processing this receipt image.";
    }
  }

  String _extractResponseText(Map<String, dynamic> data) {
    try {
      final candidates = data['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List;
        if (parts.isNotEmpty) {
          return parts[0]['text'] as String;
        }
      }
      return "I couldn't generate a proper response.";
    } catch (e) {
      print('Error extracting response: $e');
      return "I encountered an error processing my response.";
    }
  }
}
