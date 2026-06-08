import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../styles/style.dart'; 
import 'register.dart';
import '../wrapper/main_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        // _showErrorSnackBar('Gagal masuk. Periksa email dan password Anda.');
        _showErrorSnackBar('Error: ${e.toString()}');
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
            top: screenHeight * 0.08, 
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 240, 
                  height: 240, 
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
                // const SizedBox(height: 16),
                // const Text(
                //   'Pantryon',
                //   style: TextStyle(
                //     fontSize: 40,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white,
                //     letterSpacing: 1.2,
                //   ),
                // ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.60,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                padding: const EdgeInsets.all(32.0),
                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // const Text(
                    //   'Welcome Back!', 
                    //   style: kHeaderStyle,
                    //   textAlign: TextAlign.center,
                    // ),

                    Text.rich(
                      TextSpan(
                        style: kHeaderStyle,
                        children: [
                          TextSpan(
                            text: 'Welcome ',
                          ),
                          TextSpan(
                            text: 'Back!',
                            style: TextStyle(color: kSecondaryColor), 
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center, 
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Let\'s continue our journey!',
                      textAlign: TextAlign.center,
                      style: kSubHeaderStyle,
                    ),
                    const SizedBox(height: 40),

                    // Input Email
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: kInputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Input Password
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
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: kPrimaryColor.withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Masuk', style: kButtonTextStyle),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        const Text(
                          'Belum punya akun?',
                          style: TextStyle(
                            color: Colors.black54, 
                          ),
                        ),
                        
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0), 
                          ),
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Daftar di sini', 
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