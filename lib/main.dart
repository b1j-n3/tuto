import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const TutoApp());
}

class TutoApp extends StatelessWidget {
  const TutoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuto - Amazon for Childcare',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFA5F6F8),
      ),
      home: const MainTabScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({Key? key}) : super(key: key);

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const ParentDispatchView(),
    const CaregiverQRView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _views[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1E1B4B),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'Parent Dispatch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Caregiver QR',
          ),
        ],
      ),
    );
  }
}

// --- VIEW 1: PARENT 1-CLICK URGENT DISPATCH ---
class ParentDispatchView extends StatefulWidget {
  const ParentDispatchView({Key? key}) : super(key: key);

  @override
  State<ParentDispatchView> createState() => _ParentDispatchViewState();
}

class _ParentDispatchViewState extends State<ParentDispatchView> {
  bool _isDispatching = false;
  Map<String, dynamic>? _activeDispatch;

  Future<void> _triggerUrgentDispatch() async {
    setState(() => _isDispatching = true);
    
    // Simulate API call to backend matching engine
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isDispatching = false;
      _activeDispatch = {
        'nannyName': 'Sarah M., RN',
        'clearance': 'DoD Intelligence Vetted',
        'rnBadge': 'Texas Board of Nursing #89421',
        'etaMinutes': 12,
        'status': 'En Route - Target Arrival 06:14 AM',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tuto',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
          ),
          const Text('Emergency Backup & Drop-In Care', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(Icons.shield, size: 48, color: Color(0xFF4F46E5)),
                  const SizedBox(height: 10),
                  const Text(
                    'Need Urgent Backup Care?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '1-Click instant match with ER Trauma CPR-certified & DoD screened sitters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isDispatching ? null : _triggerUrgentDispatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isDispatching
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('DISPATCH URGENT CARE NOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          
          if (_activeDispatch != null) ...[
            const SizedBox(height: 20),
            Card(
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_activeDispatch!['nannyName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Chip(label: Text('${_activeDispatch!['etaMinutes']} min ETA'), backgroundColor: Colors.green.shade200),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('🛡️ ${_activeDispatch!['clearance']}', style: const TextStyle(fontSize: 12)),
                    Text('🏥 ${_activeDispatch!['rnBadge']}', style: const TextStyle(fontSize: 12)),
                    const Divider(height: 20),
                    Text(_activeDispatch!['status'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// --- VIEW 2: CAREGIVER DYNAMIC QR SCANNER ---
class CaregiverQRView extends StatefulWidget {
  const CaregiverQRView({Key? key}) : super(key: key);

  @override
  State<CaregiverQRView> createState() => _CaregiverQRViewState();
}

class _CaregiverQRViewState extends State<CaregiverQRView> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Scan Shift Verification QR',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && isScanning) {
                  setState(() => isScanning = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Verified Token: ${barcode.rawValue}')),
                  );
                  break;
                }
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}