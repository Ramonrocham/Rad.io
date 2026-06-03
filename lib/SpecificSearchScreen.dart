import 'package:flutter/material.dart';
import 'package:radio/radio_card_item.dart';
import 'radio_database_service.dart';

class SpecificSearchScreen extends StatelessWidget {
  final String title;
  final List<dynamic>? initialRadios;
  final bool isLocal;

  final Function(List<dynamic> radios, int index, String categoryTitle) onRadioTap;

  const SpecificSearchScreen({
    super.key, 
    required this.title, 
    required this.onRadioTap,
    this.initialRadios,
    this.isLocal = false,
  });

  @override
  Widget build(BuildContext context) {
    // Escolhemos o Future dependendo da flag isLocal
    Future<List<dynamic>> getData() {
      if (isLocal) {
        return title == 'Favoritos' 
          ? RadioDatabaseService.getFavorites() 
          : RadioDatabaseService.getRecent();
      } else {
        return Future.value(initialRadios ?? []); //RadioApiService.fetchRadios(endpoint);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: getData(),
                builder: (context, snapshot) {
                  // ... lógica de loading e erro (mesma de antes)
                  
                  final radios = snapshot.data ?? [];
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    // ESTA É A PARTE QUE ESTÁ FALTANDO:
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,       // Define as 3 colunas do seu design
                      crossAxisSpacing: 12,    // Espaço horizontal entre os cards
                      mainAxisSpacing: 20,     // Espaço vertical entre as linhas
                      childAspectRatio: 0.7,   // Controla a proporção (largura/altura)
                    ),
                    itemCount: radios.length,
                    itemBuilder: (context, index) {
                      final radio = radios[index];
                      return RadioCardItem(radio: radio, index: index, allRadios: radios, onRadioTap: onRadioTap); // Garante que este método retorne um Widget
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Image.asset('assets/images/logo.png', height: 28),
        ],
      ),
    );
  }
}