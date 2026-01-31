import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeReportPage extends StatefulWidget {
  @override
  _EmployeeReportPageState createState() => _EmployeeReportPageState();
}

class _EmployeeReportPageState extends State<EmployeeReportPage> {
  DateTimeRange? dateRange;
  String search = '';
  int currentPage = 1;
  int rowsPerPage = 10;

  // Simulando datos (esto debería venir de una API)
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    // Aquí deberías llamar a tu API con filtros como dateRange, search, etc.
    setState(() {
      data = List.generate(20, (index) => {
        'empleado': 'Empleado ${index + 1}',
        'silla': 'Silla ${(index % 4) + 1}',
        'servicios': (index + 3),
        'monto': (index + 3) * 120.0,
        'comision': ((index + 3) * 120.0 * 0.10),
        'detalles': List.generate(3, (d) => {
          'fecha': DateTime.now().subtract(Duration(days: d)),
          'servicio': 'Servicio ${d + 1}',
          'cliente': 'Cliente ${d + 1}',
          'cantidad': 1,
          'precio': 100.0 + d * 20,
          'total': 100.0 + d * 20,
          'comision': (100.0 + d * 20) * 0.10,
        })
      });
    });
  }

  void _showDatePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => dateRange = picked);
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = data.where((row) {
      final query = search.toLowerCase();
      return row.values.any((value) => value.toString().toLowerCase().contains(query));
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Reporte de Servicios por Empleado/Silla')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _showDatePicker,
                  child: Text(dateRange == null
                      ? 'Seleccionar rango de fechas'
                      : '${DateFormat.yMd().format(dateRange!.start)} - ${DateFormat.yMd().format(dateRange!.end)}'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Buscar...'),
                    onChanged: (value) {
                      setState(() => search = value);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final row = filtered[index];
                  return ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(flex: 2, child: Text(row['empleado'])),
                        Expanded(child: Text(row['silla'])),
                        Expanded(child: Text('${row['servicios']}')),
                        Expanded(child: Text('\$${row['monto'].toStringAsFixed(2)}')),
                        Expanded(child: Text('\$${row['comision'].toStringAsFixed(2)}')),
                      ],
                    ),
                    children: List.generate(row['detalles'].length, (i) {
                      final d = row['detalles'][i];
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(flex: 2, child: Text(DateFormat.yMd().format(d['fecha']))),
                            Expanded(child: Text(d['servicio'])),
                            Expanded(child: Text(d['cliente'])),
                            Expanded(child: Text('${d['cantidad']}')),
                            Expanded(child: Text('\$${d['precio'].toStringAsFixed(2)}')),
                            Expanded(child: Text('\$${d['total'].toStringAsFixed(2)}')),
                            Expanded(child: Text('\$${d['comision'].toStringAsFixed(2)}')),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
