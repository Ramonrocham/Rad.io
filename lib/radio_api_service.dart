import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'log_service.dart' as Log;

class RadioApiService {
  // URL base da API
  static const String _baseUrl = 'https://de1.api.radio-browser.info/json/stations';

  /// Faz uma requisição genérica para qualquer endpoint da Radio Browser
  Future<List<dynamic>> fetchRadios(String endpoint) async {
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

  Future<List<dynamic>> fetchRecomendados() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?order=topvote&reverse=true&bitrateMin=100&country=Brazil&limit=60'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.statusCode == 200 ? response.body : '[]');
      }
      return [];
    } catch (e) {
      return []; // Retorna lista vazia em caso de falha de conexão
    }
  }

// Função para buscar as rádios mais votadas (Descubra mais)
  Future<List<dynamic>> fetchDescubraMais() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?order=topvote&reverse=true&bitrateMin=100&limit=60'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}