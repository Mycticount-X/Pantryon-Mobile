import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/pantry_provider.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'Memuat...';
  String _email = 'Memuat...';

  final Color kPrimaryColor = const Color(0xFFFF9800);

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final email = user.email ?? 'Tidak ada email';
        
        final data = await Supabase.instance.client
            .from('profiles')
            .select('username')
            .eq('id', user.id)
            .single();
            
        if (mounted) {
          setState(() {
            _email = email;
            _username = data['username'] ?? 'Pantryoners';
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal mengambil profil: $e');
      if (mounted) {
        setState(() {
          _username = 'Pengguna';
          _email = 'Gagal memuat data';
        });
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari Pantryon?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMiniStatsCard(),
            ),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildActionMenu(context),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _username.isNotEmpty ? _username[0].toUpperCase() : 'P',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: kPrimaryColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _username,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatsCard() {
    return Consumer<PantryProvider>(
      builder: (context, provider, child) {
        
        // Logika untuk menghitung barang yang kondisinya masih segar (Fresh)
        final int freshCount = provider.totalItems - provider.expiringSoonCount - provider.expiredItemsCount;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8), // Sedikit penyesuaian padding agar muat 3 item
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Item Fresh (Hijau)
              _buildStatItem(
                'Fresh', 
                freshCount.toString(), 
                Icons.eco_outlined, // Ikon daun melambangkan kesegaran
                Colors.green.shade500,
              ),
              
              Container(width: 1, height: 40, color: Colors.grey.shade200), // Garis pembatas
              
              // 2. To Be Expired / Warning (Oranye)
              _buildStatItem(
                'Warning', 
                provider.expiringSoonCount.toString(), 
                Icons.timer_outlined, 
                Colors.orange.shade500,
              ),
              
              Container(width: 1, height: 40, color: Colors.grey.shade200), // Garis pembatas
              
              // 3. Expired (Merah)
              _buildStatItem(
                'Expired', 
                provider.expiredItemsCount.toString(), 
                Icons.error_outline_rounded, 
                Colors.red.shade500,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profil',
            subtitle: 'Ubah nama dan info pribadi',
            onTap: () {
              // TODO: Navigasi ke halaman edit profil nanti
              ScaffoldMessenger.of(context).clearSnackBars(); 
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Edit Profil segera hadir!')),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey.shade100, indent: 60),
          _buildMenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Bantuan & Dukungan',
            subtitle: 'Hubungi kami jika ada masalah',
            onTap: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pantryon Support v1.0')),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey.shade100, indent: 60),
          _buildMenuTile(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            subtitle: 'Akhiri sesi Anda',
            isDestructive: true,
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red.shade400 : const Color(0xFF424242);
    final iconBgColor = isDestructive ? Colors.red.shade50 : Colors.grey.shade100;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onTap: onTap,
    );
  }
}
