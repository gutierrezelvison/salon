import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrinterConfigWidget extends StatefulWidget {
  const PrinterConfigWidget({Key? key}) : super(key: key);

  @override
  State<PrinterConfigWidget> createState() => _PrinterConfigWidgetState();
}

class _PrinterConfigWidgetState extends State<PrinterConfigWidget> {
  final serverUrl = "http://localhost:5000"; // cambia si usas IP externa
  static bool serverOnline = true;
  List<String> printers = [];
  String? defaultPrinter;
  String? selectedPrinter;

  @override
  void initState() {
    super.initState();
    checkServerAndLoadData();
  }

  Future<void> checkServerAndLoadData() async {
    try {
      final statusResponse = await http.get(Uri.parse('$serverUrl/config'));
      if (statusResponse.statusCode == 200) {
        print(statusResponse.body);
        var config = jsonDecode(statusResponse.body);
        setState(() {
          //if(response["status"]=="Servidor activo")
          serverOnline = true;
          defaultPrinter = config['default_printer'];
          selectedPrinter = defaultPrinter;
        });

        final printersResponse = await http.get(Uri.parse('$serverUrl/printers'));
        if (printersResponse.statusCode == 200) {
          print(printersResponse.body);
          final data = jsonDecode(printersResponse.body);
          setState(() {
            printers = List<String>.from(data);
          });
        }
      } else {
        setState(() => serverOnline = false);
      }
    } catch (e) {
      print(e);
      setState(() => serverOnline = false);
    }
  }

  Future<void> setDefaultPrinter(String printerName) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/config'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"default_printer": printerName}),
      );

      if (response.statusCode == 200) {
        setState(() {
          defaultPrinter = printerName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impresora establecida: $printerName")),
        );
      } else {
        throw Exception("Error al establecer la impresora");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void openServerActivator() {
    // Esto depende de cómo lo tengas implementado.
    // Puede abrir una URL donde tengas un script que inicie el servidor.
    const activationUrl = "http://localhost:5000/activate"; // solo ejemplo
    // En web, puedes abrir esto con `launchUrl`
  }

  @override
  Widget build(BuildContext context) {
    if (!serverOnline) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Servidor de impresión no disponible.",
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: openServerActivator,
              child: const Text("Activar servidor"),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: checkServerAndLoadData,
              child: const Text("Reintentar"),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Selecciona impresora por defecto:"),
        const SizedBox(height: 8),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedPrinter,
          items: printers.map((p) {
            return DropdownMenuItem<String>(
              value: p,
              child: Text(p),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedPrinter = value;
            });
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: selectedPrinter != null
              ? () => setDefaultPrinter(selectedPrinter!)
              : null,
          child: const Text("Guardar como predeterminada"),
        ),
        const SizedBox(height: 20),
        if (defaultPrinter != null)
          Text("Actual: $defaultPrinter", style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
