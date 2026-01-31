
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:salon/Widgets/Components/inventory_widget.dart';
import 'package:salon/Widgets/Components/print_xml.dart';
import 'package:salon/Widgets/Components/reports_widget.dart';
import '../Widgets/Components/chairs_widget.dart';
import '../Widgets/Components/profile_widget.dart';
import '../Widgets/Components/reporte_estetico_widget.dart';
import '../Widgets/Components/reservas_widget.dart';
import '../util/db_connection.dart';
import 'package:provider/provider.dart';

import '../Widgets/Components/CategoryWidget.dart';
import '../Widgets/Components/CustomerWidget.dart';
import '../Widgets/Components/DashboardWidget.dart';
import '../Widgets/Components/EmploeeWidget.dart';
import '../Widgets/Components/ServiceWidget.dart';
import '../Widgets/Components/Settings_widget.dart';
import '../Widgets/Components/SucursalesWidget.dart';
import '../Widgets/Components/pos_widget.dart';
import '../Widgets/change_password_widget.dart';
import '../util/Keys.dart';
import '../util/SizingInfo.dart';
import '../util/Util.dart';
import '../util/states/login_state.dart';
import '../values/ResponsiveApp.dart';
import 'HomePage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late LoginState loginState;
  AppData appData = AppData();
  late ResponsiveApp responsiveApp;
  late BDConnection dbConnection = BDConnection();
  late String host;
  bool tap = false;
  double height = 0;
  double width= 0;
  bool rolFirstTime = true;
  static late  Widget _widget;
  final List _isHovering = [
    false,
    false,
    false,
    false,
    false,
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
  final List _isRaised = [
    false,
    false,
    true,
    false,
    false,
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
  List<dynamic> moduleList = [];
  double _width = 0;
  int pages=0;
  bool verSet = false;
  bool verSub = false;
  bool showList = false;
  bool isFirstTime = true;

  getModules()async {
    final query = await dbConnection.getModules(
        onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
        context: context,
        level_id: appData.getUserData().rol_id.toString()
    );
    final permissions = await dbConnection.getPermission(context, appData.getUserData().rol_id);
    for(var doc in query){

        if(doc['name']=='main_page'){
          moduleList.insert(0, doc);
        }else{
          moduleList.add(doc);
        }
        _isHovering.add(false);
        _isRaised.length==2?_isRaised.add(true):_isRaised.add(false);

    }

    appData.cleanCurrentLevelPermission();
    List<LevelPermission> permissionsList = [];
    for(var doc in permissions){
      permissionsList.add(doc);
    }
    appData.setCurrentLevelPermission(permissionsList);
    appData.setModuleListData(moduleList);
  }

  @override
  void initState() {
    getModules();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);

    return SafeArea(
      child: Scaffold(
        key: mainScaffoldKey,
        //appBar: Header(1),
        drawer: Drawer(
          child: appData.getUserData().id == null || appData.getUserData().id == 0 || appData.getCurrentLevelPermission().isEmpty?const SizedBox():isMobileAndTablet(context)?menuLateral():const SizedBox(),
        ),
        body: appData.getUserData().id == null || appData.getUserData().id == 0 || appData.getCurrentLevelPermission().isEmpty
            ? Builder(
            builder: (context) {
              //Provider.of<DBConnection>(context, listen: false);
                _simulateDataLoading();
                //tryToConnect();
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            )
            :appData.getUserData().default_pass == 1
            ? ChangePasswordWidget(reason: 'change_default', userId: appData.getUserData().id)
            :Builder(
              builder: (context) {
                if(rolFirstTime) {
                  if (appData
                      .getUserData()
                      .rol_id == 3) {
                    _widget = const CustomerWidget();
                  } else {
                    _widget = DashBoardWidget(goTo: (v) {
                      if (v == 'booking') {
                        setState(() {
                          _widget = const BookingsWidget();
                        });
                      }
                    });
                  }
                  rolFirstTime=false;
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(!isMobileAndTablet(context))
                      menuLateral(),
                    Expanded(child: _widget,),
                          ],
                        );
              }
            ),
      ),
    );
  }

  Future<void> _simulateDataLoading() async {
    await Future.delayed(const Duration(microseconds: 300)); // Simula una carga de 3 segundos

    // Actualiza el estado para mostrar los datos actualizados
    setState(() {
      //Provider.of<BDConnection>(context, listen: false);
      // Realiza cualquier actualización necesaria en los datos
    });
  }

  Widget menuLateral(){
    return Container(
      height: displayHeight(context),
      width: isMobile(context)? responsiveApp.setWidth(150): responsiveApp.setWidth(200),
      margin: EdgeInsets.only(bottom: responsiveApp.setWidth(5), top: responsiveApp.setWidth(5),right: responsiveApp.setWidth(5)),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15), topRight: Radius.circular(15)),
          boxShadow: const [
            BoxShadow(
              //color: _isRaised[index]?Colors.blueAccent:Colors.transparent,
                blurRadius: 10,
                spreadRadius: -8,
                offset: Offset(0,1)
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: responsiveApp.setWidth(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: responsiveApp.setHeight(100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: responsiveApp.setWidth(8),
                          vertical: responsiveApp.setHeight(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          appData.getUserData().image != null &&
                              appData.getUserData().image != ''
                              ? userImage(
                              width: responsiveApp.setWidth(50),
                              height: responsiveApp.setWidth(50),
                              color: Colors.white,
                              shadowColor: Theme.of(context).shadowColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(100)),
                              image: Image.memory(
                                appData.getUserData().image.bytes!,
                                fit: BoxFit.fill,
                              ))
                              : userImage(
                              width: responsiveApp.setWidth(50),
                              height: responsiveApp.setWidth(50),
                              shadowColor: Theme.of(context).shadowColor,
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(100)),
                              image: Image.asset(
                                'assets/images/default-avatar-user.png',
                                fit: BoxFit.fill,
                              )),
                          SizedBox(
                            width: responsiveApp.setWidth(5),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "${appData.getUserData().name.toString().length > 17 ? appData.getUserData().name.toString().substring(0, 17) : appData.getUserData().name}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsiveApp.setSP(12)),
                                ),
                                Text(
                                  "${appData.getUserData().email.toString().length > 20 ? appData.getUserData().email.toString().substring(0, 20) : appData.getUserData().email}",
                                  style: TextStyle(
                                    fontSize: responsiveApp.setSP(10),
                                  ),
                                ),
                                SizedBox(
                                  height: responsiveApp.setHeight(5),
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _widget = const ProfileWidget();
                                          for (int i = 0;
                                          i < _isRaised.length;
                                          i++) {
                                            i != 0
                                                ? _isRaised[i] = false
                                                : _isRaised[i] = true;
                                          }
                                        });
                                        if (isMobileAndTablet(context)) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      onHover: (v) {
                                        setState(() {
                                          v
                                              ? _isHovering[0] = true
                                              : _isHovering[0] = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Theme.of(context).primaryColor,
                                              width: 1.0),
                                          color: _isHovering[0] || _isRaised[0]
                                              ? Theme.of(context).primaryColor
                                              : Colors.transparent,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                              _isHovering[0] || _isRaised[0]
                                                  ? Theme.of(context).primaryColor
                                                  .withOpacity(0.3)
                                                  : Colors.transparent,
                                              spreadRadius: 2,
                                              blurRadius: 2,
                                              offset: const Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Ver perfil",
                                            style: TextStyle(
                                              color:
                                              _isHovering[0] || _isRaised[0]
                                                  ? Colors.white
                                                  : Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (isMobileAndTablet(context)) {
                                          Navigator.pop(context);
                                        }
                                        cerrarSesion();
                                      },
                                      onHover: (v) {
                                        setState(() {
                                          v
                                              ? _isHovering[1] = true
                                              : _isHovering[1] = false;
                                        });
                                      },
                                      child: Icon(
                                        Icons.power_settings_new_rounded,
                                        color: _isHovering[1] || _isRaised[1]
                                            ? const Color(0xffFF525C)
                                            : Colors.blueGrey.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                /*
                Padding(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  child: Badge(
                    //label: texto(text: "1", size: responsiveApp.setSP(10),color: Colors.white),
                  isLabelVisible: true,
                  textColor: Colors.white,
                  textStyle: TextStyle(
                    color: Colors.white
                  ),
                  child: Icon(Icons.notifications_rounded,color: Colors.blueGrey,),),
                ),

                 */
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: responsiveApp.setWidth(10),),
            child: Center(
              child: Container(
                width: responsiveApp.setWidth(180),
                height: responsiveApp.setHeight(1),
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10,),
                  menuLateralButton(13,"Home",_isRaised[13]?Icons.home:Icons.home_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=13?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });

                      if(kIsWeb){
                        Provider.of<LoginState>(context,listen: false).gotoHome(true);
                      }else{
                        _widget = const HomePage();
                      }
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3)
                    const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3)
                    menuLateralButton(2,"Dashboard",_isRaised[2]?Icons.dashboard_rounded:Icons.dashboard_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=2?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = DashBoardWidget(goTo: (v){

                          if(v=='booking'){
                            setState(() {
                              _widget = const BookingsWidget();
                            });
                          }
                      },);
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_location'))==1)
                  const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_location'))==1)
                    menuLateralButton(3,"Sucursales",_isRaised[3]?Icons.map:Icons.map_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=3?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = const SucursalWidget();
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_category'))==1)
                  const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_category'))==1)
                    menuLateralButton(4,"Categorías",_isRaised[4]?Icons.local_offer:Icons.local_offer_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=4?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = const CategoryWidget();
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_business_service'))==1)
                  const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_business_service'))==1)
                    menuLateralButton(5,"Servicios",_isRaised[5]?Icons.room_service:Icons.room_service_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=5?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = const ServiceWidget();
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_inventory'))==1)
                  const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_inventory'))==1)
                    menuLateralButton(6,"Inventario",_isRaised[6]?Icons.inventory_2_rounded:Icons.inventory_2_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=6?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = const InventoryWidget();
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_customer'))==1)
                  const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_customer'))==1)
                  menuLateralButton(7,"Clientes",_isRaised[7]?Icons.people_alt:Icons.people_alt_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=7?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = const CustomerWidget();
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_employee'))==1)
                  const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_employee'))==1)
                    menuLateralButton(8,"Empleados",_isRaised[8]?Icons.person:Icons.person_outline_outlined, () {
                    setState((){
                      pages = 8;
                      for(int i=0;i<_isRaised.length;i++){
                        i!=8?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = EmployeeWidget(origin: 'mainPage',);
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('create_point_of_sale'))==1)
                  const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('create_point_of_sale'))==1)
                    menuLateralButton(9,"Punto de venta",_isRaised[9]?Icons.shopping_cart:Icons.shopping_cart_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=9?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = const PosWidget();
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_booking'))==1)
                    const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_booking'))==1)
                    menuLateralButton(10,"Reservas",_isRaised[10]?Icons.calendar_month:Icons.calendar_month_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=10?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = const BookingsWidget();
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_chairs'))==1)
                    const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_chairs'))==1)
                    menuLateralButton(11,"Sillas",_isRaised[11]?Icons.chair:Icons.chair_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=11?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = const ChairsWidget();
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_report'))==1)
                    const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('read_report'))==1)
                    menuLateralButton(12,"Informes",_isRaised[12]?Icons.area_chart:Icons.area_chart_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=12?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      setState((){
                        verSet = false;
                      });
                      _widget = ReporteEstetico();
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('manage_settings'))==1)
                    const SizedBox(height: 10,),
                  if(appData.getUserData().rol_id!=3 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('manage_settings'))==1)
                  menuLateralButton(13,"Ajustes",_isRaised[13]?Icons.settings:Icons.settings_outlined, () {
                    setState((){
                      for(int i=0;i<_isRaised.length;i++){
                        i!=13?_isRaised[i] = false:_isRaised[i] = true;
                      }
                      _widget = const SettingsWidget();
                    });
                    if(isMobileAndTablet(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  const SizedBox(height: 100,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void cerrarSesion(){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text("Se perderan los datos no guardados. ¿Desea cerrar Sesión?",),
          actions: <Widget>[
            InkWell(
              autofocus: true,
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Container(
                width: 110,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.blueGrey.withOpacity(0.8),
                ),
                child: const Center(child: Text("No, Descartar", style: TextStyle(color: Colors.white))),
              ),
            ),
            InkWell(
              onTap: (){
                setState((){
                  //Navigator.of(context).pop();
                  Provider.of<LoginState>(context, listen: false)
                      .logout();
                });
                pages = 5;
                _widget = DashBoardWidget(
                  goTo: (v){
                    if(v=='bookings'){
                      setState(() {
                        _widget = const BookingsWidget();
                      });
                    }
                  },
                );
                Navigator.pop(context);
              },
              child: Container(
                width: 110,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.grey.withOpacity(0.15),
                ),
                child: const Center(child: Text("Si, Cerrar", style: TextStyle(color: Colors.grey))),
              ),
            ),
          ],
        )
    );
  }

  Widget menuLateralButton(int index, String title,IconData icon,VoidCallback onTap){

    return InkWell(

      onHover: (value) {
        setState(() {
          value?_width = responsiveApp.lineHznButtonWidth:_width=0;
          value
              ? _isHovering[index] = true
              : _isHovering[index] = false;
        });
      },
      onTap: onTap,
      child: Row(
        children: [
          AnimatedContainer(duration: const Duration(milliseconds: 300),
            width: _isRaised[index] ?width = responsiveApp.setWidth(3):0,
            height: _isRaised[index] ?height =responsiveApp.setHeight(37):0,
            decoration: BoxDecoration(
                color: _isRaised[index]?Theme.of(context).primaryColor:Colors.transparent,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(50), bottomRight: Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                      color: _isRaised[index]?Theme.of(context).primaryColor:Colors.transparent,
                      blurRadius: 5,
                      spreadRadius: 0,
                      offset: const Offset(0,1)
                  )
                ]
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.only(topRight: Radius.circular(responsiveApp.setWidth(100)),
                //    bottomRight: Radius.circular(responsiveApp.setWidth(100))),
                color: _isRaised[index]
                    ? Theme.of(context).primaryColor.withOpacity(0.08):
                _isHovering[index]
                    ? Theme.of(context).primaryColor.withOpacity(0.03)
                    : Colors.transparent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: responsiveApp.setWidth(20),
                      right: responsiveApp.setWidth(7),
                      top: responsiveApp.setHeight(7),
                      bottom: responsiveApp.setHeight(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon,
                          size: responsiveApp.setWidth(25),
                          color: _isRaised[index]
                              ? Theme.of(context).primaryColor:_isHovering[index]
                              ?Theme.of(context).primaryColor
                          //[widget.colorTone]
                              : Colors.grey,
                        ),
                        SizedBox(width: responsiveApp.setWidth(10),),
                        Column(
                          children: [
                            Text(title,
                              style: TextStyle(
                                fontSize: responsiveApp.setSP(12),
                                fontWeight: _isRaised[index]
                                    ?FontWeight.w600:FontWeight.w400,
                                color: _isRaised[index]
                                    ? Theme.of(context).primaryColor:_isHovering[index]
                                    ? Theme.of(context).primaryColor//[widget.colorTone]
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(height: responsiveApp.setHeight(3)),
                            Visibility(
                              maintainAnimation: true,
                              maintainState: true,
                              maintainSize: true,
                              visible:_isHovering[index],
                              child: AnimatedContainer(
                                height: responsiveApp.lineHznButtonHeight,
                                width: _width,
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                    color: _isRaised[index]
                                        ? Theme.of(context).primaryColor:Theme.of(context).primaryColor,//
                                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(10))
                                ),
                              ),

                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
