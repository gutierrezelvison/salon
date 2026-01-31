
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart' show CapabilityProfile, Generator, PaperSize, PosAlign, PosColumn, PosStyles, PosTextSize;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:salon/Widgets/Components/printer_config_widget.dart';
import 'package:salon/Widgets/WebComponents/Header/header_search_bar.dart';
import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../WebComponents/Body/Container/ProductContainer.dart';
import 'cash_count_widget.dart';
import 'cash_register_widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'home_controller.dart';
import 'invoice_history_widget.dart';
import 'printers_widget.dart';
import 'select_employee.dart';

class PosWidget extends StatefulWidget {
  const PosWidget({Key? key}) : super(key: key);

  @override
  State<PosWidget> createState() => _PosWidgetState();
}

class _PosWidgetState extends State<PosWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection = BDConnection();
  late AppData appData;
  bool firstTime = true;
  int pageIndex = 0;
  List<String> itemsCustomer = [];
  List<String> itemsChair = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchServiceController = TextEditingController();
  final TextEditingController _chairSearchController = TextEditingController();
  TextEditingController totalPaidController = TextEditingController();
  String? selectedCustomer;
  String? selectedChair;
  List<User> customerList=[];
  List<Chairs> chairList=[];
  List<BookingList> bookingList=[];
  List<BookingItem> bookingItemList=[];
  List<InvoiceDetail> invoiceDetailList = [];
  List<Service>? serviceList;
  List<int> idServiceList=[];
  Map<int,int> serviceCant = {};
  double subTotal=0;
  double discount_total=0;
  double discount_percent=0;
  double total=0;
  double itbis=0;
  NumberFormat numberFormat = NumberFormat('#,###.##', 'en_Us');
  DateFormat dateFormat = DateFormat('dd/MM/yyyy h:mm:ss a');
  String fechaInicio = DateTime.now().subtract(const Duration(hours: 24 * 60)).toString();
  String fechaFin =
      "${DateTime.now().year.toString()}-${DateTime.now().month
      .toString().padLeft(2, '0')}-${DateTime.now().day
      .toString().padLeft(2, '0')} 23:59:59";

  DateTime? invoiceDate;
  String searchItems = 'Servicios';
  late final dynamic logo;
  String logoStatus = 'empty';
  List<bool> isHovering=[
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  List<bool> isRaised=[
    true,
    false,
    false,
    false,
    false,
  ];
  Object? groupPaymentMethod = Object();
  String selectedPaymentMethod = 'cash';
  String invoiceNumber = '';
  double cashBack = 0.0;
  List<CashRegister> cashList = [];
  List<String> cashItems = [];
  String? selectedCash;
  String printerStatus = 'connected';
  List<int>? pendingTask;
  final HomeController controller = HomeController();

  List<Service> filteredServices =[];
  Map<String, bool> filterOptions = {};

  @override
  initState() {
    groupPaymentMethod = 'Efectivo';
    getServices();
    super.initState();
  }

  calculateResume(){
   setState(() {
     subTotal = invoiceDetailList.fold(0.0, (a, b) =>
     double.parse(a.toString())
         + double.parse(b.quantity!.toString()) *
         double.parse(b.price!.toString())
     );

     discount_total = invoiceDetailList.fold(0.0, (a, b) =>
     b.service!.discount_type! == 'percent'
         ? double.parse(a.toString())
         + ((double.parse(b.quantity!.toString()) *
             double.parse(b.price!.toString())) *
             (double.parse(b.service!.discount!) / 100))
         : double.parse(a.toString())
         + double.parse(b.service!.discount!)
     );

     discount_percent = (discount_total / subTotal)*100;

     itbis = invoiceDetailList.fold(0.0, (a, b) =>
     b.service!.apply_taxes! == 1
         ? double.parse(a.toString())
         + ((double.parse(b.quantity!.toString()) *
             double.parse(b.price!.toString())) *
             (appData
                 .getTaxData()
                 .percent
                 .roundToDouble() / 100))
         : double.parse(a.toString())
     );
     /*
     itbis = (subTotal - discount_total) * (appData
         .getTaxData()
         .percent
         .roundToDouble() / 100);

      */
     total = (subTotal - discount_total) + itbis;
   });
  }

  limpiar(){
    setState(() {
      bookingItemList.clear();
      bookingList.clear();
      invoiceDetailList.clear();
      invoiceNumber = '';
      selectedCustomer = null;
      selectedChair = null;
      serviceCant.clear();
      idServiceList.clear();
      discount_total = 0;
      pageIndex = 0;
      discount_percent = 0;
      total=0.0;
      subTotal=0.0;
      itbis = 0.0;
      cashBack = 0.0;
      totalPaidController.text ='';
    });
  }

  finalizar()async{
    if(bookingList[0].bookings.id!=null){
      if(await bdConnection.updateBooking(
        context: context,
        id: bookingList[0].bookings.id!,
        status: 'completed',
        payment_status: 'completed',
        discount: bookingList[0].bookings.discount!,
        additional_notes: bookingList[0].bookings.additional_notes!,
        tax_amount: bookingList[0].bookings.tax_amount!,
        payment_gateway: bookingList[0].bookings.payment_gateway!,
        discount_percent: bookingList[0].bookings.discount_percent!,
        amount_to_pay: bookingList[0].bookings.amount_to_pay!,
        date_time: DateTime.parse(bookingList[0].bookings.date_time!),
        employee_id: chairList.elementAt(itemsChair.indexOf(selectedChair!)).employee_id!,
        original_amount: bookingList[0].bookings.original_amount!,
        source: bookingList[0].bookings.source!,
        tax_name: bookingList[0].bookings.tax_name!,
        tax_percent: bookingList[0].bookings.tax_percent!,
        user_id: bookingList[0].user!.id!
      )){
        //finishInvoice(bookingList[0].bookings.id!);
      }
    }else{
      var query = await bdConnection.setBooking(
          context: context,
          user_id             : selectedCustomer==null?12:customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).id!,
          //chairId             : chairList.elementAt(itemsChair.indexOf(selectedChair!)).chair_id!,
          //chairId             : chairList.elementAt(itemsChair.indexOf(selectedChair!)).chair_id!,
          date_time           : invoiceDate!,
          status              : 'completed',
          payment_gateway     : selectedPaymentMethod,
          original_amount     : subTotal,
          discount            : discount_total,
          discount_percent    : discount_percent,
          tax_name            : appData.getTaxData().tax_name,
          tax_percent         : appData.getTaxData().percent,
          tax_amount          : itbis,
          amount_to_pay       : total,
          payment_status      : 'completed',
          source              : 'pos',
          itemList            : bookingItemList
      );
      if(query['success']){

       // finishInvoice(query["idBooking"]);
        /*
        CustomSnackBar().show(
            context: context,
            msg: 'El registro se completó con éxito!',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xff22d88d)
        );

         */
      }else{
        CustomSnackBar().show(
            context: context,
            msg: 'No se pudo completar la operación!',
            icon: Icons.error_outline_outlined,
            color: const Color(0xffFF525C)
        );
      }
    }
  }

  finishInvoice() async {
    if (await bdConnection.addInvoice(
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
      procedure: 'InsertInvoiceWithDetails',
      invoice: Invoice(
        booking_id: 0,
          cash_id: cashList.elementAt(cashItems.indexOf(selectedCash!)).id,
          customer_id: selectedCustomer==null?12:customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).id!,
          customer_rnc: null,
          date_time: invoiceDate,
          discount_percent: discount_percent,
          discount_total: discount_total,
          invoice_number: invoiceNumber,
          invoice_type: 'final_consumer',
          order_type: 'store',
          payment_method: selectedPaymentMethod,
          payment_status: 'completed',
          payment_way: 'cash',
          social_reason: null,
          subtotal: subTotal,
          total_taxes: itbis,
          total_amount: total.roundToDouble(),
          total_card: selectedPaymentMethod=='mixed'?(total.roundToDouble() - double.parse(totalPaidController.text)).roundToDouble():selectedPaymentMethod=='card'?total.roundToDouble():0,
          total_cash: selectedPaymentMethod=='mixed'?(double.parse(totalPaidController.text)).roundToDouble():selectedPaymentMethod=='cash'?total.roundToDouble():0,
          total_transfers: selectedPaymentMethod=='mixed'?(double.parse(totalPaidController.text)).roundToDouble():selectedPaymentMethod=='transfer'?total.roundToDouble():0,
          user_id: AppData.userData.id,
          invoiceDetail: invoiceDetailList.map((item)=>item.toJson()).toList()),
    )) {
      showNotification(
          '¡Operación realizada con éxito!', Icons.error, Colors.green);

    } else {
      showNotification(
          'Error al intentar realizar la operación', Icons.error, Colors.red);
    }
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

  setCashList() async {
    for (var element in await bdConnection.getData(
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
      table: 'cash_register',
      fields: '*',
      groupBy: 'id',
      order: 'ASC',
      orderBy: 'id',
      where: 'id > 0',
    )) {
      cashList.add(CashRegister(
        id: int.parse(element['id']),
        number: int.parse(element['number']),
        user_id: int.parse(element['user_id']),
      ));
      cashItems.add(element['number']);
      if(appData.getUserData().id == int.parse(element['user_id'])){
          appData.setCash(CashRegister(
            id: int.parse(element['id']),
            number: int.parse(element['number']),
            user_id: int.parse(element['user_id']),
          ));
      }
    }

    if (appData.getCash().number != null) {
      selectedCash = appData.getCash().number.toString();
    } else {
      selectedCash = null;
    }


    setState(() {});
  }

  getInvoiceNumber() async {
    final query = await bdConnection.getData(
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
        fields: '*',
        table: 'invoice_number',
        where: '1',
        order: 'ASC',
        orderBy: 'actual_number',
        groupBy: 'actual_number');
    int number =
        int.parse(query[0]['actual_number'].toString().split('-')[1]) + 1;
    invoiceNumber =
    '${query[0]['actual_number'].toString().split('-')[0]}-${number.toString().padLeft(query[0]['actual_number'].toString().split('-')[1].length, '0')}';
    setState(() {});
  }

  getServices()async{
    var query = await bdConnection.getServices(context: context,searchBy: 'id',type: searchItems=="Productos"?'product':'service');
    serviceList= List.from(query);
    if(query!=[]&& filterOptions.isEmpty) {
      extractFilterOptions(serviceList!, filterOptions);
    }else {
      onFilter();
    }
  }

  void onFilter() {
    String searchText = _searchServiceController.text.trim().toLowerCase();
    bool hasSearch = searchText.isNotEmpty;

    bool anyFilterSelected = filterOptions.containsValue(true);

    filteredServices = serviceList!.where((service) {
      // Primero aplicar los filtros
      bool matchesType = filterOptions[service.type] ?? false;
      bool matchesCategory = filterOptions[service.category_name] ?? false;
      bool matchesDiscountType = filterOptions[service.discount_type] ?? false;

      // Si hay filtros activos, el servicio debe cumplir al menos uno de los criterios activos
      bool passesFilters = !anyFilterSelected ||
          matchesType || matchesCategory || matchesDiscountType;

      // Luego aplicar búsqueda solo si pasa los filtros
      bool matchesSearch = !hasSearch || (service.name?.toLowerCase().contains(searchText) ?? false);

      return passesFilters && matchesSearch;
    }).toList();

    setState(() {});
  }

  int countNonEmptyLists(Map<String, bool> map) {
    int count = 0;
    map.forEach((key, value) {
      if (value) {
        count++;
      }
    });
    return count;
  }

  void extractFilterOptions(List<Service> services, Map<String, bool> filterOptions) {
    // Agregar opción "Todo"
    //filterOptions["Todo"] = true;

    // Extraer categorías únicas
    Set<String> categories = services.map((s) => s.category_name ?? "").toSet();
    for (var category in categories) {
      if (category.isNotEmpty) {
        filterOptions[category] = false; // Por defecto, no filtrar
      }
    }
/*
    // Extraer tipos de registro únicos
    Set<String> types = services.map((s) => s.type ?? "").toSet();
    for (var type in types) {
      if (type.isNotEmpty) {
        filterOptions[type] = false;
      }
    }

    // Extraer tipos de descuento únicos
    Set<String> discountTypes = services.map((s) => s.discount_type ?? "").toSet();
    for (var discountType in discountTypes) {
      if (discountType.isNotEmpty) {
        filterOptions[discountType] = false;
      }
    }

 */
    onFilter();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    appData = AppData();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
        child: Container(
          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
          //color: Theme.of(context).primaryColor,
          child: Row(
            children: [
              if(isMobileAndTablet(context))
                IconButton(onPressed: ()=> pageIndex>0?setState((){pageIndex=0;}): mainScaffoldKey.currentState!.openDrawer(), icon: Icon(pageIndex>0?Icons.arrow_back_rounded:Icons.menu_rounded)),
              if (!isMobileAndTablet(context) && pageIndex > 0)
                IconButton(
                    onPressed: () => limpiar(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                    )),
              Expanded(
                child: Text("Punto de venta",
                  style: TextStyle(
                    fontSize: responsiveApp.setSP(16),
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: responsiveApp.setWidth(10),),
              Container(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                height: responsiveApp.setHeight(40),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.10),
                    borderRadius:
                    BorderRadius.circular(responsiveApp.setWidth(8))),
                child: RealTimeClockScreen(
                  textSize: responsiveApp.setSP(12),
                ),
              ),
              SizedBox(width: responsiveApp.setWidth(10),),
              if (pageIndex == 0)
                PopupMenuButton(
                    position: PopupMenuPosition.under,
                    splashRadius: 5,
                    itemBuilder: (ctx){
                      return [
                        PopupMenuItem(
                          onTap: (){
                          },
                          child: StatefulBuilder(
                              builder: (BuildContext ctx, StateSetter setState) {
                                return Container(
                                  // margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                                    boxShadow: const [
                                      BoxShadow(
                                        //color: const Color(0xff6C9BD2).withValues(alpha: 0.3),
                                        spreadRadius: -5,
                                        blurRadius: 8,
                                        offset: Offset(0, 2), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.autofps_select_rounded, color: Colors.grey,),
                                          SizedBox(width: responsiveApp.setWidth(3),),
                                          texto(text: "Auto imprimir", size: responsiveApp.setSP(12)),
                                        ],
                                      ),
                                      SizedBox(width: responsiveApp.setWidth(3),),
                                      customSwitch(
                                          context: context,
                                          label: const SizedBox(),
                                          active: appData.getAutoPrintEnabled(),
                                          onTap: () {
                                            appData.setAutoPrintEnabled(!appData.getAutoPrintEnabled());
                                            setState((){});
                                          }),
                                    ],
                                  ),
                                );
                              }
                          ),
                        ),
                        PopupMenuItem(
                          onTap: (){
                            viewWidget(context, CashCountWidget(
                              onFinish: () {
                                Navigator.pop(context);
                                setState(() {});
                              },
                            ), () {
                              Navigator.pop(context);
                              setState(() {});
                            });
                          },
                          child: Container(
                            // margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                              boxShadow: const [
                                BoxShadow(
                                  //color: const Color(0xff6C9BD2).withValues(alpha: 0.3),
                                  spreadRadius: -5,
                                  blurRadius: 8,
                                  offset: Offset(0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                const Icon(Icons.attach_money, color: Colors.grey,),
                                SizedBox(width: responsiveApp.setWidth(3),),
                                texto(text: "Cuadre de caja", size: responsiveApp.setSP(12)),
                              ],
                            ),
                          ),
                        ),
                        if(isMobile(context))
                          PopupMenuItem(
                            onTap: (){
                              setState(() {
                               // pageIndex=2;
                              });
                            },
                            child: Container(
                              // margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                                boxShadow: const [
                                  BoxShadow(
                                    //color: const Color(0xff6C9BD2).withValues(alpha: 0.3),
                                    spreadRadius: -5,
                                    blurRadius: 8,
                                    offset: Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  const Icon(Icons.checklist_rtl_rounded, color: Colors.grey,),
                                  SizedBox(width: responsiveApp.setWidth(3),),
                                  texto(text: "Ordenes", size: responsiveApp.setSP(12)),
                                ],
                              ),
                            ),
                          ),
                        PopupMenuItem(
                          onTap: (){
                            setState(() {
                              //Navigator.push(context, MaterialPageRoute(builder: (context)=>PaginatedSearch()));
                              pageIndex = 1;
                            });
                          },
                          child: Container(
                            // margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                              boxShadow: const [
                                BoxShadow(
                                  //color: const Color(0xff6C9BD2).withValues(alpha: 0.3),
                                  spreadRadius: -5,
                                  blurRadius: 8,
                                  offset: Offset(0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                const Icon(Icons.history_rounded, color: Colors.grey,),
                                SizedBox(width: responsiveApp.setWidth(3),),
                                texto(text: "Histórico de Facturas", size: responsiveApp.setSP(12)),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: (){
                            setState(() {
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => ReceivablesWidget(origin: 'pos',onFinish: (v){})));
                            });
                          },
                          child: Container(
                            // margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                              boxShadow: const [
                                BoxShadow(
                                  //color: const Color(0xff6C9BD2).withValues(alpha: 0.3),
                                  spreadRadius: -5,
                                  blurRadius: 8,
                                  offset: Offset(0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on_outlined, color: Colors.grey,),
                                SizedBox(width: responsiveApp.setWidth(3),),
                                texto(text: "Cuentas por cobrar", size: responsiveApp.setSP(12)),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: (){

                            viewWidget(context, PrinterConfigWidget(

                            ), () {
                              Navigator.pop(context);
                              setState(() {});
                            });


                          },
                          child: Container(
                            // margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                              boxShadow: const [
                                BoxShadow(
                                  //color: const Color(0xff6C9BD2).withValues(alpha: 0.3),
                                  spreadRadius: -5,
                                  blurRadius: 8,
                                  offset: Offset(0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                const Icon(Icons.print_rounded, color: Colors.grey,),
                                SizedBox(width: responsiveApp.setWidth(3),),
                                texto(text: "Impresora", size: responsiveApp.setSP(12)),
                              ],
                            ),
                          ),
                        ),
                      ];
                    }),
              SizedBox(
                width: responsiveApp.setWidth(10),
              ),
            ],
          ),
        ),
      ),

      body: pageIndex==1 ? InvoiceHistoryWidget(takeQuotation: (invoice, invoiceDetail){},): FutureBuilder(
        future: bdConnection.getUsers(context: context,roleId: 3),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if(snapshot.data ==null){
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Text("Cargando usuarios...")
                ],
              ),
            );
          }else {
            if(itemsCustomer.isEmpty){
              for (var element in snapshot.data){
                customerList.add(element);
                itemsCustomer.add("${element.id} - ${element.name}");
              }
            }
            return FutureBuilder(
                future: bdConnection.getChairs(context: context),
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if(snapshot.data ==null){
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          Text("Cargando Sillas...")
                        ],
                      ),
                    );
                  }else {
                    if (chairList.isEmpty) {
                      for (var element in snapshot.data) {
                        chairList.add(element);
                        itemsChair.add(element.chair_name);
                      }
                    }
                    return Builder(builder: (context) {
                      if (cashList.isEmpty) {
                        setCashList();
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              Text("Cargando caja...")
                            ],
                          ),
                        );
                      } else {
                        return FutureBuilder(
                          future: bdConnection.getData(
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
                              fields: '*',
                              table: 'cash_count',
                              where:
                              'cash_id = ${selectedCash != null ? cashList.elementAt(cashItems.indexOf(selectedCash!)).id : 0} AND status = \'open\'',
                              groupBy: 'id',
                              orderBy: 'id',
                              order: 'ASC'),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.data == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              if (snapshot.data.isEmpty) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (selectedCash == null)
                                      texto(
                                          text:
                                          '¡Debe seleccionar una caja para continuar!',
                                          size: responsiveApp.setSP(14)),
                                    if (selectedCash == null)
                                      Center(
                                        child: SizedBox(
                                          width: responsiveApp.setWidth(350),
                                          child: Padding(
                                            padding: responsiveApp.edgeInsetsApp
                                                .allSmallEdgeInsets,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Expanded(
                                                    child: texto(
                                                        text: 'Num. Caja: ',
                                                        size: responsiveApp
                                                            .setSP(12))),
                                                Expanded(
                                                  child: customDropDown(
                                                    context: context,
                                                    hintText: 'Numero de caja',
                                                    hintIcon: Icons
                                                        .point_of_sale_sharp,
                                                    items: cashItems,
                                                    value: selectedCash,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        selectedCash =
                                                            newValue.toString();
                                                        _searchController.text =
                                                        '';
                                                      });
                                                      appData.setCash(CashRegister(
                                                          id: cashList
                                                              .elementAt(cashItems
                                                              .indexOf(
                                                              selectedCash!))
                                                              .id,
                                                          number: int.parse(
                                                              selectedCash
                                                                  .toString())));
                                                    },
                                                    searchController:
                                                    _searchController,
                                                    searchInnerWidgetHeight:
                                                    responsiveApp
                                                        .setHeight(120),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: responsiveApp
                                                      .setWidth(5),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    viewWidget(context,
                                                        const CashRegisterWidget(),
                                                            () {
                                                          setState(() {
                                                            cashItems.clear();
                                                            cashList.clear();
                                                            selectedCash = null;
                                                          });
                                                          //setCashList();
                                                          Navigator.pop(context);
                                                        });
                                                  },
                                                  child: Container(
                                                    padding: responsiveApp
                                                        .edgeInsetsApp
                                                        .allSmallEdgeInsets,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            responsiveApp
                                                                .setWidth(
                                                                5)),
                                                        color: Colors.green),
                                                    child: const Icon(
                                                      Icons
                                                          .settings_applications,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (selectedCash != null)
                                      texto(
                                          text:
                                          '¡Debe habilitar la caja para continuar!',
                                          size: responsiveApp.setSP(14)),
                                    if (selectedCash != null)
                                      Padding(
                                        padding: responsiveApp
                                            .edgeInsetsApp.allSmallEdgeInsets,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                viewWidget(context,
                                                    CashCountWidget(
                                                      onFinish: () {
                                                        !isMobileAndTablet(context);
                                                        Navigator.pop(context);
                                                        setState(() {});
                                                      },
                                                    ), () {
                                                      !isMobileAndTablet(context);
                                                      Navigator.pop(context);
                                                      setState(() {});
                                                    });
                                              },
                                              child: Container(
                                                padding: responsiveApp
                                                    .edgeInsetsApp
                                                    .allSmallEdgeInsets,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      responsiveApp
                                                          .setWidth(50)),
                                                  color:
                                                  const Color(0xff6C9BD2),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.play_arrow_rounded,
                                                      color: Colors.white,
                                                      size: responsiveApp
                                                          .setWidth(20),
                                                    ),
                                                    texto(
                                                      size: responsiveApp
                                                          .setSP(12),
                                                      text: 'Abrir',
                                                      color: Colors.white,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight:
                                                      FontWeight.w500,
                                                    ),
                                                    SizedBox(
                                                      width: responsiveApp
                                                          .setWidth(8),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                );
                              } else {

                                if(DateTime.parse(snapshot.data[0]['open_date'].toString()).isBefore(DateTime.parse(DateTime.now().toString().substring(0,10)))) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        texto(
                                            text:
                                            '¡La caja alcanzó el límite de tiempo abierta!\n Debe cerrar para continuar.',
                                            size: responsiveApp.setSP(14),alignment: TextAlign.center),

                                        Padding(
                                          padding: responsiveApp
                                              .edgeInsetsApp.allSmallEdgeInsets,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  viewWidget(context,
                                                      CashCountWidget(
                                                        onFinish: () {
                                                          !isMobileAndTablet(context);
                                                          Navigator.pop(context);
                                                          setState(() {});
                                                        },
                                                      ), () {
                                                        !isMobileAndTablet(context);
                                                        Navigator.pop(context);
                                                        setState(() {});
                                                      });
                                                },
                                                child: Container(
                                                  padding: responsiveApp
                                                      .edgeInsetsApp
                                                      .allSmallEdgeInsets,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        responsiveApp
                                                            .setWidth(50)),
                                                    color:
                                                    const Color(0xff6C9BD2),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.close_rounded,
                                                        color: Colors.white,
                                                        size: responsiveApp
                                                            .setWidth(20),
                                                      ),
                                                      texto(
                                                        size: responsiveApp
                                                            .setSP(12),
                                                        text: 'Cerrar',
                                                        color: Colors.white,
                                                        fontFamily: 'Montserrat',
                                                        fontWeight:
                                                        FontWeight.w500,
                                                      ),
                                                      SizedBox(
                                                        width: responsiveApp
                                                            .setWidth(8),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  );
                                }
                                return Builder(
                                    builder: (context) {
                                      if (invoiceNumber == '') {
                                        getInvoiceNumber();
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: RefreshIndicator(
                                                //color: Theme.of(context).primaryColor,
                                                onRefresh: () {
                                                  return Future.delayed(
                                                    const Duration(seconds: 1),
                                                        () {
                                                      setState(() {});
                                                    },
                                                  );
                                                },
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.vertical,
                                                  physics: const AlwaysScrollableScrollPhysics(),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          if(!isMobileAndTablet(context) ||
                                                              pageIndex == 2)
                                                            Container(
                                                              margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                                              width: isMobileAndTablet(context)? displayWidth(context)*0.94 : displayWidth(context)*0.45,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                                                                  color: Colors.white,
                                                                  boxShadow: const [
                                                                    BoxShadow(
                                                                      spreadRadius: -6,
                                                                      blurRadius: 8,
                                                                      offset: Offset(0, 0),
                                                                    )
                                                                  ]
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  _listFilter(),
                                                                  Padding(
                                                                    padding: responsiveApp
                                                                        .edgeInsetsApp
                                                                        .allMediumEdgeInsets,
                                                                    child: searchItems ==
                                                                        'Servicios'
                                                                        ? _servicios()
                                                                        : searchItems ==
                                                                        'Reservas'
                                                                        ? _reservas()
                                                                        : _servicios(),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          if(!isMobileAndTablet(context) ||
                                                              pageIndex == 0)
                                                            SizedBox(
                                                              width: responsiveApp.setWidth(
                                                                  8),),
                                                          if(!isMobileAndTablet(context) ||
                                                              pageIndex == 0)
                                                            Expanded(
                                                              child: Padding(
                                                                padding: responsiveApp
                                                                    .edgeInsetsApp
                                                                    .onlyMediumTopEdgeInsets,
                                                                child: Padding(
                                                                  padding: responsiveApp
                                                                      .edgeInsetsApp
                                                                      .onlyMediumRightEdgeInsets,
                                                                  child: _detalleVenta(),
                                                                ),
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
                                    }
                                );
                              }
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
        }
      ),
    );
  }

  Widget _listFilter(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 10,
      children: [
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        spreadRadius: -6,
                        blurRadius: 8,
                        offset: Offset(0,0),
                      )
                    ]
                ),
                child: Row(
                  children: [
                    _buttonFilter(0,'Servicios',()async{
                      filterOptions.clear();
                      searchItems = 'Servicios';
                      loadingDialog(context);
                      await getServices();
                      Navigator.pop(context);
                      setState(() {
                        for(int i=0;i<isRaised.length;i++){
                          i!=0?isRaised[i] = false:isRaised[i] = true;
                        }

                      });
                    }),
                    _buttonFilter(1,'Productos',()async{
                      filterOptions.clear();
                      searchItems = 'Productos';
                      loadingDialog(context);
                      await getServices();
                      Navigator.pop(context);
                      setState(() {
                        for(int i=0;i<isRaised.length;i++){
                          i!=1?isRaised[i] = false:isRaised[i] = true;
                        }
                      });
                    }),
                    _buttonFilter(2,'Reservas',(){
                      setState(() {
                        for(int i=0;i<isRaised.length;i++){
                          i!=2?isRaised[i] = false:isRaised[i] = true;
                        }
                        searchItems = 'Reservas';
                      });
                    }),

                  ],
                ),
              ),
            ],
          ),
        ),


        Expanded(
          flex: 2,
          child: Padding(
            padding: responsiveApp.edgeInsetsApp.onlySmallTopEdgeInsets,
            child:HeaderSearchBar(onSearchPressed: (){
              onFilter();
            },
              onChange: (v){
                onFilter();
              },
              controller: _searchServiceController,
            ),
          ),
        ),



      ],
    );
  }

  Widget _buttonFilter(int index,String text, VoidCallback onTap){
    return InkWell(
      onHover: (v){
        /*
        isHovering[index+5]=v;
         */
      },
      onTap: onTap,
      child: Container(
        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(index==2?responsiveApp.setWidth(5):responsiveApp.setWidth(0)), topLeft: Radius.circular(index==0?responsiveApp.setWidth(5):responsiveApp.setWidth(0)),
          bottomRight: Radius.circular(index==2?responsiveApp.setWidth(5):responsiveApp.setWidth(0)), bottomLeft: Radius.circular(index==0?responsiveApp.setWidth(5):responsiveApp.setWidth(0))),
          color: isHovering[index+5]?Theme.of(context).primaryColor.withOpacity(0.10):isRaised[index]?Theme.of(context).primaryColor:Colors.transparent,
        ),
        child: texto(
          text:text,
          size: responsiveApp.setSP(12),
          color: isHovering[index+5]?Colors.white:isRaised[index]?Colors.white:Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _servicios(){
    return Column(
      children: [
        Row(
          children: [
            InkWell(
                onTap: () async {

                },
                child: Container(
                    padding: responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                                padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,child: Icon(Icons.tune_rounded, color: Theme.of(context).primaryColor))),
                        if(countNonEmptyLists(filterOptions)>0)
                          Container(
                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: Text(countNonEmptyLists(filterOptions).toString(), style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white,)),
                            ),
                          ),
                      ],
                    ))
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(filterOptions.keys.length, (index){
                    var keys = filterOptions.keys.toList();
                    return InkWell(
                      onTap: ()async{
                        filterOptions[keys[index]]=!(filterOptions[keys[index]])!;
                        onFilter();
                      },
                      child: Container(
                        margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                        decoration: BoxDecoration(
                          color: !filterOptions[keys[index]]!?Colors.transparent:Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Text(keys[index],
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(color: !filterOptions[keys[index]]!?Theme.of(context).textTheme.labelMedium!.color:Colors.white,),),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Wrap(
            children: List.generate(
              filteredServices.length,
                  (index){
                isHovering.add(false);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(responsiveApp.setWidth(8)),
                      child: ProductContainer(
                        showQuantity: searchItems == 'Productos',
                        filteredServices[index],
                        onHoverAdd: (v){
                          setState((){
                            isHovering[index+8]=v;
                          });
                        },
                        addColor: isHovering[index+8]?Theme.of(context).primaryColor.withOpacity(0.85):Theme.of(context).primaryColor,
                        onAddPress: (){
                            if(searchItems == "Servicios") {

                                  viewWidget(context,
                                      SelectEmployee(
                                        onSelect: (employee) {

                                          if (bookingItemList.any((item) =>
                                          item.chair_id == employee.employee_id &&
                                              item.business_service_id == filteredServices[index].id
                                          )) {
                                              //serviceCant.update(filteredServices[index].id!, (value) => value + 1);
                                              //invoiceDetailList.firstWhere((e) => e.service?.id == filteredServices[index].id).service?.id = (invoiceDetailList.firstWhere((e) => e.service?.id == filteredServices[index].id).service?.id ?? 0) + 1;

                                              int invoiceItemIndex = invoiceDetailList.indexWhere(
                                                    (item) =>
                                                item.employee!.id == employee.employee_id &&
                                                    item.service!.id == filteredServices[index].id,
                                              );

                                              invoiceDetailList[invoiceItemIndex].quantity =(invoiceDetailList[invoiceItemIndex].quantity??0) +1;
                                              invoiceDetailList[invoiceItemIndex].tax= invoiceDetailList[invoiceItemIndex].service!.apply_taxes == 1
                                                  ? (invoiceDetailList[invoiceItemIndex].quantity! *
                                                  double.parse(
                                                      filteredServices[index].price.toString()))
                                                  .toDouble() * (appData
                                                  .getTaxData()
                                                  .percent / 100)
                                                  : 0;

                                              invoiceDetailList[invoiceItemIndex].discount =
                                              invoiceDetailList[invoiceItemIndex].service!.discount_type! == 'percent'
                                                  ? (((invoiceDetailList[invoiceItemIndex].quantity! *
                                                  double.parse(
                                                      invoiceDetailList[invoiceItemIndex].price.toString()))
                                                  .toDouble()) *
                                                  (double.parse(invoiceDetailList[invoiceItemIndex].discount.toString()) / 100))
                                                  : double.parse(invoiceDetailList[invoiceItemIndex].discount.toString())
                                                  + double.parse(invoiceDetailList[invoiceItemIndex].discount.toString());

                                              invoiceDetailList[invoiceItemIndex].total = (invoiceDetailList[invoiceItemIndex].quantity! *
                                          double.parse(
                                              invoiceDetailList[invoiceItemIndex].price.toString()))
                                              .toDouble() +
                                          (invoiceDetailList[invoiceItemIndex].service!.apply_taxes == 1
                                          ? ((invoiceDetailList[invoiceItemIndex].quantity! *
                                          double.parse(
                                              invoiceDetailList[invoiceItemIndex].price.toString()))
                                              .toDouble() * (appData
                                              .getTaxData()
                                              .percent / 100))
                                              : 0);

                                              int bookingItemIndex = bookingItemList.indexWhere(
                                                    (item) =>
                                                item.chair_id == employee.employee_id &&
                                                    item.business_service_id == filteredServices[index].id,
                                              );

                                              bookingItemList[bookingItemIndex].quantity =(bookingItemList[bookingItemIndex].quantity??0) +1;
                                              bookingItemList[bookingItemIndex].discount =
                                              bookingItemList[bookingItemIndex].discount_type! == 'percent'
                                                  ? (((bookingItemList[bookingItemIndex].quantity! *
                                                      double.parse(
                                                          bookingItemList[bookingItemIndex].unit_price.toString()))
                                                      .toDouble()) *
                                                      (double.parse(bookingItemList[bookingItemIndex].discount.toString()) / 100))
                                                  : double.parse(bookingItemList[bookingItemIndex].discount.toString())
                                                  + double.parse(bookingItemList[bookingItemIndex].discount.toString());
                                              bookingItemList[bookingItemIndex].amount = (bookingItemList[bookingItemIndex].quantity! *
                                                  double.parse(
                                                      bookingItemList[bookingItemIndex].unit_price.toString()))
                                                  .toDouble();

                                          }else{
                                            //serviceCant.putIfAbsent(filteredServices[index].id!, () => 1);
                                            //idServiceList.add(filteredServices[index].id!);
                                            bookingList.add(
                                                BookingList(
                                                    service: Service(
                                                      name: filteredServices[index].name,
                                                      id: filteredServices[index].id,
                                                      type: filteredServices[index].type,
                                                      price: filteredServices[index].price,
                                                      discount: filteredServices[index].discount ?? '0',
                                                      apply_taxes: filteredServices[index].apply_taxes ??
                                                          0,
                                                      tax_id: filteredServices[index].tax_id ?? 0,
                                                      quantity: filteredServices[index].quantity ?? 0,
                                                      discount_type: filteredServices[index]
                                                          .discount_type ?? 'percent',
                                                    ),
                                                    employee: User(id: employee.employee_id,name: employee.employee_name),
                                                    bookings: Bookings(
                                                      payment_status: 'completed',
                                                      discount: double.parse(
                                                          filteredServices[index].discount.toString()),
                                                      user_id: selectedCustomer != null ? customerList
                                                          .elementAt(
                                                          itemsCustomer.indexOf(selectedCustomer!))
                                                          .id! : 12,
                                                    ),
                                                    bookingItem: BookingItem(
                                                      business_service_id: filteredServices[index].id,
                                                      service_name: filteredServices[index].name,
                                                      unit_price: double.parse(
                                                          filteredServices[index].price!),
                                                      chair_id: employee.employee_id,
                                                      type: filteredServices[index].type,
                                                      employee_name: employee.employee_name,
                                                      quantity: 1,
                                                      discount_type: filteredServices[index].discount_type!,
                                                      discount: filteredServices[index].discount_type! == 'percent'
                                                          ? (((1 *
                                                          double.parse(
                                                              filteredServices[index].price.toString()))
                                                          .toDouble()) *
                                                          (double.parse(filteredServices[index].discount.toString()) / 100))
                                                          : double.parse(filteredServices[index].discount.toString())
                                                          + double.parse(filteredServices[index].discount.toString()),
                                                      amount: (1 *
                                                          double.parse(filteredServices[index].price!))
                                                          .toDouble(),
                                                    )
                                                )
                                            );
                                            invoiceDetailList.add(
                                                InvoiceDetail(
                                                  employee: User(name: employee.employee_name,id: employee.employee_id),
                                                  service: Service(name: filteredServices[index].name,
                                                    id: filteredServices[index].id,
                                                    type: filteredServices[index].type,
                                                    price: filteredServices[index].price,
                                                    discount: filteredServices[index].discount ?? '0',
                                                    apply_taxes: filteredServices[index].apply_taxes ??
                                                        0,
                                                    tax_id: filteredServices[index].tax_id ?? 0,
                                                    quantity: filteredServices[index].quantity ?? 0,
                                                    discount_type: filteredServices[index]
                                                        .discount_type ?? 'percent',
                                                  ),
                                                  price: double.parse(
                                                      filteredServices[index].price.toString()),
                                                  quantity: 1,
                                                  tax: filteredServices[index].apply_taxes == 1
                                                      ? (1 *
                                                      double.parse(
                                                          filteredServices[index].price.toString()))
                                                      .toDouble() * (appData
                                                      .getTaxData()
                                                      .percent / 100)
                                                      : 0,
                                                  discount: filteredServices[index].discount_type! == 'percent'
                                                      ? (((1 *
                                                      double.parse(
                                                          filteredServices[index].price.toString()))
                                                      .toDouble()) *
                                                      (double.parse(filteredServices[index].discount.toString()) / 100))
                                                      : double.parse(filteredServices[index].discount.toString())
                                                      + double.parse(filteredServices[index].discount.toString()),

                                                  total: (1 *
                                                      double.parse(
                                                          filteredServices[index].price.toString()))
                                                      .toDouble() +
                                                      (filteredServices[index].apply_taxes == 1
                                                          ? ((1 *
                                                          double.parse(
                                                              filteredServices[index].price.toString()))
                                                          .toDouble() * (appData
                                                          .getTaxData()
                                                          .percent / 100))
                                                          : 0),
                                                )
                                            );
                                            bookingItemList.add(BookingItem(
                                              business_service_id: filteredServices[index].id,
                                              service_name: filteredServices[index].name,
                                              unit_price: double.parse(filteredServices[index].price!),
                                              chair_id: employee.employee_id,
                                              employee_name: employee.employee_name,
                                              type: filteredServices[index].type,
                                              quantity: 1,
                                              discount_type: filteredServices[index].discount_type!,
                                              discount: filteredServices[index].discount_type! == 'percent'
                                                  ? (((1 *
                                                  double.parse(
                                                      filteredServices[index].price.toString()))
                                                  .toDouble()) *
                                                  (double.parse(filteredServices[index].discount.toString()) / 100))
                                                  : double.parse(filteredServices[index].discount.toString())
                                                  + double.parse(filteredServices[index].discount.toString()),
                                              amount: double.parse(filteredServices[index].price!),
                                            ));
                                          }
                                          calculateResume();
                                          Navigator.pop(context);
                                          pageIndex =0;
                                          CustomSnackBar().show(color: Colors.green, context: context, icon: Icons.check_circle_outline_rounded,msg: 'Operación realizada con éxito!');

                                        },
                                      ),

                                          () {
                                        Navigator.pop(context);
                                      });


                            }else {
                              if (invoiceDetailList.any((e)=>e.service!.id ==filteredServices[index].id)) {
                                int invoiceItemIndex = invoiceDetailList
                                    .indexWhere(
                                      (item) =>
                                  item.service!.id ==
                                      filteredServices[index].id,
                                );
                                if(filteredServices[index].quantity!>invoiceDetailList[invoiceItemIndex]
                                    .quantity!) {

                                  invoiceDetailList[invoiceItemIndex].quantity =
                                      (invoiceDetailList[invoiceItemIndex]
                                          .quantity ?? 0) + 1;
                                  invoiceDetailList[invoiceItemIndex].tax =
                                  invoiceDetailList[invoiceItemIndex].service!
                                      .apply_taxes == 1
                                      ? (invoiceDetailList[invoiceItemIndex]
                                      .quantity! *
                                      double.parse(
                                          filteredServices[index].price
                                              .toString()))
                                      .toDouble() * (appData
                                      .getTaxData()
                                      .percent / 100)
                                      : 0;

                                  invoiceDetailList[invoiceItemIndex].discount =
                                  invoiceDetailList[invoiceItemIndex].service!.discount_type! == 'percent'
                                      ? (((invoiceDetailList[invoiceItemIndex].quantity! *
                                      double.parse(
                                          invoiceDetailList[invoiceItemIndex].price.toString()))
                                      .toDouble()) *
                                      (double.parse(invoiceDetailList[invoiceItemIndex].discount.toString()) / 100))
                                      : double.parse(invoiceDetailList[invoiceItemIndex].discount.toString())
                                      + double.parse(invoiceDetailList[invoiceItemIndex].discount.toString());

                                  invoiceDetailList[invoiceItemIndex].total =
                                      (invoiceDetailList[invoiceItemIndex]
                                          .quantity! *
                                          double.parse(
                                              invoiceDetailList[invoiceItemIndex]
                                                  .price.toString()))
                                          .toDouble() +
                                          (invoiceDetailList[invoiceItemIndex]
                                              .service!.apply_taxes == 1
                                              ? ((invoiceDetailList[invoiceItemIndex]
                                              .quantity! *
                                              double.parse(
                                                  invoiceDetailList[invoiceItemIndex]
                                                      .price.toString()))
                                              .toDouble() * (appData
                                              .getTaxData()
                                              .percent / 100))
                                              : 0);

                                  int bookingItemIndex = bookingItemList
                                      .indexWhere(
                                        (item) =>
                                    item.business_service_id ==
                                        filteredServices[index].id,
                                  );

                                  bookingItemList[bookingItemIndex].quantity =
                                      (bookingItemList[bookingItemIndex]
                                          .quantity ?? 0) + 1;
                                  bookingItemList[bookingItemIndex].discount =
                                  bookingItemList[bookingItemIndex].discount_type! == 'percent'
                                      ? (((bookingItemList[bookingItemIndex].quantity! *
                                      double.parse(
                                          bookingItemList[bookingItemIndex].unit_price.toString()))
                                      .toDouble()) *
                                      (double.parse(bookingItemList[bookingItemIndex].discount.toString()) / 100))
                                      : double.parse(bookingItemList[bookingItemIndex].discount.toString())
                                      + double.parse(bookingItemList[bookingItemIndex].discount.toString());
                                  bookingItemList[bookingItemIndex].amount =
                                      (bookingItemList[bookingItemIndex]
                                          .quantity! *
                                          double.parse(
                                              bookingItemList[bookingItemIndex]
                                                  .unit_price.toString()))
                                          .toDouble();
                                  CustomSnackBar().show(color: Colors.green, context: context, icon: Icons.check_circle_outline_rounded,msg: 'Operación realizada con éxito!');
                                }else{
                                  CustomSnackBar().show(color: Colors.deepOrange, context: context, icon: Icons.warning_amber_rounded,msg: 'Imposible agregar mas de la cantidad en existencia.');
                                }
                              } else {
                                if(filteredServices[index].quantity!>=1) {
                                  bookingList.add(
                                      BookingList(
                                          service: Service(
                                            name: filteredServices[index].name,
                                            id: filteredServices[index].id,
                                            type: filteredServices[index].type,
                                            price: filteredServices[index]
                                                .price,
                                            discount: filteredServices[index]
                                                .discount ?? '0',
                                            apply_taxes: filteredServices[index]
                                                .apply_taxes ?? 0,
                                            tax_id: filteredServices[index]
                                                .tax_id ?? 0,
                                            quantity: filteredServices[index]
                                                .quantity ?? 0,
                                            discount_type: filteredServices[index]
                                                .discount_type ??
                                                'percent',
                                          ),
                                          bookings: Bookings(
                                            payment_status: 'completed',
                                            discount: double.parse(
                                                filteredServices[index].discount
                                                    .toString()),
                                            user_id: selectedCustomer != null
                                                ? customerList
                                                .elementAt(
                                                itemsCustomer.indexOf(
                                                    selectedCustomer!))
                                                .id!
                                                : 12,
                                          ),
                                          bookingItem: BookingItem(
                                            business_service_id: filteredServices[index]
                                                .id,
                                            unit_price: double.parse(
                                                filteredServices[index].price!),
                                            quantity: 1,
                                            chair_id: cashList
                                                .firstWhere((element) =>
                                            element.number! ==
                                                (int.parse(selectedCash!)))
                                                .user_id,
                                            type: filteredServices[index].type,
                                            discount_type: filteredServices[index].discount_type!,
                                            discount: filteredServices[index].discount_type! == 'percent'
                                                ? (((1 *
                                                double.parse(
                                                    filteredServices[index].price.toString()))
                                                .toDouble()) *
                                                (double.parse(filteredServices[index].discount.toString()) / 100))
                                                : double.parse(filteredServices[index].discount.toString())
                                                + double.parse(filteredServices[index].discount.toString()),
                                            amount: (1 *
                                                double.parse(
                                                    filteredServices[index]
                                                        .price!))
                                                .toDouble(),
                                          )
                                      )
                                  );
                                  invoiceDetailList.add(
                                      InvoiceDetail(
                                        employee: User(id: cashList
                                            .firstWhere((element) =>
                                        element.number! ==
                                            (int.parse(selectedCash!)))
                                            .user_id),
                                        service: Service(
                                          name: filteredServices[index].name,
                                          id: filteredServices[index].id,
                                          type: filteredServices[index].type,
                                          price: filteredServices[index].price,
                                          discount: filteredServices[index]
                                              .discount ?? '0',
                                          apply_taxes: filteredServices[index]
                                              .apply_taxes ?? 0,
                                          tax_id: filteredServices[index]
                                              .tax_id ?? 0,
                                          quantity: filteredServices[index]
                                              .quantity ?? 0,
                                          discount_type: filteredServices[index]
                                              .discount_type ??
                                              'percent',
                                        ),
                                        price: double.parse(
                                            filteredServices[index].price
                                                .toString()),
                                        quantity: 1,
                                        tax: filteredServices[index]
                                            .apply_taxes == 1
                                            ? (1 *
                                            double.parse(
                                                filteredServices[index].price
                                                    .toString()))
                                            .toDouble() * (appData
                                            .getTaxData()
                                            .percent / 100)
                                            : 0,
                                        discount: filteredServices[index].discount_type! == 'percent'
                                            ? (((1 *
                                            double.parse(
                                                filteredServices[index].price.toString()))
                                            .toDouble()) *
                                            (double.parse(filteredServices[index].discount.toString()) / 100))
                                            : double.parse(filteredServices[index].discount.toString())
                                            + double.parse(filteredServices[index].discount.toString()),
                                        total: (1 *
                                            double.parse(
                                                filteredServices[index].price
                                                    .toString()))
                                            .toDouble() +
                                            (filteredServices[index]
                                                .apply_taxes == 1
                                                ? ((1 *
                                                double.parse(
                                                    filteredServices[index]
                                                        .price
                                                        .toString()))
                                                .toDouble() * (appData
                                                .getTaxData()
                                                .percent / 100))
                                                : 0),
                                      )
                                  );
                                  bookingItemList.add(BookingItem(
                                    business_service_id: filteredServices[index]
                                        .id,
                                    unit_price: double.parse(
                                        filteredServices[index].price!),
                                    quantity: 1,
                                    chair_id: cashList
                                        .firstWhere((element) =>
                                    element.number! ==
                                        (int.parse(selectedCash!)))
                                        .user_id,
                                    type: filteredServices[index].type,
                                    discount_type: filteredServices[index].discount_type!,
                                    discount: filteredServices[index].discount_type! == 'percent'
                                        ? (((1 *
                                        double.parse(
                                            filteredServices[index].price.toString()))
                                        .toDouble()) *
                                        (double.parse(filteredServices[index].discount.toString()) / 100))
                                        : double.parse(filteredServices[index].discount.toString())
                                        + double.parse(filteredServices[index].discount.toString()),
                                    amount: (1 *
                                        double.parse(
                                            filteredServices[index].price!))
                                        .toDouble(),
                                  ));
                                  CustomSnackBar().show(color: Colors.green, context: context, icon: Icons.check_circle_outline_rounded,msg: 'Operación realizada con éxito!');
                                }else{
                                  CustomSnackBar().show(color: Colors.deepOrange, context: context, icon: Icons.warning_amber_rounded,msg: 'Producto sin existencia');
                                }
                              }
                              pageIndex =0;
                              calculateResume();
                            }
                          },
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(5),),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _reservas(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: responsiveApp.setWidth(10),
              top: responsiveApp.setWidth(8), bottom: responsiveApp.setWidth(8)),
          child: const Text('Reservas recientes'),
        ),
        Row(
          children: [
            Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: bdConnection.getBookingList(
                      context: context,
                      location: 'all',
                      userName: selectedCustomer??'all',
                      status: 'completed',
                      status2: 'in progress',
                      payment_status: 'pending',
                      fechaInicio: fechaInicio,
                      fechaFin: fechaFin),
                  builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: displayHeight(context)*0.5,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        ],
                      );
                    }else {
                      int repetido = 1;
                      return Column(
                        children: List.generate(
                          snapshot.data.length,
                            (index){
                                    index>0&&snapshot.data[index].bookings.id==snapshot.data[index-1].bookings.id?repetido++:repetido=1;

                                    return index<snapshot.data.length-1&&snapshot.data[index].bookings.id!=snapshot.data[index+1].bookings.id
                                        ? Column(
                                          children: [
                                            reservar_list(snapshot,index,repetido),
                                            Row(
                                              children: [
                                                Expanded(child: Container(height: responsiveApp.setHeight(1),)),
                                              ],
                                            )
                                          ],
                                        )
                                        : index==snapshot.data.length-1?Column(
                                          children: [
                                            reservar_list(snapshot,index,repetido),
                                            Row(
                                              children: [
                                                Expanded(child: Container(height: responsiveApp.setHeight(1),)),
                                              ],
                                            )
                                          ],
                                        ):const SizedBox();
                                    },
                        ),
                      );
                    }
                  }
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget reservar_list(AsyncSnapshot snapshot,int index,int repetido){
    var outputFormat = DateFormat('MMM dd, yyyy hh:mm a');
    return ListTile(
      title: Container(
        decoration: BoxDecoration(
          color: const Color(0xff5359ff).withOpacity(0.05),
          borderRadius: BorderRadius.circular(responsiveApp.setWidth(3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
              decoration: BoxDecoration(
                color: snapshot.data[index].bookings.status=='completed'?const Color(0xff22d88d)
                    :snapshot.data[index].bookings.status=='pending'?const Color(0xffffc44e)
                    :snapshot.data[index].bookings.status=='approved'?const Color(0xff13e9d1)
                    :snapshot.data[index].bookings.status=='in progress'?const Color(0xff5359ff)
                    :const Color(0xffFF525C) ,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(responsiveApp.setWidth(3)),
                    bottomLeft: Radius.circular(responsiveApp.setWidth(3))),
              ),
              child: Column(
                children: [
                  texto(
                    text: outputFormat.format(DateTime.parse(snapshot.data[index].bookings.date_time)).split(',')[0],
                    size: responsiveApp.setSP(14),
                    color: Colors.white,
                  ),
                  Container(
                    padding: EdgeInsets.all(responsiveApp.setWidth(3)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                      border: Border.all(width: responsiveApp.setWidth(1),
                          color: Colors.white
                      ),
                    ),
                    child: texto(
                      text: outputFormat.format(DateTime.parse(snapshot.data[index].bookings.date_time)).substring(13,21),
                      size: responsiveApp.setSP(10),
                      color: Colors.white,
                    ),
                  ),
                  texto(
                    text: outputFormat.format(DateTime.parse(snapshot.data[index].bookings.date_time)).substring(7,12),
                    size: responsiveApp.setSP(14),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(width: responsiveApp.setWidth(5),),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: responsiveApp.setHeight(2),),
                  texto(size: responsiveApp.setSP(12), text: snapshot.data[index].user.name,fontWeight: FontWeight.w600),
                  texto(size: responsiveApp.setSP(12), text: '1. ${snapshot.data[index-(repetido-1)].service.name} x '
                      '${snapshot.data[index-(repetido-1)].bookingItem.quantity}'),
                  if(repetido >= 2)
                    texto(size: responsiveApp.setSP(12), text: '2. ${snapshot.data[index-(repetido-2)].service.name} x '
                        '${snapshot.data[index-(repetido-2)].bookingItem.quantity}'),
                  if(repetido >= 3)
                    texto(size: responsiveApp.setSP(12), text: '3. ${snapshot.data[index-(repetido-3)].service.name} x '
                        '${snapshot.data[index-(repetido-3)].bookingItem.quantity}'),
                  if(repetido >= 4)
                    texto(size: responsiveApp.setSP(12), text: '4. ${snapshot.data[index-(repetido-4)].service.name} x '
                        '${snapshot.data[index-(repetido-4)].bookingItem.quantity}'),
                  if(repetido >= 5)
                    texto(size: responsiveApp.setSP(12), text: '5. ${snapshot.data[index-(repetido-5)].service.name} x '
                        '${snapshot.data[index-(repetido-5)].bookingItem.quantity}'),
                ],
              ),
            ),

            Expanded(
              child: SizedBox(
                height: responsiveApp.setHeight(60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                        border: Border.all(width: responsiveApp.setWidth(1),
                            color: snapshot.data[index].bookings.status=='completed'?const Color(0xff22d88d)
                                :snapshot.data[index].bookings.status=='pending'?const Color(0xffffc44e)
                                :snapshot.data[index].bookings.status=='approved'?const Color(0xff13e9d1)
                                :snapshot.data[index].bookings.status=='in progress'?const Color(0xff5359ff)
                                :const Color(0xffFF525C)
                        ),
                      ),
                      child: texto(
                          size: responsiveApp.setSP(12),
                          text: snapshot.data[index].bookings.status,
                          color: snapshot.data[index].bookings.status=='completed'?const Color(0xff22d88d)
                              :snapshot.data[index].bookings.status=='pending'?const Color(0xffffc44e)
                              :snapshot.data[index].bookings.status=='approved'?const Color(0xff13e9d1)
                              :snapshot.data[index].bookings.status=='in progress'?const Color(0xff5359ff)
                              :const Color(0xffFF525C)
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
              child: Container(height: responsiveApp.setHeight(53),
                width: responsiveApp.setWidth(1),
                color: Colors.black.withOpacity(0.10),),
            ),
            SizedBox(
              height: responsiveApp.setHeight(60),
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded,color: Theme.of(context).primaryColor),
                  onPressed: (){
                    /*
                    setState(() {
                      selectedCustomer = snapshot.data[index].user.name;
                      selectedChair = snapshot.data[index].chairs.chair_name;
                      for(int i=1;i<=repetido;i++){
                        if(serviceCant.containsKey(snapshot.data[index-(repetido-i)].service.id)){
                          serviceCant.update(snapshot.data[index-(repetido-i)].service.id, (value) => value+1);
                          bookingList[idServiceList.indexOf(snapshot.data[index-(repetido-i)].service.id)]=snapshot.data[index-(repetido-i)];
                          bookingItemList[idServiceList.indexOf(snapshot.data[index-(repetido-i)].service.id)]=snapshot.data[index-(repetido-i)].bookingItem;
                          invoiceDetailList[idServiceList.indexOf(snapshot.data[index-(repetido-i)].service.id)]=InvoiceDetail(
                            service: Service(id: snapshot.data[index-(repetido-i)].service.id, name: snapshot.data[index-(repetido-i)].service.name),
                            price: double.parse(snapshot.data[index-(repetido-i)].service.price),
                            quantity: serviceCant[snapshot.data[index-(repetido-i)].service.id]!.toDouble(),
                            tax: (serviceCant[snapshot.data[index-(repetido-i)].service.id]! * double.parse(snapshot.data[index-(repetido-i)].service.price)).toDouble() * (appData.getTaxData().percent/100),
                            total: (serviceCant[snapshot.data[index-(repetido-i)].service.id]! * double.parse(snapshot.data[index-(repetido-i)].service.price)).toDouble() + ((serviceCant[snapshot.data[index-(repetido-i)].service.id]! * double.parse(snapshot.data[index-(repetido-i)].service.price)).toDouble() * (appData.getTaxData().percent/100)),
                          );
                        }else{
                          serviceCant.putIfAbsent(snapshot.data[index-(repetido-i)].service.id, () => snapshot.data[index-(repetido-i)].bookingItem.quantity);
                          chairList.add(snapshot.data[index-(repetido-i)].chairs);
                          idServiceList.add(snapshot.data[index-(repetido-i)].service.id);
                          bookingList.add(snapshot.data[index-(repetido-i)]);
                          bookingItemList.add(snapshot.data[index-(repetido-i)].bookingItem);
                          invoiceDetailList.add(
                              InvoiceDetail(
                                service: Service(id: snapshot.data[index-(repetido-i)].service.id, name: snapshot.data[index-(repetido-i)].service.name),
                                price: double.parse(snapshot.data[index-(repetido-i)].service.price),
                                quantity: serviceCant[snapshot.data[index-(repetido-i)].service.id]!.toDouble(),
                                tax: (serviceCant[snapshot.data[index-(repetido-i)].service.id]! * double.parse(snapshot.data[index-(repetido-i)].service.price)).toDouble() * (appData.getTaxData().percent/100),
                                total: (serviceCant[snapshot.data[index-(repetido-i)].service.id]! * double.parse(snapshot.data[index-(repetido-i)].service.price)).toDouble() + ((serviceCant[snapshot.data[index-(repetido-i)].service.id]! * double.parse(snapshot.data[index-(repetido-i)].service.price)).toDouble() * (appData.getTaxData().percent/100)),
                              )
                          );
                        }
                      }
                      calculateResume();
                      if(isMobileAndTablet(context))pageIndex=0;
                    });

                     */
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _detalleVenta(){

    return Column(
      children: [
        Container(
          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  spreadRadius: -6,
                  blurRadius: 8,
                  offset: Offset(0, 0),
                )
              ]
          ),
          child: Padding(
            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(isMobileAndTablet(context))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      infoData(
                          'No. factura',
                          texto(text: invoiceNumber, size: responsiveApp.setSP(12)
                          ),
                          null),
                    ],
                  ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      /*       //paymentMethod(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: responsiveApp.setWidth(10)),
                        child: Container(
                          height: responsiveApp.setHeight(30),
                          width: responsiveApp.setWidth(1),
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),

                  infoData('NCF', texto(text: 'B01-00000123',size: responsiveApp.setSP(12)),null),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(10)),
                    child: Container(height: responsiveApp.setHeight(30),
                      width: responsiveApp.setWidth(1),
                      color: Colors.grey.withOpacity(0.3),),
                  ),
                  */
                      if(!isMobileAndTablet(context))
                      infoData(
                          'No. factura',
                          texto(text: invoiceNumber, size: responsiveApp.setSP(12)
                          ),
                          null),
                    ],
                  ),
                ),
                Padding(
                  padding: responsiveApp.edgeInsetsApp.onlySmallTopEdgeInsets,
                  child: Padding(
                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                    child: texto(text: 'Cliente', size: responsiveApp.setSP(10)),
                  ),
                ),
                Row(
                    children: [
                      Expanded(
                        child:
                        customDropDown(
                            searchController: _searchController,
                            items: itemsCustomer,
                            value: selectedCustomer,
                            onChanged: (value) {
                              setState(() {
                                selectedCustomer = value as String;
                                _searchController.text='';
                              });
                            },
                          context: context,
                          hintIcon: Icons.person_rounded,
                          searchInnerWidgetHeight: responsiveApp.setHeight(120),
                        ),
                      ),
                    ]
                ),
                if(selectedCustomer!=null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                texto(
                                  size: responsiveApp.setSP(12),
                                  text: selectedCustomer!=null?customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).name!:'',
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        texto(
                                          text: 'E-mail',
                                          size: responsiveApp.setSP(12),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.mail_outline_rounded,
                                              size: responsiveApp.setWidth(12),
                                              color: Colors.grey,),
                                            SizedBox(
                                                width: responsiveApp.setWidth(3)),
                                            texto(
                                              size: responsiveApp.setSP(12),
                                              text: selectedCustomer!=null?customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).email!:'',
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ]
                                  ),
                                ),
                                Padding(padding: responsiveApp.edgeInsetsApp
                                    .allSmallEdgeInsets,
                                  child: Container(
                                    color: Colors.grey,
                                    width: responsiveApp.setWidth(1),
                                    height: responsiveApp.setHeight(30),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        texto(
                                          text: 'Mobile',
                                          size: responsiveApp.setSP(12),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.phone_android_rounded,
                                              size: responsiveApp.setWidth(12),
                                              color: Colors.grey,),
                                            SizedBox(
                                                width: responsiveApp.setWidth(3)),
                                            texto(
                                              size: responsiveApp.setSP(12),
                                              text: selectedCustomer!=null?'${customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).calling_code} '
                                                  '${customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).mobile}':'',
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ]
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          children: [
                            Expanded(
                              child: texto(
                                size: responsiveApp.setSP(12),
                                text: 'Artículo',
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(60),
                              child: Center(
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: 'Precio',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(70),
                              child: Center(
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: 'Cantidad',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(60),
                              child: Center(
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: 'Total',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(25),
                              child: texto(
                                size: responsiveApp.setSP(12),
                                text: '',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if(invoiceDetailList.isNotEmpty)
                Column(
                  children:
                    List.generate(
                      invoiceDetailList.length,
                          (int index){
                        return Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        texto(
                                          size: responsiveApp.setSP(12),
                                          text: '${invoiceDetailList[index].service!.name}',
                                        ),
                                        if(invoiceDetailList[index].service!.type=='service')
                                        Text(
                                            '${invoiceDetailList[index].employee!.name}',
                                          style: Theme.of(context).textTheme.labelSmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: responsiveApp.setWidth(60),
                                    child: Center(
                                      child: texto(
                                        size: responsiveApp.setSP(12),
                                        text: '\$${invoiceDetailList[index].price}',
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: responsiveApp.setWidth(70),
                                    //height: 52,
                                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: responsiveApp.setWidth(70),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(3)),
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              setState(() {
                                                if(invoiceDetailList[index].quantity! > 1){
                                                  /*
                                                  invoiceDetailList[index].quantity =(invoiceDetailList[index].quantity??0) -1;
                                                  bookingItemList[index].quantity =(bookingItemList[index].quantity??0) -1;
                                                  bookingList[index].bookingItem.quantity =(bookingList[index].bookingItem.quantity??0) -1;

                                                   */
                                                  invoiceDetailList[index].quantity =(invoiceDetailList[index].quantity??0) -1;
                                                  invoiceDetailList[index].tax= invoiceDetailList[index].service!.apply_taxes == 1
                                                      ? (invoiceDetailList[index].quantity! *
                                                      double.parse(
                                                          filteredServices[index].price.toString()))
                                                      .toDouble() * (appData
                                                      .getTaxData()
                                                      .percent / 100)
                                                      : 0;

                                                  invoiceDetailList[index].discount =
                                                  invoiceDetailList[index].service!.discount_type! == 'percent'
                                                      ? (((invoiceDetailList[index].quantity! *
                                                      double.parse(
                                                          invoiceDetailList[index].price.toString()))
                                                      .toDouble()) *
                                                      (double.parse(invoiceDetailList[index].discount.toString()) / 100))
                                                      : double.parse(invoiceDetailList[index].discount.toString())
                                                      + double.parse(invoiceDetailList[index].discount.toString());

                                                  invoiceDetailList[index].total = (invoiceDetailList[index].quantity! *
                                                      double.parse(
                                                          invoiceDetailList[index].price.toString()))
                                                      .toDouble() +
                                                      (invoiceDetailList[index].service!.apply_taxes == 1
                                                          ? ((invoiceDetailList[index].quantity! *
                                                          double.parse(
                                                              invoiceDetailList[index].price.toString()))
                                                          .toDouble() * (appData
                                                          .getTaxData()
                                                          .percent / 100))
                                                          : 0);



                                                  bookingItemList[index].quantity =(bookingItemList[index].quantity??0) -1;
                                                  bookingItemList[index].discount =
                                                  bookingItemList[index].discount_type! == 'percent'
                                                      ? (((bookingItemList[index].quantity! *
                                                      double.parse(
                                                          bookingItemList[index].unit_price.toString()))
                                                      .toDouble()) *
                                                      (double.parse(bookingItemList[index].discount.toString()) / 100))
                                                      : double.parse(bookingItemList[index].discount.toString())
                                                      + double.parse(bookingItemList[index].discount.toString());
                                                  bookingItemList[index].amount = (bookingItemList[index].quantity! *
                                                      double.parse(
                                                          bookingItemList[index].unit_price.toString()))
                                                      .toDouble();
                                                calculateResume();
                                                }
                                              });
                                            },
                                            child: Container(
                                              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.withOpacity(0.10),
                                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(responsiveApp.setWidth(3)),bottomLeft: Radius.circular(responsiveApp.setWidth(3)))
                                              ),
                                              child: const Text("-"),
                                            ),
                                          ),
                                          Container(
                                            height: responsiveApp.setHeight(23.9),
                                            width: responsiveApp.setWidth(0.5),
                                            color: Colors.grey,
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              height: responsiveApp.setHeight(23.9),
                                              child: Center(
                                                child: texto(
                                                  text: "${invoiceDetailList[index].quantity}",
                                                  size: responsiveApp.setSP(12),
                                                )
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: responsiveApp.setHeight(23.95),
                                            width: responsiveApp.setWidth(0.5),
                                            color: Colors.grey,
                                          ),
                                          InkWell(
                                            onTap: (){
                                              if(bookingList[index].service!.type == 'service' || invoiceDetailList[index].quantity!<invoiceDetailList[index].service!.quantity!){
                                                setState(() {
                                                  //invoiceDetailList[index].quantity =(invoiceDetailList[index].quantity??0) +1;
                                                  //bookingItemList[index].quantity =(bookingItemList[index].quantity??0) +1;


                                                  invoiceDetailList[index].quantity =(invoiceDetailList[index].quantity??0) +1;
                                                  invoiceDetailList[index].tax= invoiceDetailList[index].service!.apply_taxes == 1
                                                      ? (invoiceDetailList[index].quantity! *
                                                      double.parse(
                                                          filteredServices[index].price.toString()))
                                                      .toDouble() * (appData
                                                      .getTaxData()
                                                      .percent / 100)
                                                      : 0;

                                                  invoiceDetailList[index].discount =
                                                  invoiceDetailList[index].service!.discount_type! == 'percent'
                                                      ? (((invoiceDetailList[index].quantity! *
                                                      double.parse(
                                                          invoiceDetailList[index].price.toString()))
                                                      .toDouble()) *
                                                      (double.parse(invoiceDetailList[index].discount.toString()) / 100))
                                                      : double.parse(invoiceDetailList[index].discount.toString())
                                                      + double.parse(invoiceDetailList[index].discount.toString());

                                                  invoiceDetailList[index].total = (invoiceDetailList[index].quantity! *
                                                      double.parse(
                                                          invoiceDetailList[index].price.toString()))
                                                      .toDouble() +
                                                      (invoiceDetailList[index].service!.apply_taxes == 1
                                                          ? ((invoiceDetailList[index].quantity! *
                                                          double.parse(
                                                              invoiceDetailList[index].price.toString()))
                                                          .toDouble() * (appData
                                                          .getTaxData()
                                                          .percent / 100))
                                                          : 0);



                                                  bookingItemList[index].quantity =(bookingItemList[index].quantity??0) +1;
                                                  bookingItemList[index].discount =
                                                  bookingItemList[index].discount_type! == 'percent'
                                                      ? (((bookingItemList[index].quantity! *
                                                      double.parse(
                                                          bookingItemList[index].unit_price.toString()))
                                                      .toDouble()) *
                                                      (double.parse(bookingItemList[index].discount.toString()) / 100))
                                                      : double.parse(bookingItemList[index].discount.toString())
                                                      + double.parse(bookingItemList[index].discount.toString());
                                                  bookingItemList[index].amount = (bookingItemList[index].quantity! *
                                                      double.parse(
                                                          bookingItemList[index].unit_price.toString()))
                                                      .toDouble();
                                                  calculateResume();
                                                });
                                              }else{
                                                CustomSnackBar().show(color: Colors.deepOrange, context: context, icon: Icons.warning_amber_rounded,msg: 'Imposible agregar mas de la cantidad en existencia.');
                                              }
                                            },
                                            child: Container(
                                              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.withOpacity(0.10),
                                                  borderRadius: BorderRadius.only(topRight: Radius.circular(responsiveApp.setWidth(3)),bottomRight: Radius.circular(responsiveApp.setWidth(3)))
                                              ),
                                              child: const Text("+"),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: responsiveApp.setWidth(60),
                                    child: Center(
                                      child: texto(
                                        size: responsiveApp.setSP(12),
                                        text: '\$${invoiceDetailList[index].total}',
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                      onTap: (){
                                        setState(() {

                                          bookingList.removeWhere((booking) => booking.service!.id == invoiceDetailList[index].service!.id && (booking.service!.type =='service'? booking.employee!.id == invoiceDetailList[index].employee!.id: true));
                                          bookingItemList.removeAt(index);
                                          invoiceDetailList.removeAt(index);
                                          calculateResume();
                                        });
                                      },
                                      child: const Icon(Icons.cancel_rounded,color: Colors.black,)),
                                ],
                              ),
                            ),
                            if(index<invoiceDetailList.length-1)
                            Row(
                              children: [
                                Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                ),
                Padding(
                  padding: EdgeInsets.all(responsiveApp.setWidth(10)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              if(bookingList.isEmpty)
                                Icon(Icons.remove_shopping_cart_outlined,color:  Colors.grey, size: responsiveApp.setWidth(20),),
                              if(bookingList.isEmpty)
                                texto(text: "Ningún artículo seleccionado", size: responsiveApp.setSP(12),color: Colors.grey),
                              if(bookingList.isEmpty)
                                SizedBox(height: responsiveApp.setHeight(10)),
                              if(isMobileAndTablet(context))
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        setState((){

                                          pageIndex=2;
                                          //aassss
                                        });
                                      },
                                      child: Container(
                                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: responsiveApp.setWidth(10),
                                            ),
                                            SizedBox(
                                              width: responsiveApp.setWidth(2),
                                            ),
                                            texto(
                                              size: responsiveApp.setSP(10),
                                              text: 'Añadir',
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ]
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: responsiveApp.setHeight(10),),
        Container(
          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                    spreadRadius: -6,
                    blurRadius: 8,
                  offset: Offset(0, 0)
                )
              ]
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: texto(
                      text: 'Subtotal',
                      size: responsiveApp.setSP(12),
                    )
                  ),
                  Expanded(
                      child: texto(
                        text: '${subTotal.roundToDouble()}',
                        size: responsiveApp.setSP(12),
                      )
                  ),
                ],
              ),
              SizedBox(height: responsiveApp.setHeight(10),),
              Row(
                children: [
                  Expanded(
                      child: texto(
                        text: 'Descuento',
                        size: responsiveApp.setSP(12),
                      )
                  ),
                  Expanded(
                      child: texto(
                        text: '${discount_total.roundToDouble()}',
                        size: responsiveApp.setSP(12),
                      )
                  ),
                ],
              ),
              SizedBox(height: responsiveApp.setHeight(10),),
              Row(
                children: [
                  Expanded(
                      child: texto(
                        text: '${appData.getTaxData().tax_name} (${appData.getTaxData().percent.roundToDouble()}%)',
                        size: responsiveApp.setSP(12),
                      )
                  ),
                  Expanded(
                      child: texto(
                        text: '${itbis.roundToDouble()}',
                        size: responsiveApp.setSP(12),
                      )
                  ),
                ],
              ),
              SizedBox(height: responsiveApp.setHeight(10),),
              Row(
                children: [
                  Expanded(
                      child: texto(
                        text: 'TOTAL',
                        size: responsiveApp.setSP(14),
                        fontWeight: FontWeight.w500,
                      )
                  ),
                  Expanded(
                      child: texto(
                        text: '${total.roundToDouble()}',
                        size: responsiveApp.setSP(14),
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ],
              ),
              const Divider(),

              SizedBox(height: responsiveApp.setHeight(15),),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onHover: (v) {
                        setState(() {
                         // _isHovering[1] = v;
                        });
                      },
                      onTap: () {
                        warningMsg(
                            context: context,
                            mainMsg: '¡Advertencia!',
                            msg:
                            'Si cancela, no podra recuperar los datos.\n¿Seguro que sesea cancelar?',
                            okBtnText: 'Si, Cancelar',
                            okBtn: () {
                              limpiar();
                              Navigator.pop(context);
                            },
                            cancelBtnText: 'No, abortar',
                            cancelBtn: () {
                              Navigator.pop(context);
                            });
                      },
                      child: Container(
                        //height: responsiveApp.setHeight(50),
                        //width: isMobileAndTablet(context)? displayWidth(context) * 0.8 :  350.0,
                        padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(responsiveApp.setWidth(8)),
                          color:// _isHovering[1]
                              //? Colors.grey.withOpacity(0.6)
                               Colors.grey.withOpacity(0.8),
                        ),
                        child: Center(
                          child: Text(
                            "CANCELAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile(context)
                                  ? responsiveApp.setSP(12)
                                  : responsiveApp.setSP(12),
                              fontFamily: "Montserrat",
                              //letterSpacing: 3
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: responsiveApp.setWidth(10),
                  ),
                  Expanded(
                    child: InkWell(
                      onHover: (v) {
                        setState(() {
                          //_isHovering[0] = v;
                        });
                      },
                      onTap: (){
                        //testTicket();


                        //if(selectedChair !=null){

                            /*
                          }
                            if (appData.getAutoPrintEnabled()) {
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
                          } else {*/
                              //if (logoStatus == 'empty' ||
                               //   logoStatus == 'error') {
                               // setState(() {
                              //    logoStatus = 'loading';
                             //   });
                             //   loadImage();
                            //  } else {
                            selectPaymentMethod();


                            //  }
                           // }

                        /*}else{
                          warningMsg(
                            context: context,
                            mainMsg: '',
                            msg: '¡Debe seleccionar silla!',
                            okBtnText: 'Aceptar',
                            okBtn: (){Navigator.pop(context);},
                          );
                        }

                         */

                      },
                      child: Container(
                        //height: responsiveApp.setHeight(50),
                        //width: isMobileAndTablet(context)? displayWidth(context) * 0.8 :  350.0,
                        padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(responsiveApp.setWidth(8)),
                          color: //_isHovering[0]
                              //? const Color(0xff6C9BD2).withOpacity(0.8)
                               const Color(0xff6C9BD2),
                        ),
                        child: Center(
                          child: //printerStatus == 'loading' ||
                              logoStatus == 'loading'
                              ? SizedBox(
                              width: responsiveApp.setWidth(15),
                              height: responsiveApp.setWidth(15),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ))
                              : Text(
                            "FINALIZAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile(context)
                                  ? responsiveApp.setSP(12)
                                  : responsiveApp.setSP(12),
                              fontFamily: "Montserrat",
                              //letterSpacing: 3
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  selectPaymentMethod(){
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            spacing: 10,
            children: [
              Expanded(child: Text("Método de pago",style: Theme.of(context).textTheme.titleLarge,)),
              InkWell(
                  onTap: (){Navigator.pop(context);},
                  child: Icon(Icons.close_rounded, color: Colors.grey,)
              ),
            ],
          ),
          content: StatefulBuilder(
              builder: (BuildContext ctx, StateSetter setState) {
                return Column(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text("Por favor seleccione un metodo de pago", style: Theme.of(context).textTheme.titleSmall,),
                      ],
                    ),
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      texto(
                      text: 'Método de pago',
                      size: responsiveApp.setSP(10),
                      ),
                      Row(
                      children: [
                      Radio(
                      value: "Efectivo",
                      groupValue: groupPaymentMethod,
                      onChanged: (value) {
                      setState(() {
                      groupPaymentMethod = value;
                      selectedPaymentMethod = "cash";
                      });
                      },
                      ),
                      texto(text: "Efectivo", size: responsiveApp.setSP(12)),
                      SizedBox(
                      width: responsiveApp.setWidth(10),
                ),
                Radio(
                value: "Tarjeta",
                groupValue: groupPaymentMethod,
                onChanged: (value) {
                setState(() {
                groupPaymentMethod = value;
                selectedPaymentMethod = "card";
                setState(() {
                //totalPaidController.text = '$montoTotal';
                cashBack = 0.0;
                });
                });
                },
                ),
                texto(text: "Tarjeta", size: responsiveApp.setSP(12)),
                SizedBox(
                width: responsiveApp.setWidth(10),
                ),
                Radio(
                value: "Transferencia",
                groupValue: groupPaymentMethod,
                onChanged: (value) {
                setState(() {
                groupPaymentMethod = value;
                selectedPaymentMethod = "transfer";
                setState(() {
                //totalPaidController.text = '$montoTotal';
                cashBack = 0.0;
                });
                });
                },
                ),
                texto(text: "Transferencia", size: responsiveApp.setSP(12)),
                /*
            SizedBox(
              width: responsiveApp.setWidth(10),
            ),

            Radio(
              value: "Mixto",
              groupValue: groupPaymentMethod,
              onChanged: (value) {
                setState(() {
                  groupPaymentMethod = value;
                  selectedPaymentMethod = "mixed";
                  setState(() {
                    //totalPaidController.text = '$montoTotal';
                    cashBack = 0.0;
                  });
                });
              },
            ),
            texto(text: "Mixto", size: responsiveApp.setSP(12)),

             */
                ],
                ),
                ],
                ),
                    if (selectedPaymentMethod == 'cash' || selectedPaymentMethod == 'mixed')
                      Row(
                        children: [
                          Expanded(
                              child: customField(
                                  context: context,
                                  labelText: 'Efectivo',
                                  hintText: '9999',
                                  controller: totalPaidController,
                                  keyboardType: TextInputType.number,
                                  onEditingComplete: () => setState(() {
                                    cashBack =
                                        double.parse(totalPaidController.text) -
                                            total.roundToDouble();
                                  }))),
                          InkWell(
                            canRequestFocus: false,
                            onTap: () => setState(() {
                              cashBack = double.parse(totalPaidController.text) -
                                  total.roundToDouble();
                            }),
                            child: Container(
                              width: 30,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xff6C9BD2),
                                boxShadow: const [
                                  BoxShadow(
                                    //color: const Color(0xff6C9BD2).withOpacity(0.3),
                                    spreadRadius: -6,
                                    blurRadius: 8,
                                    offset: Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (selectedPaymentMethod == 'cash' || selectedPaymentMethod == 'mixed')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: texto(
                                  text: selectedPaymentMethod == 'mixed'?'Monto tarjeta:':'Cambio: ', size: responsiveApp.setSP(12))),
                          texto(
                              text: numberFormat.format(cashBack.roundToDouble()),
                              size: responsiveApp.setSP(18),
                              fontWeight: FontWeight.w500),
                        ],
                      ),
                  ],
                );
              }
          ),
          actions: [InkWell(
            onTap: () async {
              if (invoiceDetailList.isNotEmpty) {
                if(double.parse(totalPaidController.text==''?'0':totalPaidController.text)>=total || selectedPaymentMethod !='cash'){
                  Navigator.pop(context);
                  invoiceDate = DateTime.now();
                  loadingDialog(context);
                  await finishInvoice();
                  sendDoc();
                  Navigator.pop(context);
                }else {
                  CustomSnackBar().show(
                      context: context,
                      msg: '¡El nomto pagado no puede ser menor que el monto total!',
                      icon: Icons.warning_rounded,
                      color: Colors.orange);
                }
              } else {
                CustomSnackBar().show(
                  context: context,
                  msg: '¡La factura no tiene datos!',
                  icon: Icons.warning_rounded,
                  color: Colors.orange);
              }
            },
            child: Container(
              padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.white,),
                  Text("Finalizar", style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white),)
                ],
              ),
            ),
          )],
        )
    );
  }

  Widget paymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        texto(
          text: 'Método de pago',
          size: responsiveApp.setSP(10),
        ),
        Row(
          children: [
            Radio(
              value: "Efectivo",
              groupValue: groupPaymentMethod,
              onChanged: (value) {
                setState(() {
                  groupPaymentMethod = value;
                  selectedPaymentMethod = "cash";
                });
              },
            ),
            texto(text: "Efectivo", size: responsiveApp.setSP(12)),
            SizedBox(
              width: responsiveApp.setWidth(10),
            ),
            Radio(
              value: "Tarjeta",
              groupValue: groupPaymentMethod,
              onChanged: (value) {
                setState(() {
                  groupPaymentMethod = value;
                  selectedPaymentMethod = "card";
                  setState(() {
                    //totalPaidController.text = '$montoTotal';
                    cashBack = 0.0;
                  });
                });
              },
            ),
            texto(text: "Tarjeta", size: responsiveApp.setSP(12)),
            SizedBox(
              width: responsiveApp.setWidth(10),
            ),
            Radio(
              value: "Transferencia",
              groupValue: groupPaymentMethod,
              onChanged: (value) {
                setState(() {
                  groupPaymentMethod = value;
                  selectedPaymentMethod = "transfer";
                  setState(() {
                    //totalPaidController.text = '$montoTotal';
                    cashBack = 0.0;
                  });
                });
              },
            ),
            texto(text: "Transferencia", size: responsiveApp.setSP(12)),
            /*
            SizedBox(
              width: responsiveApp.setWidth(10),
            ),

            Radio(
              value: "Mixto",
              groupValue: groupPaymentMethod,
              onChanged: (value) {
                setState(() {
                  groupPaymentMethod = value;
                  selectedPaymentMethod = "mixed";
                  setState(() {
                    //totalPaidController.text = '$montoTotal';
                    cashBack = 0.0;
                  });
                });
              },
            ),
            texto(text: "Mixto", size: responsiveApp.setSP(12)),

             */
          ],
        ),
      ],
    );
  }

  Widget infoData(
      String label, Widget body, CrossAxisAlignment? crossAxisAlignment) {
    return Column(
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

  showPrinterWarning() {
    warningMsg(
        context: context,
        mainMsg: '¡Ups!',
        msg: "No se logró establecer conexión con la impresora.\n"
            "Verifique que la impresora esté encendida y conectada al router.\n\n"
            "Si el problema persiste contacte a su administrador.",
        cancelBtnText: 'Reintentar',
        okBtnText: 'Continuar sin imprimir',
        okBtn: () {
          Navigator.of(context).pop();
        },
        cancelBtn: () {
          setState(() {
            printerStatus = 'loading';
          });
          testTicket();
          Navigator.of(context).pop();
        });
  }

  Future<void> testTicket() async {
    printerStatus = 'disconnected';
    //getInvoiceNumber();
   // var printerState = Provider.of<PrinterState>(context, listen: false).selectedPrinterPos;

   // if(printerState!=null) {
      List<int> bytes = [];

      var paper = PaperSize.mm80;

    final profile = await CapabilityProfile.load();
      final generator = Generator(paper, profile);
      bytes = testReceipt(bytes, generator, profile);

      //finishInvoice();
      // limpiar();

   /* }else{
      warningMsg(
          context: context,
          mainMsg: '¡No se encontró impresora!',
          msg: "No se encontro la impresora seleccionada.",
          cancelBtnText: 'Ir a seleccionar',
          okBtnText: 'Continuar sin imprimir',
          okBtn: () {
            Navigator.of(context).pop();
            limpiar();
          },
          cancelBtn: () {
            viewWidget(context, PrinterSettingsWidget(
              onFinish: () {
                Navigator.pop(context);
                Navigator.pop(context);
                testTicket();
                setState(() {});
              },
            ), () {
              Navigator.pop(context);
              Navigator.pop(context);
              testTicket();
              setState(() {});
            });
          });
    }

    */

  }





  sendDoc() async {
    var profile = await CapabilityProfile.load();
    var paper = PaperSize.mm80;
    List<int> bytes = [];
    var generator =  Generator(paper, profile);
    var printer = PrinterWidget(fact: [],pageFormat: PdfPageFormat.roll80,
        onPageChanged: (format){
          setState(() {

          });
        },
        printAction:null
   );

        //bytes += generator.cut();
    //var doc = await printer.generatePdf(PdfPageFormat.roll80,"Factura");
    //bytes += generator.cut();
    //bytes += await printer.generatePdfBytes(pruebaVisFact());
   // bytes += generator.cut();
    //await printer.sendImageToLocalPrinter(doc);
   // Uint8List image =  await printer.generateReceiptImage();
    //var raster = printer.convertToEscPosRaster(revceipt,revceipt.length);
    try {
      await printer.sendJobToPrinter(
          await testReceipt(bytes, generator, profile));
    }catch(e){
      CustomSnackBar().show(context: context, msg: "Error al intentar imprimir el documento, revise la impresora", icon: Icons.error, color: Colors.red);
    }
    limpiar();
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
      //finalizar();
      finishInvoice();

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

  String getServiceNameById(int id) {
    final service = filteredServices.firstWhere(
          (s) => s.id == id,
      orElse: () => Service(id: id, name: 'Desconocido'),
    );
    return service.name ?? 'Desconocido';
  }

  String? getServiceTypeById(int id) {
    final service = bookingItemList.firstWhere(
          (s) => s.id == id,
      orElse: () => BookingItem(id: id, type: null),
    );
    return service.type;
  }

  testReceipt(List<int> bytes, var printer,CapabilityProfile profile) async{
    bytes += printer.setGlobalCodeTable('CP1252');
    //  bytes += printer.setGlobalCodeTable('CP437');
// 1. Decodificar logo desde Uint8List

    final img.Image? logoImage = img.decodeImage(appData.getCompanyData().logo.bytes);

    Map<int, Map<String, dynamic>> resumen = {};

    if(bookingItemList.any((e)=>e.type=='service')) {

      List<BookingItem> bList = [];
      // SELECT MAX(id) as lastId FROM invoice_details
      for (var item in bookingItemList) {
        if (item.type == 'service') {
          bList.add(item);
        }
      }

      for (var item in bList) {
        if (!resumen.containsKey(item.chair_id)) {
          resumen[item.chair_id!] = {
            'employee_name': item.employee_name,
            'services': <int, int>{},
          };
        }

        var lasId = await bdConnection.getData(
            onError: (e){},
            fields: "MAX(id) as lastId",
            table: " booking_items",
            where: 'business_service_id = ${item.business_service_id}',
            order: 'desc limit 1',
            orderBy: 'id',
            groupBy: 'id'
        );
        var services = resumen[item.chair_id]!['services'] as Map<int, int>;

        if (services.containsKey(item.business_service_id)) {
          services[item.business_service_id!] = int.parse(lasId[0]['lastId']);
        } else {
          services[item.business_service_id!] = int.parse(lasId[0]['lastId']);
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
            text: dateFormat.format(invoiceDate!),
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
            text: selectedCustomer?.replaceAll(RegExp(r'[^\d]'), '') ??
                "Clientes en general",
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
            text: appData
                .getUserData()
                .name,
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
            text: invoiceNumber,
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
              text: bookingItemList
                  .firstWhere((e) => e.business_service_id == serviceId)
                  .service_name!
                  .toString(),
              width: 5,
              styles: const PosStyles(align: PosAlign.left, underline: false),
            ),
            PosColumn(
              text: bookingItemList
                  .firstWhere((e) => e.business_service_id == serviceId && e.chair_id == chairId)
                  .quantity!
                  .toString(),
              width: 2,
              styles: const PosStyles(align: PosAlign.right, underline: false),
            ),
            PosColumn(
              text: "\$${bookingItemList.firstWhere((e) => e.business_service_id == serviceId && e.chair_id == chairId).amount!.toString()}",
              width: 3,
                styles: const PosStyles(align: PosAlign.right, underline: false),
              ),
          ]);
          totalEmployee += bookingItemList.firstWhere((e) => e.business_service_id == serviceId && e.chair_id == chairId).amount!;
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


        //copia
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
            text: dateFormat.format(invoiceDate!),
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
            text: selectedCustomer?.replaceAll(RegExp(r'[^\d]'), '') ??
                "Clientes en general",
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
            text: appData
                .getUserData()
                .name,
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
            text: invoiceNumber,
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
        (data['services'] as Map<int, int>).forEach((serviceId, itemServiceId) {

          bytes += printer.row([
            PosColumn(
              text: itemServiceId.toString(),
              width: 2,
              styles: const PosStyles(align: PosAlign.left, underline: false),
            ),
            PosColumn(
              text: bookingItemList
                  .firstWhere((e) => e.business_service_id == serviceId)
                  .service_name!
                  .toString(),
              width: 5,
              styles: const PosStyles(align: PosAlign.left, underline: false),
            ),
            PosColumn(
              text: bookingItemList
                  .firstWhere((e) => e.business_service_id == serviceId && e.chair_id == chairId)
                  .quantity!
                  .toString(),
              width: 2,
              styles: const PosStyles(align: PosAlign.right, underline: false),
            ),
            PosColumn(
              text: "\$${bookingItemList.firstWhere((e) => e.business_service_id == serviceId && e.chair_id == chairId).amount!.toString()}",
              width: 3,
              styles: const PosStyles(align: PosAlign.right, underline: false),
            ),
          ]);
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
        text: dateFormat.format(invoiceDate!),
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
        text: 'Cliente:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: selectedCustomer?.replaceAll(RegExp(r'[^\d]'), '')??"Clientes en general",
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
        text: numberFormat.format(subTotal.roundToDouble()),
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
        text: numberFormat.format(discount_total.roundToDouble()),
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
        text: numberFormat.format(itbis),
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
        text: numberFormat.format(total.roundToDouble()),
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
        text: selectedPaymentMethod == 'card' ? 'Tarjeta' : selectedPaymentMethod == 'transfer' ? 'Transferencia' :'Efectivo',
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
        text: '** ORIGINAL **',
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
                        child: pw.Text(dateFormat.format(DateTime.now()), textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      )
                    ]),



                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                      pw.Expanded(
                        child: pw.Text('Factura:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Expanded(
                        child: pw.Text(invoiceNumber, textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
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
                        child: pw.Text('Le atendió:', textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Expanded(
                        child: pw.Text(appData.getUserData().name, textAlign: pw.TextAlign.left,style: const  pw.TextStyle(fontSize: 9)),
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
                    child: pw.Text("${data.service!.name!} x ${data.quantity}", style: const  pw.TextStyle(fontSize: 9))),
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
                            child: pw.Text(numberFormat.format(subTotal), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
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
                              child: pw.Text(numberFormat.format(itbis), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
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
                            child: pw.Text(numberFormat.format(total), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text(selectedPaymentMethod == 'card' ? 'Tarjeta' : selectedPaymentMethod == 'transfer' ? 'Transferencia' :'Efectivo', style: const  pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Expanded(
                              child: pw.Text(totalPaidController.text != ''
                                  ? numberFormat.format(
                                  double.parse(totalPaidController.text).roundToDouble())
                                  : numberFormat.format(total), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9),),
                            ),

                          ],
                        ),
                      if(selectedPaymentMethod == 'mixed')
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text('Tarjeta', style: const  pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Expanded(
                              child: pw.Text(numberFormat.format((cashBack.roundToDouble())*(-1)), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
                            ),

                          ],
                        ),
                      //listSalidas[index].canProd = double.parse(_cantidadController.text);

                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text('Cambio:', style: const  pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Expanded(
                              child: pw.Text(selectedPaymentMethod == 'mixed'?'0':numberFormat.format(cashBack), textAlign: pw.TextAlign.right, style: const  pw.TextStyle(fontSize: 9)),
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
}
