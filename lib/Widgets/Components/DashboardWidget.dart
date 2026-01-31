import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';

class Top5{
  int    idProducto;
  String descripcion;
  String unidad;
  double cantidad;
  double venta;
  double beneficio;

  Top5({required this.idProducto,required this.descripcion,
    required this.unidad,required this.cantidad,required this.venta,required this.beneficio});
}

class DashBoardWidget extends StatefulWidget {
  const DashBoardWidget({Key? key, required this.goTo}) : super(key: key);
  final Function(String) goTo;

  @override
  State<DashBoardWidget> createState() => _DashBoardWidgetState();
}

class _DashBoardWidgetState extends State<DashBoardWidget> {

  late ResponsiveApp responsiveApp;
  double completed = 0;
  double pending = 0;
  double montoBenef = 0;
  double oldVenta = 0;
  double oldBenef = 0;
  double ventaAcum = 0;
  double online = 0;
  double incomes = 0;
  double    approved    = 0;
  double    canceled = 0;
  double    in_progress = 0;
  double    pos = 0;
  bool   hven         = true;
  int pageIndex = 0;
  double containerWidth = 5;
  String host = '';
  NumberFormat numFormat=NumberFormat("#,###.##","es_MX");
  List<int> meses = [];
  List<double> ventas = [];
  List<double> ganancias = [];
  List<String> trimestre = [
    'Al 1er trimestre',
    'Al 2do trimestre',
    'Al 3er trimestre',
    'Al 4to trimestre',
  ];
  BDConnection dbConnection = BDConnection();
  final items = ['Hoy','Esta semana','Este mes', 'Rango de fecha'];
  String selectedValue = 'Rango de fecha';
  final itemsStatus = ['Todo','Completado','Pendiente','Aprobado', 'En progreso', 'Cancelado'];
  String selectedStatus = 'Todo';
  final itemsCustomer = ['Todos'];
  String selectedCustomer = 'Todos';
  final itemsLocation = ['Todos'];
  String selectedLocation = 'Todos';
  List<User> customerList=[];
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
  final List            _isHovering               = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  bool firstTime= true;

