import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://malakrabie-gloss-api.hf.space';

  static Future<String> getGloss(String sentence) async {
    final response = await http.post(
      Uri.parse('$baseUrl/convert'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sentence': sentence}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['gloss_text'];
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
