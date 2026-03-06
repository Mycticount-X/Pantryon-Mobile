import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pantry_provider.dart';
import '../models/pantry_item.dart';

class AlterItem extends StatefulWidget {
  final PantryItem? item;

  const AlterItem({super.key, this.item});

  @override
  State<AlterItem> createState() => _AlterItemState();
}

class _AlterItemState extends State<AlterItem> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late String _selectedCategory;
  late String _selectedUnit;
  late DateTime _expiryDate;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '',
    );
    _selectedCategory = widget.item?.category ?? 'Sayuran';
    _selectedUnit = widget.item?.unit ?? 'pcs';
    _expiryDate = widget.item?.expiryDate ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PantryProvider>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  isEditing ? 'Edit Item' : 'Tambah Item Baru',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Item',
                    hintText: 'Contoh: Tomat',
                    prefixIcon: const Icon(Icons.shopping_basket),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama item tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quantity and Unit Row
                Row(
                  children: [
                    // Quantity
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Jumlah',
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah tidak boleh kosong';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Unit
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedUnit,
                        decoration: InputDecoration(
                          labelText: 'Satuan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: provider.units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: provider.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Expiry Date
                InkWell(
                  onTap: _selectExpiryDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tanggal Expired',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMMM yyyy').format(_expiryDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(isEditing ? 'Update' : 'Simpan'),
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

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF9800),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PantryProvider>(context, listen: false);

      final item = PantryItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: int.parse(_quantityController.text),
        unit: _selectedUnit,
        expiryDate: _expiryDate,
        addedDate: widget.item?.addedDate ?? DateTime.now(),
      );

      if (isEditing) {
        provider.updateItem(widget.item!.id, item);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil diupdate'),
            backgroundColor: Color(0xFFFF9800),
          ),
        );
      } else {
        provider.addItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil ditambahkan'),
            backgroundColor: Color(0xFFFF9800),
          ),
        );
      }

      Navigator.pop(context);
    }
  }
}