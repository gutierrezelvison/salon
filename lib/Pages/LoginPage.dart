import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Widgets/Components/WidgetLogin.dart';
import '../util/SizingInfo.dart';
import '../util/Util.dart';
import '../util/states/theme_state.dart';
import '../values/ResponsiveApp.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.reason}) : super(key: key);
  final String reason;

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with TickerProviderStateMixin{
  late ResponsiveApp responsiveApp;
  TextEditingController serverNameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return SafeArea(
      child: Scaffold(
        body: Consumer<ThemeState>(
            builder: (context, state, child) {
              return Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image:  DecorationImage(
                      image:  AssetImage(state.isDarkModeEnabled?"assets/images/img_1.png":"assets/images/img_1.png"),
                      fit: BoxFit.cover
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
                            child: ClipRect( // Wrap the Container with ClipRect
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                child: Container(
                                  width: isMobile(context)
                                      ? displayWidth(context) * 0.95
                                      : responsiveApp.setWidth(350),
                                  padding:
                                  responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    color: Theme.of(context)
                                        .cardColor
                                        .withOpacity(0.2),
                                    borderRadius:
                                    BorderRadius.circular(responsiveApp.setWidth(15)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                                          texto(text: 'Volver', size: responsiveApp.setSP(12)),
                                        ],
                                      ),
                                      // SizedBox(height: responsiveApp.setHeight(80),),
                                      AppData().getCompanyData().logo!='null' && AppData().getCompanyData().logo!=null && AppData().getCompanyData().logo!=''
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(responsiveApp.carrouselRadiusWidth),
                                            child: Image.memory(
                                              AppData().getCompanyData().logo.bytes,
                                              height: responsiveApp.setHeight(100),
                                            ),
                                          )
                                          :Image.asset(
                                        'assets/images/logo.png',
                                        height: responsiveApp.setHeight(100),
                                      ),
                                      SizedBox(height: responsiveApp.setHeight(10),),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Text("Bienvenido",
                                              style: TextStyle(
                                                // color: Colors.white,
                                                  fontSize: responsiveApp.setSP(16),
                                                  fontFamily: "Montserrat",
                                                  letterSpacing: responsiveApp.letterSpacingHeaderWidth
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Text("Inicie sesión para continuar",
                                              style: TextStyle(
                                                //color: Colors.blueGrey,
                                                fontSize: responsiveApp.setSP(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      WidgetLogin(reason: widget.reason,),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
        ),
      ),
    );
  }
}