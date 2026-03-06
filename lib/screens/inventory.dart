import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pantry_provider.dart';
import '../models/pantry_item.dart';
import '../widgets/alter_item.dart';
import '../styles/style.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _sortBy = 'Terdekat Expired';

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Inventory Pantry', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSeamlessHeader(),
          _buildCategoryFilter(),
          
          Expanded(
            child: _buildItemsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  // Header & Search Bar
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
          hintText: 'Cari tomat, susu, dll...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9800)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // Category Filter
  Widget _buildCategoryFilter() {
    return Consumer<PantryProvider>(
      builder: (context, provider, child) {
        final categories = ['Semua', ...provider.categories];
        
        return Container(
          height: 60,
          margin: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: kPrimaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? kPrimaryColor : Colors.grey.shade300,
                    ),
                  ),
                  showCheckmark: false, 
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Items List 
  Widget _buildItemsList() {
    return Consumer<PantryProvider>(
      builder: (context, provider, child) {
        List<PantryItem> items = provider.items;
        
        if (_searchQuery.isNotEmpty) {
          items = provider.searchItems(_searchQuery);
        }
        if (_selectedCategory != 'Semua') {
          items = items.where((item) => item.category == _selectedCategory).toList();
        }
        
        items = provider.sortItems(items, _sortBy);
        
        if (items.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80), 
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildItemCard(items[index], provider);
          },
        );
      },
    );
  }

  // Item Card 
  Widget _buildItemCard(PantryItem item, PantryProvider provider) {
    Color statusColor;
    Color statusBgColor;

    if (item.isExpired) {
      statusColor = Colors.red.shade600;
      statusBgColor = Colors.red.shade50;
    } else if (item.isExpiringSoon) {
      statusColor = Colors.orange.shade700;
      statusBgColor = Colors.orange.shade50;
    } else {
      statusColor = Colors.green.shade600;
      statusBgColor = Colors.green.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditItemDialog(context, item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
                      const SizedBox(height: 4),
                      Text('${item.quantity} ${item.unit}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(item.category, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        item.isExpired ? 'Expired' : item.daysUntilExpiry == 0 ? 'Hari ini' : '${item.daysUntilExpiry} hari',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(DateFormat('dd MMM yy').format(item.expiryDate), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _confirmDelete(context, item, provider),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Empty State 
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.kitchen_outlined, size: 64, color: kPrimaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Pantry Kosong',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tidak ada item bernama "$_searchQuery"'
                : 'Mulai isi pantry Anda dengan menekan\ntombol Tambah di bawah.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
          ),
        ],
      ),
    );
  }

  // Other Logic
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
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 16),
                  child: Text('Urutkan Berdasarkan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                _buildSortOption('Terdekat Expired', Icons.hourglass_bottom),
                _buildSortOption('Nama A-Z', Icons.sort_by_alpha),
                _buildSortOption('Kategori', Icons.category_outlined),
                _buildSortOption('Terbaru Ditambah', Icons.new_releases_outlined),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option, IconData icon) {
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

  void _showAddItemDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AlterItem());
  }

  void _showEditItemDialog(BuildContext context, PantryItem item) {
    showDialog(context: context, builder: (context) => AlterItem(item: item));
  }

  void _confirmDelete(BuildContext context, PantryItem item, PantryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Item?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Anda yakin ingin membuang "${item.name}" dari pantry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} dihapus.'),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}