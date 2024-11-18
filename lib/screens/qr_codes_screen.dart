import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/qr_code_manager.dart';

class QRCodesScreen extends StatefulWidget {
  const QRCodesScreen({super.key});

  @override
  State<QRCodesScreen> createState() => _QRCodesScreenState();
}

class _QRCodesScreenState extends State<QRCodesScreen> {
  List<String> qrCodePaths = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQRCodes();
  }

  Future<void> _loadQRCodes() async {
    final codes = await QRCodeManager.getAllQRCodes();
    setState(() {
      qrCodePaths = codes;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated QR Codes'),
      ),
      body: qrCodePaths.isEmpty
          ? const Center(
              child: Text('No QR codes generated yet'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: qrCodePaths.length,
              itemBuilder: (context, index) {
                final path = qrCodePaths[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.file(File(path)),
                              ButtonBar(
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                  TextButton(
                                    onPressed: () => QRCodeManager.shareQRCode(path),
                                    child: const Text('Share'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.file(
                            File(path),
                            fit: BoxFit.contain,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            path.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}