  @override
  initState(){
    for(var i =0 ; i<DateTime.now().month;i++){
      ventas.add(0.0);
      ganancias.add(0.0);
    }
    fechaInicio = DateTime.now().subtract(const Duration(hours: 24 * 60)).toString();
    fechaFin = fechaFin =
    "${DateTime.now().year.toString()}-${DateTime.now().month
        .toString().padLeft(2, '0')}-${DateTime.now().day
        .toString().padLeft(2, '0')} 23:59:59";
    getIndicators();
    super.initState();
  }

  getIndicators(){
    getList();
    getList2();
    getList3();
    getList4();
    getList5();
    getList6();
    getList7();
    getList8();
  }

  setlists() async{

    for (var element in await dbConnection.getSucursales(context)){
      sucList.add(element);
      itemsLocation.add(element.name);
    }
    for (var element in await dbConnection.getUsers(context: context, roleId: 3)){
      customerList.add(element);
      itemsCustomer.add(element.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
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
                IconButton(onPressed: ()=> mainScaffoldKey.currentState!.openDrawer(), icon: const Icon(Icons.menu_rounded,)),
              const Expanded(
                child: Text("Dashboard",
                  style: TextStyle(
                    //color: Colors.white,
                    fontSize: 18,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w500,
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
                                      _filterStatus(),
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
                  color: Colors.white,
                  // fit: BoxFit.fill,
                  height: responsiveApp.setWidth(30),
                  width: responsiveApp.setWidth(30),
                  ),
                  /*
                  Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(50)),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: responsiveApp.setWidth(3),),
                      texto(
                        size: responsiveApp.setSP(10),
                        text: 'Filtro',
                        color: Colors.blueGrey,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),

                    ],
                  ),
                ),

                   */
              ),
              SizedBox(width: responsiveApp.setWidth(10),),
            ],
          ),
        ),
      ),
      body: body()
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
                            :newValue.toString()=='Este mes'?DateTime(DateTime.now().year,DateTime.now().month,1).toString().split('.')[0]
                            :DateTime.now().subtract(const Duration(hours: 24 * 30)).toString();
                        fechaFin =
                        newValue.toString()=='Este mes'?DateTime(DateTime.now().year,DateTime.now().month,daysInMonth(DateTime.now().month)).toString().split('.')[0]
                            :"${DateTime.now().year.toString()}-${DateTime.now().month
                            .toString().padLeft(2, '0')}-${DateTime.now().day
                            .toString().padLeft(2, '0')} 23:59:59";
                      });
                      firstTime = true;
                      getIndicators();
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
                                  getIndicators();
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
                                    firstTime = true;
                                    getIndicators();
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
                              getIndicators();
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
                                firstTime = true;
                                getIndicators();
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
  Widget _filterStatus(){
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
              //if(!editStatus) {
              getIndicators();
                firstTime = true;
               // verDetails = false;
            //  }
            },
            items: itemsStatus
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
              getIndicators();
              //verDetails = false;
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
              getIndicators();
             // verDetails = false;
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
  Widget menu(int index, String title,VoidCallback onTap){
    return Column(
      children: [
        InkWell(
          hoverColor: Colors.transparent,
          onHover: (value) {
            setState(() {
              value
                  ? _isHovering[index] = true
                  : _isHovering[index] = false;
            });
          },
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                style: TextStyle(
                  fontWeight: _isHovering[index]?FontWeight.w600:FontWeight.w500,
                  color: _isHovering[index]
                      ? index==4?const Color(0xff5359ff):index==5?const  Color(0xffFF525C):const Color(0xff22d88d)//[widget.colorTone]
                      : Colors.black.withOpacity(0.7),//[widget.colorTone],
                ),
              ),
              const SizedBox(height: 5,),
              Visibility(
                maintainAnimation: true,
                maintainState: true,
                maintainSize: true,
                visible: _isHovering[index],
                child: Container(
                  height: responsiveApp.lineHznButtonHeight,
                  width: responsiveApp.lineHznButtonWidth,
                  color: index==4?const Color(0xff5359ff):index==5?const Color(0xffFF525C).withOpacity(0.7):const Color(0xff22d88d).withOpacity(0.7),//[widget.colorTone]
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget body(){

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(!isMobileAndTablet(context))
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                        _filterStatus(),
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
          if(!isMobileAndTablet(context))
          SizedBox(height: responsiveApp.setHeight(10),),
          Expanded(child: dashBoard()),
        ],
      ),
    );
  }

  Widget dashBoard(){
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          const Duration(seconds: 1),
              () {
            setState((){});
            getIndicators();
          },
        );
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: reservas(),
      ),
    );
  }

  Widget reservas(){
    return FutureBuilder(
        future: dbConnection.getBookingList(context: context, location: location,userName: customer,status: _status,status2: _status,payment_status: 'all',fechaInicio: fechaInicio,fechaFin: fechaFin),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueGrey,),
            );
          }else {
            int repetido = 1;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  indicadores(),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          child: Container(
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

                                            return index<snapshot.data.length-1&&snapshot.data[index].bookings.id!=snapshot.data[index+1].bookings.id
                                                ? list(snapshot,index,repetido)
                                                : index==snapshot.data.length-1?list(snapshot,index,repetido):const SizedBox();
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
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

        }

    );
  }

  Widget list(AsyncSnapshot snapshot,int index,int repetido){
    var outputFormat = DateFormat('dd-MMM-yyyy hh:mm a');
    return ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: responsiveApp.setWidth(15),
                  top: responsiveApp.setHeight(5), bottom: responsiveApp.setHeight(5)),
              child: snapshot.data[index].user.image!=null&&snapshot.data[index].user.image!=''
                  ? userImage(
                  width: responsiveApp.setWidth(50),
                  height: responsiveApp.setWidth(50),
                  borderRadius: BorderRadius.circular(100),
                  shadowColor: Theme.of(context).shadowColor,
                  image: Image.memory(snapshot.data[index].user.image!.bytes!,))
                  : userImage(
                  width: responsiveApp.setWidth(50),
                  height: responsiveApp.setWidth(50),
                  borderRadius: BorderRadius.circular(100),
                  shadowColor: Theme.of(context).shadowColor,
                  image: Image.asset('assets/images/default-avatar-user.png')),
            ),
            SizedBox(
              width: isMobileAndTablet(context)?displayWidth(context)*0.48:displayWidth(context)*0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  texto(
                      size: responsiveApp.setSP(12),
                      text: snapshot.data[index].user.name,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold
                  ),
                  Row(
                    children: [
                      Icon(Icons.mail_outline_rounded, size: responsiveApp.setWidth(12),),
                      SizedBox(width: responsiveApp.setWidth(3)),
                      texto(
                          size: responsiveApp.setSP(12),
                          text: snapshot.data[index].user.email,
                          fontWeight: FontWeight.normal
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.phone_android_rounded, size: responsiveApp.setWidth(12),),
                      SizedBox(width: responsiveApp.setWidth(3)),
                      texto(
                          size: responsiveApp.setSP(12),
                          text: '${snapshot.data[index].user.calling_code} '
                              '${snapshot.data[index].user.mobile}',
                          fontWeight: FontWeight.normal
                      ),
                    ],
                  ),

                ],
              ),
            ),
            if(!isMobileAndTablet(context))
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            if(!isMobileAndTablet(context))
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: responsiveApp.setWidth(12),),
                      SizedBox(width: responsiveApp.setWidth(3)),
                      texto(size: responsiveApp.setSP(12),text: snapshot.data[index].bookings.date_time.toString().split(' ').first)
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.alarm, size: responsiveApp.setWidth(12),),
                      SizedBox(width: responsiveApp.setWidth(3)),
                      texto(size: responsiveApp.setSP(12),text: outputFormat.format(DateTime.parse(snapshot.data[index].bookings.date_time)).toString().substring(12,20))
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(10)),
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
            )
          ],
        ),
        onTap: () {
            widget.goTo('bookings');
        });
  }

  Widget indicadores(){
    List<Widget> list = [
      indicatorCards(const Color(0xff22d88d), Icons.calendar_month_rounded, "Reservas completadas", numFormat.format(completed), "",null,(){setState(() {
        selectedStatus = 'Completado';
        _status = 'completed';
      });}),

      indicatorCards(const Color(0xffffc44e), Icons.calendar_month_rounded, "Reservas pendientes", numFormat.format(pending), "",null,(){setState(() {
        selectedStatus = 'Pendiente';
        _status = 'pending';
      });}),

      indicatorCards(const Color(0xff13e9d1), Icons.calendar_month_rounded, "Reservas aprobadas", numFormat.format(approved), "",null,(){setState(() {
        selectedStatus = 'Aprobado';
        _status = 'approved';
      });}),

      indicatorCards(const Color(0xff5359ff), Icons.calendar_month_rounded, "Reservas en curso", numFormat.format(in_progress), "",null,(){setState(() {
        selectedStatus = 'En progreso';
        _status = 'in progress';
      });}),

      indicatorCards(const Color(0xffFF525C), Icons.calendar_month_rounded, "Reservas canceladas", "$canceled", "",null,(){setState(() {
        selectedStatus = 'Cancelado';
        _status = 'canceled';
      });}),

      indicatorCards(const Color(0xff464545), Icons.point_of_sale_sharp, "Reservas Walk-In", numFormat.format(pos),
          pending>0?"${numFormat.format(
              (pending / (pending - oldVenta)) * 100
          )}%":"",
          pending>oldVenta?Icons.arrow_upward_rounded: pending==0 ? null:Icons.arrow_downward_rounded,(){setState(() {

          });}),//Color(937af2)

      indicatorCards(const Color(0xff9e7fff), Icons.laptop_chromebook_rounded, "Reservas Online", numFormat.format(online),
          pending>0?"${numFormat.format(
              (pending / (pending - oldVenta)) * 100
          )}%":"",
          pending>oldVenta?Icons.arrow_upward_rounded: pending==0 ? null:Icons.arrow_downward_rounded,(){setState(() {

          });}),//Color(937af2)

      indicatorCards(const Color(0xff13e9d1), Icons.monetization_on_outlined, "Ingresos Totales", "\$${numFormat.format(incomes)}",
          montoBenef>0?"${numFormat.format(
              (montoBenef / (montoBenef -  oldBenef)) * 100
          )}%":"",montoBenef>oldBenef?Icons.arrow_upward_rounded: montoBenef==0?null:Icons.arrow_downward_rounded,(){setState(() {

          });}),
    ];
    int crossCount = isMobileAndTablet(context) ? (displayWidth(context)) ~/ 150 : (displayWidth(context) * 0.8 ) ~/ 200;

    return GridView.builder(
      primary: false,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 3,
        childAspectRatio: isMobile(context) ? 2 : isTablet(context) ? 1.5 : 1.5,
      ),
      shrinkWrap: true,
      itemCount: list.length, // Reemplaza con la cantidad de elementos que tienes
      itemBuilder: (BuildContext context, int index) {
        // Reemplaza con el código para generar cada elemento del GridView
        return list[index];
      },
    );
  }

  Widget indicatorCards(Color cardColor, IconData cardIcon,String cardName, String cardValue, String cardPercent, IconData? icons2,Function() onTap){

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(5),vertical: responsiveApp.setHeight(8)),
      child: InkWell(
        onTap: onTap,
        child: GridTile(
          child: Container(
            width: responsiveApp.setWidth(200),
            height: isMobile(context)?responsiveApp.setHeight(70):isTablet(context)? responsiveApp.setHeight(75):responsiveApp.setHeight(60),
            padding: EdgeInsets.only(bottom:responsiveApp.setHeight(10),top:responsiveApp.setHeight(10),left: responsiveApp.setWidth(10),right: responsiveApp.setWidth(10)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white.withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: cardColor.withOpacity(0.3),
                  spreadRadius: -6,
                  blurRadius: 8,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(cardIcon,size: responsiveApp.setWidth(70), color: cardColor.withOpacity(0.1),)
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(cardValue,
                      style: TextStyle(
                        color: cardColor.withOpacity(0.8),
                        fontSize: responsiveApp.setSP(25),
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: responsiveApp.setHeight(1),),
                    Text(cardName,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.65),
                        fontSize: responsiveApp.setSP(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  /*
  Widget indicatorCards(Color cardColor, IconData cardIcon,String cardName, String cardValue, String cardPercent, IconData? icons2){

    return Stack(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: responsiveApp.setWidth(15),),
            Container(
              width: responsiveApp.setWidth(200),
              height: isMobile(context)?responsiveApp.setHeight(70):isTablet(context)? responsiveApp.setHeight(75):responsiveApp.setHeight(60),
              padding: EdgeInsets.only(bottom:responsiveApp.setHeight(10),top:responsiveApp.setHeight(10),left: responsiveApp.setWidth(10),right: responsiveApp.setWidth(10)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(cardValue,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: responsiveApp.setSP(20),
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: responsiveApp.setHeight(1),),
                  Text(cardName,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.65),
                      fontSize: responsiveApp.setSP(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          children: [
            SizedBox(height: responsiveApp.setHeight(5),),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(5), vertical: responsiveApp.setHeight(10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: cardColor.withOpacity(0.85),
                      boxShadow: [
                        BoxShadow(
                          color: cardColor.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Icon(cardIcon,size: 30.0, color: Colors.white,)),
              ],
            ),
          ],
        ),
      ],
    );
  }
   */

  getList() async {

    var data = await dbConnection.getList(
      context: context,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        condition: 'completed',
        field: 'status');
    setState(() {
      completed = data;
    });
    }

  Future getList2() async {
    var data = await dbConnection.getList(
        context: context,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        condition: 'pending',
        field: 'status');
    setState(() {
      pending = data;
    });
    }

  Future getList4() async {
    var data = await dbConnection.getList(
        context: context,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        condition: 'online',
        field: 'source');
    setState(() {
      online = data;
    });
    }

  Future getList3() async {
    var data = await dbConnection.getList(
        context: context,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        condition: 'canceled',
        field: 'status');
    setState(() {
      canceled = data;
    });
    }

  Future getList5() async {
    var data = await dbConnection.getList(
        context: context,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        condition: 'approved',
        field: 'status');
    setState(() {
      approved = data;
    });
    }
  Future getList6() async {
    var data = await dbConnection.getList(
        context: context,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        condition: 'in progress',
        field: 'status');

    setState((){
      in_progress  = data;
    });
    }

  Future getList7() async {
    var data = await dbConnection.getList(
        context: context,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        condition: 'pos',
        field: 'source');
    setState(() {
      pos = data;
    });
    }

  Future getList8() async {
    var data = await dbConnection.getList8(
      context: context,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,);

    setState(() {
      incomes = data;
    });
    }
}
