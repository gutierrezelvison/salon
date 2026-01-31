
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:salon/Widgets/Components/reports_widget.dart';
import 'package:salon/util/db_connection.dart';
import 'package:salon/values/ResponsiveApp.dart';

import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../util/printReporte.dart';
import '../../util/report_export_to_excel.dart';
import 'donutChart.dart';
import 'line_chart.dart';

class ReporteEstetico extends StatefulWidget {
  const ReporteEstetico({super.key});

  @override
  State<ReporteEstetico> createState() => _ReporteEsteticoState();
}

class _ReporteEsteticoState extends State<ReporteEstetico> {
  late Future<Map<String, dynamic>> reporte;

  NumberFormat numFormat= NumberFormat("#,###.##","es_MX");
  var dateFormatOnlyDate = DateFormat('dd/MM/yyyy');
  List<double> earningsList = [];
  List<DateTime> earningsDaysList = [];
  int earningsTrending = 0;
  double totalEarningsHistory = 0;
  late ResponsiveApp responsiveApp;
  String desde = '${DateTime.now().toString().substring(0,10)}';
  String hasta = '${DateTime.now()}';
  int pageIndex = 0;
  dynamic selectedData;
  dynamic jsonData;

  @override
  void initState() {
    earningsDaysList = generarDias(DateTime.now().subtract(Duration(days: DateTime.now().day-1)), DateTime.now());
    super.initState();

  }

