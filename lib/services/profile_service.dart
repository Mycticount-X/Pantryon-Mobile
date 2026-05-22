import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String username;
  final String email;

  const UserProfile({required this.username, required this.email});
}

class ProfileServiceException implements Exception {
  final String message;
  ProfileServiceException(this.message);

  @override
  String toString() => message;
}

/// Returned after a successful profile save.
class ProfileUpdateResult {
  final bool emailConfirmationPending;
  final String? activeLoginEmail;

  const ProfileUpdateResult({
    this.emailConfirmationPending = false,
    this.activeLoginEmail,
  });
}

const String kEmailConfirmationSentMessage =
    'Email konfirmasi telah dikirim ke email lama anda. Silahkan konfirmasi terlebih dahulu sebelum login menggunakan email baru.';

class ProfileService {
  ProfileService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Active login email kept while Supabase email change awaits confirmation.
  static String? _lockedActiveLoginEmail;
  static String? _pendingNewEmail;

  static void clearEmailChangeState() {
    _lockedActiveLoginEmail = null;
    _pendingNewEmail = null;
  }

  String? _userPendingNewEmail(User user) {
    return user.newEmail?.trim();
  }

  void _syncEmailChangeState(User user) {
    if (_pendingNewEmail == null) return;

    final pendingOnServer = _userPendingNewEmail(user);
    final authEmail = user.email?.trim() ?? '';

    final bool confirmed = (pendingOnServer == null || pendingOnServer.isEmpty) &&
        authEmail.isNotEmpty &&
        authEmail == _pendingNewEmail;

    if (confirmed) {
      clearEmailChangeState();
    }
  }

  String _activeLoginEmail(User user) {
    _syncEmailChangeState(user);

    if (_lockedActiveLoginEmail != null && _pendingNewEmail != null) {
      return _lockedActiveLoginEmail!;
    }

    return user.email?.trim() ?? '';
  }

  /// Verifies old password without leaving the session in a bad state on failure.
  Future<void> _verifyOldPassword({
    required String email,
    required String password,
  }) async {
    final savedRefreshToken = _client.auth.currentSession?.refreshToken;
    if (savedRefreshToken == null || savedRefreshToken.isEmpty) {
      throw ProfileServiceException('Sesi tidak valid. Silakan masuk kembali.');
    }

    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException {
      await _restorePreviousSession(savedRefreshToken);
      throw ProfileServiceException('Password lama tidak sesuai.');
    } catch (e) {
      await _restorePreviousSession(savedRefreshToken);
      if (e is ProfileServiceException) rethrow;
      throw ProfileServiceException('Password lama tidak sesuai.');
    }
  }

  Future<void> _restorePreviousSession(String refreshToken) async {
    try {
      await _client.auth.setSession(refreshToken);
    } catch (_) {
      // Best-effort: next Konfirmasi attempt reuses a restored session.
    }
  }

  Future<UserProfile> fetchCurrentProfile() async {
    var user = _client.auth.currentUser;
    if (user == null) {
      throw ProfileServiceException('Sesi tidak valid. Silakan masuk kembali.');
    }

    try {
      try {
        final refreshed = await _client.auth.getUser();
        user = refreshed.user ?? user;
      } catch (_) {
        // Fall back to cached session user.
      }

      final activeUser = user;
      if (activeUser == null) {
        throw ProfileServiceException('Sesi tidak valid. Silakan masuk kembali.');
      }

      final data = await _client
          .from('profiles')
          .select('username')
          .eq('id', activeUser.id)
          .single();

      return UserProfile(
        username: (data['username'] as String?)?.trim() ?? '',
        email: _activeLoginEmail(activeUser),
      );
    } catch (e) {
      throw ProfileServiceException('Gagal memuat profil. Coba lagi.');
    }
  }

  /// Returns null when valid, otherwise an error message.
  String? validateUsername(String value) {
    if (value.trim().isEmpty) {
      return 'Nama tidak boleh kosong.';
    }
    return null;
  }

  /// Returns null when valid, otherwise an error message.
  String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  /// Returns null when valid, otherwise an error message.
  String? validatePasswordChange({
    required String? oldPassword,
    required String? newPassword,
  }) {
    final newPass = newPassword?.trim() ?? '';
    if (newPass.isEmpty) return null;

    final oldPass = oldPassword?.trim() ?? '';
    if (oldPass.isEmpty) {
      return 'Password lama wajib diisi untuk mengganti password.';
    }
    if (newPass.length < 6) {
      return 'Password baru minimal 6 karakter.';
    }
    return null;
  }

  Future<ProfileUpdateResult> updateProfile({
    required String username,
    required String email,
    String? oldPassword,
    String? newPassword,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw ProfileServiceException('Sesi tidak valid. Silakan masuk kembali.');
    }

    final usernameError = validateUsername(username);
    if (usernameError != null) throw ProfileServiceException(usernameError);

    final emailError = validateEmail(email);
    if (emailError != null) throw ProfileServiceException(emailError);

    final passwordError = validatePasswordChange(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    if (passwordError != null) throw ProfileServiceException(passwordError);

    final trimmedUsername = username.trim();
    final trimmedEmail = email.trim();
    final activeLoginEmail = _activeLoginEmail(user);
    final emailChanged = trimmedEmail.isNotEmpty &&
        trimmedEmail.toLowerCase() != activeLoginEmail.toLowerCase();
    final newPass = newPassword?.trim() ?? '';
    final wantsPasswordChange = newPass.isNotEmpty;

    try {
      if (wantsPasswordChange) {
        await _verifyOldPassword(
          email: activeLoginEmail,
          password: oldPassword!.trim(),
        );
        await _client.auth.updateUser(UserAttributes(password: newPass));
      }

      // Keep profiles.email aligned with the active login email until confirmation completes.
      await _client.from('profiles').update({
        'username': trimmedUsername,
        'email': activeLoginEmail,
      }).eq('id', user.id);

      if (emailChanged) {
        _lockedActiveLoginEmail = activeLoginEmail;
        _pendingNewEmail = trimmedEmail;

        try {
          await _client.auth.updateUser(UserAttributes(email: trimmedEmail));
        } catch (e) {
          clearEmailChangeState();
          rethrow;
        }

        return ProfileUpdateResult(
          emailConfirmationPending: true,
          activeLoginEmail: activeLoginEmail,
        );
      }

      return const ProfileUpdateResult();
    } on ProfileServiceException {
      rethrow;
    } on AuthException catch (e) {
      throw ProfileServiceException(_mapAuthMessage(e.message));
    } catch (e) {
      throw ProfileServiceException('Gagal menyimpan profil. Coba lagi.');
    }
  }

  String _mapAuthMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid') && lower.contains('password')) {
      return 'Password lama tidak sesuai.';
    }
    if (lower.contains('email')) {
      return 'Gagal memperbarui email. Pastikan format benar atau email belum digunakan.';
    }
    return message.isNotEmpty ? message : 'Terjadi kesalahan autentikasi.';
  }
}
