import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart'
    as mobile_scanner; // Ajout d'un préfixe

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScanPage(),
    );
  }
}

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isKeyPage = false; // Par défaut, on est dans la page SCAN
  mobile_scanner.MobileScannerController _scannerController =
      mobile_scanner.MobileScannerController();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.65,
                padding: EdgeInsets.all(16.0), // Padding général
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: _isKeyPage ? _buildKeyPage() : _buildScanPage(),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.35,
            color: Colors.grey[200],
            padding: EdgeInsets.all(8.0),
            child: _isKeyPage ? _buildKeypad() : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.close, size: 24.0, color: Colors.grey),
            Text(
              'SCAN',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Opacity(
              opacity: 0.0,
              child: Icon(Icons.close, size: 24.0),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _iconButton(Icons.qr_code_scanner, 'SCAN', isSelected: !_isKeyPage,
                onTap: () {
              setState(() {
                _isKeyPage = false;
              });
            }),
            _iconButton(Icons.apps, 'KEY', isSelected: _isKeyPage, onTap: () {
              setState(() {
                _isKeyPage = true;
              });
            }),
          ],
        ),
        SizedBox(height: 50.0),
        Text(
          'Type the product barcode',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        SizedBox(height: 80.0), // Espacement pour déplacer le code-barres
        BarcodeWidget(
          barcode: Barcode.code128(),
          data: _barcodeController.text.padRight(13, '.'),
          width: 300,
          height: 80,
          drawText: false, // Désactiver le texte intégré
        ),
        SizedBox(
            height: 1.0), // Espacement réduit entre le code-barres et le texte
        Text(
          _barcodeController.text.padRight(13, '.').split('').join(' '),
          style: TextStyle(
            fontSize: 30.0, // Taille de police personnalisée
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScanPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.close, size: 24.0, color: Colors.grey),
            Text(
              'SCAN',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Opacity(
              opacity: 0.0,
              child: Icon(Icons.close, size: 24.0),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _iconButton(Icons.qr_code_scanner, 'SCAN', isSelected: !_isKeyPage,
                onTap: () {
              setState(() {
                _isKeyPage = false;
              });
            }),
            _iconButton(Icons.apps, 'KEY', isSelected: _isKeyPage, onTap: () {
              setState(() {
                _isKeyPage = true;
              });
            }),
          ],
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: mobile_scanner.MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    final List<mobile_scanner.Barcode> barcodes =
                        capture.barcodes;
                    for (final barcode in barcodes) {
                      setState(() {
                        _barcodeController.text = barcode.rawValue ?? '';
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Scanned Barcode: ${_barcodeController.text}',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 1; i <= 9; i += 3)
          Row(
            children: [
              for (int j = i; j < i + 3; j++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _buildKey('$j', _onNumberPressed),
                  ),
                ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: SizedBox(), // Espace vide sous le 7
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildKey('0', _onNumberPressed),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: IconButton(
                  icon:
                      Icon(Icons.backspace, size: 30.0, color: Colors.black54),
                  onPressed: () => _onClearPressed(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, String label,
      {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon,
              size: 30.0, color: isSelected ? Colors.black : Colors.black54),
          SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: isSelected ? Colors.black : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, Function(String) onPressed) {
    return ElevatedButton(
      onPressed: () => onPressed(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(label, style: TextStyle(color: Colors.black)),
    );
  }

  void _onNumberPressed(String number) {
    if (_barcodeController.text.length < 13) {
      setState(() {
        _barcodeController.text += number;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barcode must be 13 digits long')),
      );
    }
  }

  void _onClearPressed() {
    if (_barcodeController.text.isNotEmpty) {
      setState(() {
        _barcodeController.text = _barcodeController.text
            .substring(0, _barcodeController.text.length - 1);
      });
    }
  }

  void _onSubmitPressed(String _) {
    if (_barcodeController.text.length == 13) {
      print('Barcode: ${_barcodeController.text}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barcode must be 13 digits long')),
      );
    }
  }
}
