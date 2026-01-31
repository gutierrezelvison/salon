import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;


import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img; // Usaremos la librería image para manipular la imagen
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:flutter/services.dart';

import '../../util/SizingInfo.dart';
import '../../util/Util.dart';

class PrinterWidget {
  PrinterWidget(
      {Key? key, required this.fact, this.pageFormat, this.quoteAction, this.printAction, this.onPageChanged});

  List<pw.Widget> fact;
  PdfPageFormat? pageFormat;
  List<Widget>? printAction;
  Widget? quoteAction;
  Function(PdfPageFormat)? onPageChanged;

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista de impresión')),
      body: SizedBox(
        child: PdfPreview(useActions: true,
          build: (format) => _generatePdf(pageFormat??format, 'Vista de impresión'),
          maxPageWidth: isMobile(context)? displayWidth(context)*0.8: pageFormat==PdfPageFormat.a4? displayWidth(context)*0.4:displayWidth(context)*0.25,
          allowPrinting: printAction==null,
          canDebug: false,
          shouldRepaint: true,
          pageFormats: {"A4":PdfPageFormat.a4,"80mm":PdfPageFormat.roll80},
          onPageFormatChanged: onPageChanged,
          actions: [printAction??const SizedBox(),quoteAction??const SizedBox()],
        ),
      ),
    );
  }

 */

  Widget pdfPreview(BuildContext context,List<Widget> onPrinted){
    return Scaffold(
      appBar: AppBar(title: const Text('Vista de impresión')),
      body: SizedBox(
        child: PdfPreview(useActions: true,
          build: (format) => generatePdf(pageFormat??format, 'Vista de impresión'),
          maxPageWidth: isMobile(context)? displayWidth(context)*0.8: pageFormat==PdfPageFormat.a4? displayWidth(context)*0.4:displayWidth(context)*0.25,
          allowPrinting: false,
          canDebug: false,
          shouldRepaint: true,
          pageFormats: {"A4":PdfPageFormat.a4,"80mm":PdfPageFormat.roll80},
          onPageFormatChanged: onPageChanged,
          actions: onPrinted
        ),
      ),
    );
  }

  Future<List<int>> generatePdfBytes(pw.Widget content) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
      build: (_) => content,
    ));

    return await pdf.save(); // Esto retorna un List<int>
  }

  Future<Uint8List> generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    //final font = await PdfGoogleFonts.nunitoExtraLight();
    final maxPageHeight = format.availableHeight;

    for(var item in fact) {
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(20),
          pageFormat: format,
          build: (context) {
            return item;
          },
        ),
      );
    }
    return pdf.save();
  }

  Future<void> printPDF() async {

    await Printing.layoutPdf(
      format: PdfPageFormat.roll80,
      onLayout: (_) => generatePdf(PdfPageFormat.roll80, 'Factura'),
    );

  }

  Future<void> printPagesIndividually(BuildContext ctx) async {
    // Seleccionar la impresora una sola vez
    final printer = await Printing.pickPrinter(context: ctx);
    if (printer == null) return;

    for (final page in fact) {
      final doc = pw.Document();
      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
        build: (_) => page,
      ));

      // Imprimir directamente en la impresora seleccionada
      await Printing.directPrintPdf(
          printer: printer,
          onLayout: (_) => doc.save(),
          );
    }
  }

  Future generatePdfPerPage(PdfPageFormat format, String title) async {
   // final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true,);
    //final font = await PdfGoogleFonts.nunitoExtraLight();
    final maxPageHeight = format.availableHeight;

    for(var item in fact) {
      final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true,);
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(20),
          pageFormat: PdfPageFormat(80*PdfPageFormat.mm, double.infinity),
          build: (_)=>item
        ),
      );
      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
      );
    }
  }

  Future<void> printPDFPerPage(Uint8List doc) async {

    await Printing.layoutPdf(
      onLayout: (_) => doc,
    );

  }

  Future<void> sendPrintJob(List<int> pdfBytes) async {
    final response = await http.post(
      Uri.parse('http://10.0.0.114:9100'),
      body: pdfBytes,
    );

    if (response.statusCode == 200) {
      print('Impresión enviada correctamente');
    } else {
      print('Error al imprimir: ${response.statusCode}');
    }
  }

  Future<String> obtenerIP() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP(); // Ej: 192.168.0.101

    print("La IP local es: $ip");

    return ip!;
  }

  Future<void> sendImageToLocalPrinter(Uint8List imageBytes) async {
    var ip = await detectarServidor();
    final url = Uri.parse('http://$ip:5000/print-image');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/pdf",
      },
      body: imageBytes,
    );

    if (response.statusCode == 200) {
      print("Impresión enviada correctamente");
    } else {
      print("Error: ${response.body}");
    }
  }

  Future<String?> detectarServidor() async {
    final posiblesIPs = [
      'localhost',
      '127.0.0.1',
      '192.168.0.100', // IP del servidor (modifica según tu red)
      '192.168.1.100',
    ];

    for (final ip in posiblesIPs) {
      try {
        final url = Uri.parse('http://$ip:5000/status');
        final response = await http.get(url).timeout(Duration(seconds: 2));
        if (response.statusCode == 200) {
          print("Servidor encontrado en: $ip");
          return ip;
        }
      } catch (_) {}
    }

    return null;
  }

  Future<Uint8List> generateReceiptImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(300, 600)));

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Dibuja un fondo blanco
    canvas.drawRect(Rect.fromLTWH(0, 0, 300, 600), paint);

    // Dibuja el texto de la factura
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Factura\n\n',
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: 300);
    textPainter.paint(canvas, Offset(10, 10));

    // Agrega una imagen (por ejemplo, un logo)
    final ByteData data = await rootBundle.load('assets/images/logo.png');
    final list = data.buffer.asUint8List();
    final image = img.decodeImage(list);
    if (image != null) {
      final uiImage = await convertToUiImage(image);
      canvas.drawImage(uiImage, Offset(10, 50),Paint()); // Dibuja la imagen en el canvas
    }

    final picture = recorder.endRecording();
    final imgData = await picture.toImage(300, 600); // 300px de ancho y 600px de alto

    final byteData = await imgData.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

