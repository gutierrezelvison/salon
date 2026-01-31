import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';

class SucursalWidget extends StatefulWidget {
  const SucursalWidget({Key? key}) : super(key: key);

  @override
  State<SucursalWidget> createState() => _SucursalWidgetState();
}

class _SucursalWidgetState extends State<SucursalWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _localNameController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  bool firstTime = true;
  int idSucursal = 0;

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
        if (edit) {
          if (await bdConnection.updateSucursal(context: context,id: idSucursal,name: _localNameController.text)) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Sucursal actualizada con éxito!',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xff22d88d)
            );
          }else{
            CustomSnackBar().show(
                context: context,
                msg: 'No se pudo completar la transacción!',
                icon: Icons.error_outline_outlined,
                color: const Color(0xffFF525C)
            );
          }
        } else {
          if (await bdConnection.setSucursal(context: context,name: _localNameController.text)) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Sucursal agregada con éxito!',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xff22d88d)
            );
          }else{
            CustomSnackBar().show(
                context: context,
                msg: 'No se pudo completar la transacción!',
                icon: Icons.error_outline_outlined,
                color: const Color(0xffFF525C)
            );
          }
      }
    }
  }

  limpiar(){
    setState(() {
      pageIndex = 0;
      _localNameController.text = '';
      edit=false;
      idSucursal=0;
    });
  }

  deleteItem(int id)async{
    if(await bdConnection.deleteSucursal(context: context,id: id)){
      setState(() {

      });
      CustomSnackBar().show(
          context: context,
          msg: 'Servicio eliminado con éxito!',
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
    bdConnection = BDConnection();

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
          child: Container(
            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
            //color: Colors.blueGrey,
            child: Row(
              children: [
                if(isMobileAndTablet(context))
                  IconButton(onPressed: ()=> pageIndex==1?limpiar():mainScaffoldKey.currentState!.openDrawer(), icon: Icon(pageIndex==1?Icons.arrow_back_rounded:Icons.menu_rounded, )),
                if(!isMobileAndTablet(context)&&pageIndex==1)
                  IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded, )),
                Expanded(
                  child: Text(pageIndex==0?"Sucursales":edit?"Modificar sucursal":"Añadir sucursal",
                    style: const TextStyle(
                   //   color: Colors.white,
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if(pageIndex==0)
                InkWell(
                  onTap: (){
                    setState(() {
                      pageIndex=1;
                    });
                  },
                  child: Container(
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(50)),
                      //color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: responsiveApp.setWidth(10),
                        ),
                        texto(
                          size: responsiveApp.setSP(10),
                          text: 'Nuevo',
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: responsiveApp.setWidth(10),),
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
                        sucursales(),
                      if(pageIndex==1)
                        newLocalization(),
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

  Widget sucursales(){
    return FutureBuilder(
        future: bdConnection.getSucursales(context),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
       if(snapshot.data ==null){
         return const Center(child:CircularProgressIndicator());
       }else{
         return Row(
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
                             top: responsiveApp.setWidth(2), bottom: responsiveApp.setWidth(2)),
                         child: Row(
                           children: [
                             SizedBox(width: responsiveApp.setWidth(50),
                               child: texto(
                                 text: '#',
                                 size: 14,
                               ),
                             ),
                             Padding(
                               padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                               child: Container(height: responsiveApp.setHeight(20),
                                 width: responsiveApp.setWidth(1),
                                 color: Colors.grey.withOpacity(0.3),),
                             ),
                             Expanded(
                               child: texto(
                                 text: 'Nombre',
                                 size: 14,
                               ),
                             ),

                           ],
                         ),
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
                                     return Column(
                                       children: [
                                         list(snapshot,index),
                                         if(index<snapshot.data.length-1)
                                           Row(
                                             children: [
                                               Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                                             ],
                                           ),
                                       ],
                                     );
                                   }
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
         );
       }
      }
    );
  }

  Widget list(AsyncSnapshot snapshot,int index){

    return ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: responsiveApp.setWidth(50),
                child: texto(
                  text: snapshot.data[index].id.toString(),
                  size: responsiveApp.setSP(10),
                ),
            ),
            Padding(
              padding: EdgeInsets.all(responsiveApp.setWidth(5)),
              child: SizedBox(height: responsiveApp.setHeight(20),
                width: responsiveApp.setWidth(1),
              ),
            ),
            Expanded(
              child: texto(
                  size: responsiveApp.setSP(10),
                  text: snapshot.data[index].name,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500
              ),
            ),
            SizedBox(width: responsiveApp.setWidth(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      setState(() {
                        pageIndex =1;
                        edit=true;
                        idSucursal=snapshot.data[index].id;
                        _localNameController.text=snapshot.data[index].name;
                      });
                    },
                    child: Container(
                      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                        color: const Color(0xffffc44e),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: responsiveApp.setWidth(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: responsiveApp.setWidth(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      warningMsg(
                          context: context,
                          mainMsg: '¿Está seguro?',
                          msg: '¡No podrá recuperar el registro borrado!',
                          okBtnText: 'Si, borrar',
                          cancelBtnText: 'No, cancelar',
                          okBtn: (){
                            deleteItem(snapshot.data[index].id);
                            Navigator.pop(context);
                          },
                          cancelBtn: (){
                            Navigator.pop(context);
                          }
                      );
                    },
                    child: Container(
                      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                        color: const Color(0xffFF525C),
                      ),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.white,
                        size: responsiveApp.setWidth(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      onTap: (){
        setState(() {

        });
      },
    );
  }

  Widget newLocalization(){
    return Padding(
      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
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
        child: Form(
          key: _formKey,
          child: Padding(
            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nombre de la sucursal*'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value != null && value.trim().length < 3) {
                            return 'This field requires a minimum of 3 characters';
                          }

                          return null;
                        },
                        cursorColor: Colors.black,
                        controller: _localNameController,
                        decoration: const InputDecoration(
                            hintText: 'Nombre',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red,))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: (){
                        _saveForm();
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          color: Colors.blueGrey,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.save_rounded,
                              color: Colors.white,
                              size: responsiveApp.setWidth(10),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(2),
                            ),
                            texto(
                              size: responsiveApp.setSP(10),
                              text: 'Guardar',
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: responsiveApp.setWidth(15),
                    ),
                    InkWell(
                      onTap: (){
                        limpiar();
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          color: const Color(0xffFF525C),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              color: Colors.white,
                              size: responsiveApp.setWidth(10),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(2),
                            ),
                            texto(
                              size: responsiveApp.setSP(10),
                              text: 'Cancelar',
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ],
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
    );
  }
}
