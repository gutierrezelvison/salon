
import 'package:flutter/material.dart';
import '../../Widgets/Components/CarouselWidget.dart';
import '../../Widgets/Components/Schedule_Settings_Widget.dart';
import '../../Widgets/Components/appearance_widget.dart';
import '../../Widgets/Components/cash_register_widget.dart';
import '../../Widgets/Components/permission_settings_widget.dart';

import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../values/ResponsiveApp.dart';
import 'Currency_Settings_Widget.dart';
import 'General_Settings_Widget.dart';
import 'Tax_Settings_Widget.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late ResponsiveApp responsiveApp;

  bool tap = false;
  static late Widget _widget;
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
    false,
    false,
    false
  ];

  @override
  void initState() {
    _widget = const GeneralSettingsWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return SafeArea(
      child: Scaffold(
        body: isMobileAndTablet(context)?_mobileBody():_body(),
      ),
    );
  }

  Widget _body(){
    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisSize:MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                    //color: Theme.of(context).primaryColor,
                    child: Row(
                      children: [
                        if(isMobileAndTablet(context))
                          IconButton(onPressed: ()=> mainScaffoldKey.currentState!.openDrawer(), icon: const Icon(Icons.menu_rounded)),
                        //if(isMobileAndTablet(context))
                        Text("Configuración",
                          style: TextStyle(
                            //color: Colors.white,
                            fontSize: responsiveApp.headLine6,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        /*
                SizedBox(width: responsiveApp.barSpace1Width,),
                menu(0, "Dashboard",(){
                  setState((){
                    pageIndex = 0;
                  });
                }),
                SizedBox(width: responsiveApp.barSpace1Width,),
                menu(1, "Cierre",(){
                    setState((){
                      pageIndex = 1;
                    });
                }),

                 */

                      ],
                    ),
                  ),
                  Expanded(child: menuLateral()),
                ],
              ),
              if(!isMobileAndTablet(context))
                Container(
                  width: 2.0,
                 // height: displayHeight(context)*0.7,
                  color: Colors.grey.withOpacity(0.1),
                ),
              if(!isMobileAndTablet(context))
                Expanded(child: _widget,),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mobileBody(){
    return SizedBox(
      height: displayHeight(context),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                if(isMobileAndTablet(context))
                  IconButton(onPressed: ()=> mainScaffoldKey.currentState!.openDrawer(), icon: const Icon(Icons.menu_rounded, color: Colors.white)),
                //if(isMobileAndTablet(context))
                Text("Configuración",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsiveApp.headLine6,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                /*
                  SizedBox(width: responsiveApp.barSpace1Width,),
                  menu(0, "Dashboard",(){
                    setState((){
                      pageIndex = 0;
                    });
                  }),
                  SizedBox(width: responsiveApp.barSpace1Width,),
                  menu(1, "Cierre",(){
                      setState((){
                        pageIndex = 1;
                      });
                  }),

                   */
              ],
            ),
          ),
          Expanded(child: menuLateral()),
        ],
      ),
    );
  }

  Widget menuLateral(){
    return Container(
      //height: displayHeight(context)*0.5,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: isMobileAndTablet(context)?Theme.of(context).scaffoldBackgroundColor:Colors.transparent,
        /* gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withOpacity(0.6),
                  Colors.red.withOpacity(0.6),
                ],
              ),

              */
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                    const SizedBox(height: 20.0,),
                  menuLateralButton(0,"General",Icons.store_mall_directory_outlined, () {
                    if(!isMobileAndTablet(context)) {
                      setState(() {
                        for (int i = 0; i < _isRaised.length; i++) {
                          i != 0 ? _isRaised[i] = false : _isRaised[i] = true;
                        }
                        _widget = const GeneralSettingsWidget();
                      });
                    }

                    if(isMobileAndTablet(context)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              const GeneralSettingsWidget()));}


                  }),
                  const SizedBox(height: 10.0,),
                  menuLateralButton(1,"Horarios",Icons.schedule_rounded, () {
                      setState((){
                        if(!isMobileAndTablet(context)) {
                          for (int i = 0; i < _isRaised.length; i++) {
                            i != 1 ? _isRaised[i] = false : _isRaised[i] = true;
                          }
                        }
                      });
                      setState((){
                        _widget = const ScheduleSettingsWidget();
                      });
                      if(isMobileAndTablet(context)) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                const ScheduleSettingsWidget()));


                      }
                    }),
                  const SizedBox(height: 10.0,),
                    menuLateralButton(2,"Impuestos",Icons.gavel_outlined, () {
                      if(!isMobileAndTablet(context)) {
                        setState(() {
                          for (int i = 0; i < _isRaised.length; i++) {
                            i != 2 ? _isRaised[i] = false : _isRaised[i] = true;
                          }
                       //   _widget = EmpresaWidget();
                        });
                        setState((){
                          _widget = const TaxesSettingsWidget();
                        });
                      }

                      if(isMobileAndTablet(context)) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                const TaxesSettingsWidget()));}


                    }),
                  const SizedBox(height: 10.0,),
                  menuLateralButton(3,"Caja",Icons.currency_exchange_rounded, () {
                    if(!isMobileAndTablet(context)) {
                      setState(() {
                        for (int i = 0; i < _isRaised.length; i++) {
                          i != 3 ? _isRaised[i] = false : _isRaised[i] = true;
                        }
                        _widget = const CashRegisterWidget();
                      });
                    }

                    if(isMobileAndTablet(context)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                          const CashRegisterWidget()));}


                  }),
                  const SizedBox(height: 10.0,),
                  menuLateralButton(4,"Monedas",Icons.currency_exchange_rounded, () {
                    if(!isMobileAndTablet(context)) {
                      setState(() {
                        for (int i = 0; i < _isRaised.length; i++) {
                          i != 4 ? _isRaised[i] = false : _isRaised[i] = true;
                        }
                        _widget = const CurrencySettingsWidget();
                      });
                    }

                    if(isMobileAndTablet(context)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              const CurrencySettingsWidget()));}


                  }),
                  const SizedBox(height: 10.0,),
                  menuLateralButton(5,"Idioma",Icons.translate_rounded, () {
                    if(!isMobileAndTablet(context)) {
                      setState(() {
                        for (int i = 0; i < _isRaised.length; i++) {
                          i != 5 ? _isRaised[i] = false : _isRaised[i] = true;
                        }
                       // _widget = TipoUsuarioWidget();
                      });
                    }

                    /*
                    if(isMobileAndTablet(context)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              TipoUsuarioWidget()));}

                     */
                  }),
                  const SizedBox(height: 10.0,),
                  menuLateralButton(6,"E-mail",Icons.email_outlined, () {
                    if(!isMobileAndTablet(context)) {
                      setState(() {
                        for (int i = 0; i < _isRaised.length; i++) {
                          i != 6 ? _isRaised[i] = false : _isRaised[i] = true;
                        }
                        //_widget = EmpleadosWidget();
                      });
                    }
/*
                    if(isMobileAndTablet(context)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              EmpleadosWidget()));}

 */
                  }),
                  const SizedBox(height: 10.0,),
                  menuLateralButton(7,"Apariencia",Icons.web_rounded, () {
                    if(!isMobileAndTablet(context)) {
                      setState(() {
                        for (int i = 0; i < _isRaised.length; i++) {
                          i != 7 ? _isRaised[i] = false : _isRaised[i] = true;
                        }
                        _widget = const AppearanceSettingsWidget();
                      });
                    }

                    if(isMobileAndTablet(context)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                             const AppearanceSettingsWidget()));}

                  }),
                  const SizedBox(height: 10.0,),
                  menuLateralButton(8,"Sitio",Icons.language_rounded, () {
                    if(!isMobileAndTablet(context)) {
                      setState(() {
                        for (int i = 0; i < _isRaised.length; i++) {
                          i != 8 ? _isRaised[i] = false : _isRaised[i] = true;
                        }
                        //_widget = UsuarioWidget();
                      });
                    }
/*
                    if(isMobileAndTablet(context)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              UsuarioWidget()));}

 */
                  }),
                  const SizedBox(height: 10.0,),
                  menuLateralButton(9,"Carousel",Icons.slideshow_rounded, () {
                    if(!isMobileAndTablet(context)) {
                      setState(() {
                        for (int i = 0; i < _isRaised.length; i++) {
                          i != 9 ? _isRaised[i] = false : _isRaised[i] = true;
                        }
                        _widget = const CarouselWidget();
                      });
                    }

                    if(isMobileAndTablet(context)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              const CarouselWidget()));}


                  }),
                  const SizedBox(height: 10.0,),
                  menuLateralButton(10,"Permisos",Icons.key_outlined, () {
                    if(!isMobileAndTablet(context)) {
                      setState(() {
                        for (int i = 0; i < _isRaised.length; i++) {
                          i != 10 ? _isRaised[i] = false : _isRaised[i] = true;
                        }
                        _widget = const PermissionSettingsWidget();
                      });
                    }

                    if(isMobileAndTablet(context)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              const PermissionSettingsWidget()));}
                  }),
                  const SizedBox(height: 10.0,),
                  menuLateralButton(11,"Pagos",Icons.payments_outlined, () {
                    if(!isMobileAndTablet(context)) {
                      setState(() {
                        for (int i = 0; i < _isRaised.length; i++) {
                          i != 11 ? _isRaised[i] = false : _isRaised[i] = true;
                        }
                        //_widget = UsuarioWidget();
                      });
                    }
/*
                    if(isMobileAndTablet(context)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              UsuarioWidget()));}

 */
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

  Widget menuLateralButton(int index, String title,IconData icon,VoidCallback onTap){
    return InkWell(

      onHover: (value) {
        setState(() {
          value
              ? _isHovering[index] = true
              : _isHovering[index] = false;
        });
      },
      onTap: onTap,
      child: Container(
        width: isMobileAndTablet(context)? displayWidth(context)*0.9 :220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: isMobileAndTablet(context)? Colors.grey.withOpacity(0.2) : _isRaised[index]
              ? Theme.of(context).primaryColor:
          _isHovering[index]
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                size: 30.0,
                color: isMobileAndTablet(context)?Colors.grey:_isRaised[index]
                    ? Colors.white:_isHovering[index]
                    ? Theme.of(context).primaryColor
                //[widget.colorTone]
                    : Colors.grey,
              ),
              const SizedBox(width: 15.0,),
              Column(
                children: [
                  Text(title,
                    style: TextStyle(
                      // fontWeight: FontWeight.w600,
                      color: isMobileAndTablet(context)?Colors.grey:_isRaised[index]
                          ? Colors.white:_isHovering[index]
                          ? Theme.of(context).primaryColor//[widget.colorTone]
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Visibility(
                    maintainAnimation: true,
                    maintainState: true,
                    maintainSize: true,
                    visible:_isHovering[index],
                    child: Container(
                      height: responsiveApp.lineHznButtonHeight,
                      width: responsiveApp.lineHznButtonWidth,
                      color: _isRaised[index]
                          ? Colors.white:Theme.of(context).primaryColor,//[widget.colorTone]
                    ),
                  ),
                ],
              ),
              if(isMobileAndTablet(context))
                const Expanded(child: SizedBox(),),
              if(isMobileAndTablet(context))
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey)
            ],
          ),
        ),
      ),
    );
  }
}
