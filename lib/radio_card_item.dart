import 'package:flutter/material.dart';
import 'package:radio/disco_icon.dart';

class RadioCardItem extends StatelessWidget {
  final dynamic radio;
  final int index;
  final List<dynamic> allRadios;
  final Function(List<dynamic> radios, int index, String categoryTitle) onRadioTap;

  const RadioCardItem({
    super.key,
    required this.radio,
    required this.index,
    required this.allRadios,
    required this.onRadioTap,
  });
  
  @override
  Widget build(BuildContext context){
    final String? favicon = radio['favicon'];
    final bool hasValidImage = favicon != null && 
                             favicon.isNotEmpty && 
                             favicon != "null"; 

    return GestureDetector(      
    // Agora passamos a lista completa e o índice do clique
    onTap: () => onRadioTap(allRadios, index, "Search Results"), // Você pode personalizar o título da categoria conforme necessário
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF282828), // Seu cinza padrão
              borderRadius: BorderRadius.circular(8),
            ),
              child: ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: hasValidImage
          ? Image.network(
              radio['favicon'],
              fit: BoxFit.cover,
              // O errorBuilder é o seu "catch" perfeito! 
              // Se a URL falhar, ele desenha o ícone no lugar da imagem quebrada.
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: DiscoIcon(index: index, height: 50, width: 50), // Você pode ajustar o tamanho do ícone conforme necessário
                );
              },
            )
          // O "else" do seu if inicial (!hasValidImage)
          : Center(
              child: DiscoIcon(index: index, height: 50, width: 50),
            ),
            )
    ),
          
        ),
        const SizedBox(height: 8),
        Text(
          radio['name']?.trim() ?? 'Rádio Sem Nome',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          children: [
            Text(
              (radio['state'] != null && radio['state'] != "") 
                  ? "${radio['state']}, ${radio['countrycode']}" 
                  : "${radio['countrycode'] ?? ''}",
              maxLines: 1,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            // Exibe a bandeira apenas se o código do país existir
            if (radio['countrycode'] != null && radio['countrycode'] != "")
              Image.asset(
                'icons/flags/png/${radio['countrycode'].toLowerCase()}.png',
                package: 'country_icons',
                height: 10,
              )
          ],
        ),
      ],
    ),
  );
  }
}