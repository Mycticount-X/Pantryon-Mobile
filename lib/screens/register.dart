import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../styles/style.dart';
import 'dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = res.user;

      if (user != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
        });

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false, 
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Gagal mendaftar. Periksa kembali email Anda.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: kDefaultGradient,
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: kPrimaryColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text('Buat Akun Baru', style: kHeaderStyle),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Mulai kelola pantry Anda hari ini.',
                      textAlign: TextAlign.center,
                      style: kSubHeaderStyle,
                    ),
                    const SizedBox(height: 48),

                    TextField(
                      controller: _usernameController,
                      decoration: kInputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: kInputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: kInputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: kTextGrey,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: kPrimaryColor.withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Daftar Sekarang', style: kButtonTextStyle),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
