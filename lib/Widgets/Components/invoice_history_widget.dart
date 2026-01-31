import 'dart:io';

import 'package:cool_dropdown/controllers/dropdown_controller.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:salon/Widgets/Components/printers_widget.dart';

import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../WebComponents/Header/header_search_bar.dart';

class InvoiceHistoryWidget extends StatefulWidget {
  const InvoiceHistoryWidget({super.key, required this.takeQuotation});
  final Function(dynamic,List<InvoiceDetail> ) takeQuotation;
  @override
  State<InvoiceHistoryWidget> createState() => _InvoiceHistoryWidgetState();
}

class _InvoiceHistoryWidgetState extends State<InvoiceHistoryWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection dbConnection;
  AppData appData = AppData();
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController pageSizeController = TextEditingController();
  TextEditingController customerCodeController = TextEditingController();
  TextEditingController customerRncController = TextEditingController();
  TextEditingController customerAddressController = TextEditingController();
  TextEditingController customerEmailController = TextEditingController();
  TextEditingController customerPhoneController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController searchCustomerController = TextEditingController();
  TextEditingController adminPasswordController = TextEditingController();
  NumberFormat numberFormat = NumberFormat('#,###.##', 'en_Us');
  DateFormat dateFormat = DateFormat('dd/MM/yyyy h:mm:ss a');
  var dateFormatOnlyDate = DateFormat('dd/MM/yyyy');
  int pageIndex = 0;
  bool edit = false;
  String order = 'DESC';
  String orderBy = 'i.`date_time`';
  String imageName = '';
  String imagePath = '';
  int customerId=0;
  bool status= true;
  bool firstTime= true;
  dynamic file;
  int imageLength=0;
  String message1 = 'Drop something here';
  bool highlighted1 = false;
  bool isDragging = false;
  String ncfNumber = '';
  String invoiceNumber = '';
  String invoiceSubtitle = '';
  DateTime? validDate;
  dynamic id_ncf_available = '';
  dynamic invoiceDetails;
  dynamic selectedInvoice;
  late final dynamic logo;
  double totalSalesAmount =0.0;
  List<CashRegister> cashList = [];
  List<User> customerList = [];
  List<InvoiceDetail> invoiceDetailList = [];
  String selectedPosWay = 'sale';
  List<String> cashItems = ['Todo'];
  List<String> customerItems = ['Todo'];
  List<String> paymentWayItems = ['Todo', 'Credito', 'Contado'];
  List<String> paymentMethodItems = ['Todo', 'Efectivo', 'Tarjeta','Transferencia', 'Depósito', 'Cheque'];
  String? selectedCash = 'Todo';
  String? selectedPaymentWay = 'Todo';
  String? selectedPaymentMethod = 'Todo';
  String? selectedCustomer = 'Todo';
  final items = ['Hoy','Ayer','Esta semana','Este mes','Mes anterior', 'Rango de fecha'];
  String selectedValue = 'Hoy';
  String logoStatus = 'empty';
  String fechaInicio = "${DateTime.now().year}-${DateTime.now().month
      .toString().padLeft(2, '0')}-${DateTime.now().day
      .toString().padLeft(2, '0')} 00:00:00";
  String fechaFin =
      "${DateTime.now().year.toString()}-${DateTime.now().month
      .toString().padLeft(2, '0')}-${DateTime.now().day
      .toString().padLeft(2, '0')} 23:59:59";

  String printerStatus = 'disconnected';
  var pFormat = PdfPageFormat.roll80;
  List<CoolDropdownItem<String>> invoiceTypeDropdownItems = [];
  List<CoolDropdownItem<String>> orderTypeDropdownItems = [];
  List<CoolDropdownItem<String>> paymentWayDropdownItems = [];
  List<CoolDropdownItem<String>> paymentMethodDropdownItems = [];
  final invoiceTypeDropdownController = DropdownController();
  final orderTypeDropdownController = DropdownController();
  final paymentWayDropdownController = DropdownController();
  final paymentMethodDropdownController = DropdownController();

  dynamic salesHistoryData;
  List<dynamic> salesHistoryDataToExport=[];

  int _currentPage = 1;
  int _pageSize = 25;
  int _totalRegs = 0;
  List<dynamic> _results = [];
  bool _loading = false;

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      if (edit) {

      }
    }
  }

  limpiar(){
    setState(() {
      customerCodeController.text = '';
      customerRncController.text = '';
      customerEmailController.text = '';
      customerAddressController.text = '';
      customerPhoneController.text = '';
      customerNameController.text = '';
      imageLength =0;
      file = null;
      imageName = '';
      imagePath = '';
      selectedCash = 'Todo';
    });
  }
