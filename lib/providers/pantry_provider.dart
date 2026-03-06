import 'package:flutter/foundation.dart';
import '../models/pantry_item.dart';

class PantryProvider extends ChangeNotifier {
  final List<PantryItem> _items = [];

  List<PantryItem> get items => List.unmodifiable(_items);

  // Categories
  final List<String> categories = [
    'Sayuran',
    'Buah',
    'Daging',
    'Ikan',
    'Dairy',
    'Bumbu',
    'Minuman',
    'Snack',
    'Bahan Kering',
    'Lainnya',
  ];

  // Units
  final List<String> units = [
    'pcs',
    'kg',
    'g',
    'L',
    'ml',
    'bungkus',
    'kaleng',
    'botol',
  ];

  PantryProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    _items.addAll([
      PantryItem(
        id: '1',
        name: 'Tomat',
        category: 'Sayuran',
        quantity: 5,
        unit: 'pcs',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        addedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PantryItem(
        id: '2',
        name: 'Susu',
        category: 'Dairy',
        quantity: 2,
        unit: 'L',
        expiryDate: DateTime.now().add(const Duration(days: 15)),
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PantryItem(
        id: '3',
        name: 'Ayam',
        category: 'Daging',
        quantity: 1,
        unit: 'kg',
        expiryDate: DateTime.now().add(const Duration(days: 1)),
        addedDate: DateTime.now(),
      ),
      PantryItem(
        id: '4',
        name: 'Bawang Putih',
        category: 'Bumbu',
        quantity: 200,
        unit: 'g',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        addedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      PantryItem(
        id: '5',
        name: 'Telur',
        category: 'Dairy',
        quantity: 10,
        unit: 'pcs',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        addedDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }

  List<PantryItem> get itemsExpiringSoon {
    return _items.where((item) => item.isExpiringSoon || item.isExpired).toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
  }

  int get totalItems => _items.length;
  int get expiredItemsCount => _items.where((item) => item.isExpired).length;
  int get expiringSoonCount => _items.where((item) => item.isExpiringSoon).length;

  void addItem(PantryItem item) {
    _items.add(item);
    notifyListeners();
  }

  void updateItem(String id, PantryItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

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