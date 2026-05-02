import 'package:flutter/material.dart';

class PlayerScreen extends StatelessWidget {
  // 1. Define que a tela PRECISA receber um mapa com os dados da rádio
  final Map<String, dynamic> radio;
  final String categoryTitle;

  const PlayerScreen({super.key, required this.radio, required this.categoryTitle,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            children: [
              // 1. Topo: Seta para fechar e Título Dinâmico
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down_sharp, size: 40, color: Color(0xFFFFFFFF),),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    categoryTitle,
                    style: const TextStyle(fontFamily: 'poppins',fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  Image.asset('assets/images/logo.png', height: 25),
                ],
              ),
              const Spacer(),

              // 2. Arte da Rádio (Dinâmica com Favicon)
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: const Color(0xFF5D4E2E), // Cor de fallback
                  borderRadius: BorderRadius.circular(20),
                  image: radio['favicon'] != null && radio['favicon'] != ""
                      ? DecorationImage(
                          image: NetworkImage(radio['favicon']),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
              ),
              const Spacer(),

              // 3. Informações da Rádio (Dinâmicas)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          radio['name'].trim() ?? 'Nome da Rádio',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildLocationRow(), // Helper para localização + bandeira
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 4. Barra de Progresso (Slider Estático por enquanto)
              _buildProgressSection(context),

              const SizedBox(height: 20),

              // 5. Controles de Playback
              _buildPlaybackControls(),
              const SizedBox(height: 60)
            ],
          ),
        ),
      ),
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

  Widget _buildPlaybackControls() {
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
  }
}