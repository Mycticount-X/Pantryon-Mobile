import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/profile_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isProcessing = false;
  bool _isCheckingLimit = true;
  bool _limitReached = false;
  int? _scanRemaining; // null = belum tahu / premium
  int? _scanLimitTotal;
  final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _checkLimitOnOpen();
  }

  Future<void> _checkLimitOnOpen() async {
    try {
      final status = await _profileService.checkScanLimit();
      if (!mounted) return;
      setState(() {
        _limitReached = !status.canScan;
        _scanRemaining = status.remaining; // -1 kalau premium
        _scanLimitTotal = status.limit;    // -1 kalau premium
        _isCheckingLimit = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingLimit = false);
    }
  }

  Future<void> _processBarcode(String barcode) async {
    if (_isProcessing || _limitReached) return;
    setState(() => _isProcessing = true);

    try {
      final allowed = await _profileService.consumeScanIfAllowed();
      if (!allowed) {
        if (mounted) setState(() { _limitReached = true; _scanRemaining = 0; });
        return;
      }
      if (mounted && _scanRemaining != null && _scanRemaining! > 0) {
        setState(() => _scanRemaining = _scanRemaining! - 1);
      }

      final data = await Supabase.instance.client
          .from('pantry_catalog')
          .select()
          .eq('barcode', barcode)
          .maybeSingle();

      if (mounted) {
        if (data != null) {
          Navigator.pop(context, {
            'found': true,
            'product_name': data['normalized_name'] ?? data['product_name'],
            'category': data['category'],
            'unit': data['unit'],
          });
        } else {
          Navigator.pop(context, {'found': false});
        }
      }
    } catch (e) {
      debugPrint('Error scanning barcode: $e');
      if (mounted) {
        Navigator.pop(context, {'found': false});
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Barcode', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Camera
          if (!_limitReached)
            MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _processBarcode(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),

          if (!_limitReached)
            Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFF9800), width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          
          // Limit Count
          if (!_isCheckingLimit && !_limitReached && _scanRemaining != null)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _scanRemaining == -1
                            ? Icons.workspace_premium_rounded
                            : Icons.qr_code_scanner_rounded,
                        color: const Color(0xFFFF9800),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _scanRemaining == -1
                            ? 'Premium · Scan tanpa batas'
                            : 'Sisa scan bulan ini: $_scanRemaining/$_scanLimitTotal',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading Limit...
          if (_isCheckingLimit)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9800)),
              ),
            ),

          // Overlay Limit
          if (!_isCheckingLimit && _limitReached)
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF9800), size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'Batas scan bulan ini sudah habis',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Free tier terbatas $kFreeTierMonthlyScanLimit scan/bulan. Upgrade ke Premium untuk scan tanpa batas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade300),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, {'found': false, 'limitReached': true}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // Loading...
          if (_isProcessing && !_limitReached)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9800)),
              ),
            ),
        ],
      ),
    );
  }
}