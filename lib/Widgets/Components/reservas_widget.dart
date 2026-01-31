
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salon/Widgets/Components/new_reserva.dart';
import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';

class BookingsWidget extends StatefulWidget {
  const BookingsWidget({Key? key}) : super(key: key);

  @override
  State<BookingsWidget> createState() => _BookingsWidgetState();
}

class _BookingsWidgetState extends State<BookingsWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  bool hasData = false;
  int bookingId = 0;
  bool firstTime =true;
  bool verDetails = false;
  final items = ['Hoy','Esta semana','Este mes', 'Rango de fecha'];
  String selectedValue = 'Rango de fecha';
  final itemsStatus = ['Todo','Completado','Pendiente','Aprobado', 'En progreso', 'Cancelado'];
  String selectedStatus = 'Todo';
  final itemsCustomer = ['Todos'];
  String selectedCustomer = 'Todos';
  final itemsLocation = ['Todos'];
  String selectedLocation = 'Todos';
  List<User> customerList=[];
  List<BookingList>? bookingList;
  List<Sucursal> sucList=[];
  String customer = 'all';
  String location = 'all';
  String _status = 'all';
  String statusEdited = 'all';
  String selectedStatusEdited = 'Todo';
  String fechaInicio = "${DateTime.now().subtract(const Duration(hours: (24 * 60))).year}-${DateTime.now().subtract(const Duration(hours: (24 * 60))).month
      .toString().padLeft(2, '0')}-${DateTime.now().subtract(const Duration(hours: (24 * 60))).day
      .toString().padLeft(2, '0')} 00:00:00";
  String fechaFin =
  "${DateTime.now().year.toString()}-${DateTime.now().month
      .toString().padLeft(2, '0')}-${DateTime.now().day
      .toString().padLeft(2, '0')} 23:59:59";
  bool editStatus = false;
  final List<bool> _isHovering = [
    false,
    false,
    false,
  ];
  int pageIndex = 0;

  setlists() async{
    var queryUser = await bdConnection.getUsers(context: context,roleId: 3);
    var queryLocation = await bdConnection.getSucursales(context);

    for (var element in queryUser){
      customerList.add(element);
      itemsCustomer.add(element.name);
    }
    for (var element in queryLocation){
      sucList.add(element);
      itemsLocation.add(element.name);
    }
  }
  getBookings() async{
      var query = await bdConnection.getCustomerBookingList(context: context,condition: bookingId, field: 'id');

      bookingList = List.from(query);

      setState(() {

      });
    }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    bdConnection = BDConnection();
    if(firstTime) {
      if(sucList.length<=1 && customerList.length<=1)setlists();
      firstTime=false;
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
        child: Container(
          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
         // color: Colors.blueGrey,
          child: Row(
            children: [
              if(isMobileAndTablet(context))
                IconButton(onPressed: ()=> verDetails?setState((){verDetails=false;}): mainScaffoldKey.currentState!.openDrawer(), icon: Icon(verDetails?Icons.arrow_back_rounded:Icons.menu_rounded,)),
              if(!isMobileAndTablet(context) && pageIndex==1)
                IconButton(onPressed: ()=> setState(()=>pageIndex=0), icon: Icon(verDetails?Icons.arrow_back_rounded:Icons.menu_rounded,)),
              const Expanded(
                child: Text("Reservas",
                  style: TextStyle(
                    //color: Colors.white,
                    fontSize: 18,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    pageIndex=1;
                  });
                },
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.white,),
                      Text("Nuevo",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),),
                    ],
                  ),
                ),
              ),
              if(isMobileAndTablet(context))
                InkWell(
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          content: SizedBox(
                            height: displayHeight(context)*0.5,
                            width: displayWidth(context)*0.8,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                height: displayHeight(context)*0.5,
                                width: displayWidth(context)*0.8,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Padding(
                                    padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        periodo(),
                                        SizedBox(height: responsiveApp.setHeight(5),),
                                        Padding(padding: responsiveApp.edgeInsetsApp
                                            .allSmallEdgeInsets,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  color: Colors.grey,
                                                  height: responsiveApp.setHeight(1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: responsiveApp.setHeight(5),),
                                        _filterStatus(
                                          value: selectedStatus,
                                          onChanged: (newValue) {
                                            setState((){
                                              selectedStatus = newValue.toString();
                                              _status = newValue.toString()=='Completado' ?'completed'
                                                  :newValue.toString()=='Pendiente' ?'pending'
                                                  :newValue.toString()=='Aprobado' ?'approved'
                                                  :newValue.toString()=='En progreso' ?'in progress'
                                                  :newValue.toString()=='Cancelado' ?'canceled'
                                                  :'all';
                                            });
                                              firstTime = true;
                                              verDetails = false;
                                          },
                                          items: itemsStatus
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) => DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              ))
                                              .toList(),
                                        ),
                                        SizedBox(height: responsiveApp.setHeight(5),),
                                        Padding(padding: responsiveApp.edgeInsetsApp
                                            .allSmallEdgeInsets,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  color: Colors.grey,
                                                  height: responsiveApp.setHeight(1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: responsiveApp.setHeight(5),),
                                        _filterCustomer(),
                                        SizedBox(height: responsiveApp.setHeight(5),),
                                        Padding(padding: responsiveApp.edgeInsetsApp
                                            .allSmallEdgeInsets,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  color: Colors.grey,
                                                  height: responsiveApp.setHeight(1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: responsiveApp.setHeight(5),),
                                        _filterLocation(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          actionsAlignment: MainAxisAlignment.end,
                          actions: [
                            InkWell(
                              autofocus: true,
                              onTap: (){
                                setState((){});
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 110,
                                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.blueGrey.withOpacity(0.8),
                                ),
                                child: const Center(child: Text('Finalizar', style: TextStyle(color: Colors.white))),
                              ),
                            ),
                          ],
                        )
                    );
                  },
                  child: Image.asset(
                    'assets/images/filter_filled_icon.png',
                    color: Colors.grey,
                    // fit: BoxFit.fill,
                    height: responsiveApp.setWidth(30),
                    width: responsiveApp.setWidth(30),
                  ),
                ),
              SizedBox(width: responsiveApp.setWidth(10),),
            ],
          ),
        ),
      ),

      body: pageIndex==1? NewReserva(): Row(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                return Future.delayed(
                  const Duration(seconds: 1),
                      () {
                    setState((){});
                  },
                );
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                child: !isMobileAndTablet(context)?detalle_cliente():verDetails?reservaDetalle():detalle_cliente(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget periodo(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Período',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: responsiveApp.setSP(12),
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                  ),),
                SizedBox(height: responsiveApp.setHeight(5),),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(10), vertical: responsiveApp.setHeight(1)),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),

                  // dropdown below..
                  child: DropdownButton<String>(
                    value: selectedValue,
                    onChanged: (newValue) {
                      setState((){
                        selectedValue = newValue.toString();
                        fechaInicio = newValue.toString()=='Hoy'?DateTime.now().subtract(Duration(hours: DateTime.now().hour,minutes: DateTime.now().minute,seconds: DateTime.now().second)).toString().split(".")[0]
                            :newValue.toString()=='Esta semana'?DateTime(DateTime.now().year,DateTime.now().month,(DateTime.now().day-DateTime.now().weekday)+1).toString().split('.')[0]
                            :newValue.toString()=='Este mes'?DateTime(DateTime.now().year, DateTime.now().month,1).toString().split('.')[0]
                            :DateTime.now().subtract(const Duration(hours: 24 * 30)).toString();
                        fechaFin =
                        newValue.toString()=='Este mes'?DateTime(DateTime.now().year,DateTime.now().month,daysInMonth(DateTime.now().month)).toString().split('.')[0]
                            :"${DateTime.now().year.toString()}-${DateTime.now().month
                            .toString().padLeft(2, '0')}-${DateTime.now().day
                            .toString().padLeft(2, '0')} 23:59:59";
                      });
                      firstTime = true;
                      verDetails = false;
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
            if(!isMobileAndTablet(context))
              Row(
                children: [
                  if(selectedValue=='Rango de fecha')
                    SizedBox(width: responsiveApp.setWidth(8),),
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
                              initialDate: DateTime.now().subtract(const Duration(hours: 24 *30)),
                              firstDate:
                              DateTime.now().subtract(const Duration(hours: 24 * 365)),
                              lastDate: DateTime.now(),
                            ).then((newDate) {
                              if (newDate != null) {
                                setState(() {
                                  fechaInicio = "${newDate.year.toString()}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')} 00:00:00";
                                  firstTime = true;
                                  verDetails = false;
                                });
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(8), vertical: responsiveApp.setHeight(10)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: const Color(0xff000000).withOpacity(0.8),
                                ),
                                SizedBox(width: responsiveApp.setHeight(8),),
                                Text(fechaInicio.substring(0,10)),
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
                              lastDate: DateTime.now().add(const Duration(hours: 24 * 30)),
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
                                    firstTime = true;
                                    verDetails = false;
                                  }
                                });
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(8), vertical: responsiveApp.setHeight(10)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.withOpacity(0.1),

                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: const Color(0xff000000).withOpacity(0.8),
                                ),
                                SizedBox(width: responsiveApp.setHeight(10),),
                                Text(fechaFin.substring(0,10)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
        if(isMobileAndTablet(context)&&selectedValue=='Rango de fecha')
          SizedBox(height: responsiveApp.setHeight(8),),
        if(isMobileAndTablet(context))
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
                              firstTime = true;
                              verDetails = false;
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(8), vertical: responsiveApp.setHeight(10)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.withOpacity(0.1),

                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color:const Color(0xff000000).withOpacity(0.8),
                            ),
                            SizedBox(width: responsiveApp.setWidth(8),),
                            Text(fechaInicio.substring(0,10)),
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
                          lastDate: DateTime.now().add(const Duration(hours: 24 * 30)),
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
                                firstTime = true;
                                verDetails = false;
                              }
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(8), vertical: responsiveApp.setHeight(10)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          color: Colors.grey.withOpacity(0.1),

                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: const Color(0xff000000).withOpacity(0.8),
                            ),
                            SizedBox(width: responsiveApp.setHeight(8),),
                            Text(fechaFin.substring(0,10)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }
  Widget _filterStatus(
      {required String value,
      required List<DropdownMenuItem<String>>? items,
      required Function(String?) onChanged}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estado',
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontSize: responsiveApp.setSP(12),
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
          ),),
        SizedBox(height: responsiveApp.setHeight(5),),
        Container(
          padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(10), vertical: responsiveApp.setHeight(1)),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),

          // dropdown below..
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items,

            // add extra sugar..
            icon: const Icon(Icons.arrow_drop_down_rounded),
            iconSize: 42,
            underline: const SizedBox(),
          ),
        ),
      ],
    );
  }
  Widget _filterCustomer(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cliente',
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontSize: responsiveApp.setSP(12),
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
          ),),
        SizedBox(height: responsiveApp.setHeight(5),),
        Container(
          padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(10), vertical: responsiveApp.setHeight(1)),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),

          // dropdown below..
          child: DropdownButton<String>(
            value: selectedCustomer,
            onChanged: (newValue) {
              setState((){
                selectedCustomer = newValue.toString();
                customer = newValue.toString()=='Todos'
                    ?'all':newValue.toString();
              });
              firstTime = true;
              verDetails = false;
            },
            items: itemsCustomer
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
    );
  }

  Widget _filterLocation(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sucursal',
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontSize: responsiveApp.setSP(12),
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
          ),),
        SizedBox(height: responsiveApp.setHeight(5),),
        Container(
          padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(10), vertical: responsiveApp.setHeight(1)),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),

          // dropdown below..
          child: DropdownButton<String>(
            value: selectedLocation,
            onChanged: (newValue) {
              setState((){
                selectedLocation = newValue.toString();
                location = newValue.toString()=='Todos'
                    ?'all':newValue.toString();
              });
              firstTime = true;
              verDetails = false;
            },
            items: itemsLocation
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
    );
  }
  Widget detalle_cliente(){
    return Padding(
      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          if(!isMobileAndTablet(context))
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(8)),
                        color: Colors.white,
                        boxShadow: const[
                          BoxShadow(
                            spreadRadius: -6,
                            blurRadius: 8,
                            offset: Offset(0, 0),
                          )
                        ]
                    ),
                    child: Row(
                      children: [
                        periodo(),
                        SizedBox(width: responsiveApp.setWidth(5),),
                        Padding(padding: responsiveApp.edgeInsetsApp
                            .allSmallEdgeInsets,
                          child: Container(
                            color: Colors.grey,
                            width: responsiveApp.setWidth(1),
                            height: responsiveApp.setHeight(45),
                          ),
                        ),
                        SizedBox(width: responsiveApp.setWidth(5),),
                        _filterStatus(
                          value: editStatus
                              ?selectedStatusEdited:selectedStatus,
                          onChanged: (newValue) {
                            setState((){
                              selectedStatus = newValue.toString();
                              _status = newValue.toString()=='Completado' ?'completed'
                                  :newValue.toString()=='Pendiente' ?'pending'
                                  :newValue.toString()=='Aprobado' ?'approved'
                                  :newValue.toString()=='En progreso' ?'in progress'
                                  :newValue.toString()=='Cancelado' ?'canceled'
                                  :'all';
                            });
                              firstTime = true;
                              verDetails = false;
                          },
                          items: itemsStatus
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                              .toList(),
                        ),
                        SizedBox(width: responsiveApp.setWidth(5),),
                        Padding(padding: responsiveApp.edgeInsetsApp
                            .allSmallEdgeInsets,
                          child: Container(
                            color: Colors.grey,
                            width: responsiveApp.setWidth(1),
                            height: responsiveApp.setHeight(45),
                          ),
                        ),
                        SizedBox(width: responsiveApp.setWidth(5),),
                        _filterCustomer(),
                        SizedBox(width: responsiveApp.setWidth(5),),
                        Padding(padding: responsiveApp.edgeInsetsApp
                            .allSmallEdgeInsets,
                          child: Container(
                            color: Colors.grey,
                            width: responsiveApp.setWidth(1),
                            height: responsiveApp.setHeight(45),
                          ),
                        ),
                        SizedBox(width: responsiveApp.setWidth(5),),
                        _filterLocation(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsiveApp.setHeight(10),),
          //if(hasData)
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reservas(),
                if(verDetails)
                  Expanded(child: reservaDetalle()),
              ],
            ),
        ],
      ),
    );
  }

  Widget reservas(){
    return FutureBuilder(
        future: bdConnection.getBookingList(
            context: context,
            location: location,
            userName: customer,
            status: _status,status2: _status,
            payment_status: 'all',
            fechaInicio: fechaInicio,
            fechaFin: fechaFin),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }else if(snapshot.data.isEmpty){
            return SizedBox(
              width: displayWidth(context)*0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_copy_outlined,size: responsiveApp.setWidth(80),color: Colors.grey),
                  SizedBox(height: responsiveApp.setHeight(20),),
                  texto(
                      text: 'No hay nada que mostrar',
                      size: responsiveApp.setSP(14),
                      color: Colors.grey,
                      fontFamily: 'Montserrat'
                  ),
                ],
              ),
            );
          }else {
            int repetido = 1;
            return Row(
              children: [
                Padding(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  child: Container(
                    width: !isMobileAndTablet(context)?displayWidth(context)*0.30:displayWidth(context)*0.92,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                        color: Colors.white,
                        boxShadow: const[
                          BoxShadow(
                            spreadRadius: -6,
                            blurRadius: 8,
                            offset: Offset(0,0),
                          )
                        ]
                    ),
                    child: Column(
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
                              child: Column(
                                children: List.generate(
                                  snapshot.data.length,
                                      (index){
                                    index>0&&snapshot.data[index].bookings.id==snapshot.data[index-1].bookings.id?repetido++:repetido=1;

                                    return Column(
                                      children: [
                                        index<snapshot.data.length-1&&snapshot.data[index].bookings.id!=snapshot.data[index+1].bookings.id
                                            ? reservar_list(snapshot,index,repetido)
                                            : index==snapshot.data.length-1?reservar_list(snapshot,index,repetido):const SizedBox(),
                                        index<snapshot.data.length-1&&snapshot.data[index].bookings.id!=snapshot.data[index+1].bookings.id
                                            ? Row(
                                          children: [
                                            Expanded(child: Container(height: responsiveApp.setHeight(1),)),
                                          ],
                                        )
                                            : index==snapshot.data.length-1?Row(
                                          children: [
                                            Expanded(child: Container(height: responsiveApp.setHeight(1),)),
                                          ],
                                        ):const SizedBox(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        }
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
                      '${snapshot.data[index].bookingItem.quantity}'),
                  if(repetido >= 2)
                    texto(size: responsiveApp.setSP(12), text: '2. ${snapshot.data[index-(repetido-2)].service.name} x '
                        '${snapshot.data[index].bookingItem.quantity}'),
                  if(repetido >= 3)
                    texto(size: responsiveApp.setSP(12), text: '3. ${snapshot.data[index-(repetido-3)].service.name} x '
                        '${snapshot.data[index].bookingItem.quantity}'),
                  if(repetido >= 4)
                    texto(size: responsiveApp.setSP(12), text: '4. ${snapshot.data[index-(repetido-4)].service.name} x '
                        '${snapshot.data[index].bookingItem.quantity}'),
                  if(repetido >= 5)
                    texto(size: responsiveApp.setSP(12), text: '5. ${snapshot.data[index-(repetido-5)].service.name} x '
                        '${snapshot.data[index].bookingItem.quantity}'),
                ],
              ),
            ),

            Padding(
              padding: responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets,
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
                color: Colors.black.withOpacity(0.1),),
            ),
            SizedBox(
              height: responsiveApp.setHeight(60),
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded,color: Colors.blueGrey),
                  onPressed: (){
                      verDetails=true;
                      bookingId = snapshot.data[index].bookings.id;
                      getBookings();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget reservaDetalle(){
    var outputFormat = DateFormat('dd-MMM-yyyy hh:mm a');
    print("booking id  en reservas: ${bookingId}");
    return Builder(
        builder: (BuildContext ctx) {
          if (bookingList == null) {
            getBookings();
            return const Center(
              child: CircularProgressIndicator(),
            );
          }else {
            print("Data en reservas: ${bookingList!}");
            return Padding(
              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
              child: Container(
                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        responsiveApp.setWidth(5)),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: responsiveApp.setWidth(5),
                                right: responsiveApp.setWidth(15),
                                top: responsiveApp.setHeight(5),
                                bottom: responsiveApp.setHeight(5)),
                            child: bookingList![0].user!.image!=null&&bookingList![0].user!.image!=''
                                ? userImage(
                                width: isMobileAndTablet(context)?responsiveApp.setWidth(100) : responsiveApp.setWidth(50),
                                height: isMobileAndTablet(context)?responsiveApp.setWidth(100) : responsiveApp.setWidth(50),
                                borderRadius: BorderRadius.circular(100),
                                shadowColor: Theme.of(context).shadowColor,
                                image: Image.memory(bookingList![0].user!.image!.bytes!,))
                                : userImage(
                                width: isMobileAndTablet(context)?responsiveApp.setWidth(100) : responsiveApp.setWidth(50),
                                height: isMobileAndTablet(context)?responsiveApp.setWidth(100) : responsiveApp.setWidth(50),
                                borderRadius: BorderRadius.circular(100),
                                shadowColor: Theme.of(context).shadowColor,
                                image: Image.asset('assets/images/default-avatar-user.png')),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          texto(
                            size: responsiveApp.setSP(14),
                            text: bookingList![0].user!.name!,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      SizedBox(height: responsiveApp.setHeight(5),),
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
                                        text: bookingList![0].user!.email!,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ]
                            ),
                          ),
                          if(!isMobileAndTablet(context))
                          Padding(padding: responsiveApp.edgeInsetsApp
                              .allSmallEdgeInsets,
                            child: Container(
                              color: Colors.grey,
                              width: responsiveApp.setWidth(1),
                              height: responsiveApp.setHeight(30),
                            ),
                          ),
                          if(!isMobileAndTablet(context))
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
                                        text: '${bookingList![0].user!.calling_code} '
                                            '${bookingList![0].user!.mobile}',
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ]
                            ),
                          ),
                        ],
                      ),
                      if(isMobileAndTablet(context))
                        SizedBox(height: responsiveApp.setHeight(2),),
                      if(isMobileAndTablet(context))
                        Row(
                          children: [
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
                                          text:  '${bookingList![0].user!.calling_code} '
                                              '${bookingList![0].user!.mobile}',
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ]
                              ),
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                        ],
                      ),
                      Row(
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    texto(
                                      text: 'Fecha',
                                      size: responsiveApp.setSP(12),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today_outlined,
                                            size: responsiveApp.setWidth(12),color: Colors.grey),
                                        SizedBox(width: responsiveApp.setWidth(3)),
                                        texto(
                                          size: 14, text: bookingList![0].bookings.date_time.toString()
                                            .split(' ')
                                            .first,
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
                                      text: 'Hora',
                                      size: responsiveApp.setSP(12),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.alarm, size: responsiveApp.setWidth(12),color: Colors.grey),
                                        SizedBox(width: responsiveApp.setWidth(3)),
                                        texto(
                                          size: 14,
                                          text: outputFormat.format(DateTime.parse(bookingList![0].bookings.date_time!)).toString().substring(12,20),
                                          color: Colors.grey,
                                        ),
                                      ],
                                    )
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
                            SizedBox(

                              child: Row(
                                children: [
                                  if(!editStatus)
                                    Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          texto(
                                            text: 'Estado',
                                            size: responsiveApp.setSP(12),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          Container(
                                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                                              border: Border.all(width: responsiveApp.setWidth(1),
                                                  color: bookingList![0].bookings.status=='completed'?const Color(0xff22d88d)
                                                      :bookingList![0].bookings.status=='pending'?const Color(0xffffc44e)
                                                      :bookingList![0].bookings.status=='approved'?const Color(0xff13e9d1)
                                                      :bookingList![0].bookings.status=='in progress'?const Color(0xff5359ff)
                                                      :const Color(0xffFF525C)
                                              ),
                                            ),
                                            child: texto(
                                                size: responsiveApp.setSP(12),
                                                text: bookingList![0].bookings.status!,
                                                color: bookingList![0].bookings.status=='completed'?const Color(0xff22d88d)
                                                    :bookingList![0].bookings.status=='pending'?const Color(0xffffc44e)
                                                    :bookingList![0].bookings.status=='approved'?const Color(0xff13e9d1)
                                                    :bookingList![0].bookings.status=='in progress'?const Color(0xff5359ff)
                                                    :const Color(0xffFF525C)
                                            ),
                                          )
                                        ]
                                    ),
                                  if(editStatus)
                                    _filterStatus(
                                      value: selectedStatusEdited,
                                      onChanged: (newValue) {
                                        setState((){
                                          selectedStatusEdited=newValue.toString();
                                          statusEdited = newValue.toString()=='Completado' ?'completed'
                                              :newValue.toString()=='Pendiente' ?'pending'
                                              :newValue.toString()=='Aprobado' ?'approved'
                                              :newValue.toString()=='En progreso' ?'in progress'
                                              :newValue.toString()=='Cancelado' ?'canceled'
                                              :'all';
                                        });
                                      },
                                      items: itemsStatus
                                          .map<DropdownMenuItem<String>>(
                                              (String value) => DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ))
                                          .toList(),
                                    ),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            editStatus = !editStatus;
                                            if(editStatus){
                                              statusEdited= bookingList![0].bookings.status!;
                                              selectedStatusEdited=
                                              bookingList![0].bookings.status=='completed' ?'Completado'
                                                  :bookingList![0].bookings.status=='pending' ?'Pendiente'
                                                  :bookingList![0].bookings.status=='approved' ?'Aprobado'
                                                  :bookingList![0].bookings.status=='in progress' ?'En progreso'
                                                  :'Cancelado';
                                            }
                                          });
                                        },
                                        child: Icon(
                                          editStatus?Icons.cancel:Icons.edit,
                                          color: editStatus?Colors.red:Colors.grey,
                                          size: responsiveApp.setWidth(20),
                                        ),
                                      ),
                                      SizedBox(height: responsiveApp.setHeight(5),),
                                      if(editStatus)
                                        InkWell(
                                          onTap: (){
                                            setState((){
                                              bdConnection.updateBooking(
                                                context: context,
                                                id:bookingList![0].bookings.id!,
                                                status: statusEdited,
                                                employee_id: bookingList![0].employee!.id!,
                                                amount_to_pay: double.parse(bookingList![0].bookings.amount_to_pay.toString()),
                                                discount: double.parse(bookingList![0].bookings.discount.toString()),
                                                discount_percent: double.parse(bookingList![0].bookings.discount_percent.toString()),
                                                payment_gateway: bookingList![0].bookings.payment_gateway.toString(),
                                                payment_status: bookingList![0].bookings.payment_status.toString(),
                                                tax_amount: double.parse(bookingList![0].bookings.tax_amount.toString()),
                                              );
                                              editStatus=false;
                                            });
                                          },
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: responsiveApp.setWidth(20),
                                          ),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ]
                      ),
                      SizedBox(height: responsiveApp.setHeight(2),),
                      if(isMobileAndTablet(context))
                        Row(
                        children: [
                            SizedBox(
                              width: responsiveApp.setWidth(150),
                              child: texto(
                                size: responsiveApp.setSP(12),
                                text: 'Método de pago',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  bookingList![0].bookings.payment_gateway == 'paypal'
                                      ? Icons.paypal_rounded:Icons.money, color: Colors.black.withOpacity(0.6),
                                ),
                                SizedBox(width: responsiveApp.setWidth(2),),
                                texto(
                                  size: responsiveApp.setSP(12),
                                  text: '${bookingList![0].bookings.payment_gateway}',
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: responsiveApp.setHeight(2),),
                      if(isMobileAndTablet(context))
                      Row(
                        children: [
                            SizedBox(
                              width: responsiveApp.setWidth(150),
                              child: texto(
                                size: responsiveApp.setSP(12),
                                text: 'Estado de pago',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  bookingList![0].bookings.payment_status == 'pending'
                                      ? Icons.cancel:Icons.check_circle,
                                  color: bookingList![0].bookings.payment_status == 'pending'
                                      ? const Color(0xffffc44e): const Color(0xff22d88d),
                                ),
                                SizedBox(width: responsiveApp.setWidth(2),),
                                texto(
                                  size: responsiveApp.setSP(12),
                                  text: '${bookingList![0].bookings.payment_status}',
                                  fontWeight: FontWeight.w500,
                                  color: bookingList![0].bookings.payment_status == 'pending'
                                      ? const Color(0xffffc44e): const Color(0xff22d88d),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: responsiveApp.setHeight(2),),
                      Row(
                        children: [
                          Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                              color: Colors.blueGrey,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: responsiveApp.setWidth(40),
                                    child: texto(
                                      size: responsiveApp.setSP(12),
                                      text: '#',
                                      color: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: texto(
                                      size: responsiveApp.setSP(12),
                                      text: 'Artículo',
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: responsiveApp.setWidth(60),
                                    child: texto(
                                      size: responsiveApp.setSP(12),
                                      text: 'Precio',
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: responsiveApp.setWidth(60),
                                    child: texto(
                                      size: responsiveApp.setSP(12),
                                      text: 'Cantidad',
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: responsiveApp.setWidth(60),
                                    child: texto(
                                      size: responsiveApp.setSP(12),
                                      text: 'Total',
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children:
                                List.generate(
                                  bookingList!.length,
                                      (int index){
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Row(
                                            children: [
                                              SizedBox(
                                                width: responsiveApp.setWidth(40),
                                                child: texto(
                                                  size: responsiveApp.setSP(12),
                                                  text: '${bookingList![index].service!.id!}',
                                                ),
                                              ),
                                              Expanded(
                                                child: texto(
                                                  size: responsiveApp.setSP(12),
                                                  text: '${bookingList![index].service!.name!}',
                                                ),
                                              ),
                                              SizedBox(
                                                width: responsiveApp.setWidth(60),
                                                child: texto(
                                                  size: responsiveApp.setSP(12),
                                                  text: '\$${bookingList![index].bookingItem.unit_price}',
                                                ),
                                              ),
                                              SizedBox(
                                                width: responsiveApp.setWidth(60),
                                                child: texto(
                                                  size: responsiveApp.setSP(12),
                                                  text: '${bookingList![index].bookingItem.quantity}',
                                                ),
                                              ),
                                              SizedBox(
                                                width: responsiveApp.setWidth(60),
                                                child: texto(
                                                  size: responsiveApp.setSP(12),
                                                  text: '\$${bookingList![index].bookingItem.amount}',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if(index<bookingList!.length-1)
                                        Row(
                                        children: [
                                        Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                                        ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: responsiveApp.setHeight(2),),
                      Row(
                        children: [
                          Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                        ],
                      ),
                      SizedBox(
                        height: responsiveApp.setHeight(30),
                        child: Row(
                            children: [
                              if(!isMobileAndTablet(context))
                              SizedBox(
                                width: responsiveApp.setWidth(150),
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: 'Método de pago',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if(!isMobileAndTablet(context))
                              Row(
                                children: [
                                  Icon(
                                    bookingList![0].bookings.payment_gateway == 'paypal'
                                        ? Icons.paypal_rounded:Icons.money, color: Colors.black.withOpacity(0.6),
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(2),),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: '${bookingList![0].bookings.payment_gateway}',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              const Expanded(child: SizedBox(),),
                              Row(
                                children: [
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: 'Subtotal',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(30),),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: '${bookingList![0].bookings.original_amount}',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(40),),
                                ],
                              ),
                            ]
                        ),
                      ),

                      SizedBox(
                        height: responsiveApp.setHeight(30),
                        child: Row(
                            children: [
                              if(!isMobileAndTablet(context))
                              SizedBox(
                                width: responsiveApp.setWidth(150),
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: 'Estado de pago',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if(!isMobileAndTablet(context))
                              Row(
                                children: [
                                  Icon(
                                    bookingList![0].bookings.payment_status == 'pending'
                                        ? Icons.cancel:Icons.check_circle,
                                    color: bookingList![0].bookings.payment_status == 'pending'
                                        ? const Color(0xffffc44e): const Color(0xff22d88d),
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(2),),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: '${bookingList![0].bookings.payment_status}',
                                    fontWeight: FontWeight.w500,
                                    color: bookingList![0].bookings.payment_status == 'pending'
                                        ? const Color(0xffffc44e): const Color(0xff22d88d),
                                  ),
                                ],
                              ),
                              const Expanded(child: SizedBox(),),
                              Row(
                                children: [
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: 'ITBIS (${bookingList![0].bookings.tax_percent}%)',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(30),),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: '${bookingList![0].bookings.tax_amount}',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(40),),
                                ],
                              ),
                            ]
                        ),
                      ),

                      SizedBox(
                        height: responsiveApp.setHeight(30),
                        child: Row(
                          children: [
                            const Expanded(child: SizedBox(),),
                            texto(
                              size: responsiveApp.setSP(14),
                              text: 'TOTAL',
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(width: responsiveApp.setWidth(30),),
                            texto(
                              size: responsiveApp.setSP(14),
                              text: '\$${bookingList![0].bookings.amount_to_pay}',
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(width: responsiveApp.setWidth(40),),
                          ],
                        ),
                      ),
                    ]
                ),
              ),
            );
          }
        }
    );
  }
}
