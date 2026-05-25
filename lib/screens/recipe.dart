import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pantry_provider.dart';
import '../models/pantry_item.dart';

class Recipe {
  final String title;
  final String duration;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
  });
}

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final Color kPrimaryColor = const Color(0xFFFF9800);
  
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  String _sortBy = 'Paling Cocok';

  final List<Recipe> _dummyRecipes = [
    Recipe(
      title: 'Nasi Goreng Spesial',
      duration: '15 Menit',
      difficulty: 'Mudah',
      ingredients: ['Nasi', 'Telur', 'Bawang Merah', 'Bawang Putih', 'Kecap'],
      steps: [
        'Iris bawang merah dan bawang putih.',
        'Tumis bumbu hingga harum, masukkan telur dan orak-arik.',
        'Masukkan nasi, tambahkan kecap, aduk rata hingga matang.'
      ],
    ),
    Recipe(
      title: 'Sup Ayam Sayuran',
      duration: '45 Menit',
      difficulty: 'Sedang',
      ingredients: ['Ayam', 'Wortel', 'Kentang', 'Bawang Putih', 'Daun Bawang'],
      steps: [
        'Rebus ayam hingga empuk, potong dadu.',
        'Masukkan kentang dan wortel ke dalam kaldu rebusan.',
        'Tumis bawang putih halus, masukkan ke dalam sup bersama daun bawang.'
      ],
    ),
    Recipe(
      title: 'Tumis Kangkung Terasi',
      duration: '10 Menit',
      difficulty: 'Mudah',
      ingredients: ['Kangkung', 'Bawang Merah', 'Bawang Putih', 'Cabai', 'Terasi'],
      steps: [
        'Petik daun kangkung dan cuci bersih.',
        'Tumis duo bawang, cabai, dan terasi hingga harum.',
        'Masukkan kangkung, masak dengan api besar dengan cepat.'
      ],
    ),
  ];

  Map<String, dynamic> _checkIngredients(List<String> recipeIngredients, List<PantryItem> pantryItems) {
    int availableCount = 0;
    List<String> missing = [];

    final validPantryNames = pantryItems
        .where((item) => !item.isExpired)
        .map((item) => item.name.toLowerCase())
        .toList();

    for (var ingredient in recipeIngredients) {
      final String ingredientLower = ingredient.toLowerCase();
      bool isFound = validPantryNames.any((pantryItemName) => pantryItemName.contains(ingredientLower));

      if (isFound) {
        availableCount++;
      } else {
        missing.add(ingredient);
      }
    }

    return {
      'available': availableCount,
      'missing': missing,
      'isReady': availableCount == recipeIngredients.length,
      'missingCount': missing.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Inspirasi Resep', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Consumer<PantryProvider>(
        builder: (context, provider, child) {
          final pantryItems = provider.items;

          List<Map<String, dynamic>> processedRecipes = _dummyRecipes.map((recipe) {
            final matchData = _checkIngredients(recipe.ingredients, pantryItems);
            return {
              'recipe': recipe,
              'available': matchData['available'],
              'total': recipe.ingredients.length,
              'missing': matchData['missing'],
              'isReady': matchData['isReady'],
              'missingCount': matchData['missingCount'],
            };
          }).toList();

          // 2. Filter Pencarian
          if (_searchQuery.isNotEmpty) {
            processedRecipes = processedRecipes.where((data) => (data['recipe'] as Recipe).title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
          }

          // 3. Filter Status 
          if (_selectedFilter != 'Semua') {
            processedRecipes = processedRecipes.where((data) {
              int missingCount = data['missingCount'];
              if (_selectedFilter == 'Bisa Dimasak') return missingCount == 0;
              if (_selectedFilter == 'Bisa Diakali') return missingCount > 0 && missingCount <= 2;
              if (_selectedFilter == 'Belum Bisa') return missingCount > 2;
              return true;
            }).toList();
          }

          processedRecipes.sort((a, b) {
            if (_sortBy == 'Paling Cocok') {
              return (a['missingCount'] as int).compareTo(b['missingCount'] as int);
            } else if (_sortBy == 'Nama A-Z') {
              return (a['recipe'] as Recipe).title.compareTo((b['recipe'] as Recipe).title);
            }
            return 0;
          });

          return Column(
            children: [
              _buildSeamlessHeader(),
              _buildStatusFilter(),
              
              Expanded(
                child: processedRecipes.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: processedRecipes.length,
                        itemBuilder: (context, index) {
                          final data = processedRecipes[index];
                          return _buildRecipeCard(
                            data['recipe'], data['available'], data['total'], data['isReady'], data['missing']
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, int available, int total, bool isReady, List<String> missing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showRecipeDetails(context, recipe, isReady, missing),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.restaurant_menu, color: kPrimaryColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(recipe.duration, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                              const SizedBox(width: 12),
                              Icon(Icons.bar_chart_rounded, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(recipe.difficulty, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress Bar Ketersediaan Bahan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bahan: $available/$total tersedia',
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.bold, 
                        color: isReady ? Colors.green.shade600 : Colors.orange.shade700
                      ),
                    ),
                    if (isReady) 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text('Bisa Dimasak!', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: available / total,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isReady ? Colors.green.shade500 : Colors.orange.shade400
                  ),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, Recipe recipe, bool isReady, List<String> missing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              alignment: Alignment.center,
              child: Text(recipe.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isReady) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
                        child: Row(
                          children: [
                            Icon(Icons.shopping_cart_outlined, color: Colors.red.shade400),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bahan yang kurang: ${missing.join(", ")}',
                                style: TextStyle(color: Colors.red.shade700, fontSize: 13, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    const Text('Bahan-bahan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...recipe.ingredients.map((ing) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            missing.contains(ing) ? Icons.cancel_outlined : Icons.check_circle, 
                            color: missing.contains(ing) ? Colors.grey.shade400 : Colors.green.shade500,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(ing, style: TextStyle(fontSize: 15, color: missing.contains(ing) ? Colors.grey.shade600 : Colors.black87)),
                        ],
                      ),
                    )),
                    
                    const Divider(height: 32, thickness: 1),
                    
                    const Text('Cara Memasak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...recipe.steps.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.2), shape: BoxShape.circle),
                            child: Text('${entry.key + 1}', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(entry.value, style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF424242))),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSeamlessHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)), 
        boxShadow: [
          BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari nasi goreng, sup...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9800)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final filters = ['Semua', 'Bisa Dimasak', 'Bisa Diakali', 'Belum Bisa'];
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => setState(() => _selectedFilter = filter),
              backgroundColor: Colors.white,
              selectedColor: kPrimaryColor,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? kPrimaryColor : Colors.grey.shade300)),
              showCheckmark: false, 
            ),
          );
        },
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(left: 16, bottom: 16), child: Text('Urutkan Resep', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                _buildSortItem('Paling Cocok', Icons.restaurant_menu),
                _buildSortItem('Nama A-Z', Icons.sort_by_alpha),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortItem(String option, IconData icon) {
    final isSelected = _sortBy == option;
    return ListTile(
      leading: Icon(icon, color: isSelected ? kPrimaryColor : Colors.grey.shade600),
      title: Text(option, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? kPrimaryColor : Colors.black87)),
      trailing: isSelected ? Icon(Icons.check_circle, color: kPrimaryColor) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        setState(() => _sortBy = option);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Tidak ada resep yang sesuai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('Coba ubah filter atau kata kunci pencarian Anda.', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}