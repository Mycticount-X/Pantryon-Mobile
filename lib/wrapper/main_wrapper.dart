import 'package:flutter/material.dart';
import '../screens/dashboard.dart';
import '../screens/inventory.dart';
import '../screens/recipe.dart'; 
import '../screens/profile.dart';
import '../screens/barcode_scanner.dart';
import '../widgets/alter_item.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  void _changeTab(int newIndex) {
    if (newIndex == _selectedIndex) return;

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = newIndex;
    });
  }

  void _navigateToInventory() {
    _changeTab(1);
  }

  void _onItemTapped(int index) {
    if (index == 2) return;
    _changeTab(index);
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> screens = [
      DashboardScreen(
        key: const ValueKey(0),
        onNavigateToInventory: _navigateToInventory,
      ),
      const InventoryScreen(key: ValueKey(1)),
      const SizedBox(key: ValueKey(2)),
      const RecipeScreen(key: ValueKey(3)),
      ProfileScreen(
        key: const ValueKey(4),
        onNavigateToInventory: _navigateToInventory,
      ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          final slideFromRight = _selectedIndex > _previousIndex;
          final begin = slideFromRight
              ? const Offset(1.0, 0.0)
              : const Offset(-1.0, 0.0);
          return SlideTransition(
            position: Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        },
        child: screens[_selectedIndex],
      ),
      
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none, 
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFFFF9800),
              unselectedItemColor: Colors.grey.shade400,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2),
                  label: 'Inventory',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code, color: Colors.transparent), 
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  activeIcon: Icon(Icons.restaurant_menu),
                  label: 'Resep',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          ),

          Positioned(
            top: -20, 
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push<Map<String, dynamic>>(
                  context, 
                  MaterialPageRoute(builder: (context) => const BarcodeScannerScreen())
                );

                if (result == null || !context.mounted) return;

                _changeTab(1);

                if (result['found'] == true) {
                  showDialog(
                    context: context,
                    builder: (context) => AlterItem(
                      initialData: result,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Barang tidak ditemukan. Silakan tambah manual.'),
                      backgroundColor: Colors.orange.shade700, // Warna peringatan
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );

                  showDialog(
                    context: context,
                    builder: (context) => const AlterItem(),
                  );
                }
              },
              backgroundColor: const Color(0xFFFF9800),
              elevation: 6, 
              shape: const CircleBorder(),
              child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
            ),
          ),
        ],
      ),

    );
  }
}
