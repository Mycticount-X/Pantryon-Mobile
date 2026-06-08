import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../styles/style.dart';
import '../wrapper/main_wrapper.dart';

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
            MaterialPageRoute(builder: (context) => const MainWrapper()), 
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.45,
            decoration: const BoxDecoration(
              gradient: kDefaultGradient,
            ),
          ),
          
          Positioned(
            top: 50, 
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            top: screenHeight * 0.1,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 200, 
                  height: 200, 
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    border: Border.all(
                      color: Colors.white, 
                      width: 4.0, 
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/icons/app_icon.png'), 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Teks "Pantryon" dan kotak ikon lama sudah dihapus dari sini
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.65,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: kHeaderStyle,
                        children: [
                          const TextSpan(
                            text: 'Create ',
                          ),
                          TextSpan(
                            text: 'New Account',
                            style: TextStyle(color: kSecondaryColor),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center, 
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start your pantry journey with us!',
                      textAlign: TextAlign.center,
                      style: kSubHeaderStyle,
                    ),
                    const SizedBox(height: 40),

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
                    const SizedBox(height: 40),

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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        const Text(
                          'Sudah punya akun?',
                          style: TextStyle(
                            color: Colors.black54, 
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0), 
                          ),
                          onPressed: () {
                            Navigator.pop(context); 
                          },
                          child: const Text(
                            'Masuk di sini', 
                            style: kLinkTextStyle,
                          ),
                        ),
                      ],
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