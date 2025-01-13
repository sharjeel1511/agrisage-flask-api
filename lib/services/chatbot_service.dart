import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotService {
  final String apiKey;
  final String apiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  ChatbotService({
    required this.apiKey,
  });

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'No response';
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in chatbot service: $e');
      throw Exception('Failed to communicate with chatbot');
    }
  }
}
