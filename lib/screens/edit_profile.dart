import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../styles/style.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _profileService = ProfileService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingProfile = true;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.fetchCurrentProfile();
      if (!mounted) return;
      setState(() {
        _nameController.text = profile.username;
        _emailController.text = profile.email;
        _isLoadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProfile = false);
      _showErrorSnackBar(ProfileService.mapError(e));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim());
  }

  String? _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (name.isEmpty) {
      return 'Nama tidak boleh kosong.';
    }
    if (email.isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    if (!_isValidEmail(email)) {
      return 'Format email tidak valid.';
    }

    final wantsPasswordChange = newPassword.isNotEmpty;
    final hasOldPassword = oldPassword.isNotEmpty;

    if (wantsPasswordChange) {
      if (!hasOldPassword) {
        return 'Password lama wajib diisi untuk mengubah password.';
      }
      if (newPassword.length < 6) {
        return 'Password baru minimal 6 karakter.';
      }
    } else if (hasOldPassword) {
      return 'Isi password baru jika ingin mengubah password.';
    }

    return null;
  }

  Future<void> _confirmUpdate() async {
    final validationError = _validateForm();
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final newPassword = _newPasswordController.text;
      await _profileService.updateProfile(
        username: _nameController.text,
        email: _emailController.text,
        oldPassword: newPassword.isNotEmpty
            ? _oldPasswordController.text
            : null,
        newPassword: newPassword.isNotEmpty ? newPassword : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui.'),
          backgroundColor: kPrimaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(ProfileService.mapError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
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

  Widget _passwordVisibilityToggle({
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: kTextGrey,
      ),
      onPressed: onToggle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nameController,
                          enabled: !_isLoading,
                          textCapitalization: TextCapitalization.words,
                          decoration: kInputDecoration(
                            labelText: 'Nama',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          enabled: !_isLoading,
                          keyboardType: TextInputType.emailAddress,
                          decoration: kInputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Ubah Password (opsional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _oldPasswordController,
                          enabled: !_isLoading,
                          obscureText: _obscureOldPassword,
                          decoration: kInputDecoration(
                            labelText: 'Password Lama',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _passwordVisibilityToggle(
                              obscure: _obscureOldPassword,
                              onToggle: () => setState(
                                () => _obscureOldPassword = !_obscureOldPassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _newPasswordController,
                          enabled: !_isLoading,
                          obscureText: _obscureNewPassword,
                          decoration: kInputDecoration(
                            labelText: 'Password Baru',
                            prefixIcon: Icons.lock_reset_outlined,
                            suffixIcon: _passwordVisibilityToggle(
                              obscure: _obscureNewPassword,
                              onToggle: () => setState(
                                () => _obscureNewPassword = !_obscureNewPassword,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _confirmUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: kPrimaryColor.withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Konfirmasi', style: kButtonTextStyle),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      side: const BorderSide(color: kPrimaryColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
