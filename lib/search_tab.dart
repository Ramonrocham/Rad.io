import 'package:flutter/material.dart';
import 'package:radio/radio_card_item.dart';
import 'radio_api_service.dart';

class SearchTab extends StatefulWidget {
  final Function(List<dynamic> radios, int index, String categoryTitle) onPlayRadio;

  const SearchTab({super.key, required this.onPlayRadio});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  
  // Controle de estado da pesquisa e ordenação
  String _selectedFilter = 'Nome'; 
  String _selectedOrder = 'Ouvintes'; // Nova variável de estado para a ordem
  
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isDescending = false;

  // MAPS: Key = UI (O que o usuário vê) | Value = API (O parâmetro da URL)
  // Ajustei os valores para baterem exatamente com a rota "search" da API do Radio Browser
  final Map<String, String> _filters = {
    'Nome': 'name', 
    'País': 'country', 
    'Gênero': 'tag', 
    'Idioma': 'language', 
    'Id': 'uuid'
  };
  
  final Map<String, String> _orders = {
    'Ouvintes': 'clickcount', 
    'Votos': 'votes', 
    'Nome': 'name', 
    'País': 'country'
  };

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResults = []; 
    });

    String endpoint;
    
    // Pegamos os valores reais que a API entende baseados nas chaves selecionadas
    final String apiFilterParam = _filters[_selectedFilter]!;
    final String apiOrderParam = _orders[_selectedOrder]!;
    final String encodedQuery = Uri.encodeComponent(query);

    // Lógica enxuta de montagem da URL
    if (_selectedFilter == 'Id') {
      endpoint = 'byuuid/$encodedQuery';
    } else {
      endpoint = 'search?$apiFilterParam=$encodedQuery&order=$apiOrderParam';
    }

    if (_isDescending) {
        endpoint += '&reverse=true';
      }

    try {
      final results = await RadioApiService().fetchRadios(endpoint);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
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
          
          // 1. Header
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
                  // TODO: Chamar a função do leitor de QR Code
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // 2. Campo de Busca
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF5D4E2E), 
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _performSearch(), 
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                suffixIcon: GestureDetector(
                  onTap: _performSearch, 
                  child: const Icon(Icons.search, color: Color(0xFFFF6B00)),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // 3. Filtros (Pesquisar por)
          Row(
            children: [
              const Text('Pesquisar por:', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // O segredo está aqui: _filters.keys.map para iterar apenas sobre os nomes em Português
                  child: Row(
                    children: _filters.keys.map((filterKey) {
                      final isSelected = _selectedFilter == filterKey;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filterKey),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFF282828),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            filterKey,
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
          
          const SizedBox(height: 12), // Espaçamento entre as duas linhas de filtro

          // 4. Ordenação (Ordenar por)
          Row(
            children: [
              const Text('Ordenar por:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(width: 19), 
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Os itens de ordenação normais (Map dinâmico)
                      ..._orders.keys.map((orderKey) {
                        final isSelected = _selectedOrder == orderKey;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedOrder = orderKey);
                            if (_hasSearched && _searchController.text.isNotEmpty) {
                              _performSearch();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFF282828),
                            borderRadius: BorderRadius.circular(4),
                          ),
                            child: Text(
                              orderKey,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                      
                      // Botão Decrescente no final da fila, com O MESMO estilo visual
                      GestureDetector(
                        onTap: () {
                          setState(() => _isDescending = !_isDescending);
                          if (_hasSearched && _searchController.text.isNotEmpty) {
                            _performSearch();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            // Aqui aplicamos a mesma identidade visual da ordem
                            color: _isDescending ? const Color(0xFFFF6B00) : const Color(0xFF282828),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Decrescente',
                                style: TextStyle(
                                  // Mesma cor de texto
                                  color: _isDescending ? Colors.white : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: _isDescending ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Mantive o ícone para dar um charme, combinando com a cor do texto
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // 5. Grid de Resultados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                : (!_hasSearched)
                    ? const Center(child: Text("Digite algo para pesquisar", style: TextStyle(color: Colors.grey)))
                    : _searchResults.isEmpty
                        ? const Center(child: Text("Nenhuma rádio encontrada", style: TextStyle(color: Colors.grey)))
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 100), 
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return RadioCardItem(radio: _searchResults[index], index: index, allRadios: _searchResults, onRadioTap: widget.onPlayRadio, categoryTitle: "Search Results");
                            },
                          ),
          ),
        ],
      ),
    );
  }
}