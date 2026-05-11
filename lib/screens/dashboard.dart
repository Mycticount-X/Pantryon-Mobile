import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/pantry_provider.dart';
import '../models/pantry_item.dart';
import 'inventory.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _username = 'Pantryoners';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('username')
            .eq('id', userId)
            .single();
        
        if (mounted) {
          setState(() {
            _username = data['username'] ?? 'User';
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal mengambil profil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer<PantryProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(_username),
                const SizedBox(height: 16),
                
                _buildUnifiedStatCard(provider),
                const SizedBox(height: 32),
                
                _buildExpiringSoonSection(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreeting(String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          'Welcome Back,',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          username,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
        ),
      ],
    );
  }

  Widget _buildUnifiedStatCard(PantryProvider provider) {
    final int freshCount = provider.totalItems - provider.expiringSoonCount - provider.expiredItemsCount;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF9800).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InventoryScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pantry Summary',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last Updated: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.8), size: 18),
                  ],
                ),
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Item Fresh 
                    _buildUnifiedStatItem(
                      freshCount.toString(),
                      'Fresh',
                      Icons.eco_outlined,
                      Colors.green.shade500,
                    ),
                    // To Be Expired 
                    _buildUnifiedStatItem(
                      provider.expiringSoonCount.toString(),
                      'Warning',
                      Icons.timer_outlined,
                      Colors.orange.shade500,
                    ),
                    // Expired 
                    _buildUnifiedStatItem(
                      provider.expiredItemsCount.toString(),
                      'Expired',
                      Icons.error_outline_rounded,
                      Colors.red.shade500,
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

  Widget _buildUnifiedStatItem(String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildExpiringSoonSection(BuildContext context, PantryProvider provider) {
    final expiringItems = provider.itemsExpiringSoon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer_outlined,
                color: Colors.red.shade400,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            
            const Text(
              'To Be Expired', 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF424242)
              ),
            ),
            
            const Spacer(),
            
            if (expiringItems.isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen()));
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'View All', 
                        style: TextStyle(
                          color: Color(0xFFFF9800), 
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        )
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded, 
                        size: 14, 
                        color: const Color(0xFFFF9800),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        expiringItems.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expiringItems.length > 5 ? 5 : expiringItems.length, 
                itemBuilder: (context, index) {
                  return _buildExpiringItemCard(expiringItems[index]);
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.shade100)),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle), child: Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade400)),
          const SizedBox(height: 16),
          const Text('All Items Safe and Controlled!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('There are no food items that will expire within the next 7 days.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildExpiringItemCard(PantryItem item) {
    Color statusColor = item.isExpired ? Colors.red.shade500 : Colors.orange.shade500;
    Color statusBgColor = item.isExpired ? Colors.red.shade50 : Colors.orange.shade50;
    String statusText = item.isExpired ? 'Expired' : (item.daysUntilExpiry == 0 ? 'Today' : '${item.daysUntilExpiry} days left');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusBgColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(item.isExpired ? Icons.error_outline : Icons.timer_outlined, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${item.quantity} ${item.unit} • ${item.category}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 6),
              Text(DateFormat('dd MMM yy').format(item.expiryDate), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}