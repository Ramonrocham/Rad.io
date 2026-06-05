import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio/disco_icon.dart';
import 'package:radio/radio_database_service.dart';
import 'package:text_scroll/text_scroll.dart';
import 'radio_share_button.dart';

class PlayerScreen extends StatelessWidget {
  final ValueNotifier<Map<String, dynamic>?> radioNotifier;
  final String categoryTitle;
  final AudioPlayer player; // Recebe o player da HomeScreen
  final VoidCallback onNext; // Função para ir para a próxima rádio
  final VoidCallback onPrevious; // Função para voltar rádio

  final ValueNotifier<bool> isFavoriteNotifier = ValueNotifier(false);
  final ValueNotifier<int> currentIndexNotifier;

  PlayerScreen({
    super.key, 
    required this.radioNotifier,
    required this.categoryTitle, 
    required this.player,
    required this.onNext,
    required this.onPrevious,
    required int currentIndex,
  }): currentIndexNotifier = ValueNotifier(currentIndex);

  void _updateFavoriteStatus(String uuid) async {
    bool fav = await RadioDatabaseService.isFavorite(uuid);
    isFavoriteNotifier.value = fav;
  }

  @override
  Widget build(BuildContext context) {
    // 4. Usamos o ValueListenableBuilder para reconstruir o UI quando a rádio mudar
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: radioNotifier,
      builder: (context, radio, child) {
        if (radio == null) return const SizedBox.shrink();

        _updateFavoriteStatus(radio['stationuuid']);

        return StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final bool isPlaying = snapshot.data?.playing ?? false;

            return Scaffold(
              backgroundColor: const Color(0xFF121212),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                  child: Column(
                    children: [
                      // O resto do seu layout usa a variável 'radio' do builder
                      // Ex: Text(radio['name'] ?? '...')
                      _buildHeader(context),
                      const Spacer(),
                      _buildRadioArt(context, radio),
                      const Spacer(),
                      _buildRadioInfo(radio),
                      const SizedBox(height: 30),
                      _buildProgressSection(context, radio, isPlaying),
                      const SizedBox(height: 20),
                      _buildPlaybackControls(isPlaying, radio),
                      const SizedBox(height: 60)
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  

  Widget _buildRadioArt(BuildContext context, Map<String, dynamic> radio) {
    final String? favicon = radio['favicon'];
    final bool hasValidImage = favicon != null && 
                             favicon.isNotEmpty && 
                             favicon != "null";
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFF5D4E2E), 
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: hasValidImage
          ? Image.network(
              radio['favicon'],
              fit: BoxFit.cover,
              // O errorBuilder é o seu "catch" perfeito! 
              // Se a URL falhar, ele desenha o ícone no lugar da imagem quebrada.
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: DiscoIcon(index: currentIndexNotifier.value, height: 210, width: 210), // Você pode ajustar o tamanho do ícone conforme necessário
                );
              },
            )
          // O "else" do seu if inicial (!hasValidImage)
          : Center(
              child: DiscoIcon(index: currentIndexNotifier.value, height: 210, width: 210),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_drop_down_sharp, size: 40, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          categoryTitle.toUpperCase(),
          style: const TextStyle(fontFamily: 'poppins', fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        Image.asset('assets/images/logo.png', height: 25, errorBuilder: (context, error, stack) => const Icon(Icons.radio)),
      ],
    );
  }

  Widget _buildRadioInfo(Map<String, dynamic> radio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRadioName(radio['name'] ?? 'Sem nome'),
                const SizedBox(height: 4),
                _buildLocationRow(radio), // Passa a radio para a localização também
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPlaybackControls(bool isPlaying, Map<String, dynamic> radio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RadioShareButton(radio: radio),
        // Botão Anterior
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white),
          onPressed: () => {onPrevious(), currentIndexNotifier.value--},
        ),
        // Botão Central de Play/Pause dinâmico
        GestureDetector(
          onTap: () {
            isPlaying ? player.pause() : player.play();
          },
          child: Container(
            height: 65,
            width: 65,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
              size: 40,
            ),
          ),
        ),
        // Botão Próximo
        IconButton(
          icon: const Icon(Icons.skip_next, size: 40, color: Colors.white),
          onPressed: () => {onNext(), currentIndexNotifier.value++}, // Passa o índice atual para a função
        ),
        ValueListenableBuilder<bool>(
        valueListenable: isFavoriteNotifier,
        builder: (context, isFav, child) {
          return IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: const Color(0xFFFF6B00),
              size: 30,
            ),
            onPressed: () async {
              // 5. Chama o toggle que criamos no DatabaseService
              bool newStatus = await RadioDatabaseService.toggleFavorite(radio);
              // 6. Atualiza o ícone na hora
              isFavoriteNotifier.value = newStatus;
            },
          );
        },
      ),
      ],
    );
  }

  // --- Widgets Auxiliares para Organização ---

  Widget _buildRadioName(String name) {
    return TextScroll(
      name.trim(),
      mode: TextScrollMode.endless, // Ele vai e volta, ou use .bouncing para girar
      velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
      delayBefore: const Duration(seconds: 2),
      pauseBetween: const Duration(seconds: 1),
      style: const TextStyle(
        fontSize: 24, 
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.start,
      intervalSpaces: 15,
    );
  }

  Widget _buildLocationRow(Map<String, dynamic> radio) {
    final String locationText = [radio['state'], radio['countrycode']]
        .where((s) => s != null && s != "")
        .join(", ");

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
        child: Text(
            locationText, 
            style: const TextStyle(fontSize: 15, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ),
        const SizedBox(width: 8),
        if (radio['countrycode'] != null && radio['countrycode'] != "")
          Image.asset(
            'icons/flags/png/${radio['countrycode'].toLowerCase()}.png',
            package: 'country_icons',
            height: 13,
          ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, Map<String, dynamic> radio, bool isPlaying) {
    String tagsRaw = radio['tags']?.toString() ?? "";

    List<String> tags = tagsRaw
        .split(',')
        .map((t) => t.trim())
        .where((String t) => t.isNotEmpty) 
        .take(2)
        .toList();

    String displayTags = tags.isNotEmpty ? tags.join(" - ") : "Sem gêneros";

    int bitrate = radio['bitrate'] ?? 0;
    return Column(
      children: [
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            height: 4, // Altura discreta, estilo Spotify
            width: double.infinity,
            decoration: BoxDecoration(
              // Verde solicitado se estiver tocando, caso contrário, branco
              color: isPlaying ? const Color(0xFF4ADE80) : Colors.white,
              boxShadow: isPlaying 
                ? [BoxShadow(color: const Color(0xFF4ADE80).withValues(alpha: 0.3))]
                : [],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
  padding: const EdgeInsets.symmetric(horizontal: 6),
  child: Row(
    children: [
      // 1. Bitrate fica fixo e imune a esmagamento
      Text('bitrate: $bitrate', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      
      const SizedBox(width: 66), // Espaçamento de segurança
      
      // 2. Carrossel das Tags (Ocupa apenas o resto da tela)
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true, // A MÁGICA: Empurra o texto para a direita!
          child: Row(
            children: [
              const Text('Tags: ', style: TextStyle(color: Color(0xFFFF6B00), fontSize: 12, fontWeight: FontWeight.bold)),
              Text(displayTags, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    ],
  ),
),
      ],
    );
  }
}