import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpecificSearchScreen extends StatefulWidget {
  final String title;
  final String endpoint;

  const SpecificSearchScreen({super.key, required this.title, required this.endpoint});

  @override
  State<SpecificSearchScreen> createState() => _SpecificSearchScreenState();
}

class _SpecificSearchScreenState extends State<SpecificSearchScreen> {
  Future<List<dynamic>> fetchRadios() async {
    final response = await http.get(Uri.parse('https://de1.api.radio-browser.info/json/stations/${widget.endpoint}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar rádios');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header conforme "Busca Especifica.png"
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Image.asset('assets/images/logo.png', height: 35), // Sua logo customizada
                ],
              ),
            ),
            
            // Grid de Rádios com API
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchRadios(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhuma rádio encontrada.'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var radio = snapshot.data![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF5D4E2E), // Cor baseada no print
                                borderRadius: BorderRadius.circular(4),
                                image: radio['favicon'] != "" 
                                  ? DecorationImage(image: NetworkImage(radio['favicon']), fit: BoxFit.cover)
                                  : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${radio['name']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${radio['state']}, ${radio['countrycode']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}