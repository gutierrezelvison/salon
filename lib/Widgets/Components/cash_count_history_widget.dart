
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:salon/Widgets/Components/printers_widget.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../util/db_connection.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../values/ResponsiveApp.dart';

class CashCountHistoryWidget extends StatefulWidget {
  const CashCountHistoryWidget({super.key});

  @override
  State<CashCountHistoryWidget> createState() => _CashCountHistoryWidgetState();
}

class _CashCountHistoryWidgetState extends State<CashCountHistoryWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection dbConnection;
  AppData appData = AppData();
  int pageIndex = 0;
  bool edit = false;
  TextEditingController initialCashAmountController = TextEditingController();
  TextEditingController systemFinalCashAmountController = TextEditingController();
  TextEditingController purchaseAmountController = TextEditingController();
  TextEditingController finalCashAmountController = TextEditingController();
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController creditCardAmountController = TextEditingController();
  TextEditingController creditAmountController = TextEditingController();
  TextEditingController cashSalesAmountController = TextEditingController();
  TextEditingController diferenceAmountController = TextEditingController();
  TextEditingController creditCollectedController = TextEditingController();
  TextEditingController extraordinaryOutFlowAmountController = TextEditingController();
  TextEditingController commentsController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  NumberFormat numberFormat = NumberFormat('#,###.##', 'en_Us');
  DateFormat dateFormat = DateFormat('dd/MM/yyyy h:mm:ss a');
  DateFormat dateFormatOnlyDate = DateFormat('dd/MM/yyyy');
  String status = '';
  String openDate = '';
  String closedDate = '';
  int cashNumber = 1;
  int cashCountId = 0;
  double totalSales = 0;
  double cashDiference = 0;
  double finalCashReal = 0;
  double cardDiference = 0;
  double creditDiference = 0;
  double discountDiference = 0;
  List<CashRegister> cashList=[];
  List<String> cashItems = [];
  String? selectedCash;
  dynamic cashCountData;
  dynamic selectedCashCount;
  dynamic invoiceList;
  dynamic creditNoteList;
  var pFormat = PdfPageFormat.roll80;

  late final dynamic logo;
  String logoStatus = 'empty';
  String printerStatus = 'disconnected';
  final List<bool> _isHovering = [false, false, false];
  bool autoPrint = false;

  String order = 'DESC';
  String orderBy = '`open_date`';


  limpiar(){
    initialCashAmountController.text = '';
    systemFinalCashAmountController.text = '';
    finalCashAmountController.text = '';
    discountAmountController.text = '';
    creditAmountController.text = '';
    creditCardAmountController.text = '';
    cashSalesAmountController.text = '';
    diferenceAmountController.text = '';
    creditCollectedController.text = '';
    extraordinaryOutFlowAmountController.text = '';
    commentsController.text = '';
    status = '';
    openDate = '';
    closedDate = '';
    cashNumber = 1;
    cashCountId = 0;
    totalSales = 0;
    cashDiference = 0;
    cardDiference = 0;
    creditDiference = 0;
    discountDiference = 0;
  }

  setCashCount()async{
    if(status=='open'){

      if(await dbConnection.updateCashCount(
          onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
          context: context, cashCount: CashCount(
            id: cashCountId,
            diference: double.parse(diferenceAmountController.text!=''?diferenceAmountController.text:'0'),
            system_final_cash: double.parse(systemFinalCashAmountController.text!=''?systemFinalCashAmountController.text:'0'),
            real_final_cash: double.parse(finalCashAmountController.text!=''?finalCashAmountController.text:'0'),
            comments: commentsController.text,
            extraordinary_outflow: double.parse(extraordinaryOutFlowAmountController.text!=''?extraordinaryOutFlowAmountController.text:'0'),
            close_date: DateTime.now().toString(),
            status: 'closed'
          )
        )
      ){

          if (logoStatus ==
              'empty' ||
              logoStatus ==
                  'error') {
            setState(() {
              logoStatus =
              'loading';
            });
            await loadImage();
            sendDoc();
          } else {
            sendDoc();
          }
        showNotification('¡Operación realizada con éxito!', Icons.error, Colors.green);

      }else{
        showNotification('Error al intentar realizar la operación', Icons.error, Colors.red);
      }

    }else{
      if(await dbConnection.addCashCount(
          onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
          context: context, 
          cashCount: CashCount(
            cash_id: cashList.elementAt(cashItems.indexOf(selectedCash!)).id,
            initial_cash_amount: double.parse(initialCashAmountController.text),
            comments: commentsController.text,
            open_date: DateTime.now().toString(),
            status: 'open'
          )
        )
      ){
        showNotification('¡Operación realizada con éxito!', Icons.error, Colors.green);
        limpiar();
      }else{
        showNotification('Error al intentar realizar la operación', Icons.error, Colors.red);
      }
    }
  }

  showWarning(String title, String msg){
    warningMsg(context: context, mainMsg: title, msg: msg, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});
  }

  showNotification(String msg,IconData icon, Color color){
    CustomSnackBar().show(context: context, msg: msg, icon: icon, color: color);
  }


  setCashList() async{
    for (var element in await dbConnection.getData(
      onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
      context: context,
      table: 'cash_register',
      fields: '*',
      groupBy: 'id',
      order: 'ASC',
      orderBy: 'id',
      where: 'id > 0',
    )){
      cashList.add(
          CashRegister(
            id: int.parse(element['id']),
            number: int.parse(element['number']),
            user_id: int.parse(element['user_id']),
          )
      );
      cashItems.add(element['number']);
    }
    if (appData.getCash().number!=null) {
      selectedCash = appData.getCash().number.toString();
    } else {
      selectedCash = null;
    }
    setState(() {

    });
  }

  getCashCount() async{
    var query = await dbConnection.getData(
        onError: (e) {
          warningMsg(context: context,
              mainMsg: '¡Error!',
              msg: e,
              okBtnText: 'Aceptar',
              okBtn: () {
                Navigator.pop(context);
              });
        },
        context: context,
        fields: '''
        cc.*, u.name, cr.number
        ''',
        table: 'cash_count cc INNER JOIN cash_register cr ON cr.id = cc.cash_id INNER JOIN users u ON u.id = cr.user_id',
        where: appData.getCash()!=null && appData.getUserData().rol_id!=1?'cc.cash_id = ${selectedCash!=null?cashList.elementAt(cashItems.indexOf(selectedCash!)).id:''}':'1',
        order: '$order limit 50',
        orderBy: orderBy,
        groupBy: 'cc.id');


     /*
    var query = await dbConnection.getDataCustomQuery(onError: (v){},
        query: '''
        SELECT cc.*, 
       (SELECT COALESCE(SUM(ar.remaining_amount),0)
        FROM invoice i
        JOIN account_receivable ar ON i.id = ar.invoice_id
        WHERE (i.date_time BETWEEN cc.open_date AND \'${DateTime.now()}\') AND i.payment_way = 'credit' AND ar.remaining_amount > 0) AS total_remaining
FROM cash_count cc
WHERE cc.cash_id = ${selectedCash!=null?cashList.elementAt(cashItems.indexOf(selectedCash!)).id:0} AND cc.status = 'open' GROUP BY cc.open_date ORDER BY cc.open_date DESC LIMIT 1;
        '''
    );

      */

      setState(() {
        cashCountData = query;
      });

  }

  getInvoicesCount() async{
    var query = await dbConnection.getData(
        onError: (e) {
          warningMsg(context: context,
              mainMsg: '¡Error!',
              msg: e,
              okBtnText: 'Aceptar',
              okBtn: () {
                Navigator.pop(context);
              });
        },
        context: context,
        fields: 'i.invoice_number, i.date_time, i.payment_method, i.total_amount, i.payment_way, i.payment_status ',
        table: 'invoice i ',
        where: 'i.cash_id = ${selectedCashCount['cash_id']??0} '
            'AND (i.date_time BETWEEN \'${selectedCashCount['open_date']}\' AND \'${selectedCashCount['close_date']!='0000-00-00 00:00:00'?selectedCashCount['close_date']:DateTime.now()}\')',
        order: 'ASC',
        orderBy: 'i.id',
        groupBy: 'i.id');


    setState(() {
      invoiceList= query;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    pFormat = PdfPageFormat.roll80;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    dbConnection = BDConnection(context: context);
    return Builder(
        builder: (context) {
          if(cashItems.isEmpty && appData.getCash()!=null){
            setCashList();
            return const Center(child: CircularProgressIndicator(),);
          }else if(appData.getCash()==null && appData.getUserData().level.id!=1){
            return Center(child: Text('!No se ha seleccionado ninguna caja!'),);
          }else {
            return Builder(
                builder: (BuildContext context) {
                  if (cashCountData == null) {
                    getCashCount();
                    return const Center(child: CircularProgressIndicator(),);
                  } else {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: responsiveApp.setWidth(10),
                              top: responsiveApp.setWidth(2), bottom: responsiveApp.setWidth(2)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if(!isMobile(context))
                                InkWell(
                                  onTap: (){
                                    setState(() {
                                      orderBy = 'cc.id';
                                      order= order == 'ASC'?'DESC':'ASC';
                                      cashCountData=null;
                                    });
                                  },
                                  child: SizedBox(width: responsiveApp.setWidth(80),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: texto(
                                            text: '# Cuadre',
                                          ),
                                        ),
                                        Icon(orderBy=='cc.id' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                                      ],
                                    ),
                                  ),
                                ),
                              if(!isMobile(context))
                                Padding(
                                  padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                  child: Container(height: responsiveApp.setHeight(20),
                                    width: responsiveApp.setWidth(1),
                                    color: Colors.grey.withValues(alpha: 0.3),),
                                ),
                              if(!isMobile(context) && isLandscape(context))
                                InkWell(
                                  onTap: (){
                                    setState(() {
                                      orderBy = 'cr.`number`';
                                      order= order == 'ASC'?'DESC':'ASC';
                                      cashCountData=null;
                                    });
                                  },
                                  child: SizedBox(width: responsiveApp.setWidth(50),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: texto(
                                            text: 'Caja',
                                          ),
                                        ),
                                        Icon(orderBy=='cr.`number`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                                      ],
                                    ),
                                  ),
                                ),
                              if(!isMobile(context) && isLandscape(context))
                                Padding(
                                  padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                  child: Container(height: responsiveApp.setHeight(20),
                                    width: responsiveApp.setWidth(1),
                                    color: Colors.grey.withValues(alpha: 0.3),),
                                ),
                              if(!isMobile(context) && isLandscape(context))
                                Expanded(
                                  child: InkWell(
                                    onTap: (){
                                      setState(() {
                                        orderBy = 'u.`name`';
                                        order= order == 'ASC'?'DESC':'ASC';
                                        cashCountData=null;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: texto(
                                            text: 'Cajera/o',
                                          ),
                                        ),
                                        Icon(orderBy=='u.`name`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                                      ],
                                    ),
                                  ),
                                ),
                              if(!isMobile(context) && isLandscape(context))
                                Expanded(
                                  child: InkWell(
                                    onTap: (){
                                      setState(() {
                                        orderBy = 'cc.`sales_amount`';
                                        order= order == 'ASC'?'DESC':'ASC';
                                        cashCountData=null;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: texto(
                                            text: 'Ventas',
                                          ),
                                        ),
                                        Icon(orderBy=='cc.`sales_amount`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                                      ],
                                    ),
                                  ),
                                ),
                              if(!isMobile(context))
                                Padding(
                                  padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                  child: Container(height: responsiveApp.setHeight(20),
                                    width: responsiveApp.setWidth(1),
                                    color: Colors.grey.withValues(alpha: 0.3),),
                                ),
                              if(!isMobile(context))
                                InkWell(
                                  onTap: (){
                                    setState(() {
                                      orderBy = 'cc.open_date';
                                      order= order == 'ASC'?'DESC':'ASC';
                                      cashCountData=null;
                                    });
                                  },
                                  child: SizedBox(width: responsiveApp.setWidth(130),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: texto(
                                            text: 'Fecha apertura',
                                          ),
                                        ),
                                        Icon(orderBy=='cc.open_date' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                                      ],
                                    ),
                                  ),
                                ),
                              if(!isMobile(context) && isLandscape(context) )
                                Padding(
                                  padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                  child: Container(height: responsiveApp.setHeight(20),
                                    width: responsiveApp.setWidth(1),
                                    color: Colors.grey.withValues(alpha: 0.3),),
                                ),
                              if(!isMobile(context))
                                InkWell(
                                  onTap: (){
                                    setState(() {
                                      orderBy = 'cc.close_date';
                                      order= order == 'ASC'?'DESC':'ASC';
                                      cashCountData=null;
                                    });
                                  },
                                  child: SizedBox(width: responsiveApp.setWidth(130),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: texto(
                                            text: 'Fecha cierre',
                                          ),
                                        ),
                                        Icon(orderBy=='cc.close_date' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                                      ],
                                    ),
                                  ),
                                ),
                              if(!isMobile(context) && isLandscape(context) )
                                Padding(
                                  padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                  child: Container(height: responsiveApp.setHeight(20),
                                    width: responsiveApp.setWidth(1),
                                    color: Colors.grey.withValues(alpha: 0.3),),
                                ),
                              if(!isMobile(context) && isLandscape(context) )
                                InkWell(
                                  onTap: (){
                                    setState(() {
                                      orderBy = 'cc.status';
                                      order= order == 'ASC'?'DESC':'ASC';
                                      cashCountData=null;
                                    });
                                  },
                                  child: SizedBox(width: responsiveApp.setWidth(80),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: texto(
                                            text: 'Estado',
                                          ),
                                        ),
                                        Icon(orderBy=='cc.status' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withValues(alpha: 0.3),)),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: List.generate(cashCountData.length, (index){
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap:()async{
                                        loadingDialog(context);
                                        selectedCashCount = cashCountData[index];
                                        cashCountId = int.parse(selectedCashCount['id'].toString());
                                          systemFinalCashAmountController.text = (selectedCashCount.isNotEmpty ? ((double.parse(selectedCashCount['cash']) + double.parse(selectedCashCount['initial_cash_amount']))-double.parse(selectedCashCount['purchase_amount'])) : 0).toString();
                                        initialCashAmountController.text = numberFormat.format(
                                            double.parse(cashCountData.isNotEmpty ? selectedCashCount['initial_cash_amount'] : '0'));
                                        finalCashAmountController.text = selectedCashCount['real_final_cash'].toString();
                                        diferenceAmountController.text =
                                            selectedCashCount['diference'].toString();
                                        await getInvoicesCount();

                                        if (logoStatus == 'empty' || logoStatus == 'error') {
                                          setState(() {
                                            logoStatus = 'loading';
                                          });
                                           await loadImage();
                                          Navigator.pop(context);
                                          sendDoc();
                                        } else {
                                          Navigator.pop(context);
                                          sendDoc();
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: responsiveApp.setWidth(10),
                                            top: responsiveApp.setWidth(2), bottom: responsiveApp.setWidth(2)),
                                        child: Row(
                                          children: [
                                            SizedBox(width: responsiveApp.setWidth(80), child: Text(cashCountData[index]['id'])),
                                            Padding(
                                              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                              child: Container(height: responsiveApp.setHeight(20),
                                                width: responsiveApp.setWidth(1),
                                              ),
                                            ),
                                            SizedBox(width: responsiveApp.setWidth(50), child: Text(cashCountData[index]['number'].toString().padLeft(2,'0'))),
                                            Padding(
                                              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                              child: Container(height: responsiveApp.setHeight(20),
                                                width: responsiveApp.setWidth(1),
                                              ),
                                            ),
                                            Expanded(child: Text(cashCountData[index]['name'])),
                                            Padding(
                                              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                              child: Container(height: responsiveApp.setHeight(20),
                                                width: responsiveApp.setWidth(1),
                                              ),
                                            ),
                                            Expanded(child: Text(numberFormat.format(double.parse(cashCountData[index]['sales_amount'].toString())))),
                                            Padding(
                                              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                              child: Container(height: responsiveApp.setHeight(20),
                                                width: responsiveApp.setWidth(1),
                                              ),
                                            ),
                                            SizedBox(width: responsiveApp.setWidth(130), child: Text(dateFormat.format(DateTime.parse(cashCountData[index]['open_date'])))),
                                            Padding(
                                              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                              child: Container(height: responsiveApp.setHeight(20),
                                                width: responsiveApp.setWidth(1),
                                              ),
                                            ),
                                            SizedBox(width: responsiveApp.setWidth(130), child: Text(dateFormat.format(DateTime.parse(cashCountData[index]['close_date'])))),
                                            Padding(
                                              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                              child: Container(height: responsiveApp.setHeight(20),
                                                width: responsiveApp.setWidth(1),
                                              ),
                                            ),
                                            SizedBox(width: responsiveApp.setWidth(80),
                                              child: Center(
                                                child: Container(
                                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
                                                    color: cashCountData[index]['status']=='open'?Colors.green.withValues(alpha: 0.2):Colors.deepOrange.withValues(alpha: 0.2)
                                                  ),
                                                    child: Text(cashCountData[index]['status'],style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cashCountData[index]['status']=='open'?Colors.green:Colors.deepOrange),)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if(index<(cashCountData.length-1))
                                      const Divider()
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }
            );
          }
        }
    );
  }

  sendDoc() async {

    var profile = await CapabilityProfile.load();
    var paper = PaperSize.mm80;
    List<int> bytes = [];
    var generator =  Generator(paper, profile);
    var printer = PrinterWidget(fact:[pruebaVisFact()],pageFormat: PdfPageFormat.roll80,
        onPageChanged: (format){
          setState(() {

          });
        },
        printAction:null
    );

    viewWidget(context, printer.pdfPreview(context,[IconButton(onPressed: (){printer.sendJobToPrinter(testReceipt(bytes, generator));}, icon: Icon(Icons.print_rounded, color: Colors.white,))]), (){Navigator.pop(context);});

  }


  Future loadImage() async {
    try {
      logo = appData.getCompanyData().logo != 'null'
          ? await flutterImageProvider(
          MemoryImage(appData.getCompanyData().logo.bytes!))
          : await flutterImageProvider(
          const AssetImage('assets/images/vendo_logo.png'));
      setState(() {
        logoStatus = 'loaded';
      });


      if (kDebugMode) {
        print("****OK****");
      }
    } catch (e) {
      setState(() {
        logoStatus = 'error';
      });
      if (kDebugMode) {
        print("****ERROR: $e****");
      }
      return;
    }
  }

  pw.Widget pruebaVisFact() {
    return pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
      pw.Column(children: [
        pw.Image(
          logo,
          width: responsiveApp.setWidth(80),
          height: responsiveApp.setHeight(80),
        ),
        pw.Column(children: [
          pw.Text("${appData.getCompanyData().company_name}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 10)),
          pw.Text("${appData.getCompanyData().company_email}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 10)),
          pw.Text("${appData.getCompanyData().company_phone.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'), (Match m) => "(${m[1]}) ${m[2]}-${m[3]}")}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 10)),
          pw.Text("${appData.getCompanyData().address}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 10)),
          //if(appData.getCompanyData().rnc!=null) pw.Text("RNC: ${appData.getCompanyData().rnc}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 12)),
        ]),
      ]),
      pw.SizedBox(height: responsiveApp.setHeight(10)),
      pw.Divider(),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Text('CUADRE DE CAJA DIARIO', style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Divider(),

      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Fecha de cierre:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text(dateFormatOnlyDate.format(DateTime.parse(selectedCashCount['close_date'])), style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Hora de cierre:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text(TimeOfDay.fromDateTime(DateTime.parse(selectedCashCount['close_date'])).format(context).toString(), style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Caja:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text(selectedCashCount['number'].toString(), style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Usuario:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text(selectedCashCount['name']),
      ]),

      pw.Divider(),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Text('RESUMEN', style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Divider(),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Efectivo inicial:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(selectedCashCount['initial_cash_amount'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Total ventas:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(selectedCashCount['sales_amount'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Ventas contado:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(selectedCashCount['sales_amount'].toString()) - double.parse(selectedCashCount['credit_sales'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Monto Tarjeta:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(selectedCashCount['credit_card'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Monto transferencia:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(selectedCashCount['transfer'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Monto depósito:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(selectedCashCount['deposit'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Monto cheque:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(selectedCashCount['check'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Monto efectivo:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(selectedCashCount['cash'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Debito por compras', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(selectedCashCount['purchase_amount'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Sal. efectivo extr.:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(extraordinaryOutFlowAmountController.text!=''?extraordinaryOutFlowAmountController.text:'0'))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Divider(),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Text('LISTADO DE FACTURAS', style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Divider(),
      pw.ListView(
        children:
        List<pw.Widget>.from(invoiceList.map((data) {
          return pw.Column(children: [
            pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          child: pw.Text(data['invoice_number'],
                               style: const  pw.TextStyle(fontSize: 9),)),
                      pw.Text("\$${numberFormat.format(double.parse(data['total_amount'].toString()))}",  style: const  pw.TextStyle(fontSize: 9),),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          child: pw.Text('Método de pago: ',
                               style: const  pw.TextStyle(fontSize: 9),)),
                      pw.Text(data['payment_method'] == 'card' ? 'Tarjeta': data['payment_method'] == 'transfer' ?'Transferencia': 'Efectivo',  style: const  pw.TextStyle(fontSize: 9),),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          child: pw.Text('Forma de pago: ',
                              style: const pw.TextStyle(fontSize: 9))),
                      pw.Text(data['payment_way'] == 'cash' ?'Contado': 'Crédito',  style: const  pw.TextStyle(fontSize: 9),),
                    ],
                  ),
                ]
            ),
            pw.SizedBox(height: 10
            ),
          ]);
        }).toList()),
      ),
      pw.Divider(),
      //pw.SizedBox(height: 10),

      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Total de facturas: ', style: const  pw.TextStyle(fontSize: 9)),
          pw.Text(invoiceList.length.toString()),
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Total efectivo esperado: ', style: const  pw.TextStyle(fontSize: 9)),
          pw.Text("RD\$${numberFormat.format(double.parse(systemFinalCashAmountController.text))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Total efectivo real: ', style: const  pw.TextStyle(fontSize: 9)),
          pw.Text("RD\$${numberFormat.format(double.parse(finalCashAmountController.text))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Diferencia: ', style: const  pw.TextStyle(fontSize: 9)),
          pw.Text("RD\$${numberFormat.format(double.parse(diferenceAmountController.text))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
        ],
      ),
      pw.SizedBox(height: 30),
    ]);
  }

  List<int> testReceipt(List<int> bytes, Generator printer) {
    bytes += printer.setGlobalCodeTable('CP1252');

    final img.Image? logoImage = img.decodeImage(appData.getCompanyData().logo.bytes);

    if (logoImage != null) {
      final imageGreyCale =  img.grayscale(logoImage);
      // 2. Redimensionar si es necesario
      final resizedLogo = img.copyResize(imageGreyCale, width: 300); // ancho en píxeles

      // 3. Agregar logo al recibo
      bytes.addAll(printer.image(resizedLogo));
    }

    bytes += printer.row([
      PosColumn(
        text: '${appData.getCompanyData().company_name}',
        width: 12,
        styles: const PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size1,
            align: PosAlign.center,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: '${appData.getCompanyData().address}',
        width: 12,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: "(${appData.getCompanyData().company_phone.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'), (Match m) => "(${m[1]}) ${m[2]}-${m[3]}")}",
        width: 12,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
    ]);

    bytes += printer.row([
      PosColumn(
        text: '-----------------------------------------------',
        width: 12,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'CUADRE DE CAJA DIARIO',
        width: 12,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: '-----------------------------------------------',
        width: 12,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
    ]);

    bytes += printer.row([
      PosColumn(
        text: 'Fecha:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: dateFormatOnlyDate.format(DateTime.parse(selectedCashCount['close_date'])),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Hora de cierre:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: TimeOfDay.fromDateTime(DateTime.parse(selectedCashCount['close_date'])).format(context).toString(),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Caja:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: cashNumber.toString(),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Usuario:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: appData.getUserData().name.toString(),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: '-----------------------------------------------',
        width: 12,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'RESUMEN',
        width: 12,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: '-----------------------------------------------',
        width: 12,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Total efectivo inicial:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(selectedCashCount['initial_cash_amount'].toString()))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            bold: true,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Total ventas:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(selectedCashCount['sales_amount'].toString()))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Ventas contado:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(selectedCashCount['sales_amount'].toString())-double.parse(selectedCashCount['cash'].toString()))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Monto Tarjeta:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(selectedCashCount['credit_card'].toString()))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Monto transferencia:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(selectedCashCount['transfer'].toString()))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Monto depósito:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(selectedCashCount['deposit'].toString()))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            underline: false),
      ),
    ]);

    bytes += printer.row([
      PosColumn(
        text: 'Monto cheque:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),

      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(selectedCashCount['check'].toString()))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Monto efectivo:',
        width: 8,
        styles: const PosStyles(
            bold: true,
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(selectedCashCount['cash'].toString()))}",
        width: 4,
        styles: const PosStyles(
            bold: true,
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Debito por compras:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(selectedCashCount['purchase_amount'].toString()))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Salida efectivo extraordinario:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(extraordinaryOutFlowAmountController.text!=''?extraordinaryOutFlowAmountController.text:'0'))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            underline: false),
      ),
    ]);
    /*
    bytes += printer.row([
      PosColumn(
        text: 'Total de devoluciones:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, bold: true, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(selectedCashCount['sales_refounds'].roundToDouble())}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            bold: true,
            underline: false),
      ),
    ]);

     */

    bytes += printer.row([
      PosColumn(
        text: '-----------------------------------------------',
        width: 12,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'LISTADO DE FACTURAS',
        width: 12,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: '-----------------------------------------------',
        width: 12,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
    ]);

    for (var i = 0; i < invoiceList.length; i++) {
      bytes += printer.row([
        PosColumn(
          text: invoiceList[i]['invoice_number'],
          width: 6,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: "\$${numberFormat.format(double.parse(invoiceList[i]['total_amount'].toString()))}",
          width: 6,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);
      bytes += printer.row([
        PosColumn(
          text: 'Método de pago:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: invoiceList[i]['payment_method'] == 'card' ? 'Tarjeta': invoiceList[i]['payment_method'] == 'transfer' ?'Transferencia': 'Efectivo',
          width: 6,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);
      bytes += printer.row([
        PosColumn(
          text: 'Forma de pago:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: invoiceList[i]['payment_way'] == 'cash' ?'Contado': 'Crédito',
          width: 6,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);
      if(invoiceList[i]['payment_way'] == 'credit') {
        bytes += printer.row([
          PosColumn(
            text: 'Estado de pago:',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: invoiceList[i]['payment_status '] == 'pending'
                ? 'Pendiente'
                : 'Completo',
            width: 6,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);
      }

      if(i<invoiceList.length-1) bytes += printer.feed(1);
    }
    bytes += printer.row([
      PosColumn(
        text: '-----------------------------------------------',
        width: 12,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
    ]);


    bytes += printer.row([
      PosColumn(
        text: 'Total de facturas:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: invoiceList.length.toString(),
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Total efectivo esperado:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(systemFinalCashAmountController.text))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            bold: true,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Total efectivo real:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(finalCashAmountController.text))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            bold: true,
            underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Diferencia:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, underline: false),
      ),
      PosColumn(
        text: "RD\$${numberFormat.format(double.parse(diferenceAmountController.text))}",
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            bold: true,
            underline: false),
      ),
    ]);

    bytes += printer.cut();
    return bytes;
  }
}