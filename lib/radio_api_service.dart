import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'log_service.dart' as Log;

class RadioApiService {
  // URL base da API
  static const String _baseUrl = 'https://de1.api.radio-browser.info/json/stations';

  /// Faz uma requisição genérica para qualquer endpoint da Radio Browser
  static Future<List<dynamic>> fetchRadios(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$endpoint'));

      if (response.statusCode == 200) {
        /*Log.LogService.saveLog('API', '''
          Endpoint: $endpoint
          Status: ${response.statusCode}
          Body: ${const JsonEncoder.withIndent('  ').convert(json.decode(response.body))}
          '''); // Log parcial para evitar excesso de dados*/
        return json.decode(response.body);
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha na conexão: $e');
    }
  }
}