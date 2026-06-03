import 'package:flutter/material.dart';
import 'package:radio/home_tab.dart';
import 'package:radio/mini_player.dart';
import 'package:radio/radio_api_service.dart';
import 'package:radio/radio_database_service.dart';
import 'package:radio/search_tab.dart';

import 'SpecificSearchScreen.dart';

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
  int _currentIndex = 0;
  
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<dynamic> currentRadiosList = []; 
  int currentRadioIndex = -1;

  List<dynamic> radiosRecomendados = [];
  List<dynamic> radiosDescubraMais = [];
  List<dynamic> radiosMaisOuvidas = [];
  List<dynamic> radiosMaisOuvidasBrasil = [];
  
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
        RadioApiService().fetchRadios('topclick/60'),
        RadioApiService().fetchRadios('search?order=clickcount&reverse=true&country=Brazil'),
      ]);

      // Atualiza o estado com as listas reais e desativa o loading
      setState(() {
        radiosRecomendados = resultados[0];
        radiosRecomendados.removeAt(0);
        radiosDescubraMais = resultados[1];
        radiosMaisOuvidas = resultados[2];
        radiosMaisOuvidasBrasil = resultados[3];
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
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Conteúdo Rolável
            HomeTab(
              playRadio: playRadio,
              radiosRecomendados: radiosRecomendados,
              radiosDescubraMais: radiosDescubraMais,
              radiosMaisOuvidas: radiosMaisOuvidas,
              radiosMaisOuvidasBrasil: radiosMaisOuvidasBrasil,
              isLoading: isLoading,
            ),
            SearchTab(
              onPlayRadio: playRadio,
            )
          ],
        ),
      ),
      bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
                children: [
                  MiniPlayer(radioNotifier: currentRadioNotifier, player: _audioPlayer, radiosList: currentRadiosList, currentIndex: currentRadioIndex, categoryTitle: currentCategoryTitle ?? '', onPlay: playRadio),
                  _buildBottomNav(),
                ],
            ),
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
          GestureDetector(
          behavior: HitTestBehavior.opaque, // Torna toda a área clicável (não só o ícone)
          onTap: () {
            if (_currentIndex != 0) {
              setState(() => _currentIndex = 0); // Muda para a aba 0 (Home)
            }
          },
          child: _buildNavItem(Icons.home, 'Home', _currentIndex == 0), // Ativo se index for 0
        ),
          GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_currentIndex != 1) {
              setState(() => _currentIndex = 1); // Muda para a aba 1 (Search)
            }
          },
          child: _buildNavItem(Icons.search, 'Search', _currentIndex == 1), // Ativo se index for 1
        ),
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