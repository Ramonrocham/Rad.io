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
            borderRadius: BorderRadius.circular(8),
            child: hasValidImage
            ? Image.network(
              radio['favicon'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              // O errorBuilder é o seu "catch" perfeito! 
              // Se a URL falhar, ele desenha o ícone no lugar da imagem quebrada.
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: DiscoIcon(index: index, height: 85, width: 90), // Você pode ajustar o tamanho do ícone conforme necessário
                );
              },
            )
          // O "else" do seu if inicial (!hasValidImage)S
          : Center(
              child: DiscoIcon(index: index, height: 90, width: 90),
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
        Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // 1. O ESTADO: Fica dentro do Flexible para ganhar os "..." se for gigante
    if (radio['state'] != null && radio['state'].toString().trim().isNotEmpty)
      Flexible(
        child: Text(
          radio['state'].toString().trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // Corta e coloca reticências
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ),
      
    // 2. PAÍS: Texto fixo. Se tinha estado antes, coloca a vírgula. Se não, só a sigla.
    Text(
      (radio['state'] != null && radio['state'].toString().trim().isNotEmpty) 
          ? ", ${radio['countrycode'] ?? ''}" 
          : "${radio['countrycode'] ?? ''}",
      style: const TextStyle(fontSize: 10, color: Colors.white70),
    ),
    
    // 3. BANDEIRA: Fica fixa no final da linha
    if (radio['countrycode'] != null && radio['countrycode'].toString().trim().isNotEmpty) ...[
      const SizedBox(width: 5),
      Image.asset(
        'icons/flags/png/${radio['countrycode'].toString().toLowerCase()}.png',
        package: 'country_icons',
        height: 10,
      ),
    ],
  ],
)
      ],
    ),
  );
  }
}