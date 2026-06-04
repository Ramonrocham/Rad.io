import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio/disco_icon.dart';
import 'radio_database_service.dart';
import 'player_screen.dart';

class MiniPlayer extends StatefulWidget {
  final ValueNotifier<Map<String, dynamic>?> radioNotifier;
  final AudioPlayer player;
  final List<dynamic> radiosList;
  final int currentIndex;
  final String categoryTitle;
  final Function(List<dynamic>, int, String) onPlay;

  const MiniPlayer({
    super.key,
    required this.radioNotifier,
    required this.player,
    required this.radiosList,
    required this.currentIndex,
    required this.categoryTitle,
    required this.onPlay,
  });

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final ValueNotifier<bool> isFavoriteNotifier = ValueNotifier(false);

  // Verifica se a rádio atual é favorita sempre que o notifier mudar
  void _checkFav(String? uuid) async {
    if (uuid == null) return;
    isFavoriteNotifier.value = await RadioDatabaseService.isFavorite(uuid);
  }

  @override
  void initState() {
    super.initState();
    // 3. Ouve o banco de dados. Sempre que o "sino" tocar, a gente re-checa o favorito.
    RadioDatabaseService.favoriteChangeNotifier.addListener(_refreshFavoriteStatus);
  }

  @override
  void dispose() {
    // 4. Importante para evitar vazamento de memória no Android/Linux
    RadioDatabaseService.favoriteChangeNotifier.removeListener(_refreshFavoriteStatus);
    super.dispose();
  }

  void _refreshFavoriteStatus() {
    final radio = widget.radioNotifier.value;
    if (radio != null) {
      _checkFav(radio['stationuuid']);
    }
  }

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: widget.radioNotifier,
      builder: (context, radio, child) {
        if (radio == null) return const SizedBox.shrink();

        _checkFav(radio['stationuuid']); // Atualiza o coração ao mudar de rádio

        return Dismissible(
          key: Key(radio['stationuuid'] ?? UniqueKey().toString()),
          direction: DismissDirection.horizontal,
          onDismissed: (_) {
            widget.player.stop();
            widget.radioNotifier.value = null;
          },
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerScreen(
                  radioNotifier: widget.radioNotifier,
                  categoryTitle: widget.categoryTitle,
                  player: widget.player,
                  onNext: () => widget.onPlay(widget.radiosList, (widget.currentIndex + 1) % widget.radiosList.length, widget.categoryTitle),
                  onPrevious: () => widget.onPlay(widget.radiosList, (widget.currentIndex - 1 + widget.radiosList.length) % widget.radiosList.length, widget.categoryTitle),
                  currentIndex: widget.currentIndex,
                ),
              ),
            ),
            child: Container(
              height: 75,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  _buildArt(radio['favicon'], widget.currentIndex),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfo(radio)),
                  
                  // BOTÃO FAVORITO FUNCIONAL
                  ValueListenableBuilder<bool>(
                    valueListenable: isFavoriteNotifier,
                    builder: (context, isFav, _) => IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFFF6B00)),
                      onPressed: () async {
                        bool res = await RadioDatabaseService.toggleFavorite(radio);
                        isFavoriteNotifier.value = res;
                      },
                    ),
                  ),

                  // BOTÃO PLAY/PAUSE FUNCIONAL
                  StreamBuilder<PlayerState>(
                    stream: widget.player.playerStateStream,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data?.playing ?? false;
                      final processingState = snapshot.data?.processingState;

                      if (processingState == ProcessingState.buffering || processingState == ProcessingState.loading) {
                        return const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B00)));
                      }

                      return IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 35, color: const Color(0xFFFF6B00)),
                        onPressed: () => isPlaying ? widget.player.pause() : widget.player.play(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArt(String? url, int index) { // <-- Adicionado o index aqui
  final bool hasValidImage = url != null && url.isNotEmpty;

  return Container(
    width: 48, 
    height: 48,
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: hasValidImage
          ? Image.network(
              url,
              fit: BoxFit.cover,
              // Se a URL falhar ao carregar, exibe o seu DiscoIcon
              errorBuilder: (context, error, stackTrace) {
                return DiscoIcon(index: index, margin: 6);
              },
            )
          // Se a URL vier nula ou vazia da API, exibe o seu DiscoIcon
          : DiscoIcon(index: index, margin: 6),
    ),
  );
}

  Widget _buildInfo(Map<String, dynamic> radio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(radio['name'] ?? 'Rádio', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        _buildLocationRow(radio),
      ],
    );
  }

  Widget _buildLocationRow(Map<String, dynamic> radio) {
    final String location = [radio['state'], radio['countrycode']].where((s) => s != null && s != "").join(", ");
    return Row(
      children: [
        Flexible(child: Text(location, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 4),
        if (radio['countrycode'] != null)
          Image.asset('icons/flags/png/${radio['countrycode'].toLowerCase()}.png', package: 'country_icons', height: 10),
      ],
    );
  }
}