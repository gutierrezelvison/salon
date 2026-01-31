
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:salon/Widgets/Components/printers_widget.dart';
import '../../util/Util.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import 'cash_count_history_widget.dart';

class CashCountWidget extends StatefulWidget {
  const CashCountWidget({super.key, required this.onFinish,this.origin});
  final String? origin;
  final Function() onFinish;

  @override
  State<CashCountWidget> createState() => _CashCountWidgetState();
}

class _CashCountWidgetState extends State<CashCountWidget>  with TickerProviderStateMixin {
  late ResponsiveApp responsiveApp;
  late TabController _controller;
  late BDConnection dbConnection;
  AppData appData = AppData();
  int pageIndex = 0;
  bool edit = false;
  TextEditingController adminPasswordController = TextEditingController();
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
  int adminId = 0;
  double totalSales = 0;
  double cashDiference = 0;
  double finalCashReal = 0;
  double cardDiference = 0;
  double creditDiference = 0;
  double discountDiference = 0;
  List<CashRegister> cashList=[];
  List<String> cashItems = [];
  String? selectedCash;
  DateTime? lastCashCountClose;
  dynamic cashCountData;
  dynamic invoiceList;
  dynamic creditNoteList;
  var pFormat = PdfPageFormat.roll80;

  late final dynamic logo;
  String logoStatus = 'empty';
  String printerStatus = 'disconnected';
  final List<bool> _isHovering = [false, false, false];
  bool autoPrint = false;

  int _selectedIndex = 0;
  int fromIndex = 0;


  limpiar(){
    initialCashAmountController.text = '';
    finalCashAmountController.text = '';
    discountAmountController.text = '';
    creditAmountController.text = '';
    creditCardAmountController.text = '';
    cashSalesAmountController.text = '';
    diferenceAmountController.text = '';
    creditCollectedController.text = '';
    extraordinaryOutFlowAmountController.text = '';
    commentsController.text = '';
    adminPasswordController.text = '';
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
    adminId = 0;
    cashList.clear();
    cashCountData = null;
  }

