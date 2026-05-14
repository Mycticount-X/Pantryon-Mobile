import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isProcessing = false;

  Future<void> _processBarcode(String barcode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barang tidak ditemukan di database. Silakan isi manual.'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context, {'found': false});
        }
      }
    } catch (e) {
      debugPrint('Error scanning barcode: $e');
      if (mounted) {
        Navigator.pop(context, {'found': false});
      }
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
          
          // UI
          Container(
            width: 250,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFF9800), width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          if (_isProcessing)
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