 import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';

class CurrencySettingsWidget extends StatefulWidget {
  const CurrencySettingsWidget({Key? key}) : super(key: key);

  @override
  State<CurrencySettingsWidget> createState() => _CurrencySettingsWidgetState();
}

class _CurrencySettingsWidgetState extends State<CurrencySettingsWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _currencyNameController = TextEditingController();
  final TextEditingController _currencySymbolController = TextEditingController();
  final TextEditingController _currencyCodeController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  bool firstTime = true;
  int idCurrency = 0;

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
        if (edit) {
          if (await bdConnection.updateCurrencies(context: context,currencyData: Currencies(
            currency_name: _currencyNameController.text,
            currency_code: _currencyCodeController.text,
            currency_symbol: _currencySymbolController.text
          ))) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Moneda actualizada con éxito!',
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
          if (await bdConnection.addCurrency(context: context, currency: Currencies(
            currency_name: _currencyNameController.text,
            currency_code: _currencyCodeController.text,
            currency_symbol: _currencySymbolController.text
          ))) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Moneda agregada con éxito!',
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
      _currencyNameController.text = '';
      _currencyCodeController.text = '';
      _currencySymbolController.text = '';
      edit=false;
      idCurrency=0;
    });
  }

  deleteItem(int id)async{
    if(await bdConnection.deleteCurrency(context: context, id: id)){
      setState(() {});
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
                  IconButton(onPressed: ()=> pageIndex==1?limpiar():Navigator.pop(context), icon: Icon(pageIndex==1?Icons.arrow_back_rounded:Icons.arrow_back_rounded)),
                if(!isMobileAndTablet(context)&&pageIndex==1)
                  IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded,)),
                Expanded(
                  child: Text(pageIndex==0?"Monedas":edit?"Modificar Moneda":"Añadir Moneda",
                    style: const TextStyle(
                     // color: Colors.white,
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
                      color: Theme.of(context).primaryColor,
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
        future: bdConnection.getCurrencies(context),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
       if(snapshot.data ==null){
         return const Center(child:CircularProgressIndicator(color: Colors.blueGrey));
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
                             Padding(
                               padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                               child: Container(height: responsiveApp.setHeight(20),
                                 width: responsiveApp.setWidth(1),
                                 color: Colors.grey.withOpacity(0.3),),
                             ),
                             Expanded(
                               child: texto(
                                 text: 'Símbolo',
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
                                 text: 'Código',
                                 size: 14,
                               ),
                             ),
                             Padding(
                               padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                               child: Container(height: responsiveApp.setHeight(20),
                                 width: responsiveApp.setWidth(1),
                                 color: Colors.grey.withOpacity(0.3),),
                             ),
                             const Expanded(
                               child: Icon(Icons.settings, color: Colors.black54),
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
                  text: snapshot.data[index].currency_name,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500
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
                  text: snapshot.data[index].currency_symbol,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500
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
                  text: snapshot.data[index].currency_code,
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
                        idCurrency=snapshot.data[index].id;
                        _currencyNameController.text=snapshot.data[index].currency_name;
                        _currencyCodeController.text=snapshot.data[index].currency_code;
                        _currencySymbolController.text=snapshot.data[index].currency_symbol;
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
                        controller: _currencyNameController,
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
                const Text('Símbolo de moneda*'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null) {
                            return 'This field requires a minimum of 3 characters';
                          }

                          return null;
                        },
                        cursorColor: Colors.black,
                        controller: _currencySymbolController,
                        decoration: const InputDecoration(
                            hintText: 'Símbolo',
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
                const Text('Código de moneda*'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null) {
                            return 'This field requires a minimum of 3 characters';
                          }

                          return null;
                        },
                        cursorColor: Colors.black,
                        controller: _currencyCodeController,
                        decoration: const InputDecoration(
                            hintText: 'Código',
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
