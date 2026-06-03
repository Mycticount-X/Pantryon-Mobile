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

  void _onItemTapped(int index) {
      if (index == 2) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    void navigateToInventory() {
      setState(() {
        _selectedIndex = 1;
      });
    }

    final List<Widget> screens = [
      DashboardScreen(
        key: const ValueKey(0),
        onNavigateToInventory: navigateToInventory,
      ),
      const InventoryScreen(key: ValueKey(1)),
      const SizedBox(key: ValueKey(2)),
      const RecipeScreen(key: ValueKey(3)),
      ProfileScreen(
        key: const ValueKey(4),
        onNavigateToInventory: navigateToInventory,
      ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: screens[_selectedIndex],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 20), 
        
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push<Map<String, dynamic>>(
              context, 
              MaterialPageRoute(builder: (context) => const BarcodeScannerScreen())
            );

            if (result == null || !context.mounted) return;

            setState(() {
              _selectedIndex = 1;
            });

            showDialog(
              context: context,
              builder: (context) => AlterItem(
                initialData: result['found'] == true ? result : null,
              ),
            );
          },
          backgroundColor: const Color(0xFFFF9800),
          elevation: 6, 
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
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
    );
  }
}
