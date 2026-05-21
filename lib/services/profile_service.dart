import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileData {
  final String username;
  final String email;

  const ProfileData({required this.username, required this.email});
}

class ProfileUpdateException implements Exception {
  final String message;
  ProfileUpdateException(this.message);

  @override
  String toString() => message;
}

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ProfileData> fetchCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw ProfileUpdateException('Sesi login tidak ditemukan.');
    }

    final data = await _client
        .from('profiles')
        .select('username, email')
        .eq('id', user.id)
        .single();

    return ProfileData(
      username: (data['username'] as String?)?.trim() ?? 'Pantryoners',
      email: user.email ?? (data['email'] as String?)?.trim() ?? '',
    );
  }

  Future<void> updateProfile({
    required String username,
    required String email,
    String? oldPassword,
    String? newPassword,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw ProfileUpdateException('Sesi login tidak ditemukan.');
    }

    final trimmedName = username.trim();
    final trimmedEmail = email.trim();
    final currentEmail = user.email ?? '';
    final changingPassword =
        newPassword != null && newPassword.isNotEmpty;

    if (changingPassword) {
      if (oldPassword == null || oldPassword.isEmpty) {
        throw ProfileUpdateException(
          'Password lama wajib diisi untuk mengubah password.',
        );
      }
      try {
        await _client.auth.signInWithPassword(
          email: currentEmail,
          password: oldPassword,
        );
      } on AuthException catch (e) {
        if (_isInvalidCredentials(e)) {
          throw ProfileUpdateException('Password lama tidak sesuai.');
        }
        rethrow;
      }

      await _client.auth.updateUser(UserAttributes(password: newPassword));
    }

    if (trimmedEmail != currentEmail) {
      await _client.auth.updateUser(UserAttributes(email: trimmedEmail));
    }

    await _client.from('profiles').update({
      'username': trimmedName,
      'email': trimmedEmail,
    }).eq('id', user.id);
  }

  bool _isInvalidCredentials(AuthException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials');
  }

  static String mapError(Object error) {
    if (error is ProfileUpdateException) return error.message;
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials')) {
        return 'Password lama tidak sesuai.';
      }
      if (msg.contains('email') && msg.contains('invalid')) {
        return 'Format email tidak valid.';
      }
      if (msg.contains('password') && msg.contains('weak')) {
        return 'Password baru terlalu lemah. Minimal 6 karakter.';
      }
      if (msg.contains('network') || msg.contains('connection')) {
        return 'Koneksi bermasalah. Periksa internet Anda.';
      }
      return 'Gagal memperbarui akun: ${error.message}';
    }
    if (error is PostgrestException) {
      return 'Gagal menyimpan profil: ${error.message}';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
