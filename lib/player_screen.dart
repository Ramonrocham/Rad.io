import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // Certifique-se de importar o player

class PlayerScreen extends StatelessWidget {
  final Map<String, dynamic> radio;
  final String categoryTitle;
  final AudioPlayer player; // Recebe o player da HomeScreen
  final VoidCallback onNext; // Função para ir para a próxima rádio
  final VoidCallback onPrevious; // Função para voltar rádio

  const PlayerScreen({
    super.key, 
    required this.radio, 
    required this.categoryTitle, 
    required this.player,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Usamos o StreamBuilder para reagir ao estado do áudio (play/pause)
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final bool isPlaying = playerState?.playing ?? false;

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Column(
                children: [
                  // Topo com Título e Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down_sharp, size: 40, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        categoryTitle.toUpperCase(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      Image.asset('assets/images/logo.png', height: 25),
                    ],
                  ),
                  const Spacer(),

                  // Arte da Rádio
                  _buildRadioArt(context),
                  
                  const Spacer(),

                  // Informações da Rádio
                  _buildRadioInfo(),

                  const SizedBox(height: 30),

                  // Barra de Progresso (Visual por enquanto)
                  _buildProgressSection(context),

                  const SizedBox(height: 20),

                  // 2. Controles de Playback Funcionais
                  _buildPlaybackControls(isPlaying),
                  
                  const SizedBox(height: 60)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadioArt(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFF5D4E2E),
        borderRadius: BorderRadius.circular(20),
        image: radio['favicon'] != null && radio['favicon'] != ""
            ? DecorationImage(image: NetworkImage(radio['favicon']), fit: BoxFit.cover)
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
    );
  }

  Widget _buildRadioInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                radio['name']?.trim() ?? 'Nome da Rádio',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              _buildLocationRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(bool isPlaying) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Icon(Icons.ios_share_rounded, color: Color(0xFFFF6B00)),
        // Botão Anterior
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white),
          onPressed: onPrevious,
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
          onPressed: onNext,
        ),
        const Icon(Icons.favorite_border, color: Color(0xFFFF6B00)),
      ],
    );
  }

  // --- Widgets Auxiliares para Organização ---

  Widget _buildLocationRow() {
    final String locationText = [radio['state'], radio['countrycode']]
        .where((s) => s != null && s != "")
        .join(", ");

    return Row(
      children: [
        Text(
          locationText,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        if (radio['countrycode'] != null && radio['countrycode'] != "")
          Image.asset(
            'icons/flags/png/${radio['countrycode'].toLowerCase()}.png',
            package: 'country_icons',
            height: 16,
          ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: const Color(0xFFFF6B00),
            inactiveTrackColor: Colors.grey[800],
            thumbColor: Colors.white,
          ),
          child: Slider(value: 0.3, onChanged: (v) {}),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('LIVE', style: TextStyle(color: Color(0xFFFF6B00), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  /*Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Icon(Icons.ios_share_rounded, color: Color(0xFFFF6B00)),
        const Icon(Icons.skip_previous, size: 40),
        Container(
          height: 65,
          width: 65,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow, color: Colors.black, size: 40),
        ),
        const Icon(Icons.skip_next, size: 40),
        const Icon(Icons.favorite_border, color: Color(0xFFFF6B00)),
      ],
    );
  }*/
}