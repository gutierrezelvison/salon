
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../util/Util.dart';
import 'package:provider/provider.dart';

import '../../util/SizingInfo.dart';
import '../../util/db_connection.dart';
import '../../util/states/local_auth_state.dart';
import '../../util/states/theme_state.dart';
import '../../values/ResponsiveApp.dart';

class AppearanceSettingsWidget extends StatefulWidget {
  const AppearanceSettingsWidget({Key? key}) : super(key: key);

  @override
  State<AppearanceSettingsWidget> createState() => _AppearanceSettingsWidgetState();
}

class _AppearanceSettingsWidgetState extends State<AppearanceSettingsWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  int pageIndex = 0;
  bool edit = false;
  bool firstTime = true;
  int idCurrency = 0;
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool canCheckBiometric = false;
  late Color dialogPickerColor; // Color for picker in dialog using onChanged
  late Color dialogSelectColor; // Color for picker using color select dialog.

  @override
  initState(){
    checkBiometric();
    dialogPickerColor = Colors.red;
    dialogSelectColor = const Color(0xFFA239CA);
    super.initState();
  }

  Future<void> checkBiometric() async {

    bool value = await _localAuthentication.isDeviceSupported();

    setState(() {
      canCheckBiometric = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    bdConnection = BDConnection(context: context);

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
          child: Container(
            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
            color: Colors.transparent,
            child: Row(
              children: [
                if(isMobileAndTablet(context))
                  IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(pageIndex==1?Icons.arrow_back_rounded:Icons.arrow_back_rounded,)),
                if(!isMobileAndTablet(context)&&pageIndex==1)
                  IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back_rounded, )),
                const Expanded(
                  child: Text("Apariencia",
                    style: TextStyle(
                      //color: Colors.white,
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        body: Row(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  return Future.delayed(
                    const Duration(seconds: 1),
                        () {
                      setState((){
                      });
                    },
                  );
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if(pageIndex==0)
                        body(),
                      if(pageIndex==1)
                        const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget body(){
    return Column(
      children: [
        Row(
          children: [
            /*
            Container(
              margin: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
              width: isMobileAndTablet(context)? responsiveApp.setWidth(180): responsiveApp.setWidth(120),
              height: responsiveApp.setHeight(80),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      spreadRadius: -7,
                      offset: Offset(0,1),
                    ),
                  ]
              ),
              child: Consumer<ThemeState>(
                builder: (context, state, child) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(8)),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(height: responsiveApp.setHeight(8),),
                        const Text('Modo oscuro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: responsiveApp.setHeight(8),),
                        InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: (){
                            state.setDarkMode(!state.isDarkModeEnabled);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.decelerate,
                            width: responsiveApp.setWidth(50),
                            decoration:BoxDecoration(
                              borderRadius:BorderRadius.circular(50.0),
                              color: state.isDarkModeEnabled ? const Color(0xff22d88d) : Colors.grey.withOpacity(0.6),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              alignment: state.isDarkModeEnabled ? Alignment.centerRight : Alignment.centerLeft,
                              curve: Curves.decelerate,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  width: responsiveApp.setWidth(20),
                                  height: responsiveApp.setHeight(20),
                                  decoration:BoxDecoration(
                                    color: const Color (0xffFFFFFF),
                                    borderRadius:BorderRadius.circular(100.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: responsiveApp.setHeight(8),),
                      ],
                    ),
                  );
                },
              ),
            ),

             */
            Container(
              margin: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
              width: isMobileAndTablet(context)? responsiveApp.setWidth(180): responsiveApp.setWidth(120),
              height: responsiveApp.setHeight(80),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      spreadRadius: -7,
                      offset: Offset(0,1),
                    ),
                  ]
              ),
              child: Column(
                children: [
                  texto(text: 'Color principal', size: responsiveApp.setSP(12)),
                  ColorIndicator(
                    width: 40,
                    height: 40,
                    borderRadius: 0,
                    color: dialogSelectColor,
                    elevation: 1,
                    onSelectFocus: false,
                    onSelect: ()async{
                      final Color newColor = await showColorPickerDialog(
                        // The dialog needs a context, we pass it in.
                        context,
                        // We use the dialogSelectColor, as its starting color.
                        dialogSelectColor,
                        title: Text('ColorPicker',
                            style: Theme.of(context).textTheme.titleLarge),
                        width: 40,
                        height: 40,
                        spacing: 0,
                        runSpacing: 0,
                        borderRadius: 0,
                        wheelDiameter: 165,
                        enableOpacity: true,
                        showColorCode: true,
                        colorCodeHasColor: true,
                        pickersEnabled: <ColorPickerType, bool>{
                          ColorPickerType.wheel: true,
                        },
                        copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                          copyButton: false,
                          pasteButton: false,
                          longPressMenu: true,
                        ),
                        actionButtons: const ColorPickerActionButtons(
                          okButton: true,
                          closeButton: true,
                          dialogActionButtons: false,
                        ),
                        transitionBuilder: (BuildContext context,
                            Animation<double> a1,
                            Animation<double> a2,
                            Widget widget) {
                          final double curvedValue =
                              Curves.easeInOutBack.transform(a1.value) - 1.0;
                          return Transform(
                            transform: Matrix4.translationValues(
                                0.0, curvedValue * 200, 0.0),
                            child: Opacity(
                              opacity: a1.value,
                              child: widget,
                            ),
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                        constraints: const BoxConstraints(
                            minHeight: 480, minWidth: 320, maxWidth: 320),
                      );
                      // We update the dialogSelectColor, to the returned result
                      // color. If the dialog was dismissed it actually returns
                      // the color we started with. The extra update for that
                      // below does not really matter, but if you want you can
                      // check if they are equal and skip the update below.
                      setState(() {
                        dialogSelectColor = newColor;
                      });
                    },
                  ),
                ],
              ),
            ),
            if(canCheckBiometric && !kIsWeb)
            Container(
              margin: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
              width: isMobileAndTablet(context)? responsiveApp.setWidth(170): responsiveApp.setWidth(120),
              height: responsiveApp.setHeight(80),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      spreadRadius: -7,
                      offset: Offset(0,1),
                    ),
                  ]
              ),
              child: Consumer<LocalAuthState>(
                builder: (context, state, child) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsiveApp.setWidth(8)),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(height: responsiveApp.setHeight(8),),
                        const Text('Biometricos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: responsiveApp.setHeight(8),),
                        InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {

                            if(!state.biometricEnabled){
                              bool isAuthorized = false;
                              try {
                                isAuthorized = await _localAuthentication.authenticate(
                                  localizedReason: "Por favor autenticarse para continuar con la operación",
                                );
                              } on PlatformException catch (e) {
                                if (kDebugMode) {
                                  print(e);
                                }
                              }

                              if (!mounted) return;

                              setState(() {
                                if (isAuthorized) {
                                  state.setBiometrics(!state.biometricEnabled);
                                }
                              });
                            }else{
                              state.setBiometrics(!state.biometricEnabled);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.decelerate,
                            width: responsiveApp.setWidth(50),
                            decoration:BoxDecoration(
                              borderRadius:BorderRadius.circular(50.0),
                              color: state.isBiometricEnabled() ? const Color(0xff22d88d) : Colors.grey.withOpacity(0.6),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              alignment: state.isBiometricEnabled() ? Alignment.centerRight : Alignment.centerLeft,
                              curve: Curves.decelerate,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  width: responsiveApp.setWidth(20),
                                  height: responsiveApp.setHeight(20),
                                  decoration:BoxDecoration(
                                    color: const Color (0xffFFFFFF),
                                    borderRadius:BorderRadius.circular(100.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: responsiveApp.setHeight(8),),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