  setCashCount()async{

    if(status=='open'){

      if(await dbConnection.updateCashCount(
          onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
          context: context, cashCount: CashCount(
          id: cashCountId,
          admin_close_id: adminId,
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
            loadImage();
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
            admin_open_id: adminId,
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
        widget.onFinish();
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
    for (var element in await BDConnection(context: context).getData(
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

  getLastCashCount()async{
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
        cc.* 
        ''',
        table: 'cash_count cc',
        where: 'cc.cash_id = ${selectedCash!=null?cashList.elementAt(cashItems.indexOf(selectedCash!)).id:0} AND cc.status = \'closed\'',
        order: 'DESC limit 1',
        orderBy: 'cc.close_date',
        groupBy: 'cc.close_date');
  if(query.isNotEmpty){
    lastCashCountClose = DateTime.parse(query[0]['close_date'].toString().substring(0,10));
  }

    setState(() {

    });

  }

  getCashCount() async{

    var query = await BDConnection(context: context).getData(
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
        cc.* 
        ''',
        table: 'cash_count cc',
        where: 'cc.cash_id = ${selectedCash!=null?cashList.elementAt(cashItems.indexOf(selectedCash!)).id:0} AND cc.status = \'open\'',
        order: 'DESC limit 1',
        orderBy: 'cc.open_date',
        groupBy: 'cc.open_date');

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
        where: 'i.cash_id = ${appData.getCash().id??0} '
            'AND (i.date_time BETWEEN \'${cashCountData[0]['open_date']}\' AND \'${DateTime.now()}\')',
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
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      // Aquí puedes manejar el cambio de pestaña
      setState(() {
        fromIndex = _selectedIndex;
        _selectedIndex = _controller.index;
      });
    });
    pFormat = PdfPageFormat.roll80;
    super.initState();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Good place to initialize/update responsiveApp if it depends on context
    // or InheritedWidgets.
    responsiveApp = ResponsiveApp(context);
    dbConnection = BDConnection(context: context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
              child: Container(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: ()=> Navigator.pop(context),//homeScaffoldKey.currentState!.openDrawer(),
                        icon:const Icon(Icons.arrow_back_rounded,)),
                    Expanded(
                      child: Text(pageIndex==0?"Cuadre de caja":edit?"Modificar cuadre":"Añadir cuadre",
                        style: const TextStyle(
                          //color: Colors.white,
                          fontSize: 18,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(10),),
                  ],
                ),
              ),
            ),

            body: Column(
              children: [
                TabBar(
                    enableFeedback: true,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    controller: _controller,
                    isScrollable: true,
                    labelColor: Theme.of(context).textTheme.titleSmall!.color,
                    indicatorColor: Theme.of(context).primaryColor,
                    automaticIndicatorColorAdjustment: true,
                    tabAlignment: TabAlignment.center,
                    tabs: [
                      createTab(
                        0,
                        'Cuadre',
                        Icon(Icons.monetization_on_rounded, color: _selectedIndex==0?Theme.of(context).primaryColor:Colors.grey,),
                        context,
                      ),
                      createTab(
                        1,
                        'Historial',
                        Icon(Icons.history_rounded, color: _selectedIndex==1?Theme.of(context).primaryColor:Colors.grey,),
                        context,
                      ),
                    ]),
                Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: <Widget>[
                      cashCountWidget(),
                      CashCountHistoryWidget(),
                    ],
                  ),
                ),
              ],
            )
        )
    );
  }
  createTab(int index, String text, Widget? icon, BuildContext context) {
    return Tab(
        text: text,

        icon: icon


    );
  }
  Widget cashCountWidget(){
    return Builder(
        builder: (context) {
          if(cashItems.isEmpty && appData.getCash()!=null){
            setCashList();
            return const Center(child: CircularProgressIndicator(),);
          }else if(appData.getCash()==null){
            return Center(child: Text('!No se ha seleccionado ninguna caja!'),);
          }else {
            return Builder(
                builder: (BuildContext context) {
                  if (cashCountData == null) {
                    getCashCount();
                    return const Center(child: CircularProgressIndicator(),);
                  } else {
                    cashCountId = int.parse(
                        cashCountData.isNotEmpty ? cashCountData[0]['id'] : '0');
                    if (systemFinalCashAmountController.text == '') {
                      systemFinalCashAmountController.text = (cashCountData.isNotEmpty ? ((double.parse(cashCountData[0]['cash']) + double.parse(cashCountData[0]['initial_cash_amount']))-double.parse(cashCountData[0]['purchase_amount'])) : 0).toString();
                    }
                    status =
                    cashCountData.isNotEmpty ? cashCountData[0]['status'] : '';
                    initialCashAmountController.text = numberFormat.format(
                        double.parse(cashCountData.isNotEmpty ? cashCountData[0]['initial_cash_amount'] : '0'));
                    return Builder(
                      builder: (context) {
                        if((invoiceList==null) && cashCountData.isNotEmpty){
                          getInvoicesCount();
                          return const Center(child: CircularProgressIndicator());
                        }else{
                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                Padding(
                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  child: Row(
                                    spacing: 25,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: texto(text: 'Num. Caja: ',
                                          size: responsiveApp.setSP(12))),
                                      Expanded(child: texto(text: selectedCash.toString().padLeft(2,'0'),fontWeight: FontWeight.bold,
                                          size: responsiveApp.setSP(16))),

                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  child: Row(
                                    spacing: 25,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: texto(text: 'Cajero(a) ',
                                          size: responsiveApp.setSP(12))),
                                      Expanded(child: texto(text: appData.getUserData().name,fontWeight: FontWeight.bold,
                                          size: responsiveApp.setSP(16))),

                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                  child: Row(
                                    children: [
                                      Expanded(child: texto(
                                          text: 'Monto efectivo inicial: ',
                                          size: responsiveApp.setSP(12))),
                                      Expanded(child: customField(
                                          readOnly: status == '' ? false : true,
                                          style: Theme.of(context).textTheme.titleMedium!,
                                          context: context,
                                          hintText: 'Monto Inicial',
                                          controller: initialCashAmountController,
                                          keyboardType: TextInputType.number),),
                                    ],
                                  ),
                                ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(text: 'Total Venta: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Text(numberFormat.format(double.parse(
                                                cashCountData.isNotEmpty ? cashCountData[0]['sales_amount'] : '0')),
                                              style: Theme.of(context).textTheme.bodyMedium!,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(text: 'Venta contado: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Text(numberFormat.format(
                                                cashCountData.isNotEmpty ? (double.parse(cashCountData[0]['sales_amount']) - double.parse(
                                                    cashCountData[0]['credit_sales'])) : '0'),
                                              style: Theme.of(context).textTheme.bodyMedium!,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(text: 'Monto efectivo: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Text(cashCountData.isNotEmpty
                                                ? numberFormat.format(
                                                double.parse(cashCountData[0]['cash']))
                                                : numberFormat.format(0),
                                              style: Theme.of(context).textTheme.titleMedium!,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(text: 'Monto tarjeta: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Text(cashCountData.isNotEmpty
                                                ? numberFormat.format(double.parse(
                                                cashCountData[0]['credit_card']))
                                                : numberFormat.format(0),
                                              style: Theme.of(context).textTheme.bodyMedium!,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(text: 'Monto transferencia: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Text(cashCountData.isNotEmpty
                                                ? numberFormat.format(double.parse(
                                                cashCountData[0]['transfer']))
                                                : numberFormat.format(0),
                                              style: Theme.of(context).textTheme.bodyMedium!,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(text: 'Monto depósito: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Text(cashCountData.isNotEmpty
                                                ? numberFormat.format(double.parse(
                                                cashCountData[0]['deposit']))
                                                : numberFormat.format(0),
                                              style: Theme.of(context).textTheme.bodyMedium!,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(text: 'Monto cheque: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Text(cashCountData.isNotEmpty
                                                ? numberFormat.format(double.parse(
                                                cashCountData[0]['check']))
                                                : numberFormat.format(0),
                                              style: Theme.of(context).textTheme.bodyMedium!,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(text: 'Descuentos: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Text(cashCountData.isNotEmpty
                                                ? numberFormat.format(double.parse(
                                                cashCountData[0]['discounts']))
                                                : numberFormat.format(0),
                                              style: Theme.of(context).textTheme.bodyMedium!,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(
                                              text: 'Debito por compras: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Text(cashCountData.isNotEmpty
                                                ? numberFormat.format(
                                                double.parse(cashCountData[0]['purchase_amount'].toString()))
                                                : numberFormat.format(0),
                                              style: Theme.of(context).textTheme.bodyMedium!,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Row(
                                      children: [
                                        Expanded(child: texto(
                                            text: 'Salida extraordinaria de dinero: ',
                                            size: responsiveApp.setSP(12))),
                                        Expanded(child: customField(context: context,
                                            controller: extraordinaryOutFlowAmountController,
                                            hintText: 'Salida extraordinaria de dinero',
                                            keyboardType: TextInputType.number,
                                            style: Theme.of(context).textTheme.titleMedium!,
                                            onChanged: (v) {
                                              if (cashCountData.isNotEmpty) {
                                                setState(() {
                                                  systemFinalCashAmountController.text =

                                                      ((cashCountData.isNotEmpty
                                                          ? (double.parse(
                                                          cashCountData[0]['cash'])  +
                                                          double.parse(cashCountData[0]['initial_cash_amount'].toString()))
                                                          : 0) - double.parse(
                                                          extraordinaryOutFlowAmountController
                                                              .text != ''
                                                              ? extraordinaryOutFlowAmountController
                                                              .text
                                                              : '0') - double.parse(cashCountData[0]['purchase_amount'].toString())).toString();
                                                });
                                              }
                                            }),),
                                      ],
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(
                                              text: 'Monto final efectivo: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Flex(
                                              direction: Axis.horizontal,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(numberFormat.format(double.parse(systemFinalCashAmountController.text==''?'0':systemFinalCashAmountController.text)),
                                                    style: Theme.of(context).textTheme.bodyMedium!,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: customField(context: context,
                                                      controller: finalCashAmountController,
                                                      hintText: 'Monto final efectivo',
                                                      keyboardType: TextInputType.number,
                                                      onChanged: (v) {
                                                        if (cashCountData.isNotEmpty) {
                                                          setState(() {
                                                            diferenceAmountController.text =
                                                                (double.parse(
                                                                    finalCashAmountController.text !=
                                                                        '' ? finalCashAmountController
                                                                        .text : '0') - double.parse(
                                                                    systemFinalCashAmountController
                                                                        .text != ''
                                                                        ? systemFinalCashAmountController
                                                                        .text
                                                                        : '0')).toString();
                                                          });
                                                        }
                                                      }
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                      child: Row(
                                        spacing: 25,
                                        children: [
                                          Expanded(child: texto(text: 'Diferencia: ',
                                              size: responsiveApp.setSP(12))),
                                          Expanded(
                                            child: Text(numberFormat.format(double.parse(diferenceAmountController.text==''?'0':diferenceAmountController.text)),
                                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                  color: double.parse(diferenceAmountController.text==''?'0':diferenceAmountController.text)<0?Colors.red:Colors.black
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                  child: Padding(
                                    padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                                    child: Row(
                                      spacing: 25,
                                      children: [
                                        Expanded(child: texto(text: 'Comentarios: ',
                                            size: responsiveApp.setSP(12))),
                                        Expanded(child: customField(readOnly: false,
                                            context: context,
                                            controller: commentsController,
                                            hintText: 'Comentarios',
                                            style: Theme.of(context).textTheme.bodyMedium!,
                                            keyboardType: TextInputType.text),

                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  child: Row(
                                    children: [
                                      Expanded(child: texto(text: 'Hora apertura: ',
                                          size: responsiveApp.setSP(12))),
                                      texto(text: cashCountData.isNotEmpty ? dateFormat.format(DateTime.parse(cashCountData[0]['open_date'])) : 'No disponible',
                                          size: responsiveApp.setSP(12)),
                                    ],
                                  ),
                                ),
                                if(status != '')
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                    child: Row(
                                      children: [
                                        Expanded(child: texto(text: 'Hora cierre: ',
                                            size: responsiveApp.setSP(12))),
                                        texto(text: cashCountData.isNotEmpty && cashCountData[0]['close_date']!='0000-00-00 00:00:00'? dateFormat.format(DateTime.parse(cashCountData[0]['close_date'])) : 'No disponible',
                                            size: responsiveApp.setSP(12)),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  child: Row(
                                    children: [
                                      Expanded(child: texto(
                                          text: 'Estado: ', size: responsiveApp.setSP(12))),
                                      texto(text: cashCountData.isNotEmpty ? cashCountData[0]['status'] == 'open'
                                          ? 'Abierto'
                                          : 'Cerrado' : 'No disponible',
                                          size: responsiveApp.setSP(12)),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () async{
                                          if(status=='open') {
                                            if (finalCashAmountController
                                                .text != '') {
                                              if (diferenceAmountController.text == '0'||diferenceAmountController.text=='0.0') {
                                                warningMsg(
                                                    context: context,
                                                    mainMsg:
                                                    "Se procederá a cerrar la caja.",
                                                    msg:
                                                    "Si continua se realizará el cierre de forma definiva.",
                                                    okBtnText: "Cerrar caja",
                                                    okBtn: () {
                                                      Navigator.pop(context);
                                                      validateAdmin();
                                                    },
                                                    cancelBtnText: "Cancelar",
                                                    cancelBtn: () {
                                                      Navigator.pop(context);
                                                    });
                                              } else {
                                                CustomSnackBar().show(
                                                    context: context,
                                                    msg:
                                                    'La caja no puede cerrar con diferencias',
                                                    icon: Icons.error,
                                                    color: Colors.red);
                                              }
                                            } else {
                                              CustomSnackBar().show(
                                                  context: context,
                                                  msg:
                                                  'Elmonto real efectivo no debe estar vacío',
                                                  icon: Icons.error,
                                                  color: Colors.red);
                                            }
                                          }else{
                                            print("monto inicial : ${initialCashAmountController.text}");
                                            loadingDialog(context);
                                            await getLastCashCount();
                                            print("monto inicial2 : ${initialCashAmountController.text}");

                                            Navigator.pop(context);
                                            if((appData.getCompanyData().cash_time_control_status == 'enabled'?(lastCashCountClose?.isAtSameMomentAs(DateTime.parse(DateTime.now().toString().substring(0,10)))??false):false)){
                                              showWarning("¡Atencion!", "La caja se encuentra en estatus cerrada y no puede reabrirse.");
                                            }else {
                                              print("monto inicial3 : ${initialCashAmountController.text}");
                                              var initialAmount= initialCashAmountController.text;
                                              warningMsg(
                                                  context: context,
                                                  mainMsg:
                                                  "Se procederá a abrir la caja.",
                                                  msg:
                                                  "Desea continuar.",
                                                  okBtnText: "Abrir caja",
                                                  okBtn: () {
                                                    print("monto inicial final 4: ${initialCashAmountController.text}");
                                                    initialCashAmountController.text = initialAmount;
                                                    Navigator.pop(context);
                                                    validateAdmin();
                                                    print("monto inicial final : ${initialCashAmountController.text}");

                                                  },
                                                  cancelBtnText: "Cancelar",
                                                  cancelBtn: () {
                                                    Navigator.pop(context);
                                                  });
                                            }

                                          }
                                        },
                                        child: Container(
                                          padding: responsiveApp.edgeInsetsApp
                                              .allSmallEdgeInsets,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                responsiveApp.setWidth(50)),
                                            color: const Color(0xff6C9BD2),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                cashCountData.isNotEmpty ? cashCountData[0]['status'] == 'open' ? Icons
                                                    .close_rounded : Icons
                                                    .play_arrow_rounded : Icons
                                                    .play_arrow_rounded,
                                                color: Colors.white,
                                                size: responsiveApp.setWidth(20),
                                              ),
                                              texto(
                                                size: responsiveApp.setSP(12),
                                                text: cashCountData.isNotEmpty ? cashCountData[0]['status'] == 'open'
                                                    ? 'Cerrar'
                                                    : 'Abrir' : 'Abrir',
                                                color: Colors.white,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                              ),
                                              SizedBox(width: responsiveApp.setWidth(8),),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  }
                }
            );
          }
        }
    );
  }

  validateAdmin(){

    print("monto inicial5 : ${initialCashAmountController.text}");
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            spacing: 10,
            children: [
              Expanded(child: Text("Autorización de caja",style: Theme.of(context).textTheme.titleLarge,)),
              InkWell(
                  onTap: (){Navigator.pop(context);},
                  child: Icon(Icons.close_rounded, color: Colors.grey,)
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext ctx, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    child: FutureBuilder(future: dbConnection.getData(
                        onError: (onError){},
                        fields: 'acm.*, u.name, u.image',
                        table: ' admin_cash_validator acm INNER JOIN users u ON u.id = acm.user_id ',
                        where: '1',
                        order: 'DESC',
                        orderBy: 'acm.id',
                        groupBy: 'acm.id'
                    ),
                        builder: (BuildContext context, AsyncSnapshot snapshot){
                          if(snapshot.data==null){
                            return Center(child: CircularProgressIndicator(),);
                          }else if(snapshot.data.isEmpty){
                            return Center(child: Text("No se ha agregado ningun usuario"));
                          }else{
                            return Column(
                              children: List.generate(snapshot.data.length, (index){
                                print("Usuario antes: ${snapshot.data[index]['user_id']}");
                                return Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap:(){
                                          showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: Row(
                                                  spacing: 10,
                                                  children: [
                                                    Expanded(child: Text("Credenciales",style: Theme.of(context).textTheme.titleLarge,)),
                                                    InkWell(
                                                        onTap: (){Navigator.pop(context);},
                                                        child: Icon(Icons.close_rounded, color: Colors.grey,)
                                                    ),
                                                  ],
                                                ),
                                                content: StatefulBuilder(
                                                    builder: (BuildContext ctx, StateSetter setState) {
                                                    return Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      spacing: 10,
                                                      children: [
                                                        Text("Por favor escriba su contraseña para continuar"),
                                                        customField(context: context, hintText: "Contraseña",obscureText: true,
                                                            controller: adminPasswordController,
                                                            onChanged: (v){
                                                              setState((){});
                                                            },
                                                            onEditingComplete:()async{
                                                              loadingDialog(context);
                                                              var query = await dbConnection.validateAdminPass(context, int.parse(snapshot.data[index]['user_id']), adminPasswordController.text);
                                                              if(query[0]=='Contraseña incorrecta'){
                                                                showNotification('Contraseña incorrecta', Icons.error, Colors.red);
                                                                Navigator.pop(context);
                                                              }else if(query[0]=='Usuario no encontrado'){
                                                                showNotification('Usuario no encontrado', Icons.error, Colors.red);
                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                              }else if(query.isEmpty){
                                                                showNotification('Algo salio mal, por favor intenelo de nuevo', Icons.error, Colors.red);
                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                              }else{
                                                                adminId= int.parse(snapshot.data[index]['user_id'].toString());

                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                                setCashCount();
                                                              }
                                                            },
                                                            suffix: InkWell(
                                                              onTap: ()async{
                                                                loadingDialog(context);
                                                                var query = await dbConnection.validateAdminPass(context, int.parse(snapshot.data[index]['user_id']), adminPasswordController.text);
                                                                if(query[0]=='Contraseña incorrecta'){
                                                                  showNotification('Contraseña incorrecta', Icons.error, Colors.red);
                                                                  Navigator.pop(context);
                                                                }else if(query[0]=='Usuario no encontrado'){
                                                                  showNotification('Usuario no encontrado', Icons.error, Colors.red);
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                }else if(query.isEmpty){
                                                                  showNotification('Algo salio mal, por favor intenelo de nuevo', Icons.error, Colors.red);
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                }else{
                                                                  adminId= int.parse(snapshot.data[index]['user_id'].toString());

                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                  setCashCount();
                                                                }
                                                              },
                                                              child: Icon(Icons.forward,color: adminPasswordController.text.length>=3?Colors.green:Colors.grey,),
                                                            )
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                ),
                                              )
                                          );
                                        },
                                        child: Container(
                                            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                                            decoration: BoxDecoration(
                                              // color: selectedIndex[index]? Theme.of(context).primaryColor.withValues(alpha: 0.3):Colors.transparent,
                                            ),
                                            child: Text(snapshot.data[index]['name'],style: Theme.of(context).textTheme.titleMedium,)
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }
                              ),
                            );
                          }
                        }
                    ),
                  ),
                ],
              );
            }
          ),
        )
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

    var receipt = await testReceipt(bytes, generator);
    viewWidget(context, printer.pdfPreview(context,[IconButton(onPressed: (){printer.sendJobToPrinter(receipt);}, icon: Icon(Icons.print_rounded, color: Colors.white,))]), (){Navigator.pop(context);limpiar(); widget.onFinish();});




    //limpiar();
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
      sendDoc();

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
        pw.Text('Fecha:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text(dateFormatOnlyDate.format(DateTime.now())),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Hora de cierre:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text(TimeOfDay.now().format(context).toString()),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Caja:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text(cashNumber.toString()),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Usuario:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text(appData.getUserData().name),
      ]),

      pw.Divider(),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Text('RESUMEN', style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Divider(),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Efectivo inicial:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(cashCountData[0]['initial_cash_amount'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Total ventas:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(cashCountData[0]['sales_amount'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Ventas contado:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(cashCountData[0]['sales_amount'].toString()) - double.parse(cashCountData[0]['credit_sales'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Monto Tarjeta:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(cashCountData[0]['credit_card'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Monto transferencia:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(cashCountData[0]['transfer'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Monto depósito:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(cashCountData[0]['deposit'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Monto cheque:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(cashCountData[0]['check'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Monto efectivo:', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(cashCountData[0]['cash'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Debito por compras', style: const  pw.TextStyle(fontSize: 9)),
        pw.Text("RD\$${numberFormat.format(double.parse(cashCountData[0]['purchase_amount'].toString()))}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
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
                              style: const  pw.TextStyle(fontSize: 9))),
                      pw.Text("\$${numberFormat.format(double.parse(data['total_amount'].toString()))}", style: const  pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          child: pw.Text('Método de pago: ',
                              style: const  pw.TextStyle(fontSize: 9))),
                      pw.Text(data['payment_method'] == 'card' ? 'Tarjeta': data['payment_method'] == 'transfer' ?'Transferencia': 'Efectivo', style: const  pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          child: pw.Text('Forma de pago: ',
                              style: const  pw.TextStyle(fontSize: 9))),
                      pw.Text(data['payment_way'] == 'cash' ?'Contado': 'Crédito', style: const  pw.TextStyle(fontSize: 9)),
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

  Future<List<int>> testReceipt(List<int> bytes, Generator printer) async{
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
        text: dateFormatOnlyDate.format(DateTime.now()),
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
        text: TimeOfDay.now().format(context).toString(),
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
        text: "RD\$${numberFormat.format(double.parse(cashCountData[0]['initial_cash_amount'].toString()))}",
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
        text: "RD\$${numberFormat.format(double.parse(cashCountData[0]['sales_amount'].toString()))}",
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
        text: "RD\$${numberFormat.format(double.parse(cashCountData[0]['sales_amount'].toString())-double.parse(cashCountData[0]['cash'].toString()))}",
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
        text: "RD\$${numberFormat.format(double.parse(cashCountData[0]['credit_card'].toString()))}",
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
        text: "RD\$${numberFormat.format(double.parse(cashCountData[0]['transfer'].toString()))}",
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
        text: "RD\$${numberFormat.format(double.parse(cashCountData[0]['deposit'].toString()))}",
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
        text: "RD\$${numberFormat.format(double.parse(cashCountData[0]['check'].toString()))}",
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
        text: "RD\$${numberFormat.format(double.parse(cashCountData[0]['cash'].toString()))}",
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
        text: "RD\$${numberFormat.format(double.parse(cashCountData[0]['purchase_amount'].toString()))}",
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
        text: "RD\$${numberFormat.format(cashCountData[0]['sales_refounds'].roundToDouble())}",
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