/*
  deleteItem(int id, String table)async{
    if(await dbConnection.deleteData(
        onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
        context: context,id: id,table: table)){
      CustomSnackBar().show(
          context: context,
          msg: 'Registro eliminado con éxito!',
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xff22d88d)
      );
      setState(() {});
    }else{
      CustomSnackBar().show(
          context: context,
          msg: 'No se pudo completar la operación!',
          icon: Icons.error_outline_outlined,
          color: const Color(0xffFF525C)
      );
    }
  }


 */
  setCustomerList() async {
    var query = await dbConnection.getData(
      onError: (e) {
        warningMsg(
            context: context,
            mainMsg: '¡Error!',
            msg: e,
            okBtnText: 'Aceptar',
            okBtn: () {
              Navigator.pop(context);
            });
      },
      context: context,
      table: 'users INNER JOIN role_user ON users.id = role_user.user_id ',
      fields: 'id, name',
      groupBy: 'id',
      order: 'ASC',
      orderBy: 'id',
      where: 'role_user.role_id = 3',
    );
    if(query.isNotEmpty) {
      for (var element in query) {
        customerList.add(User(
          id: int.parse(element['id']),
          name: element['name'],
        ));
        customerItems.add(element['name']);
      }
    }
    setState(() {});
  }

  setCashList() async {
      for (var element in await dbConnection.getData(
        onError: (e) {
          warningMsg(
              context: context,
              mainMsg: '¡Error!',
              msg: e,
              okBtnText: 'Aceptar',
              okBtn: () {
                Navigator.pop(context);
              });
        },
        context: context,
        table: 'cash_register ',
        fields: '*',
        groupBy: 'id',
        order: 'ASC',
        orderBy: 'id',
        where: '1',
      )) {
        cashList.add(CashRegister(
          id: int.parse(element['id']),
          number: int.parse(element['number']),
          user_id: int.parse(element['user_id']),
        ));
        cashItems.add(element['number']);
      }

      if (appData.getCash().id != null) {
        selectedCash = appData.getCash().number.toString();
      } else {
        selectedCash = 'Todo';
      }
      setState(() {});
    }

  @override
  void initState() {
    if(appData.getCompanyLogo()!=null){
      logo = appData.getCompanyLogo();
      logoStatus = 'loaded';
    }
    pageSizeController.text = '25';
    pFormat = PdfPageFormat.roll80;
    invoiceTypeDropdownItems.addAll(
        [
          CoolDropdownItem<String>(label: "Consumidor final", value: 'final_consumer'),
          CoolDropdownItem<String>(label: "Valor fiscal", value: 'tax_value'),
          CoolDropdownItem<String>(label: "Regimen especial", value: 'special_regime'),
        ]
    );
    orderTypeDropdownItems.addAll(
        [
          CoolDropdownItem<String>(label: "Delivery", value: 'delivery'),
          CoolDropdownItem<String>(label: "Recoger", value: 'takeout'),
          CoolDropdownItem<String>(label: "Local", value: 'store'),
        ]
    );
    paymentWayDropdownItems.addAll(
        [
          CoolDropdownItem<String>(label: "Contado", value: 'cash'),
          CoolDropdownItem<String>(label: "Crédito", value: 'credit'),
          //CoolDropdownItem<String>(label: "Parcial", value: 'partial'),
        ]
    );
    paymentMethodDropdownItems.addAll(
        [
          CoolDropdownItem<String>(label: "Efectivo", value: 'cash'),
          CoolDropdownItem<String>(label: "Tarjeta", value: 'card'),
          CoolDropdownItem<String>(label: "Transferencia", value: 'transfer'),
          //CoolDropdownItem<String>(label: "Mixto", value: 'mixed'),
        ]
    );

    super.initState();
  }

  showWarning(String title, String msg) {
    warningMsg(
        context: context,
        mainMsg: title,
        msg: msg,
        okBtnText: 'Aceptar',
        okBtn: () {
          Navigator.pop(context);
        });
  }

  showNotification(String msg, IconData icon, Color color) {
    CustomSnackBar().show(context: context, msg: msg, icon: icon, color: color);
  }

  Future<void> _fetchResults() async {
    setState(() {
      _loading = true;
    });

    // Consulta real a la base de datos
    salesHistoryData = await getSalesHistory(false,_currentPage,_pageSize);

    setState(() {
      _loading = false;
    });
  }


  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _fetchResults();
    }
  }

  void _nextPage() {
    if (_currentPage < (_totalRegs / _pageSize).ceil()) {
      setState(() {
        _currentPage++;
      });
      _fetchResults();
    }
  }

  getSalesHistory(bool toExport,int currentPage, int pageSize) async {
    var query = await dbConnection.getData(
      onError: (e){},
      context: context,
      fields: '''
      i.*,
             cc.number, 
             u.name AS 'user_name', 
             c.name AS 'customer_name', 
             c.mobile AS 'customer_phone', 
             COALESCE((SELECT SUM(total_amount) 
              FROM invoice 
              WHERE (invoice_number LIKE '%${searchController.text}%' OR ncf LIKE '%${searchController.text}%') 
                AND customer_id LIKE '%${selectedCustomer != 'Todo' ? customerList[customerItems.indexOf(selectedCustomer!) - 1].id : ''}%' 
                AND DATE(date_time) BETWEEN '${fechaInicio}' AND '${fechaFin}' 
                ${selectedCash!= 'Todo'?'AND cash_id = ${cashList.firstWhere((element) => element.number.toString() == selectedCash.toString(),).id}':''} 
                AND payment_way LIKE '%${selectedPaymentWay == 'Credito' ? 'credit' : selectedPaymentWay == 'Contado' ? 'cash' : ''}%'
                AND payment_method LIKE '%${selectedPaymentMethod == 'Efectivo' ? 'cash' : selectedPaymentMethod == 'Tarjeta' ? 'card' : selectedPaymentMethod == 'Transferencia' ? 'transfer' : selectedPaymentMethod == 'Depósito' ? 'deposit' : selectedPaymentMethod == 'Cheque' ? 'check' : ''}%'
                AND invoice_status = 'normal'
             ),0) AS total_sales_amount, 
             (SELECT COUNT(id) 
              FROM invoice 
              WHERE (invoice_number LIKE '%${searchController.text}%' OR ncf LIKE '%${searchController.text}%') 
                AND customer_id LIKE '%${selectedCustomer != 'Todo' ? customerList[customerItems.indexOf(selectedCustomer!) - 1].id : ''}%' 
                AND DATE(date_time) BETWEEN '${fechaInicio}' AND '${fechaFin}' 
                ${selectedCash!= 'Todo'?'AND cash_id = ${cashList.firstWhere((element) => element.number.toString() == selectedCash.toString(),).id}':''} 
                AND payment_way LIKE '%${selectedPaymentWay == 'Credito' ? 'credit' : selectedPaymentWay == 'Contado' ? 'cash' : ''}%'
                AND payment_method LIKE '%${selectedPaymentMethod == 'Efectivo' ? 'cash' : selectedPaymentMethod == 'Tarjeta' ? 'card' : selectedPaymentMethod == 'Transferencia' ? 'transfer' : selectedPaymentMethod == 'Depósito' ? 'deposit' : selectedPaymentMethod == 'Cheque' ? 'check' : ''}%'
               ) AS total_regs
      ''',
      table: '''
       invoice i 
          INNER JOIN cash_register cc ON cash_id = cc.id 
          INNER JOIN users u ON u.id = i.user_id 
          INNER JOIN users c ON c.id = i.customer_id 
      ''',
      where: selectedPosWay=='sale'? '''
      (i.invoice_number LIKE '%${searchController.text}%' OR i.ncf LIKE '%${searchController.text}%') 
            AND i.customer_id LIKE '%${selectedCustomer != 'Todo' ? customerList[customerItems.indexOf(selectedCustomer!) - 1].id : ''}%' 
            AND DATE(i.date_time) BETWEEN '${fechaInicio}' AND '${fechaFin}' 
      ''':'''
       (i.quote_number LIKE '%%') 
            AND i.customer_id LIKE '%%' 
            AND DATE(i.date_time) BETWEEN '${fechaInicio}' AND '${fechaFin}' 
      ''',
      groupBy: selectedPosWay == 'sale'? '''
      i.id HAVING ${selectedCash!= 'Todo'?'cash_id = ${cashList.firstWhere((element) => element.number.toString() == selectedCash.toString(),).id} AND':''} i.payment_way LIKE '%${selectedPaymentWay == 'Credito' ? 'credit' : selectedPaymentWay == 'Contado' ? 'cash' : ''}%' 
        AND payment_method LIKE '%${selectedPaymentMethod == 'Efectivo' ? 'cash' : selectedPaymentMethod == 'Tarjeta' ? 'card' : selectedPaymentMethod == 'Transferencia' ? 'transfer' : selectedPaymentMethod == 'Depósito' ? 'deposit' : selectedPaymentMethod == 'Cheque' ? 'check' : ''}%'
               ''':' i.id ',
      orderBy: '''
       $orderBy 
      ''',
      order: ' $order LIMIT $pageSize OFFSET ${(currentPage - 1) * pageSize}'
    );
    if(toExport) {
      for(var item in query) {
        salesHistoryDataToExport.add(item);
      }
    }else{
      setState(() {
        query.isNotEmpty
            ? totalSalesAmount =
            double.parse(query[0]['total_sales_amount'].toString())
            : totalSalesAmount = 0.0;
        query.isNotEmpty ?
        _totalRegs = int.parse(query[0]['total_regs'].toString()) : _totalRegs =
        0;
        salesHistoryData = query;
      });
    }
  }
  Widget infoData(
      String label, Widget body, CrossAxisAlignment? crossAxisAlignment) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        texto(
          text: label,
          size: responsiveApp.setSP(10),
        ),
        body,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    dbConnection = BDConnection(context: context);
    return SafeArea(
      child: Scaffold(
        body: Builder(
          builder: (context) {
            if(cashItems.length==1){
              setCashList();
              return const Center(child: CircularProgressIndicator(),);
            }else {
              if(customerItems.length==1){
                setCustomerList();
                return const Center(child: CircularProgressIndicator(),);
              }else {

                return Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal,child: periodo())),
                                  Container(
                                    height: responsiveApp.setHeight(40),
                                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.10),
                                        borderRadius:
                                        BorderRadius.circular(responsiveApp.setWidth(8))),
                                    child: Center(child: quotationOrSale()),
                                  ),
                                  if(!isMobile(context))
                                    SizedBox(width: responsiveApp.setWidth(10),),
                                  if(!isMobile(context))
                                  Row(
                                    children: [
                                      infoData(
                                          'Total ventas',
                                          Text('\$${numberFormat.format(
                                              totalSalesAmount)}',
                                            textAlign: TextAlign.center,
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .titleLarge!.copyWith(fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                                          ),
                                          CrossAxisAlignment.center),
                                      const SizedBox(width: 15,),
                                      infoData(
                                          'Exportar a excell',
                                          InkWell(
                                              onTap: ()async{
                                                loadingDialog(context);
                                                int regs=_totalRegs;
                                                int page=0;
                                                int pageSize=50;
                                                int totalPages=(regs / pageSize).ceil();
                                                salesHistoryDataToExport.clear();

                                                for(page;page<totalPages;page++){
                                                  getSalesHistory(true,page+1,pageSize);
                                                }
                                                await Future.delayed(Duration(seconds: 3)); // Simulación de una operación asíncrona

                                                if(salesHistoryDataToExport.length==regs) {
                                                  Navigator.pop(context);
                                                  exportToExcel(context, salesHistoryDataToExport);
                                                }
                                              },
                                              child: SvgPicture.asset('assets/svg/excel_icon.svg',
                                                width: 30,
                                              )
                                          ),
                                          CrossAxisAlignment.center),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if(isMobile(context))
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                infoData(
                                    'Total ventas',
                                    Text('\$${numberFormat.format(
                                        totalSalesAmount)}',
                                      textAlign: TextAlign.center,
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleLarge!.copyWith(fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                                    ),
                                    CrossAxisAlignment.center),
                                const SizedBox(width: 15,),
                                infoData(
                                    'Exportar a excell',
                                    InkWell(
                                        onTap: ()async{
                                          loadingDialog(context);
                                          int regs=_totalRegs;
                                          int page=0;
                                          int pageSize=50;
                                          int totalPages=(regs / pageSize).ceil();
                                          salesHistoryDataToExport.clear();

                                          for(page;page<totalPages;page++){
                                            getSalesHistory(true,page+1,pageSize);
                                          }
                                          await Future.delayed(Duration(seconds: 3)); // Simulación de una operación asíncrona


                                          if(salesHistoryDataToExport.length==regs) {
                                            Navigator.pop(context);
                                            exportToExcel(context, salesHistoryDataToExport);
                                          }
                                        },
                                        child: SvgPicture.asset('assets/svg/excel_icon.svg',
                                          width: 30,
                                        )
                                    ),
                                    CrossAxisAlignment.center),
                              ],
                            ),
                            users(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
          }
        ),
      ),
    );
  }

  Widget users(){
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                  color: Theme.of(context).cardColor,
                  boxShadow: const  [
                    BoxShadow(
                      spreadRadius: -7,
                      blurRadius: 8,
                      offset: Offset(0,0),
                    )
                  ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HeaderSearchBar(
                          width: responsiveApp.setWidth(280),
                          controller: searchController,
                          onChange: (v){
                            setState((){
                              searchController.text=v;
                              salesHistoryData=null;
                            });
                          },
                          onSearchPressed: (){
                            setState(() {});
                          },
                          suffix: InkWell(
                            onTap: (){
                              setState(() {
                                searchController.text = '';
                                salesHistoryData=null;
                              });
                            },
                            child: searchController.text != ''? Icon(Icons.cancel, color: Colors.grey.withValues(alpha: 0.5),):const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                              orderBy = 'i.`date_time`';
                              order= order == 'ASC'?'DESC':'ASC';
                              salesHistoryData=null;
                            });
                          },
                          child: SizedBox(width: responsiveApp.setWidth(100),
                            child: Row(
                              children: [
                                Expanded(
                                  child: texto(
                                    text: 'Fecha',
                                  ),
                                ),
                                Icon(orderBy=='i.`date_time`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
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
                          InkWell(
                            onTap: (){
                              setState(() {
                                orderBy = 'i.`invoice_number`';
                                order= order == 'ASC'?'DESC':'ASC';
                                salesHistoryData=null;
                              });
                            },
                            child: SizedBox(width: responsiveApp.setWidth(100),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: texto(
                                      text: 'Num. Fact.',
                                    ),
                                  ),
                                  Icon(orderBy=='i.`invoice_number`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                                ],
                              ),
                            ),
                          ),
                        if(!isMobile(context) && isLandscape(context) && selectedPosWay=='quotation')
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withValues(alpha: 0.3),),
                        ),
                        if(!isMobile(context) && isLandscape(context) && selectedPosWay=='quotation')
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  orderBy = 'i.`customer_name`';
                                  order= order == 'ASC'?'DESC':'ASC';
                                  salesHistoryData=null;
                                });
                              },
                              child: SizedBox(width: responsiveApp.setWidth(100),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: texto(
                                        text: 'Cliente',
                                      ),
                                    ),
                                    Icon(orderBy=='i.`customer_name`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                                  ],
                                ),
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
                              orderBy = 'i.`total_amount`';
                              order= order == 'ASC'?'DESC':'ASC';
                              salesHistoryData=null;
                            });
                          },
                          child: SizedBox(width: responsiveApp.setWidth(80),
                            child: Row(
                              children: [
                                Expanded(
                                  child: texto(
                                    text: 'Monto total',
                                  ),
                                ),
                                Icon(orderBy=='i.`total_amount`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                              ],
                            ),
                          ),
                        ),
                        if(!isMobile(context) && isLandscape(context) && selectedPosWay=='sale')
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withValues(alpha: 0.3),),
                        ),
                        if(!isMobile(context) && isLandscape(context) && selectedPosWay=='sale')
                        InkWell(
                          onTap: (){
                            setState(() {
                              orderBy = 'i.`payment_status`';
                              order= order == 'ASC'?'DESC':'ASC';
                              salesHistoryData=null;
                            });
                          },
                          child: SizedBox(width: responsiveApp.setWidth(80),
                            child: Row(
                              children: [
                                Expanded(
                                  child: texto(
                                    text: 'Estado de pago',
                                  ),
                                ),
                                Icon(orderBy=='i.`payment_status`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                              ],
                            ),
                          ),
                        ),
                        if(!isMobile(context)&& isLandscape(context))
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
                              orderBy = 'c.`number`';
                              order= order == 'ASC'?'DESC':'ASC';
                              salesHistoryData=null;
                            });
                          },
                          child: SizedBox(width: responsiveApp.setWidth(80),
                            child: Row(
                              children: [
                                Expanded(
                                  child: texto(
                                    text: 'Caja',
                                  ),
                                ),
                                Icon(orderBy=='c.`number`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                              ],
                            ),
                          ),
                        ),
                        if(!isMobile(context) && isLandscape(context) && selectedPosWay=='sale')
                        Padding(
                            padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                            child: Container(height: responsiveApp.setHeight(20),
                              width: responsiveApp.setWidth(1),
                              color: Colors.grey.withValues(alpha: 0.3),),
                          ),
                        if(!isMobile(context) && isLandscape(context) && selectedPosWay=='sale')
                        SizedBox(width: responsiveApp.setWidth(80),
                          child: texto(
                            text: 'Estado',
                            size: responsiveApp.setSP(12),
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
                  Row(
                    children: [
                      Expanded(
                        child: Builder(
                            builder: (BuildContext ctx) {
                              if (salesHistoryData == null) {
                                getSalesHistory(false,_currentPage,_pageSize);
                                return const Center(
                                  child: LinearProgressIndicator(backgroundColor: Colors.transparent,),
                                );
                              }else if(_loading){
                                return const Center(
                                  child: LinearProgressIndicator(backgroundColor: Colors.transparent,),
                                );
                              }else {
                                if (salesHistoryData.isNotEmpty) {
                                  return Column(
                                    children: List.generate(
                                      salesHistoryData.length,
                                          (index){
                                        return Column(
                                          children: [
                                            list(index),

                                              Row(
                                                children: [
                                                  Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withValues(alpha: 0.3),)),
                                                ],
                                              ),
                                            if(index==salesHistoryData.length-1)
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('Registros: $_totalRegs'),

                                                    SizedBox(
                                                      width: responsiveApp.setWidth(140),
                                                      child: Row(
                                                        children: [
                                                          Text('Visualizando: '),
                                                          Expanded(
                                                            child: customField(context: context, hintText: '25', keyboardType: TextInputType.number,
                                                                controller: pageSizeController,
                                                              onEditingComplete: (){
                                                              setState(() {
                                                                _pageSize=int.parse(pageSizeController.text);
                                                                salesHistoryData=null;
                                                              });
                                                              }
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: _currentPage > 1 ? _previousPage : null,
                                                      child: Text('< Anterior'),
                                                    ),
                                                    Text('Pagina: $_currentPage de ${(_totalRegs / _pageSize).ceil()}'),
                                                    ElevatedButton(
                                                      onPressed: _currentPage < (_totalRegs / _pageSize).ceil()?_nextPage:null,
                                                      child: Text('Siguiente >'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    )
                                );
                                } else {
                                  totalSalesAmount=0.0;
                                  return Padding(
                                  padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                                  child: Column(
                                      children: [
                                        Icon(Icons.file_copy_outlined, size: responsiveApp.setWidth(30),color: Colors.grey,),
                                        texto(text: 'No hay nada que mostrar', size: responsiveApp.setSP(14), color: Colors.grey),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Registros: $_totalRegs'),

                                            SizedBox(
                                              width: responsiveApp.setWidth(140),
                                              child: Row(
                                                children: [
                                                  Text('Visualizando: '),
                                                  Expanded(
                                                    child: customField(context: context, hintText: '25', keyboardType: TextInputType.number,
                                                        controller: pageSizeController,
                                                        onEditingComplete: (){
                                                          setState(() {
                                                            _pageSize=int.parse(pageSizeController.text);
                                                            salesHistoryData=null;
                                                          });
                                                        }
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: _currentPage > 1 ? _previousPage : null,
                                              child: Text('< Anterior'),
                                            ),
                                            Text('Pagina: $_currentPage de ${(_totalRegs / _pageSize).ceil()}'),
                                            ElevatedButton(
                                              onPressed: _currentPage < (_totalRegs / _pageSize).ceil()?_nextPage:null,
                                              child: Text('Siguiente >'),
                                            ),
                                          ],
                                        ),
                                      ]
                                  ),
                                );
                                }
                              }
                            }
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget list(int index){

    return ListTile(
      contentPadding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: responsiveApp.setHeight(3)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if(!isMobile(context))
            SizedBox(width: responsiveApp.setWidth(100),
              child: texto(
                  text: dateFormatOnlyDate.format(DateTime.parse(salesHistoryData[index]['date_time'])),
              ),
            ),
            if(!isMobile(context))
            Padding(
              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
              child: SizedBox(height: responsiveApp.setHeight(20),
                width: responsiveApp.setWidth(1),
              ),
            ),
              SizedBox(width: responsiveApp.setWidth(100),
                child: texto(
                    text: salesHistoryData[index][selectedPosWay=='sale'? 'invoice_number':'quote_number'],
                ),
              ),
            if(!isMobile(context) && isLandscape(context) && selectedPosWay=='quotation')
            Padding(
              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
              child: SizedBox(height: responsiveApp.setHeight(20),
                width: responsiveApp.setWidth(1),
              ),
            ),
            if(!isMobile(context) && isLandscape(context) && selectedPosWay=='quotation')
              Expanded(//width: responsiveApp.setWidth(100),
                child: texto(
                    text: salesHistoryData[index]['customer_name'],
                ),
              ),
            if(!isMobile(context))
            Padding(
              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
              child: SizedBox(height: responsiveApp.setHeight(20),
                width: responsiveApp.setWidth(1),
              ),
            ),
            if(!isMobile(context))
            SizedBox(width: responsiveApp.setWidth(80),
              child: texto(
                  text: numberFormat.format(double.parse(salesHistoryData[index]['total_amount'])),
              ),
            ),
            if(!isMobile(context) && isLandscape(context) && selectedPosWay=='sale')
            Padding(
              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
              child: SizedBox(height: responsiveApp.setHeight(20),
                width: responsiveApp.setWidth(1),
              ),
            ),
            if(!isMobile(context) && isLandscape(context) && selectedPosWay == 'sale')
            SizedBox(width: responsiveApp.setWidth(80),
              child: texto(
                  text: salesHistoryData[index]['payment_status'],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
              child: SizedBox(height: responsiveApp.setHeight(20),
                width: responsiveApp.setWidth(1),
              ),
            ),
            if(!isMobile(context) && isLandscape(context))
            SizedBox(width: responsiveApp.setWidth(80),
              child: texto(
                  text: salesHistoryData[index]['number'],
              ),
            ),
            if(!isMobile(context) && isLandscape(context) && selectedPosWay=='sale')
            Padding(
              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
              child: SizedBox(height: responsiveApp.setHeight(20),
                width: responsiveApp.setWidth(1),
              ),
            ),
            if(!isMobile(context) && isLandscape(context) && selectedPosWay=='sale')
              SizedBox(width: responsiveApp.setWidth(80),
                child: FocusedMenuHolder(
                  menuWidth: responsiveApp.setWidth(300),
                  blurSize: 5.0,
                  menuItemExtent: 45,
                  menuBoxDecoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  duration: const Duration(milliseconds: 100),
                  animateMenuItems: true,
                  blurBackgroundColor: Colors.black54,
                  bottomOffsetHeight: 100,
                  openWithTap: false,
                  menuItems: <FocusedMenuItem>[
                    if(salesHistoryData[index]['invoice_status']=='normal')
                    FocusedMenuItem(
                          backgroundColor: Theme.of(context).cardColor,
                          title: texto(text: 'Cancelar factura', size: responsiveApp.setSP(12), color: Colors.red),
                          trailingIcon: const Icon(Icons.cancel_rounded, color: Colors.red,),
                          onPressed: () {
                            warningMsg(
                                context: context,
                                icon: Icons.warning_rounded,
                                mainMsg: '¡Atencion!',
                                msg: '¿Esta seguro que desea cancelar esta factura?',
                                okBtnText: 'Aceptar',
                                //cancelBtnText: 'Cancelar',
                                okBtn: () async {
                                  Navigator.pop(context);


                                  validateAdmin(index);


                                },
                               // cancelBtn: (){
                              //    Navigator.pop(context);
                              //  }
                            );
                          }),
                  ],
                  onPressed: () {},
                  child: Container(
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    decoration: BoxDecoration(
                      color: salesHistoryData[index]['invoice_status']=='normal'?Colors.green.withValues(alpha: 0.2)
                          : salesHistoryData[index]['invoice_status']=='annulled'? Colors.orange.withValues(alpha: 0.2)
                          :  Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: texto(
                      text: salesHistoryData[index]['invoice_status']=='normal'?'Normal'
                          : salesHistoryData[index]['invoice_status']=='annulled'? 'Anulada'
                          :  'Cancelada',
                      color: salesHistoryData[index]['invoice_status']=='normal'?Colors.green
                          : salesHistoryData[index]['invoice_status']=='annulled'? Colors.orange
                          :  Colors.red,
                      alignment: TextAlign.center,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      onTap: () async{
        loadingDialog(context);
        selectedInvoice = salesHistoryData[index];
        await getInvoiceDetails();

        if (logoStatus == 'empty' || logoStatus == 'error') {
          setState(() {
            logoStatus = 'loading';
          });
          await loadImage();
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          sendDoc();
        }
      },
    );
  }

  getInvoiceDetails()async{

    var query = await dbConnection.getData(onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
        context: context,
        fields: '''
        i.invoice_id, 
        i.product_id, 
        p.type AS service_type, 
        p.name AS service_name, 
        i.price, 
        i.quantity, 
        i.tax, 
        i.total, 
        bi.id AS booking_item_id, 
        u.id AS employee_id, 
        u.name AS employee_name
        ''',
      table: '''
        invoice_detail i 
        INNER JOIN invoice inv ON i.invoice_id = inv.id 
        INNER JOIN bookings b ON inv.booking_id = b.id 
        INNER JOIN booking_items bi ON b.id = bi.booking_id AND i.product_id = bi.business_service_id 
        INNER JOIN business_services p ON i.product_id = p.id 
        INNER JOIN users u ON bi.chair_id = u.id 
      ''',
      where: ' i.invoice_id = ${selectedInvoice['id']} ',
      groupBy: 'i.product_id, u.name',
      orderBy: ' i.id ',
      order: 'ASC '
    );
    /*
    var query = await dbConnection.getDataOpen(onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
        context: context,
        query: 'SELECT i.invoice_id, i.product_id, p.name, um.unit, i.price, i.quantity, i.tax, i.total FROM invoice_detail i RIGHT JOIN product p ON i.product_id = p.id RIGHT JOIN unit_measure um ON p.unit = um.id '
            'WHERE i.invoice_id = ${selectedInvoice['id']} GROUP BY i.product_id');


     */
      invoiceDetails = query;
      invoiceDetailList = List.from(query.map((e) => InvoiceDetail(
        total: double.parse(e['total'].toString()),
        invoice_id: int.parse(e['invoice_id'].toString()),
        price: double.parse(e['price'].toString()),
        quantity: double.parse(e['quantity'].toString()),
        tax: double.parse(e['tax'].toString()),
          booking_item_id: int.parse(e['booking_item_id'].toString()),
        employee: User(
          id : int.parse(e['employee_id'].toString()),
          name : e['employee_name'].toString()
        ),
        service: Service(
          id: int.parse(e['product_id']),
          name: e['service_name'],
          type: e['service_type'],
          price: double.parse(e['price'].toString()).toString(),

        )
      )));

  }

  validateAdmin(int invoiceIndex){
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
                                                                     // adminId= int.parse(snapshot.data[index]['user_id'].toString());

                                                                      Navigator.pop(context);
                                                                      Navigator.pop(context);
                                                                      Navigator.pop(context);

                                                                      if(await  dbConnection.updateInvoiceStatus(onError: (onError){}, id: int.parse(salesHistoryData[invoiceIndex]['id']), status: 'canceled')) {
                                                                        adminPasswordController.text = '';
                                                                        _fetchResults();
                                                                        CustomSnackBar().show(
                                                                            color: Colors.green,
                                                                            context: context,
                                                                            icon: Icons.check_circle,
                                                                            msg: 'Operacion realizada con exito!'
                                                                        );
                                                                      }else{
                                                                        CustomSnackBar().show(
                                                                            color: Colors.red,
                                                                            context: context,
                                                                            icon: Icons.error,
                                                                            msg: 'Error al intentar realizar la operacion.'
                                                                        );
                                                                      }
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

  Widget actionButton({required String name, required IconData icon,required Color color,required VoidCallback onTap}){
    return Column(
      children: [
        InkWell(
            onTap: onTap,
            child: Container(
                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(10)),
                ),
                child: Icon(icon, color: Colors.white,)
            )
        ),
        SizedBox(height: name!=''?responsiveApp.setHeight(3):0,),
        name!=''?texto(text: name, size: responsiveApp.setSP(10)):const SizedBox(),

      ],
    );
  }

  Widget quotationOrSale() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.horizontal,
          spacing: 8.0, // espacio entre los widgets
          runSpacing: 8.0, // espacio entre líneas
          children: [
            AnimatedContainer(
              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
              decoration: BoxDecoration(
                color: selectedPosWay == 'sale'
                    ? const Color(0xff6C9BD2)
                    : Colors.transparent,
                borderRadius:
                BorderRadius.circular(responsiveApp.setWidth(50)),
              ),
              duration: const Duration(milliseconds: 300),
              child: InkWell(
                onTap:(){
                  selectedPosWay = "sale";
                  _fetchResults();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    texto(
                      text: " Venta",
                      size: responsiveApp.setSP(12),
                      color:
                      selectedPosWay == 'sale' ? Colors.white : null,
                    ),
                    if(selectedPosWay == 'sale')
                      SizedBox(
                        width: responsiveApp.setWidth(5),
                      )
                  ],
                ),
              ),
            ),

            AnimatedContainer(
              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
              decoration: BoxDecoration(
                color: selectedPosWay == 'quotation'
                    ? const Color(0xff6C9BD2)
                    : Colors.transparent,
                borderRadius:
                BorderRadius.circular(responsiveApp.setWidth(50)),
              ),
              duration: const Duration(milliseconds: 300),
              child: InkWell(
                onTap:(){
                  selectedPosWay = "quotation";
                  _fetchResults();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    texto(
                      text: " Cotización",
                      size: responsiveApp.setSP(12),
                      color:
                      selectedPosWay == 'quotation' ? Colors.white : null,
                    ),
                    if(selectedPosWay == 'quotation')
                      SizedBox(
                        width: responsiveApp.setWidth(5),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget periodo(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Período',
                  style: TextStyle(
                    //color: Colors.black.withValues(alpha: 0.7),
                    fontSize: responsiveApp.setSP(12),
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                  ),),
                SizedBox(height: responsiveApp.setHeight(5),),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(10), vertical: responsiveApp.setHeight(1)),
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),

                  // dropdown below..
                  child: DropdownButton<String>(
                    value: selectedValue,
                    onChanged: (newValue) {
                      setState((){
                        selectedValue = newValue.toString();
                        fechaInicio = newValue.toString()=='Hoy'?DateTime.now().subtract(Duration(hours: DateTime.now().hour,minutes: DateTime.now().minute,seconds: DateTime.now().second)).toString().split(".")[0]
                            :newValue.toString()=='Ayer'?DateTime(DateTime.now().year,DateTime.now().month,(DateTime.now().day-1)).toString().split('.')[0]
                            :newValue.toString()=='Esta semana'?DateTime(DateTime.now().year,DateTime.now().month,(DateTime.now().day-DateTime.now().weekday)+1).toString().split('.')[0]
                            :newValue.toString()=='Este mes'?DateTime(DateTime.now().year,DateTime.now().month,1).toString().split('.')[0]
                            :newValue.toString()=='Mes anterior'?DateTime(DateTime.now().year,DateTime.now().month-1,1).toString().split('.')[0]
                            :DateTime.now().subtract(const Duration(hours: 24 * 30)).toString();
                        fechaFin =
                        newValue.toString()=='Ayer'?DateTime(DateTime.now().year,DateTime.now().month,(DateTime.now().day-1)).toString().split('.')[0]
                            :newValue.toString()=='Mes anterior'?DateTime(DateTime.now().year,DateTime.now().month-1,daysInMonth(DateTime.now().month-1),23,59,59).toString().split('.')[0]
                            :"${DateTime.now().year.toString()}-${DateTime.now().month
                            .toString().padLeft(2, '0')}-${DateTime.now().day
                            .toString().padLeft(2, '0')} 23:59:59";
                      });
                      salesHistoryData=null;
                      firstTime = true;
                    },
                    items: items
                        .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                        .toList(),

                    // add extra sugar..
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    iconSize: 42,
                    underline: const SizedBox(),
                  ),
                ),
              ],
            ),
            if(!isMobile(context))
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(selectedValue=='Rango de fecha')
                        const Text('Desde'),
                      if(selectedValue=='Rango de fecha')
                        SizedBox(height: responsiveApp.setHeight(5),),
                      if(selectedValue=='Rango de fecha')
                        InkWell(
                          canRequestFocus: false,
                          onTap: (){
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate:
                              DateTime.now().subtract(const Duration(hours: 24 * 365)),
                              lastDate: DateTime.now(),
                            ).then((newDate) {
                              if (newDate != null) {
                                setState(() {
                                  fechaInicio = "${newDate.year.toString()}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')} 00:00:00";
                                  salesHistoryData=null;
                                  firstTime = true;
                                });
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(8), vertical: responsiveApp.setHeight(10)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.withValues(alpha: 0.1),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  //color: const Color(0xff000000).withValues(alpha: 0.8),
                                ),
                                SizedBox(width: responsiveApp.setHeight(8),),
                                Text(dateFormatOnlyDate.format(DateTime.parse(fechaInicio))),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if(selectedValue=='Rango de fecha')
                    SizedBox(width: responsiveApp.setWidth(8),),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(selectedValue=='Rango de fecha')
                        const Text('Hasta'),
                      if(selectedValue=='Rango de fecha')
                        SizedBox(height: responsiveApp.setHeight(5),),
                      if(selectedValue=='Rango de fecha')
                        InkWell(
                          canRequestFocus: false,
                          onTap: (){
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate:
                              DateTime.now().subtract(const Duration(hours: 24 * 365)),
                              lastDate: DateTime.now(),
                            ).then((newDate) {
                              if (newDate != null) {
                                setState(() {
                                  if(newDate.isBefore(DateTime.parse(fechaInicio)) ) {
                                    CustomSnackBar().show(
                                        context: context,
                                        msg: "Por favor seleccione un rango de fecha válido",
                                        icon: Icons.warning_rounded,
                                        color: const Color(0xffffc44e)
                                    );
                                  }else{
                                    fechaFin =
                                    "${newDate.year.toString()}-${newDate.month
                                        .toString().padLeft(2, '0')}-${newDate.day
                                        .toString().padLeft(2, '0')} 23:59:59";
                                    salesHistoryData=null;
                                    firstTime = true;
                                  }
                                });
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(8), vertical: responsiveApp.setHeight(10)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.withValues(alpha: 0.1),

                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  //color: const Color(0xff000000).withValues(alpha: 0.8),
                                ),
                                SizedBox(width: responsiveApp.setHeight(10),),
                                Text(dateFormatOnlyDate.format(DateTime.parse(fechaFin))),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            if(!isMobile(context)  && appData.getUserData().rol_id! == 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Caja',
                  style: TextStyle(
                    //color: Colors.black.withValues(alpha: 0.7),
                    fontSize: responsiveApp.setSP(12),
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                  ),),
                SizedBox(height: responsiveApp.setHeight(5),),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(10), vertical: responsiveApp.setHeight(1)),
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),

                  // dropdown below..
                  child: DropdownButton<String>(
                    value: selectedCash,
                    onChanged: (newValue) {
                      setState((){
                        selectedCash = newValue.toString();
                        salesHistoryData=null;
                      });
                    },
                    items: cashItems
                        .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                        .toList(),

                    // add extra sugar..
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    iconSize: 42,
                    underline: const SizedBox(),
                  ),
                ),
              ],
            ),
            if(!isMobile(context))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Método de pago',
                    style: TextStyle(
                      //color: Colors.black.withValues(alpha: 0.7),
                      fontSize: responsiveApp.setSP(12),
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                    ),),
                  SizedBox(height: responsiveApp.setHeight(5),),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(10), vertical: responsiveApp.setHeight(1)),
                    decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),

                    // dropdown below..
                    child: DropdownButton<String>(
                      value: selectedPaymentMethod,
                      onChanged: (newValue) {
                        setState((){
                          selectedPaymentMethod = newValue.toString();
                          salesHistoryData=null;
                        });
                      },
                      items:paymentMethodItems
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                          .toList(),

                      // add extra sugar..
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      iconSize: 42,
                      underline: const SizedBox(),
                    ),
                  ),
                ],
              ),
          if(!isMobile(context))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente',
                    style: TextStyle(
                      //color: Colors.black.withValues(alpha: 0.7),
                      fontSize: responsiveApp.setSP(12),
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                    ),),
                  SizedBox(height: responsiveApp.setHeight(5),),
                  SizedBox(
                    width: responsiveApp.setWidth(120),
                    // dropdown below..
                    child: customDropDown(
                      context: context,
                      searchController: searchCustomerController,
                      value: selectedCustomer,
                      items: customerItems,
                      onChanged: (newValue) {
                        setState((){
                          selectedCustomer = newValue.toString();
                          salesHistoryData=null;
                        });
                      },
                      searchInnerWidgetHeight: responsiveApp.setHeight(200)
                    ),
                  ),
                ],
              ),
          ],
        ),
        if(isMobile(context)&&selectedValue=='Rango de fecha')
          SizedBox(height: responsiveApp.setHeight(8),),
        if(isMobile(context))
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if(selectedValue=='Rango de fecha')
                    const Text('Desde'),
                  if(selectedValue=='Rango de fecha')
                    SizedBox(height: responsiveApp.setHeight(3),),
                  if(selectedValue=='Rango de fecha')
                    InkWell(
                      canRequestFocus: false,
                      onTap: (){
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate:
                          DateTime.now().subtract(const Duration(hours: 24 * 365)),
                          lastDate: DateTime.now(),
                        ).then((newDate) {
                          if (newDate != null) {
                            setState(() {
                              fechaInicio = "${newDate.year.toString()}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')} 00:00:00";
                              salesHistoryData=null;
                              firstTime = true;
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(8), vertical: responsiveApp.setHeight(10)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.withValues(alpha: 0.1),

                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              //color:const Color(0xff000000).withValues(alpha: 0.8),
                            ),
                            SizedBox(width: responsiveApp.setWidth(8),),
                            Text(dateFormatOnlyDate.format(DateTime.parse(fechaInicio))),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if(selectedValue=='Rango de fecha')
                SizedBox(width: responsiveApp.setWidth(8),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(selectedValue=='Rango de fecha')
                    const Text('Hasta'),
                  if(selectedValue=='Rango de fecha')
                    SizedBox(height: responsiveApp.setHeight(3),),
                  if(selectedValue=='Rango de fecha')
                    InkWell(
                      canRequestFocus: false,
                      onTap: (){
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate:
                          DateTime.now().subtract(const Duration(hours: 24 * 365)),
                          lastDate: DateTime.now(),
                        ).then((newDate) {
                          if (newDate != null) {
                            setState(() {
                              if(newDate.isBefore(DateTime.parse(fechaInicio)) ) {
                                CustomSnackBar().show(
                                    context: context,
                                    msg: "Por favor seleccione un rango de fecha válido",
                                    icon: Icons.warning_rounded,
                                    color:const Color(0xffffc44e)
                                );
                              }else{
                                fechaFin =
                                "${newDate.year.toString()}-${newDate.month
                                    .toString().padLeft(2, '0')}-${newDate.day
                                    .toString().padLeft(2, '0')} 23:59:59";
                                salesHistoryData=null;
                                firstTime = true;
                              }
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(8), vertical: responsiveApp.setHeight(10)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          color: Colors.grey.withValues(alpha: 0.1),

                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              //color: const Color(0xff000000).withValues(alpha: 0.8),
                            ),
                            SizedBox(width: responsiveApp.setHeight(8),),
                            Text(dateFormatOnlyDate.format(DateTime.parse(fechaFin))),
                          ],
                        ),
                      ),
                    ),

                ],
              ),
            ],
          ),
        if(isMobile(context) && appData.getUserData().level!.id == 1)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Caja',
              style: TextStyle(
                //color: Colors.black.withValues(alpha: 0.7),
                fontSize: responsiveApp.setSP(12),
                fontFamily: "Montserrat",
                fontWeight: FontWeight.bold,
              ),),
            SizedBox(height: responsiveApp.setHeight(5),),
            Container(
              padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(10), vertical: responsiveApp.setHeight(1)),
              decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),

              // dropdown below..
              child: DropdownButton<String>(
                value: selectedCash,
                onChanged: (newValue) {
                  setState((){
                    selectedCash = newValue.toString();
                    salesHistoryData=null;
                  });
                },
                items: cashItems
                    .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                    .toList(),

                // add extra sugar..
                icon: const Icon(Icons.arrow_drop_down_rounded),
                iconSize: 42,
                underline: const SizedBox(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  sendDoc() async {
    var profile = await CapabilityProfile.load();
    var paper = PaperSize.mm80;
    List<int> bytes = [];
    var generator =  Generator(paper, profile);
    List<pw.Widget> ticketAndReceipt= [];
    ticketAndReceipt = List.from(ticketData());
    ticketAndReceipt.add(pruebaVisFact());
    var printer = PrinterWidget(fact:ticketAndReceipt,pageFormat: PdfPageFormat.roll80,
        onPageChanged: (format){
          setState(() {

          });
        },
        printAction:null
    );

    viewWidget(context,
        printer.pdfPreview(context,
            [
              IconButton(
                  onPressed: (){
                    printer.sendJobToPrinter(testReceipt(bytes, generator));
                    },
                  icon: Icon(Icons.receipt_long_rounded, color: Colors.white,)
              ),
              IconButton(
                  onPressed: (){
                    printer.sendJobToPrinter(ticketReceipt(bytes, generator));
                  },
                  icon: Icon(Icons.receipt_sharp, color: Colors.white,)
              ),
            ]
        ), (){Navigator.pop(context);});

    /*
    if(appData.getAutoPrintEnabled()){
      await printer.sendPrintJob(testReceipt(bytes, generator, profile));
      limpiar();
    }else{
      await printer.printPDF();
      limpiar();
    }
     */
    // ).sendPrintJob(testReceipt(bytes, generator, profile));
    /*
    viewWidget(context, PrinterWidget(fact: [pruebaVisFact()],pageFormat: PdfPageFormat.roll80,
      onPageChanged: (format){
        setState(() {

        });
      },
      printAction:null
          /*
          IconButton(
          onPressed: (){
            /*
            if (printerStatus == 'connected') {
              testTicket();
            } else if (printerStatus == 'disconnected') {
              setState(() {
                printerStatus = 'loading';
              });
              testTicket();
            } else if (printerStatus == 'error') {
              showPrinterWarning();
            }

             */
          },
          icon: printerStatus == 'loading'
              ? SizedBox(
              width: responsiveApp.setWidth(15),
              height: responsiveApp.setWidth(15),
              child: const CircularProgressIndicator(
                color: Colors.white,
              ))
              : const Icon(Icons.print_rounded, color: Colors.white,)
      ),
           */
    ), () {
      limpiar();
      Navigator.pop(context);
    });
    limpiar();

     */
  }

  Future loadImage() async {
    try {
      logo = appData.getCompanyData().logo != 'null'&&appData.getCompanyData().logo != null
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
    return pw.Column(
        mainAxisSize: pw.MainAxisSize.max,
        children: [
          invoiceData(),
          pw.SizedBox(height: 30),
          /*
          if(selectedPosWay =='sale')
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.SizedBox(width: 150,child: pw.Divider()),
              ],
            ),
          if(selectedPosWay =='sale')
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(pFormat == PdfPageFormat.a4? 'Recibido por, firma y sello':'Firma cliente',style: pw.TextStyle(fontSize: 9)),
              ],
            ),

           */
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('** Original **',style: pw.TextStyle(fontSize: 9)),
            ],
          ),

          pw.SizedBox(height: 10),
        ]
    );
  }

  ticketReceipt(List<int> bytes, Generator printer) {
    bytes += printer.setGlobalCodeTable('CP1252');

    Map<int, Map<String, dynamic>> resumen = {};

    if(invoiceDetailList.any((e)=>e.service!.type=='service')) {
      List<InvoiceDetail> bList = [];

      // SELECT MAX(id) as lastId FROM invoice_details
      for (var item in invoiceDetailList) {
        if (item.service!.type == 'service') {
          bList.add(item);
        }
      }

      for (var item in bList) {
        if (!resumen.containsKey(item.employee!.id)) {
          resumen[item.employee!.id!] = {
            'employee_name': item.employee!.name,
            'services': <int, int>{},
          };
        }

        var services = resumen[item.employee!.id]!['services'] as Map<int, int>;

        if (services.containsKey(item.service!.id!)) {
          services[item.service!.id!] = item.booking_item_id!;
        } else {
          services[item.service!.id!] = item.booking_item_id!;
        }
      }

      resumen.forEach((chairId, data) {
        bytes += printer.row([
          PosColumn(
            text: '${appData
                .getCompanyData()
                .company_name}',
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
            text: '${appData
                .getCompanyData()
                .address}',
            width: 12,
            styles: const PosStyles(align: PosAlign.center, underline: false),
          ),
        ]);
        bytes += printer.row([
          PosColumn(
            text: "${appData
                .getCompanyData()
                .company_phone
                .replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'), (
                Match m) => "(${m[1]}) ${m[2]}-${m[3]}")}",
            width: 12,
            styles: const PosStyles(align: PosAlign.center, underline: false),
          ),
        ]);

        bytes += printer.feed(1);

        bytes += printer.row([
          PosColumn(
            text: 'Fecha:',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: dateFormat.format(DateTime.parse(selectedInvoice['date_time'])),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);
        bytes += printer.row([
          PosColumn(
            text: 'Cliente:',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: selectedInvoice['customer_name'],
            width: 6,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);
        bytes += printer.row([
          PosColumn(
            text: 'Le atendio:',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: selectedInvoice['user_name'],
            width: 6,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);
        bytes += printer.row([
          PosColumn(
            text: 'Serivio a nombre de:',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: data['employee_name'],
            width: 6,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);

        bytes += printer.row([
          PosColumn(
            text: 'Factura referencia:',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: selectedInvoice['invoice_number'],
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
            text: 'Ticket de servicio',
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
            text: '#',
            width: 2,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: 'DESCRIPCION',
            width: 5,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: 'CAN',
            width: 2,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
          PosColumn(
            text: 'TOTAL',
            width: 3,
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
        double totalEmployee = 0;
        (data['services'] as Map<int, int>).forEach((serviceId, itemServiceId) {

          bytes += printer.row([
            PosColumn(
              text: itemServiceId.toString(),
              width: 2,
              styles: const PosStyles(align: PosAlign.left, underline: false),
            ),
            PosColumn(
              text: invoiceDetailList
                  .firstWhere((e) => e.service!.id == serviceId)
                  .service!.name!
                  .toString(),
              width: 5,
              styles: const PosStyles(align: PosAlign.left, underline: false),
            ),
            PosColumn(
              text: invoiceDetailList
                  .firstWhere((e) => e.service!.id == serviceId && e.employee!.id == chairId)
                  .quantity!
                  .toString(),
              width: 2,
              styles: const PosStyles(align: PosAlign.right, underline: false),
            ),
            PosColumn(
              text: "\$${invoiceDetailList.firstWhere((e) => e.service!.id == serviceId && e.employee!.id == chairId).total!.toString()}",
              width: 3,
              styles: const PosStyles(align: PosAlign.right, underline: false),
            ),
          ]);
          totalEmployee += invoiceDetailList.firstWhere((e) => e.service!.id == serviceId && e.employee!.id == chairId).total!;
        });

        bytes += printer.row([
          PosColumn(
            text: '-----------------------------------------------',
            width: 12,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
        ]);
        bytes += printer.row([
          PosColumn(
            text: 'TOTAL RD\$:',
            width: 9,
            styles: const PosStyles(
                align: PosAlign.right,
                width: PosTextSize.size1,
                height: PosTextSize.size1, bold: true, underline: false),
          ),
          PosColumn(
            text: numberFormat.format(totalEmployee.roundToDouble()),
            width: 3,
            styles: const PosStyles(
                align: PosAlign.right,
                width: PosTextSize.size1,
                height: PosTextSize.size1,
                bold: true,
                underline: false),
          ),
        ]);
        //data['services'].fold(0,(a,b)=>a+b[b.keys]);
        bytes += printer.cut();

      });
    }

    return bytes;
  }

  testReceipt(List<int> bytes, var printer) {
    bytes += printer.setGlobalCodeTable('CP1252');
    //  bytes += printer.setGlobalCodeTable('CP437');
// 1. Decodificar logo desde Uint8List

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
        text: "${appData.getCompanyData().company_phone.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'), (Match m) => "(${m[1]}) ${m[2]}-${m[3]}")}",
        width: 12,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
    ]);

    bytes += printer.feed(1);

     bytes += printer.row([
      PosColumn(
        text: 'Fecha:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: dateFormat.format(DateTime.parse(selectedInvoice['date_time'])),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Factura:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: selectedInvoice['invoice_number'],
        width: 6,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Cliente:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: selectedInvoice['customer_name'],
        width: 6,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Le atendio:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: selectedInvoice['user_name'],
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
        text: 'Factura para consumidor final',
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
        text: 'DESCRIPCION',
        width: 8,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: 'ITBIS',
        width: 2,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
      PosColumn(
        text: 'TOTAL',
        width: 2,
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
    for (var i = 0; i < invoiceDetailList.length; i++) {
      bytes += printer.row([
        PosColumn(
          text: "${invoiceDetailList[i].service!.name!} ${invoiceDetailList[i].service!.type=="service"? "(${invoiceDetailList[i].employee!.name!})":""} x ${invoiceDetailList[i].quantity!}",
          width: 8,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: numberFormat.format(invoiceDetailList[i].tax).toString(),
          width: 2,
          styles: const PosStyles(align: PosAlign.center, underline: false),
        ),
        PosColumn(
          text: numberFormat.format(invoiceDetailList[i].total).toString(),
          width: 2,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);
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
        text: 'Subtotal:',
        width: 9,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
      PosColumn(
        text: numberFormat.format(double.parse(selectedInvoice['subtotal'])),
        width: 3,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Descuento:',
        width: 9,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
      PosColumn(
        text: numberFormat.format(double.parse(selectedInvoice['discount_total'])),
        width: 3,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: '${appData.getTaxData().tax_name} ${appData.getTaxData().percent}%:',
        width: 9,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
      PosColumn(
        text: numberFormat.format(double.parse(selectedInvoice['total_taxes'])),
        width: 3,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'TOTAL RD\$:',
        width: 9,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1, bold: true, underline: false),
      ),
      PosColumn(
        text: numberFormat.format(double.parse(selectedInvoice['total_amount'])),
        width: 3,
        styles: const PosStyles(
            align: PosAlign.right,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            bold: true,
            underline: false),
      ),
    ]);
    bytes += printer.feed(1);
    bytes += printer.row([
      PosColumn(
        text: selectedInvoice['payment_method'] == 'card' ? 'Tarjeta' : selectedInvoice['payment_method'] == 'transfer' ? 'Transferencia' :'Efectivo',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: numberFormat.format(double.parse(selectedInvoice['total_amount'].toString())),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);


    bytes += printer.feed(1);
    //print barcode
    // final List<int> barData = [];
    //final formattedInvoiceNumber = invoiceNumber.toString().padLeft(12, '0');

    // for (int i = 0; i < 13; i++) {
    //   barData.add(int.parse(formattedInvoiceNumber.substring(i, i + 1)));
    // }
/*
    final List<int> barData = [
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(0,1)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(1,2)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(2,3)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(3,4)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(4,5)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(5,6)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(6,7)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(7,8)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(8,9)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(9,10)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(10,11)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(11,12)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(12,13)),
    ];

    bytes += generator.barcode(Barcode.ean13(barData));
*/
    bytes += printer.feed(1);
    bytes += printer.row([
      PosColumn(
        text: '-------------------------',
        width: 12,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
    ]);
    bytes += printer.row([
      PosColumn(
        text: 'Firma cliente',
        width: 12,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
    ]);
    bytes += printer.feed(1);
    bytes += printer.row([
      PosColumn(
        text: '** DUPLICADO **',
        width: 12,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
    ]);
    /*
    bytes += printer.feed(1);
    bytes += printer.row([
      PosColumn(
        text: '** No se aceptan devoluciones de productos **',
        width: 12,
        styles: const PosStyles(align: PosAlign.center, underline: false),
      ),
    ]);

     */
    bytes += printer.feed(1);
    bytes += printer.cut();
    /*

    if (appData.getPrintCopyEnabled()) {
      bytes += printer.row([
        PosColumn(
          text: '${appData.getCompanyData().name}',
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
          text: "(${appData.getCompanyData().phone.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'), (Match m) => "(${m[1]}) ${m[2]}-${m[3]}")}",
          width: 12,
          styles: const PosStyles(align: PosAlign.center, underline: false),
        ),
      ]);
      bytes += printer.feed(1);

      bytes += printer.row([
        PosColumn(
          text: 'Fecha:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: dateFormat.format(DateTime.now()),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);
      bytes += printer.row([
        PosColumn(
          text: 'Factura:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: invoiceNumber,
          width: 6,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);
      bytes += printer.row([
        PosColumn(
          text: 'Le atendio:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: appData.getUserData().name,
          width: 6,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);
      /*
      if(selectedPaymentWay=='credit') {
        bytes += printer.feed(1);
        bytes += printer.row([
          PosColumn(
            text: 'Forma de pago:',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: paymentWayDropdownItems
                .firstWhere(
                  (element) =>
              element.value.toString() ==
                  selectedPaymentWay.toString(),
            )
                .label,
            width: 6,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);
        bytes += printer.row([
          PosColumn(
            text: 'Código cliente:',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: customer!.code.toString(),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);
        bytes += printer.row([
          PosColumn(
            text: 'Nombre cliente:',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: customer!.name.toString(),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);
        bytes += printer.row([
          PosColumn(
            text: 'Fecha límite de pago:',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: paydayLimit!=null?dateFormatOnlyDate.format(paydayLimit!):selectedPaymentWay=='credit'? dateFormatOnlyDate.format(DateTime.now().add(Duration(days: customer!.customerCredit!.days!))):dateFormatOnlyDate.format(DateTime.now()),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);
      }
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
          text: 'Factura para consumidor final',
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
          text: 'DESCRIPCION',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: 'CANT.',
          width: 2,
          styles: const PosStyles(align: PosAlign.center, underline: false),
        ),
        PosColumn(
          text: 'TOTAL',
          width: 2,
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
      for (var i = 0; i < invoiceDetailList.length; i++) {
        bytes += printer.row([
          PosColumn(
            text: invoiceDetailList[i].service!.name.toString(),
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: numberFormat.format(invoiceDetailList[i].quantity).toString(),
            width: 2,
            styles: const PosStyles(align: PosAlign.center, underline: false),
          ),
          PosColumn(
            text: numberFormat.format(invoiceDetailList[i].total).toString(),
            width: 2,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);
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
          text: 'subtotal:',
          width: 8,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
        PosColumn(
          text: numberFormat.format(subTotal.roundToDouble()),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);
      bytes += printer.row([
        PosColumn(
          text: 'TOTAL RD\$:',
          width: 8,
          styles: const PosStyles(
              align: PosAlign.right,
              width: PosTextSize.size1,
              height: PosTextSize.size1, bold: true, underline: false),
        ),
        PosColumn(
          text: numberFormat.format(total.roundToDouble()),
          width: 4,
          styles: const PosStyles(
              align: PosAlign.right,
              width: PosTextSize.size1,
              height: PosTextSize.size1,
              bold: true,
              underline: false),
        ),
      ]);
      bytes += printer.feed(1);
      bytes += printer.row([
        PosColumn(
          text: selectedPaymentMethod == 'card' ? 'Tarjeta' : 'Efectivo',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: totalPaidController.text != ''
              ? numberFormat.format(
              double.parse(totalPaidController.text).roundToDouble())
              : numberFormat.format(total.roundToDouble()),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);
      if(selectedPaymentMethod == 'mixed'){
        bytes += printer.row([
          PosColumn(
            text: 'Tarjeta',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, underline: false),
          ),
          PosColumn(
            text: numberFormat.format((cashBack.roundToDouble())*(-1)),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, underline: false),
          ),
        ]);
      }
      bytes += printer.row([
        PosColumn(
          text: 'Cambio:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: selectedPaymentMethod == 'mixed'?'0':numberFormat.format(cashBack.roundToDouble()),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);

      bytes += printer.feed(1);
      //print barcode
      // final List<int> barData = [];
      //final formattedInvoiceNumber = invoiceNumber.toString().padLeft(12, '0');

      // for (int i = 0; i < 13; i++) {
      //   barData.add(int.parse(formattedInvoiceNumber.substring(i, i + 1)));
      // }
/*
    final List<int> barData = [
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(0,1)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(1,2)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(2,3)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(3,4)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(4,5)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(5,6)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(6,7)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(7,8)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(8,9)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(9,10)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(10,11)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(11,12)),
      int.parse(invoiceNumber.toString().padLeft(13,'0').substring(12,13)),
    ];

    bytes += generator.barcode(Barcode.ean13(barData));
*/
      bytes += printer.feed(1);
      bytes += printer.row([
        PosColumn(
          text: '-------------------------',
          width: 12,
          styles: const PosStyles(align: PosAlign.center, underline: false),
        ),
      ]);
      bytes += printer.row([
        PosColumn(
          text: 'Firma cliente',
          width: 12,
          styles: const PosStyles(align: PosAlign.center, underline: false),
        ),
      ]);
      bytes += printer.feed(1);
      bytes += printer.row([
        PosColumn(
          text: '** COPIA CLIENTE **',
          width: 12,
          styles: const PosStyles(align: PosAlign.center, underline: false),
        ),
      ]);
      /*
      bytes += printer.feed(1);
      bytes += printer.row([
        PosColumn(
          text: '** No se aceptan devoluciones de productos **',
          width: 12,
          styles: const PosStyles(align: PosAlign.center, underline: false),
        ),
      ]);

       */
      bytes += printer.feed(2);
      bytes += printer.cut();
    }
     */
    //_printEscPos(bytes, printer);

    // await  controller.printNormal(bytes: bytes);

    return bytes;
  }

  pw.Widget invoiceData(){
    return pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
      pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Image(
              logo,
              width: responsiveApp.setWidth(80),
              height: responsiveApp.setHeight(80),
            ),
            pw.Text("${appData.getCompanyData().company_name}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 12)),
            pw.Text("${appData.getCompanyData().address}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 10)),
            pw.Text("${appData.getCompanyData().company_email}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 10)),
            /*
              if(appData.getModuleListData().any((mapa) => mapa['name'] == 'dgii'))
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text("RNC: ",style: const  pw.TextStyle(fontSize: 10)),
                      pw.Text("${appData.getCompanyData().rnc}", style: const  pw.TextStyle(fontSize: 10)),
                    ]
                ),
               */
            pw.Text("${appData.getCompanyData().company_phone.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'), (Match m) => "(${m[1]}) ${m[2]}-${m[3]}")}", style: const  pw.TextStyle(fontSize: 10)),

            //if(appData.getCompanyData().rnc!=null) pw.Text("RNC: ${appData.getCompanyData().rnc}"),
          ]),
      pw.SizedBox(height: responsiveApp.setHeight(10)),

      pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.SizedBox(
              width: PdfPageFormat.roll80.width*0.83,
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                      pw.Expanded(
                        child: pw.Text('Fecha:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Expanded(
                        child: pw.Text(dateFormat.format(DateTime.parse(selectedInvoice['date_time'].toString())), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      )
                    ]),



                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                      pw.Expanded(
                        child: pw.Text('Factura:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Expanded(
                        child: pw.Text(selectedInvoice['invoice_number'].toString(), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      )
                    ]),
                    /*
                    if(appData.getModuleListData().any((mapa) => mapa['name'] == 'dgii'))
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Expanded(
                          child: pw.Text('NCF:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Expanded(
                          child: pw.Text(ncfNumber, textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                        ),
                      ]),


                    if(selectedPosWay=='sale' && appData.getModuleListData().any((mapa) => mapa['name'] == 'dgii'))
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Expanded(
                          child: pw.Text('Válida hasta:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Expanded(
                          child: pw.Text(dateFormatOnlyDate.format(validDate!), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                        )
                      ]),

                     */
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                      pw.Expanded(
                        child: pw.Text('Cliente:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Expanded(
                        child: pw.Text(selectedInvoice['customer_name'].toString(), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      )
                    ]),
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                      pw.Expanded(
                        child: pw.Text('Le atendió:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Expanded(
                        child: pw.Text(selectedInvoice['user_name'].toString(), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      )
                    ]),
                    /*
                    if((selectedPaymentWay=='credit'||selectedInvoiceType!='final_consumer') && pFormat!=PdfPageFormat.a4)
                      pw.Column(
                          children: [
                            pw.SizedBox(height: 5),
                            if(selectedPaymentWay=='credit')
                              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                                pw.Expanded(
                                  child:pw.Text('Forma de pago:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                ),
                                pw.Expanded(
                                  child: pw.Text(paymentWayDropdownItems
                                      .firstWhere(
                                        (element) =>
                                    element.value.toString() ==
                                        selectedPaymentWay.toString(),
                                  )
                                      .label, textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                )
                              ]),
                            if(selectedPaymentWay=='credit')
                              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                                pw.Expanded(
                                  child: pw.Text('Código cliente:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                ),
                                pw.Expanded(
                                  child: pw.Text(customer!.code.toString(), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                )
                              ]),
                            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                              pw.Expanded(
                                child: pw.Text('RNC cliente:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                              ),
                              pw.Expanded(
                                child: pw.Text(rncController.text, textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                              )
                            ]),
                            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                              pw.Expanded(
                                child: pw.Text('Nombre cliente:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                              ),
                              pw.Expanded(
                                child: pw.Text(socialReason.toString(), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                              )
                            ]),
                            if(selectedPaymentWay=='credit')
                              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                                pw.Expanded(
                                  child: pw.Text('Fecha límite de pago:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                ),
                                pw.Expanded(
                                  child: pw.Text(paydayLimit!=null?dateFormatOnlyDate.format(paydayLimit!):selectedPaymentWay=='credit'? dateFormatOnlyDate.format(DateTime.now().add(Duration(days: customer!.customerCredit!.days!))):dateFormatOnlyDate.format(DateTime.now()), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                )
                              ]),
                          ]
                      ),


                    if(selectedPosWay=='sale' && pFormat==PdfPageFormat.a4)
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Expanded(
                          child: pw.Text('Orden #:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Expanded(
                          child: pw.Text(orderController.text==''?'N/A':orderController.text, textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                        )
                      ]),

                    if(selectedPosWay=='sale'&& quotationRef!='' && pFormat==PdfPageFormat.a4)
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Expanded(
                          child: pw.Text('Cotización:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Expanded(
                          child: pw.Text(quotationRef, textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                        )
                      ]),

                     */
                  ]
              ),
            ),
            /*
            if((selectedPaymentWay=='credit'||selectedInvoiceType!='final_consumer') && pFormat==PdfPageFormat.a4)
              pw.SizedBox(
                width: pFormat==PdfPageFormat.a4?200:pFormat.width*0.82,
                child: pw.Column(
                    children: [

                      pw.SizedBox(height: 5),
                      if(selectedPaymentWay=='credit')
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                          pw.Expanded(
                            child:pw.Text('Forma de pago:', textAlign: pw.TextAlign.right,style: const  pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            child: pw.Text(paymentWayDropdownItems
                                .firstWhere(
                                  (element) =>
                              element.value.toString() ==
                                  selectedPaymentWay.toString(),
                            )
                                .label, textAlign: pw.TextAlign.right,style: const  pw.TextStyle(fontSize: 9)),
                          )
                        ]),

                      if(selectedPaymentWay=='credit')
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                          pw.Expanded(
                            child: pw.Text('Código cliente:', textAlign: pw.TextAlign.right,style: const  pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            child: pw.Text(customer!.code.toString(), textAlign: pw.TextAlign.right,style: const  pw.TextStyle(fontSize: 9)),
                          )
                        ]),
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Expanded(
                          child: pw.Text('RNC cliente:', textAlign: pw.TextAlign.right,style: const  pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Expanded(
                          child: pw.Text(rncController.text, textAlign: pw.TextAlign.right,style: const  pw.TextStyle(fontSize: 9)),
                        )
                      ]),
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Expanded(
                          child: pw.Text('Nombre cliente:', textAlign: pw.TextAlign.right,style: const  pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Expanded(
                          child: pw.Text(socialReason.toString(), textAlign: pw.TextAlign.right,style: const  pw.TextStyle(fontSize: 9)),
                        )
                      ]),
                      if(selectedPaymentWay=='credit')
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                          pw.Expanded(
                            child: pw.Text('Fecha límite de pago:', textAlign: pw.TextAlign.right,style: const  pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            child: pw.Text(paydayLimit!=null?dateFormatOnlyDate.format(paydayLimit!):selectedPaymentWay=='credit'? dateFormatOnlyDate.format(DateTime.now().add(Duration(days: customer!.customerCredit!.days!))):dateFormatOnlyDate.format(DateTime.now()), textAlign: pw.TextAlign.right,style: const  pw.TextStyle(fontSize: 9)),
                          )
                        ]),

                    ]
                ),
              ),

               */
          ]
      ),
      pw.Divider(),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Flexible(
          child: pw.Text('Factura para consumidor final',textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
        )
      ]),
      pw.Divider(),

      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Expanded(
          flex: 5,
          child: pw.Text('DESCRIPCION', style: const  pw.TextStyle(fontSize: 9)),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text('ITBIS',textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9),),),
        /*    pw.SizedBox(
            width: 30,
            child: pw.Text('PRECIO',textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9),),),

        if(appData.getModuleListData().any((mapa) => mapa['name'] == 'dgii')&&pFormat == PdfPageFormat.a4)
          pw.SizedBox(
            width: 50,
            child: pw.Text('ITBIS',textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9),),),

         */
        pw.Expanded(
            flex: 2,
            child: pw.Text(
              'MONTO',
              textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9),
            )),
      ]),
      pw.Divider(),
      pw.ListView(
        children:
        List<pw.Widget>.from(invoiceDetailList.map((data) {
          return pw.Column(children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                    flex: 5,
                    child: pw.Text("${data.service!.name!}  ${data.service!.type=="service"? "(${data.employee!.name!})":""} x ${data.quantity}", style: const  pw.TextStyle(fontSize: 9))),
                //  child: pw.Text('${pFormat == PdfPageFormat.a4?data.product!.name!:data.product!.name!.toLowerCase()} ${pFormat == PdfPageFormat.a4?data.product!.unit!.unit!:data.product!.unit!.unit!.toLowerCase()}', style: const  pw.TextStyle(fontSize: 9))),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(numberFormat.format(data.tax),textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),),
/*
                  pw.SizedBox(
                    width: 30,
                    child: pw.Text('${data.price!}',textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),),

                if(appData.getModuleListData().any((mapa) => mapa['name'] == 'dgii')&&pFormat == PdfPageFormat.a4)
                  pw.SizedBox(
                    width: 50,
                    child: pw.Text(numberFormat.format(data.tax),textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),),

                 */
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(numberFormat.format(data.total),
                      textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
                )
              ],
            ),
            pw.SizedBox(height: 5
            ),
          ]);
        }).toList()),
      ),
      pw.Divider(),
      //pw.SizedBox(height: 10),
      pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children:[
            pw.SizedBox(
                width: PdfPageFormat.roll80.width*0.83,
                child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text('Subtotal: ', style: const  pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            child: pw.Text(numberFormat.format(double.parse(selectedInvoice['subtotal'].toString())), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
                          )
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text('Descuento: ', style: const  pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            child: pw.Text(numberFormat.format(double.parse(selectedInvoice['discount_total'].toString())), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
                          )
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text('${appData.getTaxData().tax_name} ${appData.getTaxData().percent}%: ', style: const  pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            child: pw.Text(numberFormat.format(double.parse(selectedInvoice['total_taxes'].toString())), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
                          )
                        ],
                      ),


                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text('TOTAL: ', style: const  pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            child: pw.Text(numberFormat.format(double.parse(selectedInvoice['total_amount'].toString())), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(selectedInvoice['payment_method'] == 'card' ? 'Tarjeta' : selectedInvoice['payment_method'] == 'transfer' ? 'Transferencia' :'Efectivo', style: const  pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            child: pw.Text(numberFormat.format(double.parse(selectedInvoice['total_amount'].toString())), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9),),
                          ),

                        ],
                      ),

                    ]
                )
            ),
          ]
      )
    ]);
  }

  List<pw.Widget> ticketData(){
    Map<int, Map<String, dynamic>> resumen = {};
    List<pw.Widget> ticketList = [];
    if(invoiceDetailList.any((e)=>e.service!.type=='service')) {
      List<InvoiceDetail> bList = [];

      // SELECT MAX(id) as lastId FROM invoice_details
      for (var item in invoiceDetailList) {
        if (item.service!.type == 'service') {
          bList.add(item);
        }
      }

      for (var item in bList) {
        if (!resumen.containsKey(item.employee!.id)) {
          resumen[item.employee!.id!] = {
            'employee_name': item.employee!.name,
            'services': <int, int>{},
          };
        }

        var services = resumen[item.employee!.id]!['services'] as Map<int, int>;

        if (services.containsKey(item.service!.id!)) {
          services[item.service!.id!] = item.booking_item_id!;
        } else {
          services[item.service!.id!] = item.booking_item_id!;
        }
      }

      resumen.forEach((chairId, data) {
        double totalEmployee = 0;
          ticketList.add(
              pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
                pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text("${appData.getCompanyData().company_name}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 12)),
                      pw.Text("${appData.getCompanyData().address}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 10)),
                      pw.Text("${appData.getCompanyData().company_email}",textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 10)),
                      /*
              if(appData.getModuleListData().any((mapa) => mapa['name'] == 'dgii'))
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text("RNC: ",style: const  pw.TextStyle(fontSize: 10)),
                      pw.Text("${appData.getCompanyData().rnc}", style: const  pw.TextStyle(fontSize: 10)),
                    ]
                ),
               */
                      pw.Text("${appData.getCompanyData().company_phone.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'), (Match m) => "(${m[1]}) ${m[2]}-${m[3]}")}", style: const  pw.TextStyle(fontSize: 10)),

                      //if(appData.getCompanyData().rnc!=null) pw.Text("RNC: ${appData.getCompanyData().rnc}"),
                    ]),
                pw.SizedBox(height: responsiveApp.setHeight(10)),

                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.SizedBox(
                        width: PdfPageFormat.roll80.width*0.83,
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                                pw.Expanded(
                                  child: pw.Text('Fecha:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                ),
                                pw.Expanded(
                                  child: pw.Text(dateFormat.format(DateTime.parse(selectedInvoice['date_time'].toString())), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                )
                              ]),

                              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                                pw.Expanded(
                                  child: pw.Text('Cliente', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                ),
                                pw.Expanded(
                                  child: pw.Text(selectedInvoice['customer_name'].toString(), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                )
                              ]),

                              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                                pw.Expanded(
                                  child: pw.Text('Le atendió:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                ),
                                pw.Expanded(
                                  child: pw.Text(selectedInvoice['user_name'].toString(), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                )
                              ]),

                              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                                pw.Expanded(
                                  child: pw.Text('Servicio a nombre de:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                ),
                                pw.Expanded(
                                  child: pw.Text(data['employee_name'].toString(), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                )
                              ]),

                              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                                pw.Expanded(
                                  child: pw.Text('Factura referencia:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                ),
                                pw.Expanded(
                                  child: pw.Text(selectedInvoice['invoice_number'].toString(), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                                )
                              ]),

                            ]
                        ),
                      ),
                    ]
                ),
                pw.Divider(),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                  pw.Flexible(
                    child: pw.Text('Ticket de servicio',textAlign: pw.TextAlign.center, style: const  pw.TextStyle(fontSize: 9)),
                  )
                ]),
                pw.Divider(),

                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('#', style: const  pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text('DESCRIPCION', style: const  pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('CAN',textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9),),),
                  /*    pw.SizedBox(
            width: 30,
            child: pw.Text('PRECIO',textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9),),),

        if(appData.getModuleListData().any((mapa) => mapa['name'] == 'dgii')&&pFormat == PdfPageFormat.a4)
          pw.SizedBox(
            width: 50,
            child: pw.Text('ITBIS',textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9),),),

         */
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'MONTO',
                        textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9),
                      )),
                ]),
                pw.Divider(),

                pw.ListView(
                  children: (data['services'] as Map<int, int>).entries.map((entry) {
                    var serviceId = entry.key;
                    var itemServiceId = entry.value;

                    // Buscar el detalle de la factura de forma segura
                    var invoiceDetail = invoiceDetailList.firstWhere(
                          (e) => e.service?.id == serviceId && e.employee?.id == chairId,
                    );

                    totalEmployee += invoiceDetailList.firstWhere((e) => e.service!.id == serviceId && e.employee!.id == chairId).total!;

                    return pw.Column(children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text("$itemServiceId", style: const pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(invoiceDetail.service?.name ?? "No disponible",
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(invoiceDetail.quantity?.toString() ?? "0",
                                textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              numberFormat.format(invoiceDetail.total ?? 0),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                    ]);

                  }).toList(),
                ),

                pw.Divider(),
                //pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children:[
                      pw.SizedBox(
                          width: PdfPageFormat.roll80.width*0.83,
                          child: pw.Column(
                              children: [
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text('TOTAL: ', style: const  pw.TextStyle(fontSize: 9)),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(numberFormat.format(totalEmployee), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
                                    ),
                                  ],
                                ),

                              ]
                          )
                      ),
                    ]
                )
              ])
          );
      });
    }


    return ticketList;
  }
}