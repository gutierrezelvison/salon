import 'package:flutter/material.dart';
import 'package:salon/util/db_connection.dart';
import 'package:salon/values/ResponsiveApp.dart';

import '../../util/Util.dart';

class AdminCashValidatorWidget extends StatefulWidget {
  const AdminCashValidatorWidget({super.key});

  @override
  State<AdminCashValidatorWidget> createState() => _AdminCashValidatorWidgetState();
}

class _AdminCashValidatorWidgetState extends State<AdminCashValidatorWidget> {

  late ResponsiveApp responsiveApp;
  BDConnection bdConnection = BDConnection();
  int pageIndex = 0;
  int selectedId = 0;
  List<bool> selectedIndex =[];

  void _saveForm() async {
      if (await bdConnection.addAdminCashValidator(
            onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},

              userId: selectedId,
            )) {
        setState(() {
          pageIndex = 0;
          selectedIndex .clear();
          selectedId = 0;
        });
          CustomSnackBar().show(
              context: context,
              msg: 'Registro agregado con éxito!',
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

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
            children: [Expanded(child: Text("Autorizaciones de caja",style: Theme.of(context).textTheme.titleLarge,)),
              if(pageIndex==0)
                InkWell(
                  onTap: (){
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                  child: Container(
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(50)),
                      color: const Color(0xff6C9BD2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: responsiveApp.setWidth(20),
                        ),
                        texto(
                          size: responsiveApp.setSP(12),
                          text: 'Añadir',
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(width: responsiveApp.setWidth(10),),
            ]),
        if(pageIndex==0)
        SingleChildScrollView(
          child: FutureBuilder(future: bdConnection.getData(
              onError: (onError){},
              fields: 'acm.*, u.name, u.image',
              table: ' admin_cash_validator acm INNER JOIN users u ON u.id = acm.user_id ',
              where: '1',
              order: 'DESC',
              orderBy: 'acm.id',
              groupBy: 'acm.id'
          ),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.data==null){
                  return Center(child: CircularProgressIndicator(),);
                }else if(snapshot.data.isEmpty){
                  return Center(child: Text("No se ha agregado ningun usuario"));
                }else{
                  return Column(
                    children: List.generate(snapshot.data.length, (index){
                      return Row(
                        children: [
                          Expanded(child: Text(snapshot.data[index]['name'],style: Theme.of(context).textTheme.titleMedium,)),
                          IconButton(onPressed: ()async{if(await bdConnection.deleteData(context: context,table: 'admin_cash_validator', id: int.parse(snapshot.data[index]['id'].toString()))) {
                            setState(() {
                            });
                          }}, icon: Icon(Icons.delete_forever_rounded))
                        ],
                      );
                    }
                    ),
                  );
                }
              }
          ),
        ),
      if(pageIndex==1)
        SingleChildScrollView(
          child: FutureBuilder(future: bdConnection.getData(
              onError: (onError){},
              fields: 'u.id, u.name, u.image',
              table: ' users u INNER JOIN role_user ur ON u.id = ur.user_id',
              where: 'u.id > 1 AND ur.role_id = 1',
              order: 'ASC',
              orderBy: 'u.id',
              groupBy: 'u.id'
          ),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.data==null){
                  return Center(child: CircularProgressIndicator(),);
                }else if(snapshot.data.isEmpty){
                  return Center(child: Text("No se ha agregado ningun usuario"));
                }else{
                  if(selectedIndex.isEmpty) {
                    for (var i = 0; i < snapshot.data.length; i++) {
                      selectedIndex.add(false);
                    }
                  }
                  return Column(
                    children: List.generate(snapshot.data.length, (index){
                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap:(){
                                setState(() {
                                  if (selectedIndex[index]) {
                                    selectedIndex[index] = false;
                                    selectedId = 0;
                                  } else {
                                    for (int i = 0; i < selectedIndex.length; i++) {
                                      selectedIndex[i] = (i == index);
                                    }
                                    selectedId = int.parse(snapshot.data[index]['id'].toString());
                                  }
                                });
                              },
                              child: Container(
                                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                                  decoration: BoxDecoration(
                                    color: selectedIndex[index]? Theme.of(context).primaryColor.withValues(alpha: 0.3):Colors.transparent,
                                  ),
                                  child: Text(snapshot.data[index]['name'],style: Theme.of(context).textTheme.titleMedium,)
                              ),
                            ),
                          )
                        ],
                      );
                    }
                    ),
                  );
                }
              }
          ),
        ),
        Row(
          children: [
            if(pageIndex==1)
              InkWell(
                onTap: (){
                  _saveForm();
                },
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(50)),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.save,
                        color: Colors.white,
                        size: responsiveApp.setWidth(20),
                      ),
                      texto(
                        size: responsiveApp.setSP(12),
                        text: 'Guardar',
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }
}
