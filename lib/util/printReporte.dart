import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:salon/util/Util.dart';

Future<void> generarPdf(Map<String, dynamic> data) async {
  final pdf = pw.Document();

  final ingresosPorPago = data['ingresos_por_pago'] ?? [];
  final ingresosPorDia = data['ingresos_por_dia'] ?? [];
  final ingresosPorSilla = data['ingresos_por_silla'] ?? [];
  final ventasPorProducto = data['ventas_por_producto'] ?? [];
  final impuestos = data['impuestos'] ?? [];
  final citasPorEstado = data['citas_por_estado'] ?? [];
  final citasPorFuente = data['citas_por_fuente'] ?? [];
  final totalDescuento = data['total_descuento']?['total_descuento'] ?? "0.00";
  final totalFacturas = data['total_facturas']?[0]?['total_facturas'] ?? "0";
  final primeraFactura = data['primera_y_ultima_factura']?[0]?['first_invoice_number'] ?? "-";
  final ultimaFactura = data['primera_y_ultima_factura']?[0]?['last_invoice_number'] ?? "-";

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text("Reporte Ejecutivo", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),

        pw.Text("Totales por método de pago", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Método', 'Total'],
          data: ingresosPorPago.map<List<dynamic>>((e) => [
            (e['payment_gateway']=='cash'?"Efectivo":e['payment_gateway']=='card'?"Tarjeta":e['payment_gateway']=='transfer'?"Transferencia":e['payment_gateway']=='deposit'?"Depósito":e['payment_gateway']=='check'?"Cheque":e['payment_gateway'])?.toString() ?? '',
            numberFormat.format(double.parse(e['total']?.toString() ?? '0.00')),
          ]).toList(),
        ),


        pw.SizedBox(height: 10),
        pw.Text("Ingresos por Día", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Fecha', 'Ingresos'],
          data: ingresosPorDia.map<List<dynamic>>((e) => [e['fecha']??'', numberFormat.format(double.parse(e['ingresos']??'0')),]).toList(),
        ),

        pw.SizedBox(height: 10),
        pw.Text("Ingresos por Silla", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Empleado', 'Silla', 'Servicio', 'Ingresos', 'Comisión'],
          data: ingresosPorSilla.map<List<dynamic>>((e) => [
            e['employee_name']??'',
            e['chair_name']??'',
            e['service_name']??'',
            numberFormat.format(double.parse(e['ingresos']??'0')),
            numberFormat.format(double.parse(e['service_comision_porcentaje']!='0'?e['comision_servicio']??'0':e['comision']??'0')),

          ]).toList(),
        ),

        pw.SizedBox(height: 10),
        pw.Text("Ventas por Producto", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Producto', 'Cantidad', 'Ventas', 'Descuento'],
          data: ventasPorProducto.map<List<dynamic>>((e) => [
            e['product_name']??'',
            e['total_quantity']??'',
            numberFormat.format(double.parse(e['total_sales']??'0')),
            numberFormat.format(double.parse(e['total_discount']??'0')),
          ]).toList(),
        ),

        pw.SizedBox(height: 10),
        pw.Text("Impuestos", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Impuesto', '%', 'Total'],
          data: impuestos.map<List<dynamic>>((e) => [e['tax_name']??'', e['tax_percent']??'', numberFormat.format(double.parse(e['total']??'0'))]).toList(),
        ),

        pw.SizedBox(height: 10),
        pw.Text("Citas por Estado", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Estado', 'Cantidad'],
          data: citasPorEstado.map<List<dynamic>>((e) => [e['status']??'', e['cantidad']??'']).toList(),
        ),

        pw.SizedBox(height: 10),
        pw.Text("Citas por Fuente", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Fuente', 'Cantidad'],
          data: citasPorFuente.map<List<dynamic>>((e) => [e['source']??'', e['cantidad']??'']).toList(),
        ),

        pw.SizedBox(height: 10),
        pw.Text("Resumen Final", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Bullet(text: "Total Descuento: \$${numberFormat.format(double.parse(totalDescuento))}"),
        pw.Bullet(text: "Total ITBIS: \$${numberFormat.format(impuestos.fold(0,(a,b)=>a+double.parse(b['total'])))}"),
        pw.Bullet(text: "Total Ingresos: \$${numberFormat.format(ingresosPorPago.fold(0,(a,b)=>a+double.parse(b['total'])))}"),
        pw.Bullet(text: "Ingresos x producto: \$${numberFormat.format(ventasPorProducto.fold(0,(a,b)=>a+(double.parse(b['total_sales'])-double.parse(b['total_discount']))))}"),
        pw.Bullet(text: "Ingresos x servicio: \$${numberFormat.format(ingresosPorSilla.fold(0,(a,b)=>a+double.parse(b['ingresos'])))}"),
        pw.Bullet(text: "Total comisión: \$${numberFormat.format(ingresosPorSilla.fold(0,(a,b)=>a+double.parse(b["service_comision_porcentaje"]!='0'?b["comision_servicio"].toString():b["comision"].toString())))}"),
        pw.Bullet(text: "Total Facturas: ${numberFormat.format(double.parse(totalFacturas))}"),
        pw.Bullet(text: "Primera Factura: ${primeraFactura}"),
        pw.Bullet(text: "Última Factura: ${ultimaFactura}"),
      ],
    ),
  );

  // Mostrar impresora
  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
