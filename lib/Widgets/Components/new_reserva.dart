import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salon/Widgets/Components/timeSelectionWidget.dart';
import 'package:salon/util/db_connection.dart';
import 'package:salon/values/ResponsiveApp.dart';

import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../WebComponents/Body/Container/ProductContainer.dart';

class NewReserva extends StatefulWidget {
  const NewReserva({super.key});

  @override
  State<NewReserva> createState() => _NewReservaState();
}

class _NewReservaState extends State<NewReserva> {
  late ResponsiveApp responsiveApp;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _chairSearchController = TextEditingController();

  List<String> itemsCustomer = [];
  List<String> itemsChair = [];
  String? selectedCustomer;
  String? selectedChair;
  List<User> customerList=[];
  List<Chairs> chairList=[];
  List<BookingList> bookingList=[];
  List<BookingItem> bookingItemList=[];
  List<int> idServiceList=[];
  Map<int,int> serviceCant = {};

  int pageIndex = 0;
  double subTotal=0;
  double discount_total=0;
  double discount_percent=0;
  double total=0;
  double itbis=0;

  DateFormat dateFormat = DateFormat('dd/MM/yyyy h:mm a');
  var formatterOnlyDate = DateFormat('yyyy-MM-dd');
  var dateFormatOnlyDate = DateFormat('dd/MM/yyyy');
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getUsers()async{
    var db = Provider.of<BDConnection>(context, listen: false);
    var query = await db.getUsers(context: context,roleId: 3);

    if(itemsCustomer.isEmpty){
      for (var element in query){
        customerList.add(element);
        itemsCustomer.add(element.name);
      }
    }
    setState(() {

    });
  }

  getChairs()async{
      var db = Provider.of<BDConnection>(context, listen: false);
      var query = await db.getChairs(context: context);

      if (itemsChair.isEmpty) {
        for (var element in query) {
          chairList.add(element);
          itemsChair.add(element.chair_name);
        }
      }
      setState(() {

      });
    }

  limpiar(){
    setState(() {
      bookingItemList.clear();
      bookingList.clear();
      selectedCustomer = null;
      selectedChair = null;
      serviceCant.clear();
      idServiceList.clear();
      discount_total = 0;
      discount_percent = 0;
      total=0.0;
      subTotal=0.0;
      itbis = 0.0;
    });
  }

  calculateResume(){
    setState(() {
      subTotal = bookingList.fold(0.0, (a, b) =>
      double.parse(a.toString())
          + double.parse(b.bookingItem.quantity!.toString()) *
          double.parse(b.bookingItem.unit_price!.toString())
      );

      discount_total = bookingList.fold(0.0, (a, b) =>
      b.service!.discount_type! == 'percent'
          ? double.parse(a.toString())
          + ((double.parse(b.bookingItem.quantity!.toString()) *
              double.parse(b.bookingItem.unit_price!.toString())) *
              (double.parse(b.service!.discount!) / 100))
          : double.parse(a.toString())
          + double.parse(b.service!.discount!)
      );

      discount_percent = (discount_total / subTotal)*100;

      itbis = (subTotal - discount_total) * (AppData()
          .getTaxData()
          .percent
          .roundToDouble() / 100);
      total = (subTotal - discount_total) + itbis;
    });
  }

  finalizar()async{
    var db = Provider.of<BDConnection>(context, listen: false);
    if((await db.setBooking(
    context: context,
    user_id             : customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).id!,
    //chairId             : chairList.elementAt(itemsChair.indexOf(selectedChair!)).chair_id!,
    date_time           : selectedDate,
    status              : 'approved',
    payment_gateway     : 'cash',
    original_amount     : subTotal,
    discount            : discount_total,
    discount_percent    : discount_percent,
    tax_name            : AppData().getTaxData().tax_name,
    tax_percent         : AppData().getTaxData().percent,
    tax_amount          : itbis,
    amount_to_pay       : total,
    payment_status      : 'pending',
    source              : 'pos',
    itemList            : bookingItemList
    ))["success"]){

        CustomSnackBar().show(
            context: context,
            msg: 'El registro se completó con éxito!',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xff22d88d)
        );

