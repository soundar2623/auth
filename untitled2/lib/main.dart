import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

void main() => runApp(QRAuthApp());

class QRAuthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Authentication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRAuthScreen(),
    );
  }
}

class QRAuthScreen extends StatefulWidget {
  @override
  _QRAuthScreenState createState() => _QRAuthScreenState();
}

class _QRAuthScreenState extends State<QRAuthScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final TextEditingController ipController = TextEditingController();
  late QRViewController controller;
  String? qrCodeData;
  bool authenticated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Authentication'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: 'Enter PC IP Address',
              ),
            ),
          ),
          qrCodeData != null
              ? Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('QR Code Data: $qrCodeData'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _sendSuccessMessage();
                  },
                  child: Text('Authenticate'),
                ),
              ],
            ),
          )
              : Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                authenticated ? 'Authentication Successful' : 'Authentication Failed',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrCodeData = scanData.code; // Save scanned QR data
      });
    });
  }

  void _sendSuccessMessage() async {
    if (qrCodeData != null && ipController.text.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://${ipController.text}:5000/update_authentication_status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'session_id': qrCodeData, 'authenticated': true}),
      );
      if (response.statusCode == 200) {
        setState(() {
          authenticated = true;
        });
        print('Success message sent successfully');
      } else {
        print('Failed to send success message');
      }
    } else {
      print('QR code data or IP address is empty');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    ipController.dispose();
    super.dispose();
  }
}
