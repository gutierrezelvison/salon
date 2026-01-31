import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ReportePorEmpleadoWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ingresosPorSilla;

  ReportePorEmpleadoWidget({
    super.key,
    required this.ingresosPorSilla,
  });
  NumberFormat numFormat = NumberFormat("#,###.##","es_MX");

  @override
  Widget build(BuildContext context) {
    final empleadosAgrupados = _agruparPorEmpleado(ingresosPorSilla);

    return Column(
      children: [
        ElevatedButton(
        onPressed: () {
      imprimirReportePorEmpleado(ingresosPorSilla);
    },
    child: Text('Imprimir Informe Ejecutivo'),
    ),
        Expanded(
          child: ListView(
            children: empleadosAgrupados.entries.map((entry) {
              final empleado = entry.key;
              final items = entry.value;

              final totalCantidad = items.fold<int>(0, (sum, item) => sum + (int.parse(item["cantidad"])));
              final totalIngresos = items.fold<double>(0, (sum, item) => sum + (double.parse(item["ingresos"])));
              final totalComision = items.fold<double>(0, (sum, item) => sum + (double.parse(item["comision"])));

              return ExpansionTile(
                title: Text(
                  empleado,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Servicios: $totalCantidad | Ingresos: \$${totalIngresos.toStringAsFixed(2)} | Comisión: \$${totalComision.toStringAsFixed(2)}",
                ),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Servicio")),
                        DataColumn(label: Text("Cantidad")),
                        DataColumn(label: Text("Ingresos")),
                        DataColumn(label: Text("Comisión")),
                        DataColumn(label: Text("Silla")),
                      ],
                      rows: items.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item["service_name"] ?? "")),
                          DataCell(Text(item["cantidad"].toString())),
                          DataCell(Text(item["ingresos"].toString())),
                          DataCell(Text(item["comision"].toString())),
                          DataCell(Text(item["chair_name"].toString())),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Agrupa los datos por nombre del empleado
  Map<String, List<Map<String, dynamic>>> _agruparPorEmpleado(List<Map<String, dynamic>> data) {
    final Map<String, List<Map<String, dynamic>>> resultado = {};

    for (var item in data) {
      final empleado = item["employee_name"] ?? "Desconocido";
      resultado.putIfAbsent(empleado, () => []);
      resultado[empleado]!.add(item);
    }

    return resultado;
  }


  void imprimirReportePorEmpleado(List<Map<String, dynamic>> ingresosPorSilla) {
    final doc = pw.Document();
    final empleadosAgrupados = _agruparPorEmpleado(ingresosPorSilla);

    doc.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Informe Ejecutivo de Servicios', style: pw.TextStyle(fontSize: 20)),
            ),
            pw.Text("Fecha de generación: ${DateTime.now().toString().split(' ').first}\n\n"),
            ...empleadosAgrupados.entries.map((entry) {
              final empleado = entry.key;
              final items = entry.value;

              final totalCantidad = items.fold<int>(0, (sum, item) => sum + (int.parse(item["cantidad"]) ?? 0));
              final totalIngresos = items.fold<double>(0, (sum, item) => sum + (double.parse(item["ingresos"])?.toDouble() ?? 0));
              final totalComision = items.fold<double>(0, (sum, item) => sum + (double.parse(item["comision"])?.toDouble() ?? 0));

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Empleado: $empleado", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Total servicios: $totalCantidad"),
                  pw.Text("Total ingresos: \$${totalIngresos.toStringAsFixed(2)}"),
                  pw.Text("Total comisión: \$${totalComision.toStringAsFixed(2)}"),
                  pw.SizedBox(height: 10),
                  pw.Table.fromTextArray(
                    headers: ["Servicio", "Cantidad", "Ingresos", "Comisión", "Silla"],
                    data: items.map((item) {
                      return [
                        item["service_name"] ?? "",
                        item["cantidad"].toString(),
                        item["ingresos"].toString(),
                        item["comision"].toString(),
                        item["chair_name"].toString(),
                      ];
                    }).toList(),
                  ),
                  pw.Divider(),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    // Mostrar vista previa o imprimir directamente
    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }


}
