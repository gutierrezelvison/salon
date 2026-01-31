import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../util/db_connection.dart';
import 'package:provider/provider.dart';
import '../util/SizingInfo.dart';
import '../util/Util.dart';
import '../util/states/login_state.dart';
import '../util/states/theme_state.dart';
import '../values/ResponsiveApp.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key,required this.reason, required this.userId});
  final String reason;
  final int userId;
  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  late final ResponsiveApp responsiveApp;

  late final BDConnection dbConnection;

  final AppData appData = AppData();

  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController passController = TextEditingController();

  final TextEditingController newPassController = TextEditingController();

  final TextEditingController rNewPassController = TextEditingController();

  List<String> userQuestions = [];

  bool firstTime = true;
  bool edit = false;
  bool verPass1 = true;
  bool verPass2 = true;
  bool verPass3 = true;

  @override
  Widget build(BuildContext context) {
    if(firstTime){
      responsiveApp = ResponsiveApp(context);
      dbConnection = BDConnection(context: context);
      firstTime = false;
    }
    return SafeArea(child: Scaffold(body: body()));
  }

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      if(appData.getUserData().password == passController.text || widget.reason=='forgot_pass'){
        if(newPassController.text == rNewPassController.text){
          if(await dbConnection.changePassword(
              onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context: context, password: newPassController.text, isDefaultPass: 0, userId: widget.userId)){
            CustomSnackBar().show(
                context: context,
                msg: 'Operación realizada con éxito!',
                icon: Icons.check_circle_rounded,
                color: const Color(0xff22d88d)
            );
            if(widget.reason=='change_default'){
              Provider.of<LoginState>(context, listen: false).logout();
            }else if(widget.reason=='user_change'){
              Provider.of<LoginState>(context, listen: false).logout();
              Navigator.pop(context);
            }else{
            Navigator.pop(context);
          }
          }else{
            CustomSnackBar().show(
                context: context,
                msg: 'No se pudo completar la operación!',
                icon: Icons.error_rounded,
                color: const Color(0xffFF525C)
            );
          }
        }else{
          CustomSnackBar().show(
              context: context,
              msg: 'Las contraseñas no coinciden.',
              icon: Icons.warning_rounded,
              color: const Color(0xfff8b91a)
          );
        }
      }else{
        CustomSnackBar().show(
            context: context,
            msg: 'Contraseña incorrecta',
            icon: Icons.error_rounded,
            color: const Color(0xffFF525C)
        );
      }
    }
  }

  Widget body(){
    return Consumer<ThemeState>(
        builder: (context, state, child) {
        return Container(
          height: displayHeight(context),
          width: displayWidth(context),
          decoration: BoxDecoration(
            image:  DecorationImage(
                image:  AssetImage(state.isDarkModeEnabled?"assets/images/fondo_color_dark.jpg":"assets/images/fondo_color.jpeg"),
                fit: BoxFit.cover
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
            child: Padding(
              padding: isMobileAndTablet(context)? EdgeInsets.zero : responsiveApp.edgeInsetsApp.onlySmallLeftEdgeInsets,
              child: Padding(
                padding: isMobileAndTablet(context)? responsiveApp.edgeInsetsApp.onlySmallRightEdgeInsets : responsiveApp.edgeInsetsApp.onlyMediumRightEdgeInsets,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: isMobile(context)? displayWidth(context)*0.85 :responsiveApp.setWidth(350),
                        margin: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
                        padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(15)),
                        ),
                        /*
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(10)),
                                    boxShadow: const [
                                      BoxShadow(
                                        spreadRadius: -7,
                                        blurRadius: 8,
                                        offset: Offset(0, 0),
                                      ),
                                    ]
                                ),

                                 */
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: responsiveApp.setHeight(20),),
                                      if(widget.reason!='forgot_pass')
                                      field(context: context,maxLines: 1, controller: passController, label: 'Contraseña actual', keyboardType: TextInputType.text,obscureText: verPass1,suffix: InkWell(
                                        onTap: (){
                                          setState((){
                                            verPass1 = !verPass1;
                                          });
                                        },
                                        child: Icon(
                                            verPass1? Icons.remove_red_eye: Icons.disabled_visible,
                                            //color: Colors.black.withOpacity(0.7)
                                        ),
                                      ),
                                      ),
                                      SizedBox(height: responsiveApp.setHeight(5),),
                                      field(context: context,maxLines: 1, controller: newPassController, label: 'Nueva contraseña', keyboardType: TextInputType.text,obscureText: verPass2,suffix: InkWell(
                                        onTap: (){
                                          setState((){
                                            verPass2 = !verPass2;
                                          });
                                        },
                                        child: Icon(
                                            verPass2? Icons.remove_red_eye: Icons.disabled_visible,
                                            //color: Colors.black.withOpacity(0.7)
                                        ),
                                      ),
                                      ),
                                      SizedBox(height: responsiveApp.setHeight(5),),
                                      field(context: context, maxLines: 1, controller: rNewPassController, label: 'Repetir Contraseña', keyboardType: TextInputType.text,obscureText: verPass3,suffix: InkWell(
                                        onTap: (){
                                          setState((){
                                            verPass3 = !verPass3;
                                          });
                                        },
                                        child: Icon(
                                            verPass3? Icons.remove_red_eye: Icons.disabled_visible,
                                            //color: Colors.black.withOpacity(0.7)
                                        ),
                                      ),
                                      ),
                                      SizedBox(height: responsiveApp.setHeight(5),),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: responsiveApp.setWidth(10),),
                                          if(widget.reason!='change_default')
                                          actionButton(
                                              name: 'Volver',
                                              color: const Color(0xffD3D3D3).withOpacity(0.4),
                                              iconColor: Colors.grey,
                                              icon: Icons.arrow_back_ios_new_rounded,
                                              onTap: (){
                                                Navigator.pop(context);
                                              }
                                          ),
                                          SizedBox(width: responsiveApp.setWidth(20),),
                                          Padding(
                                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                actionButton(
                                                    name: 'Continuar',
                                                    color: const Color(0xff6C9BD2),
                                                    iconColor: Colors.white,
                                                    icon: Icons.arrow_forward_ios_rounded,
                                                    onTap: (){
                                                      _saveForm();
                                                    }
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: responsiveApp.setHeight(20),),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget actionButton({required String name, required Color iconColor,required IconData icon,required Color color,required VoidCallback onTap}){
    return Column(
      children: [
        InkWell(
            onTap: onTap,
            child: Container(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(100)),
                ),
                child: Center(child: Icon(icon, color: iconColor,))
            )
        ),
        SizedBox(height: name!=''?responsiveApp.setHeight(3):0,),
        name!=''?texto(text: name, size: responsiveApp.setSP(10)):const SizedBox(),

      ],
    );
  }
}