  Future<Map<String, dynamic>> obtenerReporte() async {
    final url = Uri.parse('${BDConnection().getHost()}/getReports.php?desde=$desde&hasta=$hasta');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      jsonData= response.body;

      return compute(_parseData, response.body);
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  Map<String, dynamic> _parseData(String body) {
    return jsonDecode(body);
  }
    /*
    if (response.statusCode == 200) {
      return jsonDecode(response.body);

    } else {
      throw Exception('Error al cargar los reportes');
    }

     */

  List<DateTime>
  generarDias(DateTime desde, DateTime hasta) {
    List<DateTime> dias = [];
    for (int i = 0; i <= hasta.difference(desde).inDays; i++) {
      dias.add(DateTime(desde.year, desde.month, desde.day + i));
    }
    return dias;
  }

  Widget _tarjetaResumen(String titulo, String valor, IconData icono, Color color,{double? fSize}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize:  MainAxisSize.min,
          children: [
            CircleAvatar(backgroundColor: color, child: Icon(icono, color: Colors.white)),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
              Text(valor, style: GoogleFonts.poppins(fontSize: fSize??20, fontWeight: FontWeight.bold)),
            ])
          ],
        ),
      ),
    );
  }
  Widget _tarjetaResumenInvoice(String titulo, String valor, IconData icono, Color color,{double? fSize}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize:  MainAxisSize.min,
          children: [
            CircleAvatar(backgroundColor: color, child: Icon(icono, color: Colors.white)),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
              Text(valor.split(' - ')[0], style: GoogleFonts.poppins(fontSize: fSize??20, fontWeight: FontWeight.normal)),
              Text(valor.split(' - ')[1], style: GoogleFonts.poppins(fontSize: fSize??20, fontWeight: FontWeight.normal)),
            ])
          ],
        ),
      ),
    );
  }
  Widget _tarjetaSilla(String titulo, String valor, Color color, String cantidad) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize:  MainAxisSize.min,
          children: [
            CircleAvatar(backgroundColor: color.withValues(alpha: 0.20), child: SizedBox(width: 30,
                child: userImage(height: 30,
                    image: ColorFiltered(colorFilter: ColorFilter.mode(color, BlendMode.modulate),
                      child: Image.asset('assets/images/silla.png'),))
            ),),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
              Row(
                mainAxisSize: MainAxisSize.max,
                spacing: 25,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("\$$valor", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("#$cantidad", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ])
          ],
        ),
      ),
    );
  }
  Widget _tarjetaDia(String titulo, String valor,MainAxisSize? mainAxisSize) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: mainAxisSize??  MainAxisSize.min,
          children: [
            Text(titulo=='cash'?"Efectivo":titulo=='card'?"Tarjeta":titulo=='transfer'?"Transferencia":titulo=='deposit'?"Depósito":titulo=='check'?"Cheque":titulo, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(width: 16),
            Text(numFormat.format(double.parse(valor.toString())), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
  Widget _tarjetaProducto(String titulo, String valor,String quantity,String discount,MainAxisSize? mainAxisSize) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: mainAxisSize??  MainAxisSize.min,
            children: [
              Text(titulo, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(width: 16),
              Text(numberFormat.format((double.parse(valor)-double.parse(discount))), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold))
            ],
          ),
        ),
      );
    }

  Widget _graficoPie(List<dynamic> data) {
    return PieChartSample2(
      values: data.map((e)=>double.parse(e['total'])).toList(),
      labels: data.map((e)=>e['payment_gateway'].toString()).toList(),
      width: isMobileAndTablet(context)? displayWidth(context) * 0.85 : 200,
      height: 200,
    );
  }

  Widget _listaIngresosPorDia(List<dynamic> data) {
    return Column(
      children: data.map((e) {
        return _tarjetaDia(e['fecha'],e['ingresos'],null);
      }).toList(),
    );
  }
  Widget _listaIngresosPorProducto(List<dynamic> data) {
    return Column(
      children: data.map((e) {

        return _tarjetaProducto(e['product_name'],e['total_sales'],e['total_quantity'],e['total_discount'],null);
      }).toList(),
    );
  }
  Widget _listaIngresosPorSilla(List<dynamic> data) {
    var summarizedData = summarizeData(data);

    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: summarizedData.entries.map((entry) {
          var e = entry.value;
          return ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize:  MainAxisSize.min,
                children: [
                  CircleAvatar(backgroundColor: Color(int.parse(e['color'])).withValues(alpha: 0.20), child: SizedBox(width: 30,
                      child: userImage(height: 30,
                          image: ColorFiltered(colorFilter: ColorFilter.mode(Color(int.parse(e['color'])), BlendMode.modulate),
                            child: Image.asset('assets/images/silla.png'),))
                  ),),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e['chair_name'], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      spacing: 25,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("\$${numFormat.format(double.parse(e['total_ingresos'].toString()))}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text("#${e['total_cantidad']}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text("Comisión: \$${numberFormat.format(double.parse(e['total_commission'].toString()))}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ])
                ],
              ),
            ),
            children: e['services'].map<Widget>((service) {
              return Card(
                child: Padding(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${service['booking_items_id'].toString()} - ${service['service_name'].toString()}".dotTail,style: Theme.of(context).textTheme.titleMedium,overflow: TextOverflow.ellipsis,),
                              Text("Factura: ${service['invoice_number']} - Cantidad: ${service['cantidad']} - Ingresos: ${numberFormat.format(double.parse(service['ingresos']))} - Comisión(${service['service_comision_porcentaje']!='0'?service['service_comision_porcentaje']:service['comision_porcentaje']}%): ${numberFormat.format(double.parse(service['service_comision_porcentaje']!='0'?service['comision_servicio']:service['comision']))}",style: Theme.of(context).textTheme.labelMedium,),
                            ]
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
  Map<String, Map<String, dynamic>> summarizeData(List<dynamic> data) {
    Map<String, Map<String, dynamic>> summary = {};

    for (var item in data) {
      String employeeId = item["employee_id"].toString();

      if (!summary.containsKey(employeeId)) {
        summary[employeeId] = {
          "employee_name": item["employee_name"],
          "chair_name": item["chair_name"],
          "booking_items_id": item["booking_items_id"],
          "color": item["color"],
          "total_ingresos": 0,
          "total_commission": 0,
          "total_cantidad": 0,
          "comision_porcentaje": item["comision_porcentaje"],
          "service_comision_porcentaje": item["service_comision_porcentaje"],
          "services": [], // Guardar la lista de detalles
        };
      }

      summary[employeeId]!["total_ingresos"] += int.parse(item["ingresos"].toString());
      summary[employeeId]!["total_cantidad"] += int.parse(item["cantidad"].toString());
      summary[employeeId]!["total_commission"] += double.parse(item["service_comision_porcentaje"]!='0'?item["comision_servicio"].toString():item["comision"].toString());
      summary[employeeId]!["services"].add(item); // Agregar el servicio a la lista de detalles
    }

    return summary;
  }

  Widget infoData(
      String label, Widget body, CrossAxisAlignment? crossAxisAlignment) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:Theme.of(context).textTheme.labelSmall,
        ),
        body,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard de Reportes'),
        leading: isMobileAndTablet(context)
            ?IconButton(onPressed: ()=> pageIndex==1?setState((){pageIndex=0;}): mainScaffoldKey.currentState!.openDrawer(), icon: Icon(pageIndex==1?Icons.arrow_back_rounded:Icons.menu_rounded))
            :!isMobileAndTablet(context) && pageIndex > 0?IconButton(
            onPressed: () => setState(() {
              pageIndex = 0;
            }),
            icon: const Icon(
              Icons.arrow_back_rounded,
            )):null,
        actions: [
          infoData(
              'Imprimir reporte',
              InkWell(
                  onTap: ()async{
                    loadingDialog(context);
                    await generarPdf(jsonDecode(jsonData));

                    Navigator.pop(context);
                  },
                  child: Icon(Icons.local_print_shop_rounded,
                    size: 30,
                  )
              ),
              CrossAxisAlignment.center),
          SizedBox(width: responsiveApp.setWidth(10),),
          infoData(
              'Exportar a excell',
              InkWell(
                  onTap: ()async{
                    loadingDialog(context);
                    await exportarReporteExcelWeb(context,await jsonData);

                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset('assets/svg/excel_icon.svg',
                    width: 30,
                  )
              ),
              CrossAxisAlignment.center),
          SizedBox(width: responsiveApp.setWidth(10),),
          InkWell(
            onTap: ()async{
              final DateTimeRange? picked = await showDialog(
                    useSafeArea: true,
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                          insetAnimationDuration: Duration(milliseconds: 400),
                          insetAnimationCurve: Curves.elasticInOut,
                          child: Container(margin: EdgeInsets.all(8),
                              constraints: BoxConstraints(maxWidth: displayWidth(context)*0.3,maxHeight: displayHeight(context)*0.6),
                              child: DateRangePickerDialog(
                                  currentDate: DateTime.now(),
                                  initialDateRange: DateTimeRange(start: DateTime.parse(desde), end: DateTime.parse(hasta)),
                                  firstDate: DateTime(2024,01,01), lastDate: DateTime.now().add(Duration(days: 365),)))
                      );
                    }
                );
                if (picked != null) {
                  desde = picked.start.toString().substring(0,10);
                  hasta = picked.end.toString().substring(0,10);
                  earningsDaysList = generarDias(picked.start, picked.end);
                    reporte = obtenerReporte();
                    setState(() {

                    });
                }

            },
            child: Container(
              margin: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color:Colors.grey.withOpacity(0.2))
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded,color: Theme.of(context).primaryColor,),
                  Container(
                    margin: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                    color: Colors.grey.withOpacity(0.20),
                    width: 1,
                    height: responsiveApp.setHeight(25),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Período",style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.grey),),
                      Text("${DateTime.parse(hasta.substring(0,10)).isAtSameMomentAs(DateTime.parse(desde.toString()))? dateFormatOnlyDate.format(DateTime.parse(desde.toString())).toString():"${dateFormatOnlyDate.format(DateTime.parse(desde.toString())).toString()} - ${dateFormatOnlyDate.format(DateTime.parse(hasta.toString())).toString()}"}".substring(0,10),style: Theme.of(context).textTheme.titleSmall,),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      body: pageIndex==1? ReportePorEmpleadoWidget(ingresosPorSilla: List.from(selectedData),): FutureBuilder<Map<String, dynamic>>(
        future: obtenerReporte(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final data = snapshot.data!;
          final totalDescuento = data['total_descuento']['total_descuento'] ?? '0';
          final totalImpuestos = data['impuestos'][0]['total'] ?? '0';
          final totalIngresos = data['ingresos_por_pago'].fold(0,(a,b)=>a+double.parse(b['total'].toString()));
          //final totalIngresos = data['ingresos_por_silla'].fold(0,(a,b)=>a+double.parse(b['ingresos'].toString()));


          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Wrap(
                  children: [
                    _tarjetaResumen('Facturas Completadas', '${data['citas_por_estado']?.firstWhere((e) => e['status'] == 'completed', orElse: () => {'cantidad': 0})['cantidad']}', Icons.check_circle, const Color(0xff22d88d)),
                    _tarjetaResumen('Facturas Canceladas', '${data['citas_por_estado']?.firstWhere((e) => e['status'] == 'canceled', orElse: () => {'cantidad': 0})['cantidad']}', Icons.cancel_rounded, const Color(0xffFF525C)),
                   // _tarjetaResumen('Citas Aprobadas', '${data['citas_por_estado']?.firstWhere((e) => e['status'] == 'approved', orElse: () => {'cantidad': 0})['cantidad']}', Icons.approval_rounded, const Color(0xff02a4b3)),
                   // _tarjetaResumen('Citas Walk-In', '${data['citas_por_fuente']?.firstWhere((e) => e['source'] == 'pos', orElse: () => {'cantidad': 0})['cantidad']}', Icons.point_of_sale_rounded, const Color(0xff464545)),
                  //  _tarjetaResumen('Citas Online', '${data['citas_por_fuente']?.firstWhere((e) => e['source'] == 'online', orElse: () => {'cantidad': 0})['cantidad']}', Icons.point_of_sale_rounded, const Color(0xff9e7fff)),
                    //
                    _tarjetaResumenInvoice('Rango Facturas',fSize: 12, '${data['primera_y_ultima_factura'][0]['first_invoice_number']} - ${data['primera_y_ultima_factura'][0]['last_invoice_number']} ', Icons.receipt, Colors.blueAccent),
                    _tarjetaResumen('Total Ingresos', '\$${numFormat.format(double.parse(totalIngresos.toString()))}', Icons.discount, Colors.green),
                    _tarjetaResumen('Descuentos aplicados', '\$${numFormat.format(double.parse(totalDescuento.toString()))}', Icons.discount, Colors.deepOrangeAccent),
                    _tarjetaResumen('Impuestos aplicados', '\$${numFormat.format(double.parse(totalImpuestos.toString()))}', Icons.monetization_on_rounded, Colors.amber),

                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          linealChart(data['ingresos_por_dia']),

                          Column(
                            spacing: 20,
                            children: [
                              Text('Métodos de Pago', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 200, width: 300, child: _graficoPie(data['ingresos_por_pago'].isEmpty?[{"payment_gateway": "cash", "total": "0"}]:data['ingresos_por_pago'])),
                              Column(
                                children:  List.generate(data['ingresos_por_pago'].length, (index){
                                  return _tarjetaDia(data['ingresos_por_pago'][index]['payment_gateway'], data['ingresos_por_pago'][index]['total'],null);
                                }),
                              )
                            ],
                          ),

                          Column(
                            children: [
                              Text('Ingresos por Día', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              _listaIngresosPorDia(data['ingresos_por_dia']),
                            ],
                         ),

                        Column(
                            children: [
                              Text('Ingresos por producto', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text("""\$${numFormat.format((
                                  data['ventas_por_producto'].fold(0,(a,b)=>a+(double.parse(b['total_sales'].toString())-double.parse(b['total_discount'].toString())))
                              ))}""", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              _listaIngresosPorProducto(data['ventas_por_producto']),
                            ],
                         ),

                        ]
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Ingresos por silla', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            /*
                            InkWell(
                              onTap: (){
                                selectedData = data['ingresos_por_silla'];
                                setState(() {
                                  pageIndex=1;
                                });
                              },
                                child: Icon(Icons.launch_rounded, color: Colors.grey,))

                             */
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("""\$${numFormat.format((
                            data['ingresos_por_silla'].fold(0,(a,b)=>a+double.parse(b['ingresos'].toString()))
                        ))}""", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Card(
                          margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _listaIngresosPorSilla(data['ingresos_por_silla']),
                              // _listaIngresosPorSilla(summarizeByEmployee(data['ingresos_por_silla'])),
                              //Text(data['ingresos_por_silla'].fold(0,(a,b)=>a+double.parse(b['ingresos'].toString())).toString())
                            ],
                          ),
                        )

                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
  String _nombreMesCorto(int mes) {
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return meses[mes - 1];
  }

  Widget linealChart(List<dynamic> data){
    totalEarningsHistory = data.fold(0, (a,b)=>(a+double.parse(b['ingresos'].toString())).roundToDouble());
    final spots = <FlSpot>[];
    Map<String, double> mapaIngresos = {
      for (var e in data)
        DateTime.parse(e['fecha']).toIso8601String().substring(0, 10): (double.parse(e['ingresos']) as num).toDouble()
    };

    for (int i = 0; i < earningsDaysList.length; i++) {
      final fechaStr = earningsDaysList[i].toIso8601String().substring(0, 10);
      final total = mapaIngresos[fechaStr] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), total));
    }

    final etiquetasX = earningsDaysList.map((d) => "${d.day.toString().padLeft(2, '0')} ${_nombreMesCorto(d.month)}").toList();
   /*
    for(var item in data){
      earningsList.insert(DateTime.parse(item['fecha']).day-1, double.parse(item['ingresos']));
      earningsList.removeAt(DateTime.parse(item['fecha']).day);
    }


    */

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: isMobile(context)?displayWidth(context)*0.90: 800),
          //width: isMobile(context)? displayWidth(context) * 0.9 : isTablet(context)? displayWidth(context) * 0.6 : responsiveApp.setWidth(450),
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).cardColor,
            boxShadow: const [
              BoxShadow(
                spreadRadius: -7,
                blurRadius: 8,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15,),
              Row(
                children: [
                  Expanded(
                    child: Text("Ingresos por dia",
                      style: TextStyle(
                        //color: Colors.black.withOpacity(0.7),
                        fontSize: 16,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8,),
              Row(
                children: [
                  Text("\$${numFormat.format(totalEarningsHistory)}",
                    style: TextStyle(
                      //color: Colors.black.withOpacity(0.7),
                      fontSize: 16,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10,),
                  Icon(
                    earningsTrending>0 ?Icons.trending_up_rounded:earningsTrending<0 ?Icons.trending_down_rounded:Icons.remove,
                    color: earningsTrending>0 ?const Color(0xff22d88d):earningsTrending<0 ?const Color(0xffFF525C):Colors.grey,
                    size: 15.0,),
                  Text(" ${earningsTrending}%",
                    style: TextStyle(
                      color: earningsTrending>0 ?const Color(0xff22d88d):earningsTrending<0 ?const Color(0xffFF525C):Colors.grey,
                      fontSize: 14,
                      fontFamily: "Montserrat",
                    ),
                  ),
                  /*
                  if(selectedSalesHistoryPeriod!='this_year')
                    const Expanded(child: SizedBox()),

                  if(selectedSalesHistoryPeriod=='this_year')
                    Expanded(
                      child: Text("    ${isMobileAndTablet(context)?salesList.length>=3?trimestre[(salesList.length~/3)-1].substring(0, 11):trimestre[0]: salesList.length>=3?trimestre[(earningsList.length~/3)-1]:trimestre[0]}",
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 12,
                          fontFamily: "Montserrat",
                        ),
                      ),
                    ),
                  */
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: (){
                        setState((){
                        });
                      },
                      child: Icon(Icons.cached_rounded,color: Colors.grey.withOpacity(0.7),),
                    ),
                  ),
                ],
              ),

              LineChartSample2(
                  period: 'this_month',
                  ventas: spots,
                  xTiles: etiquetasX,
                  maxX: etiquetasX.length,
                  maxY: spots.map((e)=>e.y).reduce((curr, next) => curr >next?curr:next)
              ),
            ],
          ),
        ),
      ],
    );
  }
}
