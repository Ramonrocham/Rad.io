import 'package:flutter/material.dart';
import 'package:radio/radio_card_item.dart';
import 'specific_search_screen.dart';

class HomeTab extends StatelessWidget {
  final List<dynamic> radiosRecomendados;
  final List<dynamic> radiosDescubraMais;
  final List<dynamic> radiosMaisOuvidas;
  final List<dynamic> radiosMaisOuvidasBrasil;
  final bool isLoading;
  final Function playRadio;

  const HomeTab({
    super.key,
    required this.radiosRecomendados,
    required this.radiosDescubraMais,
    required this.isLoading,
    required this.playRadio,
    required this.radiosMaisOuvidas,
    required this.radiosMaisOuvidasBrasil,
  });
  

@override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 160), // Espaço para o player + nav
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Header: Logo e Nome
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo.png', height: 40), // Substitua pelo caminho do seu logo
                        const SizedBox(width: 10),
                        const Text(
                          'Rad.io',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'poppins',
                            color: Color(0xFFFF6B00),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Grid de Categorias Superiores
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.2,
                      children: [
                        _buildQuickCard(context: context, title: 'Mais ouvidas', icon: Icons.local_fire_department, radios: radiosMaisOuvidas), // PASSA A LISTA PRÉ-CARREGADA
                        _buildQuickCard(context: context, title: 'Favoritos', icon: Icons.favorite, isLocal: true), // LOCAL
                        _buildQuickCard(context: context, title: 'Mais ouvidas Brasil', icon: Icons.local_fire_department, radios: radiosMaisOuvidasBrasil), // PASSA A LISTA PRÉ-CARREGADA
                        _buildQuickCard(context: context, title: 'Recentes', icon: Icons.refresh, isLocal: true), // LOCAL
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    _buildSectionTitle('Recomendados'),
                    const SizedBox(height: 10),

                    // Se estiver carregando as APIs, mostra o indicador uma única vez para as duas grades
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
                        ),
                      )
                    else if (radiosRecomendados.isEmpty)
                      const Text("Nenhuma rádio recomendada encontrada.", style: TextStyle(color: Colors.grey))
                    else
                      // Passa a lista limpa e direta, sem misturar lógica de async no layout
                      _buildRadioGrid(radiosRecomendados, 'Recomendados'),

                    const SizedBox(height: 30),
                    _buildSectionTitle('Descubra mais'),
                    const SizedBox(height: 10),

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
                        ),
                      )
                    else if (radiosDescubraMais.isEmpty)
                      const Text("Nenhuma rádio encontrada.", style: TextStyle(color: Colors.grey))
                    else
                      _buildRadioGrid(radiosDescubraMais, 'Descubra mais'),
                  ],
                ),
              ),
            );
  }

  Widget _buildQuickCard({
  required BuildContext context,
  required String title,
  required IconData icon,
  List<dynamic>? radios,
  bool isLocal = false,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpecificSearchScreen(
            title: title,
            isLocal: isLocal,
            initialRadios: radios,
            // CORREÇÃO AQUI: Adicione (list, index, title) para bater com a nova assinatura
            onRadioTap: (list, index, title) { 
              playRadio(list, index, title); // Agora passa os 3 parâmetros
              Navigator.pop(context); 
            },
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF282828), // Cinza padrão Rad.io
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6B00), size: 30), // Laranja Rad.io
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRadioGrid(List<dynamic> radios, String sectionTitle) {
    
    if (radios.isEmpty) return const SizedBox.shrink();

    return SizedBox( 
    height: 310,
    child: GridView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      //physics: const NeverScrollableScrollPhysics(),
      itemCount: radios.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final radio = radios[index];
        return SizedBox(
          width: 105, // Largura máxima fixa de cada coluna/card
          child: RadioCardItem(
            radio: radio, 
            index: index, 
            allRadios: radios, 
            onRadioTap: (list, idx, title) => playRadio(list, idx, title),
            categoryTitle: sectionTitle, // Passa o título da seção para o playRadio
          ),
        );
      },
    )
    );
  }
}