// Convierte imagen de la librería 'image' a una imagen de tipo UI (usable en el Canvas)
  Future<ui.Image> convertToUiImage(img.Image image) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(Uint8List.fromList(img.encodePng(image)), (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  List<int> convertToEscPosRaster(Uint8List imageBytes, int width) {
    final img.Image image = img.decodeImage(imageBytes)!;
    final List<int> escPosCommands = [];

    // Comando de inicio de imagen en formato raster
    escPosCommands.addAll([0x1D, 0x76, 0x30, 0x00]);

    // Ancho en bytes (ancho de la imagen / 8)
    int bytesPerRow = (width / 8).ceil();

    escPosCommands.add(bytesPerRow % 256); // LSB
    escPosCommands.add(bytesPerRow ~/ 256); // MSB

    escPosCommands.add(image.height % 256); // LSB
    escPosCommands.add(image.height ~/ 256); // MSB

    for (int y = 0; y < image.height; y++) {
      List<int> row = [];
      for (int x = 0; x < image.width; x += 8) {
        int byte = 0;
        for (int i = 0; i < 8; i++) {
          if (x + i < image.width && image.getPixel(x + i, y) == image.getColor(0, 0, 0, 255)) {
            byte |= (1 << (7 - i));  // Si el pixel es negro, activa el bit correspondiente
          }
        }
        row.add(byte);
      }
      escPosCommands.addAll(row);
    }

    return escPosCommands;
  }

  //Metodo para enviar factura a imprimir
  Future<void> sendJobToPrinter(List<int> bytes) async {
    final url = Uri.parse('http://localhost:5000/print-raw');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/octet-stream",
      },
      body: bytes,
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Comandos ESC/POS enviados correctamente");
      }
    } else {
      if (kDebugMode) {
        print("Error: ${response.body}");
      }
    }
  }

  //Metodo para establecer impresora por defecto
  Future<void> sendDefaultPrinter(String printerName) async {
    final url = Uri.parse('http://localhost:5000/config');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "default_printer": printerName,
      }),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Impresora enviada correctamente");
      }
    } else {
      if (kDebugMode) {
        print("Error: ${response.body}");
      }
    }
  }

  //Metodo para obtener el listado de impresoras
  Future<dynamic> getPrinterList() async {
    final url = Uri.parse('http://localhost:5000/printers');

    final response = await http.get(
      url,
    );


    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Se muestra la lista de impresoras correctamente");
      }
      return response.body;
    } else {
      if (kDebugMode) {
        print("Error: ${response.body}");
      }
    }
  }
}