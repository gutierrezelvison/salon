import 'package:flutter/material.dart';
import 'package:salon/util/db_connection.dart';

import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../values/ResponsiveApp.dart';
import '../WebComponents/Header/header_search_bar.dart';

class BatchWidget extends StatefulWidget {
  const BatchWidget({Key? key, this.status, required this.productId}) : super(key: key);
  final String? status;
  final int productId;

  @override
  State<BatchWidget> createState() => _BatchWidgetState();
}

class _BatchWidgetState extends State<BatchWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection dbConnection;
  AppData appData = AppData();
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController categoryNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController expDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  String order = 'ASC';
  int batchId=0;
  final statusItems = ['Disponible', 'Bloqueado'];
  String? selectedStatus = 'Disponible';

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
          if (await dbConnection.updateBatch(
            onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context: context,
              batch: Batch(
                  id: batchId,
                  batch: categoryNameController.text,
                  status: selectedStatus=='Disponible'?'available':'blocked',
                  quantity: quantityController.text,
                  expiration_date: expDateController.text,
                  cost: costController.text,
                  description: descriptionController.text,
              ),
              )) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Registro actualizado con éxito!',
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

  limpiar(){
    setState(() {
      pageIndex = 0;
      categoryNameController.text = '';
      quantityController.text = '';
      edit=false;
    });
  }

  deleteItem(int id, String table)async{

    if(await dbConnection.deleteData(
        context: context,id: id,table: table)){
      CustomSnackBar().show(
          context: context,
          msg: 'Registro eliminado con éxito!',
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xff22d88d)
      );
      setState(() {});
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
    dbConnection = BDConnection(context: context);

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
                  IconButton(
                      onPressed: ()=> pageIndex==1
                          ? limpiar()
                          : Navigator.pop(context),//homeScaffoldKey.currentState!.openDrawer(),
                      icon: Icon(pageIndex==1
                          ? Icons.arrow_back_rounded
                          : Icons.arrow_back_rounded,)),
                if(!isMobileAndTablet(context)&&pageIndex==1)
                  IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded,)),
                Expanded(
                  child: Text(pageIndex==0?"Lotes":edit?"Modificar Lote":"Añadir Lote",
                    style: const TextStyle(
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

        body:Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(pageIndex == 0)
                      users(),
                    if(pageIndex == 1)
                      newUser(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget users(){
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                  color: Theme.of(context).cardColor,
                  boxShadow: const  [
                    BoxShadow(
                      spreadRadius: -7,
                      blurRadius: 8,
                      offset: Offset(0,0),
                    )
                  ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HeaderSearchBar(
                          onChange: (v){
                            setState((){
                              searchController.text=v;
                            });
                          },
                          onSearchPressed: (){
                            setState(() {});
                          },
                        ),
                        const SizedBox(width: 10,),
                        InkWell(
                          canRequestFocus: false,
                          onTap: (){
                            setState(() {
                              order == "ASC"?order="DESC":order="ASC";
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xff6C9BD2),
                              boxShadow: const [
                                BoxShadow(
                                  //color: const Color(0xff6C9BD2).withOpacity(0.3),
                                  spreadRadius: -5,
                                  blurRadius: 8,
                                  offset: Offset(0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.sort_rounded,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: responsiveApp.setWidth(10),
                        top: responsiveApp.setWidth(2), bottom: responsiveApp.setWidth(2)),
                    child: Row(
                      children: [
                        if(!isMobileAndTablet(context))
                        SizedBox(width: responsiveApp.setWidth(50),
                          child: texto(
                            text: '#',
                            size: 14,
                          ),
                        ),
                        if(!isMobileAndTablet(context))
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
                        SizedBox(width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Cantidad',
                            size: 14,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),
                        SizedBox(width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Estado',
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
                        child: FutureBuilder(
                            future: dbConnection.getData(
                                onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
                                context: context,
                                fields: '*',
                                table: 'batch',
                                where: 'product_id = ${widget.productId} AND status LIKE \'%${widget.status??''}%\' AND batch LIKE \'%${searchController.text}%\'',
                                order: order,
                                orderBy: 'batch',
                                groupBy: 'id'),
                            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                              if (snapshot.data == null) {
                                return const Center(
                                  child: LinearProgressIndicator(backgroundColor: Colors.transparent,),
                                );
                              }else {
                                return snapshot.data.isNotEmpty? Column(
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
                                      },
                                  )
                                ):Padding(
                                  padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                                  child: Column(
                                      children: [
                                        Icon(Icons.file_copy_outlined, size: responsiveApp.setWidth(30),color: Colors.grey,),
                                        texto(text: 'No hay datos que mostrar', size: responsiveApp.setSP(14), color: Colors.grey),
                                      ]
                                  ),
                                );
                              }
                            }
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

  Widget list(AsyncSnapshot snapshot,int index){

    return ListTile(
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: responsiveApp.setHeight(3)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if(!isMobileAndTablet(context))
              SizedBox(width: responsiveApp.setWidth(50),
                  child: texto(
                    text: (index+1).toString(),
                    size: responsiveApp.setSP(10),
                  ),
              ),
              if(!isMobileAndTablet(context))
              Padding(
                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                child: SizedBox(height: responsiveApp.setHeight(20),
                  width: responsiveApp.setWidth(1),
                ),
              ),
              Expanded(
                child: texto(
                    size: responsiveApp.setSP(10),
                    text: snapshot.data[index]['batch'],
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
              SizedBox(width: responsiveApp.setWidth(90),
                child: texto(
                    size: responsiveApp.setSP(10),
                    text: snapshot.data[index]['quantity'],
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
              SizedBox(width: responsiveApp.setWidth(90),
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                    color: snapshot.data[index]['status']=='available'?Colors.green.withOpacity(0.1): Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(5))
                  ),
                  child: Center(
                    child: texto(
                        size: responsiveApp.setSP(10),
                        text: snapshot.data[index]['status']=='available'?'Disponible':'Bloqueado',
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        color: snapshot.data[index]['status']=='available'?Colors.green: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      onTap: (){
        setState(() {
          pageIndex =1;
          edit=appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('update_inventory'))==1;
          batchId = int.parse(snapshot.data[index]['id']);
          categoryNameController.text=snapshot.data[index]['batch'];
          quantityController.text=snapshot.data[index]['quantity'];
          costController.text=snapshot.data[index]['cost'];
          expDateController.text=snapshot.data[index]['expiration_date'];
          descriptionController.text=snapshot.data[index]['description_controller'].toString();
          selectedStatus = snapshot.data[index]['status']=='available'?'Disponible':'Bloqueado';
        });
      },
    );
  }

  Widget newUser(){
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                  color: Theme.of(context).cardColor,
                  boxShadow: const [
                    BoxShadow(
                      spreadRadius: -7,
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
                      field(readOnly: true,context: context, controller: categoryNameController, label: 'Nombre', hint: 'Ej: Carnes, Lácteos, Bebidas, etc.', keyboardType: TextInputType.text),
                      field(readOnly: true, context: context, controller: quantityController, label: 'Cantidad', hint: 'Ej: 1, 1.5, 2,...', keyboardType: TextInputType.text),
                      field(readOnly: !edit,context: context, controller: costController, label: 'Costo', hint: 'Ej: 1, 1.5, 2,...', keyboardType: TextInputType.number),
                      field(readOnly: !edit,context: context, controller: expDateController, label: 'Fecha de caducidad', hint: 'Ej: 1, 1.5, 2,...', keyboardType: TextInputType.text),
                      field(readOnly: !edit,context: context, controller: descriptionController, label: 'Descriptción', hint: 'Ej: Some comment', keyboardType: TextInputType.text),
                      Padding(
                        padding: responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets,
                        child: texto(text: 'Estado', size: responsiveApp.setSP(12)),
                      ),
                      customDropDown(context: context, searchController: searchController,hintText: 'Estado',value: selectedStatus, items: statusItems, onChanged: (v){setState(() => selectedStatus=v);}, searchInnerWidgetHeight: responsiveApp.setHeight(150)),
                      const SizedBox(
                        height: 20,
                      ),
                      if(appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('update_inventory'))==1)
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
                                color: const Color(0xff6C9BD2),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.save_rounded,
                                    color: Colors.white,
                                    size: responsiveApp.setWidth(20),
                                  ),
                                  SizedBox(
                                    width: responsiveApp.setWidth(2),
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
                                    size: responsiveApp.setWidth(20),
                                  ),
                                  SizedBox(
                                    width: responsiveApp.setWidth(2),
                                  ),
                                  texto(
                                    size: responsiveApp.setSP(12),
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
          ),
        ),
      ],
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
