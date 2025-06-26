import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class PdAgreementScreen extends StatefulWidget {
  const PdAgreementScreen({super.key});

  @override
  State<PdAgreementScreen> createState() => _PdAgreementScreenState();
}

class _PdAgreementScreenState extends State<PdAgreementScreen> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    preparePdf();
  }

  Future<void> preparePdf() async {
    final bytes = await rootBundle.load('assets/Обработка ПНД.pdf');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pd_agreement.pdf');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    setState(() {
      localPath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        backgroundColor: Colors.white,
        title: const Text('Согласие на обработку ПД',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                fontFamily: "Inter")),
      ),
      body: localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(filePath: localPath!),
    );
  }
}
