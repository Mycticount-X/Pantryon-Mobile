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
        centerTitle: true,
      ),
      body: Consumer<PantryProvider>(
        builder: (context, provider, child) {
          final pantryItems = provider.items;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _dummyRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _dummyRecipes[index];
              final matchData = _checkIngredients(recipe.ingredients, pantryItems);
              
              final int available = matchData['available'];
              final int total = recipe.ingredients.length;
              final bool isReady = matchData['isReady'];
              final List<String> missingIngredients = matchData['missing'];

              return _buildRecipeCard(recipe, available, total, isReady, missingIngredients);
            },
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
}