import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const GeneratePdf(),
    );
  }
}

class GeneratePdf extends StatefulWidget {
  const GeneratePdf({Key? key}) : super(key: key);

  @override
  State<GeneratePdf> createState() => _GeneratePdfState();
}

class _GeneratePdfState extends State<GeneratePdf> {
  Future<void> generatePdf() async {
    final pdf = pw.Document();
    ByteData picturedata = await rootBundle.load("lib/assets/picture.jpg");
    Uint8List bytes = picturedata.buffer
        .asUint8List(picturedata.offsetInBytes, picturedata.lengthInBytes);
    List<pw.Widget> pictures = List.generate(
        40,
        (index) => pw.Padding(
            child: pw.Image(
              pw.MemoryImage(bytes),
              width: 40,
              height: 20,
            ),
            padding: const pw.EdgeInsets.all(8)));

    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pictures;
        }));

    Uint8List generatedPdf = await pdf.save();
    print("pdf generated");
    await Printing.sharePdf(bytes: generatedPdf);
  }

  bool loading = false;
  @override
  void initState() {
    loading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: loading
          ? const Text("Loading ...")
          : TextButton(
              child: const Text("Generate pdf"),
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                await generatePdf();
                setState(() {
                  loading = false;
                });
              },
            ),
    );
  }
}
