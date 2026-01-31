import 'package:flutter/material.dart';
import '../../../util/db_connection.dart';

import '../util/Util.dart';
import '../values/ResponsiveApp.dart';

class SecurityQuestionsWidget extends StatefulWidget {
  const SecurityQuestionsWidget({super.key, required this.hasSecurityQuestions,});
  final bool hasSecurityQuestions;
  @override
  State<SecurityQuestionsWidget> createState() => _SecurityQuestionsWidgetState();
}

class _SecurityQuestionsWidgetState extends State<SecurityQuestionsWidget> {
  late final ResponsiveApp responsiveApp;

  late final BDConnection dbConnection;

  final AppData appData = AppData();

  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _searchController = TextEditingController();

  final TextEditingController r1Controller = TextEditingController();

  final TextEditingController r2Controller = TextEditingController();

  final TextEditingController r3Controller = TextEditingController();

  late String selectedQuestion1 = 'Selecciona una pregunta';

  late String selectedQuestion2 = 'Selecciona una pregunta';

  late String selectedQuestion3 = 'Selecciona una pregunta';

  List<String> userSelection = [];

  bool firstTime = true;
  bool edit = false;

  final List<String> questions = [
      'Selecciona una pregunta',
      '¿Cuál fue el nombre de tu primera mascota?',
      '¿Cuál es el nombre de soltera de tu madre?',
      '¿Cuál fue tu ciudad natal?',
      '¿Cuál es tu comida favorita?',
      '¿Cuál es el nombre de tu mejor amigo/a de la infancia?',
      '¿Cuál es tu canción favorita?',
      '¿Cuál es el nombre de tu abuelo/a?',
      '¿Cuál es tu color favorito?',
      '¿Cuál fue tu primer trabajo?',
      '¿Cuál es el nombre de tu libro favorito?',
  ];

