import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../util/db_connection.dart';
import 'package:provider/provider.dart';

import '../util/SizingInfo.dart';
import '../util/Util.dart';
import '../util/states/theme_state.dart';
import '../values/ResponsiveApp.dart';
import 'change_password_widget.dart';

class AnswerQuestionsWidget extends StatefulWidget {
  const AnswerQuestionsWidget({super.key});

  @override
  State<AnswerQuestionsWidget> createState() => _AnswerQuestionsWidgetState();
}

class _AnswerQuestionsWidgetState extends State<AnswerQuestionsWidget> {
  late final ResponsiveApp responsiveApp;

  late final BDConnection dbConnection;

  final AppData appData = AppData();

  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController r1Controller = TextEditingController();

  final TextEditingController r2Controller = TextEditingController();

  final TextEditingController r3Controller = TextEditingController();

  late String selectedQuestion1 = 'Selecciona una pregunta';

  late String selectedQuestion2 = 'Selecciona una pregunta';

  late String selectedQuestion3 = 'Selecciona una pregunta';

  static String response1 = '';

  static String response2 = '';

  static String response3 = '';

  List<String> userQuestions = [];

  static int userId = 0;

  bool firstTime = true;
  bool edit = false;

  @override
  Widget build(BuildContext context) {
    if(firstTime){
      responsiveApp = ResponsiveApp(context);
      dbConnection = BDConnection(context: context);
      firstTime = false;
    }
    return SafeArea(
        child: Scaffold(
            body: Consumer<ThemeState>(
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
                  child: body(),
                );
              }
            )
        )
    );
  }

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      if(userId==0){
        getUserId();
      }else{
        if(response1 == r1Controller.text &&response2 == r2Controller.text &&response3 == r3Controller.text){
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                ChangePasswordWidget(reason: 'forgot_pass',userId: userId,)));
        }else{
          CustomSnackBar().show(
              context: context,
              msg: 'Las respuestas no coinciden.',
              icon: Icons.warning_rounded,
              color: const Color(0xfff8b91a)
          );
        }
      }
    }
  }

  getUserId()async{
    final query = await dbConnection.getData(
        onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
        context: context,
        fields: 'users.id', table: 'users',
        where: 'email=\'${usernameController.text}\' OR mobile=\'${usernameController.text}\'',
        order: 'ASC', orderBy: 'id', groupBy: 'id');
    if(query.isNotEmpty){
        setState(() {
        userId = int.parse(query[0]['id']);
      });
    }else{
      CustomSnackBar().show(context: context, msg: 'Usuario no encontrado!', icon: Icons.error_rounded, color: Colors.red);
    }
  }

  Widget body(){
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
      child: FutureBuilder(
          future: dbConnection.getData(
              onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
              context: context,
              fields: '*',
              table: 'security_questions',
              where: 'user_id=$userId',
              orderBy: 'user_id',
              order: 'ASC',
              groupBy: "user_id"
          ),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.data==null){
              return const Center(child: CircularProgressIndicator(),);
            }else{
                if(userId>0 && snapshot.data.isNotEmpty){
                  selectedQuestion1 = snapshot.data[0]['question_1'];
                  selectedQuestion2 = snapshot.data[0]['question_2'];
                  selectedQuestion3 = snapshot.data[0]['question_3'];
                  response1 = snapshot.data[0]['response_1'];
                  response2 = snapshot.data[0]['response_2'];
                  response3 = snapshot.data[0]['response_3'];
                }

              return Padding(
                padding: isMobileAndTablet(context)? EdgeInsets.zero : responsiveApp.edgeInsetsApp.onlySmallLeftEdgeInsets,
                child: Padding(
                  padding: isMobileAndTablet(context)? responsiveApp.edgeInsetsApp.onlySmallRightEdgeInsets : responsiveApp.edgeInsetsApp.onlyMediumRightEdgeInsets,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
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
                          mainAxisSize: MainAxisSize.min,
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
                                      field(context: context, controller: usernameController, label: 'Nombre de usuario', keyboardType: TextInputType.text,),
                                      SizedBox(height: responsiveApp.setHeight(5),),
                                      if(userId>0 && snapshot.data.isNotEmpty)texto(text: selectedQuestion1, size: responsiveApp.setSP(14)),
                                      if(userId>0 && snapshot.data.isNotEmpty)field(context: context, controller: r1Controller, label: 'Respuesta', keyboardType: TextInputType.text,),
                                      SizedBox(height: responsiveApp.setHeight(5),),
                                      if(userId>0 && snapshot.data.isNotEmpty)texto(text: selectedQuestion2, size: responsiveApp.setSP(14)),
                                      if(userId>0 && snapshot.data.isNotEmpty)field(context: context, controller: r2Controller, label: 'Respuesta', keyboardType: TextInputType.text,),
                                      SizedBox(height: responsiveApp.setHeight(5),),
                                      if(userId>0 && snapshot.data.isNotEmpty)texto(text: selectedQuestion3, size: responsiveApp.setSP(14)),
                                      if(userId>0 && snapshot.data.isNotEmpty)field(context: context, controller: r3Controller, label: 'Respuesta', keyboardType: TextInputType.text,),
                                      SizedBox(height: responsiveApp.setHeight(5),),
                                      if(userId>0 && snapshot.data.isEmpty)
                                      Padding(
                                        padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                                        child: Column(
                                            children: [
                                              Icon(Icons.error_outline_rounded, size: responsiveApp.setWidth(30),color: Colors.red,),
                                              texto(text: '¡Lo sentimos!', size: responsiveApp.setSP(14), color: Colors.grey),
                                              texto(text: 'Este usuario no tiene configurado las respuestas de seguridad, pongase en contacto con su administrador.', alignment: TextAlign.center, size: responsiveApp.setSP(14), color: Colors.grey),
                                            ]
                                        ),
                                      ),
                                      SizedBox(height: responsiveApp.setHeight(5),),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: responsiveApp.setWidth(10),),
                                            actionButton(
                                                name: 'Volver',
                                                color: const Color(0xffD3D3D3).withOpacity(0.4),
                                                iconColor: Colors.grey,
                                                icon: Icons.arrow_back_ios_new_rounded,
                                                onTap: (){
                                                  userId = 0;
                                                  Navigator.pop(context);
                                                }
                                            ),
                                          SizedBox(width: responsiveApp.setWidth(20),),
                                          if(userId==0 || (userId>0 && snapshot.data.isNotEmpty))
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
                    ],
                  ),
                ),
              );
            }
          }
      ),
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
