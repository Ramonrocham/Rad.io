import 'package:flutter/material.dart';
import 'package:radio/mini_player.dart';
import 'package:radio/radio_api_service.dart';
import 'package:radio/radio_database_service.dart';

import 'SpecificSearchScreen.dart';

import 'player_screen.dart';

import 'package:just_audio/just_audio.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dart:io';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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

  List<dynamic> radiosRecomendados = [];
  List<dynamic> radiosDescubraMais = [];
  
  bool isLoading = true;

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
    RadioDatabaseService.addRecent(currentRadioNotifier.value!);
  }

  Future<void> _loadRadioData() async {
    try {
      // Dispara as duas requisições HTTP simultaneamente
      final resultados = await Future.wait([
        RadioApiService().fetchRecomendados(),
        RadioApiService().fetchDescubraMais(),
      ]);

      // Atualiza o estado com as listas reais e desativa o loading
      setState(() {
        radiosRecomendados = resultados[0];
        radiosDescubraMais = resultados[1];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRadioData(); // Chama a função que faz a requisição por fora
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
                        _buildQuickCard(context: context, title: 'Mais ouvidas Brasil', icon: Icons.local_fire_department, endpoint: 'search?order=clickcount&reverse=true&country=Brazil'),
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
            ),

            // Player de Áudio Flutuante (Fixo em cima da Nav)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  MiniPlayer(radioNotifier: currentRadioNotifier, player: _audioPlayer, radiosList: currentRadiosList, currentIndex: currentRadioIndex, categoryTitle: currentCategoryTitle ?? '', onPlay: playRadio),
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
        return GestureDetector(
          onTap: () => playRadio(radios, index, sectionTitle),
          child: SizedBox(
            width: 105, // Largura máxima fixa de cada coluna/card
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF282828), // Cinza padrão do Rad.io de fundo
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: radio['favicon'] != null && radio['favicon'] != ""
                        ? Image.network(
                            radio['favicon'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            // Fallback seguro se a imagem da API falhar
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.radio, color: Colors.white24, size: 28),
                          )
                        : const Icon(Icons.radio, color: Colors.white24, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  radio['name']?.toString().trim() ?? 'Rádio',
                  maxLines: 1, // 1 ou 2 linhas, dependendo do quanto quer economizar espaço
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      },
    )
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