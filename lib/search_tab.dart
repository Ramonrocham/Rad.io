import 'package:flutter/material.dart';
import 'radio_api_service.dart';

class SearchTab extends StatefulWidget {
  // Recebe a função do main.dart para tocar a música
  final Function(List<dynamic>, int, String) onPlayRadio;

  const SearchTab({super.key, required this.onPlayRadio});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  
  // Controle de estado da pesquisa
  String _selectedFilter = 'Nome'; // Filtro padrão
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<String> _filters = ['País', 'Nome', 'Gênero', 'Idioma', 'Id'];

  // Função que faz a requisição baseada no filtro selecionado
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      // Limpa os resultados anteriores enquanto busca
      _searchResults = []; 
    });

    String endpoint = '';
    
    // Switch para definir a rota correta da API baseado na Label
    switch (_selectedFilter) {
      case 'País':
        endpoint = 'bycountry/${Uri.encodeComponent(query)}';
        break;
      case 'Nome':
        endpoint = 'byname/${Uri.encodeComponent(query)}';
        break;
      case 'Gênero': // Na API é chamado de Tag
        endpoint = 'bytag/${Uri.encodeComponent(query)}';
        break;
      case 'Idioma':
        endpoint = 'bylanguage/${Uri.encodeComponent(query)}';
        break;
      case 'Id': // uuid da rádio
        endpoint = 'byuuid/${Uri.encodeComponent(query)}';
        break;
    }

    try {
      final results = await RadioApiService().fetchRadios(endpoint);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro na busca: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // 1. Header: Logo, Texto e Ícone QR Code
          Row(
            children: [
              Image.asset('assets/images/logo.png', height: 40),
              const SizedBox(width: 10),
              const Text(
                'Search',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Color(0xFFFF6B00), size: 32),
                onPressed: () {
                  // TODO: Chamar a função do leitor de QR Code desenvolvida anteriormente
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // 2. Campo de Busca
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF5D4E2E), // O fundo marrom/dourado escuro do mockup
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _performSearch(), // Pesquisa ao dar "Enter" no teclado
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                suffixIcon: GestureDetector(
                  onTap: _performSearch, // Pesquisa ao clicar na Lupa
                  child: const Icon(Icons.search, color: Color(0xFFFF6B00)),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // 3. Filtros (Pesquisar por:)
          Row(
            children: [
              const Text(
                'Pesquisar por:',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFF282828),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // 4. Grid de Resultados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                : (!_hasSearched)
                    ? const Center(
                        child: Text("Digite algo para pesquisar", style: TextStyle(color: Colors.grey)))
                    : _searchResults.isEmpty
                        ? const Center(
                            child: Text("Nenhuma rádio encontrada", style: TextStyle(color: Colors.grey)))
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 100), // Espaço para o MiniPlayer
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return _buildSearchResultItem(_searchResults[index], index);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // Layout individual de cada item da grade (idêntico ao mockup)
  Widget _buildSearchResultItem(dynamic radio, int index) {
    final String? favicon = radio['favicon'];
    final bool hasValidImage = favicon != null && favicon.isNotEmpty && favicon != "null";

    return GestureDetector(
      onTap: () => widget.onPlayRadio(_searchResults, index, 'Busca: ${_searchController.text}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4E2E), // Fundo padronizado do mockup
                borderRadius: BorderRadius.circular(4),
                image: hasValidImage
                    ? DecorationImage(image: NetworkImage(radio['favicon']), fit: BoxFit.cover)
                    : null,
              ),
              child: !hasValidImage
                  ? const Center(child: Icon(Icons.radio, color: Colors.white24, size: 30))
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            radio['name']?.trim() ?? 'Rádio Sem Nome',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            (radio['state'] != null && radio['state'] != "") 
                ? "${radio['state']}, ${radio['countrycode'] ?? ''}" 
                : "${radio['countrycode'] ?? ''}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}