  @override
  Widget build(BuildContext context) {
    if(firstTime){
      responsiveApp = ResponsiveApp(context);
      dbConnection = BDConnection(context: context);
      firstTime = false;
    }
    return body();
  }

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      if(edit){
        if(await dbConnection.updateQuestions(
            onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context: context,
            questions: Questions(
              user_id: appData.getUserData().id,
              question_1: selectedQuestion1,
              question_2: selectedQuestion2,
              question_3: selectedQuestion3,
              response_1: r1Controller.text,
              response_2: r2Controller.text,
              response_3: r3Controller.text,
            )
        )){
          setState(() {
            edit = false;
          });
          CustomSnackBar().show(
              context: context,
              msg: 'Operación realizada con éxito!',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xff22d88d)
          );
        }else{
          CustomSnackBar().show(
              context: context,
              msg: 'No se pudo completar la operación!',
              icon: Icons.error_outline_outlined,
              color: const Color(0xffFF525C)
          );
        }
      }else{
        if(await dbConnection.addQuestions(
            onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
            context: context,
            questions: Questions(
              user_id: appData.getUserData().id,
              question_1: selectedQuestion1,
              question_2: selectedQuestion2,
              question_3: selectedQuestion3,
              response_1: r1Controller.text,
              response_2: r2Controller.text,
              response_3: r3Controller.text,
            )
        )){
          CustomSnackBar().show(
              context: context,
              msg: 'Operación realizada con éxito!',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xff22d88d)
          );
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
  }

  Widget body(){
    return FutureBuilder(
      future: dbConnection.getData(
          onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
        context: context,
        fields: '*',
        table: 'security_questions',
        where: 'user_id=${appData.getUserData().id}',
        orderBy: 'user_id',
        order: 'ASC',
        groupBy: "user_id"
      ),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.data==null){
          return const Center(child: CircularProgressIndicator(),);
        }else{
          if(!edit && widget.hasSecurityQuestions){
            selectedQuestion1 = snapshot.data[0]['question_1'];
            selectedQuestion2 = snapshot.data[0]['question_2'];
            selectedQuestion3 = snapshot.data[0]['question_3'];
            r1Controller.text = snapshot.data[0]['response_1'];
            r2Controller.text = snapshot.data[0]['response_2'];
            r3Controller.text = snapshot.data[0]['response_3'];
          }
          return Padding(
            padding: responsiveApp.edgeInsetsApp.onlySmallLeftEdgeInsets,
            child: Padding(
              padding: responsiveApp.edgeInsetsApp.onlyMediumRightEdgeInsets,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: responsiveApp.setHeight(20),),
                            if(edit || !widget.hasSecurityQuestions)
                            Padding(
                              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                              child: Row(
                                  children: [
                                    Expanded(
                                      child:
                                      customDropDown(
                                          searchController: _searchController,
                                          items: questions,
                                          value: selectedQuestion1,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedQuestion1 = value as String;
                                              _searchController.text='';
                                            });
                                          },
                                          searchInnerWidgetHeight: responsiveApp.setHeight(50), context: context
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                            field(context: context, controller: r1Controller, label: !edit & widget.hasSecurityQuestions?selectedQuestion1:'Respuesta', keyboardType: TextInputType.text,enabled: edit||!widget.hasSecurityQuestions),
                            if(edit || !widget.hasSecurityQuestions)
                            Padding(
                              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                              child: Row(
                                  children: [
                                    Expanded(
                                      child:
                                      customDropDown(
                                          searchController: _searchController,
                                          items: questions,
                                          value: selectedQuestion2,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedQuestion2 = value as String;
                                              _searchController.text='';
                                            });
                                          },
                                          searchInnerWidgetHeight: responsiveApp.setHeight(50), context: context
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                            field(context: context, controller: r2Controller, label: !edit & widget.hasSecurityQuestions?selectedQuestion2:'Respuesta', keyboardType: TextInputType.text, enabled: edit||!widget.hasSecurityQuestions),
                            if(edit || !widget.hasSecurityQuestions)
                            Padding(
                              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                              child: Row(
                                  children: [
                                    Expanded(
                                      child:
                                      customDropDown(
                                          searchController: _searchController,
                                          items: questions,
                                          value: selectedQuestion3,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedQuestion3 = value as String;
                                              _searchController.text='';
                                            });
                                          },
                                          searchInnerWidgetHeight: responsiveApp.setHeight(50), context: context
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                            field(context: context, controller: r3Controller, label: !edit & widget.hasSecurityQuestions?selectedQuestion3:'Respuesta', keyboardType: TextInputType.text, enabled: edit||!widget.hasSecurityQuestions),
                            SizedBox(height: responsiveApp.setHeight(5),),
                            Row(
                              children: [
                                SizedBox(width: responsiveApp.setWidth(10),),
                                if(widget.hasSecurityQuestions)
                                actionButton(
                                    name: edit?'Cancelar':'Editar',
                                    color: edit?const Color(0xffff4567):const Color(0xffffdc65),
                                    icon: edit? Icons.cancel :Icons.edit,
                                    onTap: (){
                                      if(edit) {
                                        warningMsg(
                                            context: context,
                                            mainMsg: 'Seguro que desea cancelar?',
                                            msg: 'Se perderan los datos no guardados.',
                                            okBtnText: 'Si, Cancelar',
                                            cancelBtnText: 'No, abortar',
                                            okBtn: (){
                                              setState(() {
                                                edit=false;
                                              });
                                              Navigator.pop(context);
                                            },
                                            cancelBtn: (){Navigator.pop(context);}
                                        );
                                      }else{
                                        setState(() {
                                          edit = true;
                                        });
                                      }
                                    }
                                ),
                                SizedBox(width: responsiveApp.setWidth(10),),
                                if(edit || !widget.hasSecurityQuestions)
                                  Padding(
                                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        actionButton(
                                            name: 'Guardar',
                                            color: const Color(0xff6C9BD2),
                                            icon: Icons.save,
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
          );
        }
      }
    );
  }

  Widget actionButton({required String name, required IconData icon,required Color color,required VoidCallback onTap}){
    return Column(
      children: [
        InkWell(
            onTap: onTap,
            child: Container(
                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(10)),
                ),
                child: Icon(icon, color: Colors.white,)
            )
        ),
        SizedBox(height: name!=''?responsiveApp.setHeight(3):0,),
        name!=''?texto(text: name, size: responsiveApp.setSP(10)):const SizedBox(),

      ],
    );
  }
}
