import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = 'AIzaSyCWIRedidV-LLs3uHi-qDrrb1fL1nlkAno';
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> generateResponse(String prompt, {String? context}) async {
    try {
      final fullPrompt = context != null ? "$context\n\nUser: $prompt" : prompt;

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
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
            'topK': 40,
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