        limpiar();
    }else{
    CustomSnackBar().show(
    context: context,
    msg: 'No se pudo completar la operación!',
    icon: Icons.error_outline_outlined,
    color: const Color(0xffFF525C)
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Row(
      children: [
        if(!isMobileAndTablet(context) ||
            pageIndex == 1)
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
          child: Padding(
            padding: responsiveApp
                .edgeInsetsApp
                .allMediumEdgeInsets,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
                child: _servicios()
            )

          ),
        ),
        if(!isMobileAndTablet(context) ||
            pageIndex == 0)
          SizedBox(
            width: responsiveApp.setWidth(
                8),),
        if(!isMobileAndTablet(context) ||
            pageIndex == 0)
        Expanded(child: _detalleVenta()),
      ],
    );
  }

  Widget _detalleVenta() {
    if (itemsCustomer.isEmpty) {
      getUsers();
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          Text("Cargando clientes.."),
        ],
      ),);
    } else if (itemsChair.isEmpty) {
      getChairs();
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          Text("Cargando sillas.."),
        ],
      ),);
    }else {
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
                  Padding(
                    padding: responsiveApp.edgeInsetsApp.onlySmallTopEdgeInsets,
                    child: Padding(
                      padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                      child: texto(
                          text: 'Cliente', size: responsiveApp.setSP(10)),
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
                                _searchController.text = '';
                              });
                            },
                            context: context,
                            hintIcon: Icons.person_rounded,
                            searchInnerWidgetHeight: responsiveApp.setHeight(
                                120),
                          ),
                        ),
                      ]
                  ),
                  if(selectedCustomer != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            padding: responsiveApp.edgeInsetsApp
                                .allSmallEdgeInsets,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(
                                  responsiveApp.setWidth(5)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    texto(
                                      size: responsiveApp.setSP(12),
                                      text: selectedCustomer != null
                                          ? customerList
                                          .elementAt(itemsCustomer.indexOf(
                                          selectedCustomer!))
                                          .name!
                                          : '',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            texto(
                                              text: 'E-mail',
                                              size: responsiveApp.setSP(12),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.mail_outline_rounded,
                                                  size: responsiveApp.setWidth(
                                                      12),
                                                  color: Colors.grey,),
                                                SizedBox(
                                                    width: responsiveApp
                                                        .setWidth(3)),
                                                texto(
                                                  size: responsiveApp.setSP(12),
                                                  text: selectedCustomer != null
                                                      ? customerList
                                                      .elementAt(
                                                      itemsCustomer.indexOf(
                                                          selectedCustomer!))
                                                      .email!
                                                      : '',
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
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            texto(
                                              text: 'Mobile',
                                              size: responsiveApp.setSP(12),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.phone_android_rounded,
                                                  size: responsiveApp.setWidth(
                                                      12),
                                                  color: Colors.grey,),
                                                SizedBox(
                                                    width: responsiveApp
                                                        .setWidth(3)),
                                                texto(
                                                  size: responsiveApp.setSP(12),
                                                  text: selectedCustomer != null
                                                      ? '${customerList
                                                      .elementAt(
                                                      itemsCustomer.indexOf(
                                                          selectedCustomer!))
                                                      .calling_code} '
                                                      '${customerList
                                                      .elementAt(
                                                      itemsCustomer.indexOf(
                                                          selectedCustomer!))
                                                      .mobile}'
                                                      : '',
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
                  Padding(
                    padding: responsiveApp.edgeInsetsApp.onlySmallTopEdgeInsets,
                    child: Padding(
                      padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                      child: texto(
                          text: 'Silla', size: responsiveApp.setSP(10)),
                    ),
                  ),
                  Row(
                      children: [
                        Expanded(
                          child:
                          customDropDown(
                            searchController: _chairSearchController,
                            items: itemsChair,
                            value: selectedChair,
                            onChanged: (value) {
                              setState(() {
                                selectedChair = value as String;
                                _chairSearchController.text = '';
                              });
                            },
                            context: context,
                            hintIcon: Icons.chair_rounded,
                            searchInnerWidgetHeight: responsiveApp.setHeight(
                                120),
                          ),
                        ),
                      ]
                  ),
                  Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: responsiveApp.edgeInsetsApp.onlySmallTopEdgeInsets,
                                        child: Padding(
                                          padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                          child: texto(
                                              text: 'Fecha', size: responsiveApp.setSP(10)),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: (){
                                          viewWidget(context, SingleChildScrollView(child: TimeSelectionWidget(
                                            origin: 'new_reserva_company',
                                            onDateTimeSelected: (d){
                                              setState(() {
                                                selectedDate = d;
                                                selectedTime = TimeOfDay.fromDateTime(d);
                                              });
                                              Navigator.pop(context);
                                            },
                                          )), () {
                                            Navigator.pop(context);
                                        });
                                        },
                                        child: Padding(
                                          padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                          child: Text(dateFormatOnlyDate.format(selectedDate)),
                                        ),
                                      ),
                                    ],
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
                                      Padding(
                                        padding: responsiveApp.edgeInsetsApp.onlySmallTopEdgeInsets,
                                        child: Padding(
                                          padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                          child: texto(
                                              text: 'Hora', size: responsiveApp.setSP(10)),
                                        ),
                                      ),
                                      Padding(
                                        padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                        child: Text(selectedTime.format(context).toString()),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: responsiveApp.edgeInsetsApp
                              .allSmallEdgeInsets,
                          color: Theme
                              .of(context)
                              .primaryColor,
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
                  if(bookingList.isNotEmpty)
                    Column(
                      children:
                      List.generate(
                        bookingList.length,
                            (int index) {
                          return Column(
                            children: [
                              ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: texto(
                                        size: responsiveApp.setSP(12),
                                        text: '${bookingList[index].service!.name}',
                                      ),
                                    ),
                                    SizedBox(
                                      width: responsiveApp.setWidth(60),
                                      child: Center(
                                        child: texto(
                                          size: responsiveApp.setSP(12),
                                          text: '\$${bookingList[index].bookingItem.unit_price}',
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
                                                  if(serviceCant[bookingList[index].service!.id]! > 1){
                                                    serviceCant.update(bookingList[index].service!.id!, (value) => value-1);
                                                    bookingList[index]=BookingList(
                                                        service: Service(
                                                          name: bookingList[index].service!.name,
                                                          id: bookingList[index].service!.id,
                                                          price: bookingList[index].service!.price,
                                                          discount: bookingList[index].service!.discount ?? '0',
                                                          discount_type: bookingList[index].service!.discount_type ?? 'percent',
                                                        ),
                                                        bookings: Bookings(
                                                          payment_status: 'completed',
                                                          user_id: selectedCustomer!=null?customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).id!:0,
                                                        ),
                                                        bookingItem: BookingItem(
                                                          business_service_id: bookingList[index].service!.id,
                                                          unit_price: double.parse(bookingList[index].service!.price!),
                                                          quantity: serviceCant[bookingList[index].service!.id],
                                                          amount: (serviceCant[bookingList[index].service!.id]! * double.parse(bookingList[index].service!.price!)).toDouble(),
                                                        )
                                                    );
                                                    bookingItemList[index]=BookingItem(
                                                      business_service_id: bookingList[index].service!.id,
                                                      unit_price: double.parse(bookingList[index].service!.price!),
                                                      quantity: serviceCant[bookingList[index].service!.id],
                                                      amount: (serviceCant[bookingList[index].service!.id]! * double.parse(bookingList[index].service!.price!)).toDouble(),
                                                    );
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
                                                      text: "${bookingList[index].bookingItem.quantity}",
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
                                                setState(() {
                                                  serviceCant.update(bookingList[index].service!.id!, (value) => value+1);
                                                  bookingList[idServiceList.indexOf(bookingList[index].service!.id!)]=BookingList(
                                                      service: Service(
                                                        name: bookingList[index].service!.name,
                                                        id: bookingList[index].service!.id,
                                                        price: bookingList[index].service!.price,
                                                        discount: bookingList[index].service!.discount ?? '0',
                                                        discount_type: bookingList[index].service!.discount_type ?? 'percent',
                                                      ),
                                                      bookings: Bookings(
                                                        payment_status: 'completed',
                                                        chair_id: 1,
                                                        user_id: selectedCustomer!=null?customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).id!:0,
                                                      ),
                                                      bookingItem: BookingItem(
                                                        business_service_id: bookingList[index].service!.id,
                                                        unit_price: double.parse(bookingList[index].service!.price!),
                                                        quantity: serviceCant[bookingList[index].service!.id],
                                                        amount: (serviceCant[bookingList[index].service!.id]! * double.parse(bookingList[index].service!.price!)).toDouble(),
                                                      )
                                                  );
                                                  bookingItemList[idServiceList.indexOf(bookingList[index].service!.id!)]= BookingItem(
                                                    business_service_id: bookingList[index].service!.id,
                                                    unit_price: double.parse(bookingList[index].service!.price!),
                                                    quantity: serviceCant[bookingList[index].service!.id],
                                                    amount: (serviceCant[bookingList[index].service!.id]! * double.parse(bookingList[index].service!.price!)).toDouble(),
                                                  );
                                                  calculateResume();
                                                });
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
                                          text: '\$${bookingList[index].bookingItem.amount}',
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                        onTap: (){
                                          setState(() {
                                            serviceCant.remove(bookingList[index].service!.id);
                                            bookingList.remove(bookingList.elementAt(index));
                                            calculateResume();
                                          });
                                        },
                                        child: const Icon(Icons.cancel_rounded,color: Colors.black,)),
                                  ],
                                ),
                              ),
                              if(index < bookingList.length - 1)
                                Row(
                                  children: [
                                    Expanded(child: Container(
                                      height: responsiveApp.setHeight(1),
                                      color: Colors.grey.withOpacity(0.3),)),
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
                                  Icon(Icons.remove_shopping_cart_outlined,
                                    color: Colors.grey,
                                    size: responsiveApp.setWidth(20),),
                                if(bookingList.isEmpty)
                                  texto(text: "Ningún artículo seleccionado",
                                      size: responsiveApp.setSP(12),
                                      color: Colors.grey),
                                if(bookingList.isEmpty)
                                  SizedBox(height: responsiveApp.setHeight(10)),
                                if(isMobileAndTablet(context))
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            pageIndex = 1;
                                          });
                                        },
                                        child: Container(
                                          padding: responsiveApp.edgeInsetsApp
                                              .allSmallEdgeInsets,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                responsiveApp.setWidth(5)),
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: responsiveApp.setWidth(
                                                    10),
                                              ),
                                              SizedBox(
                                                width: responsiveApp.setWidth(
                                                    2),
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
                          padding: responsiveApp.edgeInsetsApp
                              .allMediumEdgeInsets,
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(responsiveApp.setWidth(8)),
                            color: // _isHovering[1]
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
                        onTap: () {
                          if (selectedCustomer != null &&
                              selectedChair != null) {
                            finalizar();
                          } else {
                            warningMsg(
                              context: context,
                              mainMsg: '',
                              msg: '¡Debe seleccionar silla y cliente!',
                              okBtnText: 'Aceptar',
                              okBtn: () {
                                Navigator.pop(context);
                              },
                            );
                          }
                        },
                        child: Container(
                          //height: responsiveApp.setHeight(50),
                          //width: isMobileAndTablet(context)? displayWidth(context) * 0.8 :  350.0,
                          padding: responsiveApp.edgeInsetsApp
                              .allMediumEdgeInsets,
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(responsiveApp.setWidth(8)),
                            color: //_isHovering[0]
                            //? const Color(0xff6C9BD2).withOpacity(0.8)
                            const Color(0xff6C9BD2),
                          ),
                          child: Center(
                            child: //printerStatus == 'loading' ||
                            Text(
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
  }

  Widget _servicios(){
    return FutureBuilder(
        future: BDConnection().getCategory(context),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }else {
            return Column(
              children: List.generate(
                  snapshot.data.length,
                      (index){
                    snapshot.data[index].name!='all'?AppData().setView('only'):AppData().setView('all');
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              snapshot.data[index].name!='all'?"${snapshot.data[index].name}":'Todos',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: displayWidth(context),
                          child: FutureBuilder(
                              future: BDConnection().getServices(context: context,searchBy: 'category_id',id: snapshot.data[index].id),
                              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                if (snapshot.data == null) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }else {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: List.generate(
                                        snapshot.data.length,
                                            (index){
                                          isHovering.add(false);
                                          return Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(responsiveApp.setWidth(8)),
                                                child: ProductContainer(
                                                  snapshot.data[index],
                                                  onHoverAdd: (v){
                                                    setState((){
                                                      isHovering[index+8]=v;
                                                    });
                                                  },
                                                  addColor: isHovering[index+8]?Theme.of(context).primaryColor.withOpacity(0.85):Theme.of(context).primaryColor,
                                                  onAddPress: (){
                                                    setState(() {
                                                      if(serviceCant.containsKey(snapshot.data[index].id)){
                                                        serviceCant.update(snapshot.data[index].id, (value) => value+1);
                                                        bookingList[idServiceList.indexOf(snapshot.data[index].id)]=BookingList(
                                                            service: Service(
                                                              name: snapshot.data[index].name,
                                                              id: snapshot.data[index].id,
                                                              price: snapshot.data[index].price,
                                                              discount: snapshot.data[index].discount ?? 0,
                                                              discount_type: snapshot.data[index].discount_type ?? 'percent',
                                                            ),
                                                            bookings: Bookings(
                                                              payment_status: 'completed',
                                                              chair_id: 1,
                                                              user_id: selectedCustomer!=null?customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).id!:0,
                                                            ),
                                                            bookingItem: BookingItem(
                                                              business_service_id: snapshot.data[index].id,
                                                              unit_price: double.parse(snapshot.data[index].price),
                                                              quantity: serviceCant[snapshot.data[index].id],
                                                              amount: (serviceCant[snapshot.data[index].id]! * double.parse(snapshot.data[index].price)).toDouble(),
                                                            )
                                                        );
                                                        bookingItemList[idServiceList.indexOf(snapshot.data[index].id)]= BookingItem(
                                                          business_service_id: snapshot.data[index].id,
                                                          unit_price: double.parse(snapshot.data[index].price),
                                                          quantity: serviceCant[snapshot.data[index].id],
                                                          amount: (serviceCant[snapshot.data[index].id]! * double.parse(snapshot.data[index].price)).toDouble(),
                                                        );
                                                      }else{
                                                        serviceCant.putIfAbsent(snapshot.data[index].id, () => 1);
                                                        idServiceList.add(snapshot.data[index].id);
                                                        bookingList.add(
                                                            BookingList(
                                                                service: Service(
                                                                  name: snapshot.data[index].name,
                                                                  id: snapshot.data[index].id,
                                                                  price: snapshot.data[index].price,
                                                                  discount: snapshot.data[index].discount ?? 0,
                                                                  discount_type: snapshot.data[index].discount_type ?? 'percent',
                                                                ),
                                                                bookings: Bookings(
                                                                  payment_status: 'completed',
                                                                  discount: double.parse(snapshot.data[index].discount.toString()),
                                                                  user_id: selectedCustomer!=null?customerList.elementAt(itemsCustomer.indexOf(selectedCustomer!)).id!:0,
                                                                ),
                                                                bookingItem: BookingItem(
                                                                  business_service_id: snapshot.data[index].id,
                                                                  unit_price: double.parse(snapshot.data[index].price),
                                                                  quantity: serviceCant[snapshot.data[index].id],
                                                                  amount: (serviceCant[snapshot.data[index].id]! * double.parse(snapshot.data[index].price)).toDouble(),
                                                                )
                                                            )
                                                        );
                                                        bookingItemList.add(BookingItem(
                                                          business_service_id: snapshot.data[index].id,
                                                          unit_price: double.parse(snapshot.data[index].price),
                                                          quantity: serviceCant[snapshot.data[index].id],
                                                          amount: (serviceCant[snapshot.data[index].id]! * double.parse(snapshot.data[index].price)).toDouble(),
                                                        ));
                                                      }
                                                      calculateResume();
                                                    });
                                                    CustomSnackBar().show(color: Colors.green, context: context, icon: Icons.check_circle_outline_rounded,msg: 'Operación realizada con éxito!');
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: responsiveApp.setWidth(5),),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              }
                          ),
                        )
                      ],
                    );
                  }
              ),
            );
          }
        }
    );
  }
}
