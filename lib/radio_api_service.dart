import 'dart:convert';
import 'package:http/http.dart' as http;

class RadioApiService {
  // URL base da API
  static const String _baseUrl = 'https://de1.api.radio-browser.info/json/stations';

  /// Faz uma requisição genérica para qualquer endpoint da Radio Browser
  static Future<List<dynamic>> fetchRadios(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$endpoint'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha na conexão: $e');
    }
  }
}