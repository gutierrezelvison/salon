import 'dart:io';

import 'package:danfe/danfe.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import 'custom_printer.dart';

class HomeController {
  Danfe? parseXml(String xml) {
    try {
      Danfe? danfe = DanfeParser.readFromString(xml);
      return danfe;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> readFileBytes(String path) async {
    ByteData fileData = await rootBundle.load(path);
    Uint8List fileUnit8List = fileData.buffer
        .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
    return fileUnit8List;
  }

  Future<void> printDefault(
      {Danfe? danfe,
        required PaperSize paper,
        required CapabilityProfile profile}) async {
    DanfePrinter danfePrinter = DanfePrinter(paper);
    List<int> dados =
    await danfePrinter.bufferDanfe(danfe, mostrarMoeda: false);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.114:9100'),
        // Cambia por la dirección de tu impresora
        body: dados,
      );

      if (response.statusCode == 200) {
        print('Impresión enviada exitosamente');
      } else {
        print('Error en la impresión: ${response.statusCode}');
      }
    }catch(e){
      print(e);
    }

  }

  Future<void> printNormal(
      {required List<int> bytes}) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.114:9100'),
        body: bytes,
      );

      if (response.statusCode == 200) {
        print('Impresión enviada exitosamente');
      } else {
        print('Error en la impresión: ${response.statusCode}');
      }
    }catch(e){
      print(e);
    }

  }

  Future<void> printImage(
      {required PaperSize paper, required CapabilityProfile profile}) async {
    final profile = await CapabilityProfile.load();

    final ByteData data = await rootBundle.load('assets/images/logo.png');
    final Uint8List bytes = data.buffer.asUint8List();
    img.Image image = img.decodeImage(bytes)!;
    image = img.grayscale(image);
    image = img.copyResize(image,
        width: 550); // Adjust the width as per your printer's max width
    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.114:9100'),
        // Cambia por la dirección de tu impresora
        body: data,
      );

      if (response.statusCode == 200) {
        print('Impresión enviada exitosamente');
      } else {
        print('Error en la impresión: ${response.statusCode}');
      }
    }catch(e){
      print(e);
    }
  }

  printCustomLayout(
      {Danfe? danfe,
        required PaperSize paper,
        required CapabilityProfile profile}) async {
    final CustomPrinter custom = CustomPrinter(paper);
    List<int> dados = await custom.bufferDanfe(danfe);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.114:9100'),
        // Cambia por la dirección de tu impresora
        body: dados,
      );

      if (response.statusCode == 200) {
        print('Impresión enviada exitosamente');
      } else {
        print('Error en la impresión: ${response.statusCode}');
      }
    }catch(e){
      print(e);
    }
  }
}