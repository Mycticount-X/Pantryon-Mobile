import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pantry_item.dart';

class PantryProvider extends ChangeNotifier {
  List<PantryItem> _items = [];
  bool _isLoading = false;

  List<PantryItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading; 

  // Categories
  final List<String> categories = [
    'Sayuran', 'Buah', 'Daging', 'Ikan', 'Dairy',
    'Bumbu', 'Minuman', 'Snack', 'Bahan Kering', 'Lainnya',
  ];

  // Units
  final List<String> units = [
    'pcs', 'kg', 'g', 'L', 'ml', 'bungkus', 'kaleng', 'botol',
  ];

  PantryProvider() {
    fetchItems(); 
  }

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) return;

      final response = await supabase
          .from('pantry_items')
          .select()
          .eq('user_id', userId)
          .order('expiry_date', ascending: true);

      _items = response.map((item) => PantryItem.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error mengambil data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(PantryItem item) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final itemData = item.toJson();
      itemData['user_id'] = userId;

      await supabase.from('pantry_items').insert(itemData);

      _items.add(item);
      notifyListeners();
    } catch (e) {
      debugPrint('Error menambah data: $e');
    }
  }

  Future<void> updateItem(String id, PantryItem updatedItem) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase
          .from('pantry_items')
          .update(updatedItem.toJson())
          .eq('id', id);

      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error mengupdate data: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase.from('pantry_items').delete().eq('id', id);

      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error menghapus data: $e');
    }
  }

  List<PantryItem> get itemsExpiringSoon {
    return _items.where((item) => item.isExpiringSoon || item.isExpired).toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
  }

  int get totalItems => _items.length;
  int get expiredItemsCount => _items.where((item) => item.isExpired).length;
  int get expiringSoonCount => _items.where((item) => item.isExpiringSoon).length;

  List<PantryItem> searchItems(String query) {
    if (query.isEmpty) return _items;
    return _items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<PantryItem> filterByCategory(String category) {
    if (category == 'Semua') return _items;
    return _items.where((item) => item.category == category).toList();
  }

  List<PantryItem> sortItems(List<PantryItem> items, String sortBy) {
    final sortedItems = List<PantryItem>.from(items);
    switch (sortBy) {
      case 'Terdekat Expired':
        sortedItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;
      case 'Nama A-Z':
        sortedItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Kategori':
        sortedItems.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Terbaru Ditambah':
        sortedItems.sort((a, b) => b.addedDate.compareTo(a.addedDate));
        break;
    }
    return sortedItems;
  }
}
