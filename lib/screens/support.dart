import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/style.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const String _phoneNumber = '0812345678910';
  static const String _emailAddress = 'pantryon@gmail.com';

  Future<void> _launchUri(BuildContext context, Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showLaunchError(context);
      }
    } catch (_) {
      if (context.mounted) _showLaunchError(context);
    }
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tidak dapat membuka aplikasi terkait.'),
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Support',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Container(
          width: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: kPrimaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Jika ada kendala silahkan hubungi kami.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: kTextBlack,
                ),
              ),
              const SizedBox(height: 28),
              _buildContactRow(
                icon: Icons.phone_outlined,
                label: 'Kontak kami:',
                value: _phoneNumber,
                onTap: () => _launchUri(
                  context,
                  Uri.parse('tel:$_phoneNumber'),
                ),
              ),
              const SizedBox(height: 20),
              _buildContactRow(
                icon: Icons.email_outlined,
                label: 'Email kami:',
                value: _emailAddress,
                isLink: true,
                onTap: () => _launchUri(
                  context,
                  Uri(scheme: 'mailto', path: _emailAddress),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isLink = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: kAccentColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Colors.grey.shade800,
                  ),
                  children: [
                    TextSpan(
                      text: '$label ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        color: isLink ? kPrimaryColor : kTextBlack,
                        fontWeight: isLink ? FontWeight.w600 : FontWeight.normal,
                        decoration: isLink ? TextDecoration.underline : null,
                        decorationColor: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
