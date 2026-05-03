import 'package:flutter/material.dart';

import 'SpecificSearchScreen.dart';

import 'player_screen.dart';

import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const RadioApp());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Fundo preto Spotify
        primaryColor: const Color(0xFFFF6B00), // Seu Laranja
      ),
      home: const HomeScreen(),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {

  final AudioPlayer _audioPlayer = AudioPlayer();

  List<dynamic> currentRadiosList = []; 
  int currentRadioIndex = -1;

  final ValueNotifier<Map<String, dynamic>?> currentRadioNotifier = ValueNotifier(null);
  String? currentCategoryTitle;


  // Função para dar o "play" e exibir o player
  void playRadio (List<dynamic> radios, int index, String categoryTitle) async{
    setState(() {
      currentRadiosList = radios;
      currentRadioIndex = index;
      currentRadioNotifier.value = radios[index];
      currentCategoryTitle = categoryTitle;
    });

    try {
      await _audioPlayer.setUrl(currentRadioNotifier.value!['url_resolved'] ?? currentRadioNotifier.value!['url']);
      _audioPlayer.play();
    } catch (e) {
      print('Erro ao tocar a rádio: $e');
    }
  }

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Conteúdo Rolável
            SingleChildScrollView(
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
                        _buildQuickCard(context: context, title: 'Mais ouvidas', icon: Icons.local_fire_department, endpoint: 'topclick/30'),
                        _buildQuickCard(context: context, title: 'Favoritos', icon: Icons.favorite, isLocal: true), // LOCAL
                        _buildQuickCard(context: context, title: 'Mais ouvidas Brasil', icon: Icons.local_fire_department, endpoint: 'bycountry/brazil'),
                        _buildQuickCard(context: context, title: 'Recentes', icon: Icons.refresh, isLocal: true), // LOCAL
                      ],
                    ),

                    const SizedBox(height: 40),
                    _buildSectionTitle('Recomendados'),
                    _buildRadioGrid([], 'Recomendados'), // Você precisará passar a lista de rádios recomendados aqui

                    const SizedBox(height: 30),
                    _buildSectionTitle('Descubra mais'),
                    _buildRadioGrid([], 'Descubra mais'),
                  ],
                ),
              ),
            ),

            // Player de Áudio Flutuante (Fixo em cima da Nav)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  _buildBottomPlayer(context),
                  _buildBottomNav(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para os cards de acesso rápido no topo
  Widget _buildQuickCard({
  required BuildContext context,
  required String title,
  required IconData icon,
  String? endpoint,
  bool isLocal = false,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpecificSearchScreen(
            title: title,
            endpoint: endpoint ?? '',
            isLocal: isLocal,
            // CORREÇÃO AQUI: Adicione (list, index) para bater com a nova assinatura
            onRadioTap: (list, index) { 
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

  // Título das seções
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Grid das rádios (Recomendados / Descubra)
  Widget _buildRadioGrid(List<dynamic> radios, String sectionTitle) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: radios.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final radio = radios[index];
        return GestureDetector(
          onTap: () => playRadio(radios, index, sectionTitle), // Passa a lista e o index
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D4E2E),
                    borderRadius: BorderRadius.circular(4),
                    image: radio['favicon'] != "" 
                      ? DecorationImage(image: NetworkImage(radio['favicon']), fit: BoxFit.cover)
                      : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                radio['name'] ?? 'Rádio',
                maxLines: 2,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }

  // Barra do Player
  Widget _buildBottomPlayer(BuildContext context) {
  // Se não houver rádio selecionada, retorna um widget vazio
  final radio = currentRadioNotifier.value;

  if (radio == null) return const SizedBox.shrink();

  return Dismissible(
    key: UniqueKey(), // Chave única para o widget ser destruído e recriado
    direction: DismissDirection.horizontal, // Permite arrastar para os lados
    onDismissed: (direction) {
      _audioPlayer.stop();

      setState(() {
        currentRadioNotifier.value = null; // Para de tocar e "some" com o player
      });
      // Log para debug no seu Linux Mint
    },
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              radioNotifier: currentRadioNotifier,
              categoryTitle: currentCategoryTitle ?? "Rádio",
              player: _audioPlayer,
              onNext: () {
                // Lógica de loop para a próxima rádio
                int nextIndex = (currentRadioIndex + 1) % currentRadiosList.length;
                playRadio(currentRadiosList, nextIndex, currentCategoryTitle!);
              },
              onPrevious: () {
                // Lógica de loop para a rádio anterior
                int prevIndex = (currentRadioIndex - 1 + currentRadiosList.length) % currentRadiosList.length;
                playRadio(currentRadiosList, prevIndex, currentCategoryTitle!);
              },
            ),
          ),
        );
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF282828), // Seu cinza padrão
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Capa da Rádio
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4E2E),
                borderRadius: BorderRadius.circular(4),
                image: radio['favicon'] != "" && radio['favicon'] != null
                  ? DecorationImage(image: NetworkImage(radio['favicon']), fit: BoxFit.cover)
                  : null,
              ),
            ),
            const SizedBox(width: 15),
            // Informações (Nome e Localização com Bandeira)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    radio['name'] ?? 'Rádio',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  _buildLocationRow(radio), // Sua lógica de localização
                ],
              ),
            ),
            const Icon(Icons.favorite_border, color: Color(0xFFFF6B00)),
            const SizedBox(width: 15),
            const Icon(Icons.play_arrow, color: Color(0xFFFF6B00), size: 40),
          ],
        ),
      ),
    ),
  );
}

// Widget auxiliar para formatar Estado, País e Bandeira
Widget _buildLocationRow(Map<String, dynamic> radio) {
  final String location = [radio['state'], radio['countrycode']]
      .where((s) => s != null && s != "")
      .join(", ");

  return Row(
    children: [
      Flexible(
        child: Text(
          location,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 5),
      if (radio['countrycode'] != null)
        Image.asset(
          'icons/flags/png/${radio['countrycode'].toLowerCase()}.png',
          package: 'country_icons',
          height: 12,
        ),
    ],
  );
}

  // Barra de Navegação Inferior
  Widget _buildBottomNav() {
    return Container(
      color: Colors.black,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.search, 'Search', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFFFF6B00) : Colors.grey),
        Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 12)),
      ],
    );
  }
}