import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';

import 'Util.dart';

Future<void> exportarReporteExcelWeb(BuildContext context,String jsonResponse) async {
  final excel = ex.Excel.createExcel();
  final data = json.decode(jsonResponse);

  void crearHoja(String nombre, List<String> headers, List<List<dynamic>> rows) {
    final sheet = excel[nombre];
    // Agrega los encabezadosject.appendRow(row);
    List<ex.CellValue> header = [];
    List<ex.CellValue> values = [];

    try {
      for (var cell in headers.toList()) {
        header.add(ex.TextCellValue(cell));
      }
      sheet.appendRow(header);

      // Agrega los datos
      for (var row in rows) {
        for (var cell in row.toList()) {
          values.add(ex.TextCellValue(cell ?? ''));
        }

        sheet.appendRow(values);
        values.clear();
      }
    }catch(e){
      CustomSnackBar().show(context: context, msg: 'Error al preparar los datos a exportar.', icon: Icons.error_outline_rounded, color: Colors.red);

    }

    /*
    // Convertir headers a CellValue
    sheet.appendRow(headers.map((h) => ex.TextCellValue(h)).toList());

    // Convertir cada fila a List<CellValue?>
    for (final row in rows) {
      sheet.appendRow(row.map((c) {
        if (c == null) return null;
        if (c is num) return ex.DoubleCellValue(c.toDouble());
        return ex.TextCellValue(c.toString());
      }).toList());
    }
     */
  }

  void agregarResumenPorEmpleado(excel, List<dynamic> ingresosPorSilla) {
    final Map<String, Map<String, dynamic>> resumen = {};

    for (final item in ingresosPorSilla) {
      final nombre = item['employee_name'] ?? 'Sin nombre';
      final silla = item['chair_name'] ?? 'Sin silla';
      final cantidad = int.tryParse(item['cantidad'].toString()) ?? 0;
      final ingresos = double.tryParse(item['ingresos'].toString()) ?? 0.0;
      final comision = double.tryParse(item['comision'].toString()) ?? 0.0;

      if (!resumen.containsKey(nombre)) {
        resumen[nombre] = {
          'empleado': nombre,
          'chair_name': silla,
          'cantidad': cantidad,
          'ingresos': 0.0,
          'comision': 0.0,
        };
      }

      resumen[nombre]!['cantidad'] += cantidad;
      resumen[nombre]!['ingresos'] += ingresos;
      resumen[nombre]!['comision'] += comision;
    }

    final hoja = excel['ResumenEmpleado'];
    hoja.appendRow([ex.TextCellValue('Empleado'),ex.TextCellValue('Silla'),ex.TextCellValue('Servicios'), ex.TextCellValue('Ingresos'),ex.TextCellValue('Comision')],);

    for (final empleado in resumen.values) {
      hoja.appendRow([
        ex.TextCellValue(empleado['empleado']),
        ex.TextCellValue(empleado['chair_name']),
        ex.IntCellValue(empleado['cantidad']),
        ex.DoubleCellValue(double.parse(empleado['ingresos'].toStringAsFixed(2))),
        ex.DoubleCellValue(double.parse(empleado['comision'].toStringAsFixed(2))),
      ]);
    }
  }

  agregarResumenPorEmpleado(excel, data['ingresos_por_silla']);

  crearHoja(
    'IngresosPorDia',
    ['Fecha', 'Ingresos'],
    (data['ingresos_por_dia'] as List).map((e) => [e['fecha'], e['ingresos']]).toList(),
  );

  crearHoja(
    'IngresosPorPago',
    ['Método de Pago', 'Total'],
    (data['ingresos_por_pago'] as List).map((e) => [e['payment_gateway']=='cash'?"Efectivo":e['payment_gateway']=='card'?"Tarjeta":e['payment_gateway']=='transfer'?"Transferencia":e['payment_gateway']=='deposit'?"Depósito":e['payment_gateway']=='check'?"Cheque":e['payment_gateway'], e['total']]).toList(),
  );

  crearHoja(
    'IngresosPorSilla',
    ['Factura', 'Servicio', 'Empleado', 'Silla', 'Cantidad', 'Ingreso', 'Comisión', 'Comisión Servicio', 'Porcentaje Comisión'],
    (data['ingresos_por_silla'] as List).map((e) => [
      e['invoice_number'],
      e['service_name'],
      e['employee_name'],
      e['chair_name'],
      e['cantidad'],
      e['ingresos'],
      e['comision'],
      e['comision_servicio'],
      e['comision_porcentaje']
    ]).toList(),
  );

  crearHoja(
    'VentasPorProducto',
    ['Producto', 'Total Ventas', 'Total Descuento', 'Cantidad'],
    (data['ventas_por_producto'] as List).map((e) => [
      e['product_name'],
      e['total_sales'],
      e['total_discount'],
      e['total_quantity']
    ]).toList(),
  );

  crearHoja(
    'CitasPorEstado',
    ['Estado', 'Cantidad'],
    (data['citas_por_estado'] as List).map((e) => [e['status'], e['cantidad']]).toList(),
  );

  crearHoja(
    'CitasPorFuente',
    ['Fuente', 'Cantidad'],
    (data['citas_por_fuente'] as List).map((e) => [e['source'], e['cantidad']]).toList(),
  );

  crearHoja(
    'Impuestos',
    ['Nombre Impuesto', 'Porcentaje', 'Total'],
    (data['impuestos'] as List).map((e) => [e['tax_name'], e['tax_percent'], e['total']]).toList(),
  );

  crearHoja(
    'Totales',
    ['Total Descuento'],
    [[data['total_descuento']['total_descuento']]],
  );

  crearHoja(
    'Facturas',
    ['Total Facturas'],
    [[data['total_facturas'][0]['total_facturas']]],
  );

  crearHoja(
    'RangoFacturas',
    ['Primera Factura', 'Última Factura'],
    [[
      data['primera_y_ultima_factura'][0]['first_invoice_number'],
      data['primera_y_ultima_factura'][0]['last_invoice_number']
    ]],
  );

  // Convertir el archivo Excel a bytes
  var list = excel.encode();

  if (list != null) {
    Uint8List bytes = Uint8List.fromList(list);

    // Guardar el archivo Excel en la ubicación seleccionada por el usuario
    await saveFile(context,bytes, 'output.xlsx');

  } else {
    CustomSnackBar().show(context: context, msg: 'Error al codificar el archivo Excel.', icon: Icons.error_outline_rounded, color: Colors.red);
  }

}
