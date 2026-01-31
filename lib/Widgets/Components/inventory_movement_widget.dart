import 'package:flutter/material.dart';
import 'package:salon/util/db_connection.dart';
import '../../util/Util.dart';
import '../../values/ResponsiveApp.dart';
import 'custom_table.dart';

class InventoryMovementWidget extends StatefulWidget {
   const InventoryMovementWidget({Key? key,required this.ctx,required this.onFinish, required this.onCancel}) : super(key: key);
  final VoidCallback onCancel;
  final Function() onFinish;
  final BuildContext ctx;

  @override
  State<InventoryMovementWidget> createState() => _InventoryMovementWidgetState();
}

class _InventoryMovementWidgetState extends State<InventoryMovementWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection dbConnection;
  AppData appData = AppData();
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController productCodeController = TextEditingController();
  TextEditingController productTaxesController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController productBarCodeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int pageIndex = 0;
  bool edit = false;
  String order = 'ASC';
  bool status= true;
  bool firstTime= true;
  final conceptItems = ['Compra', 'Venta', 'Devolución', 'Decomiso', 'Diferencia de inventario'];
  String? selectedConcept = 'Compra';
  final movementItems = ['Entrada', 'Salida'];
  String? selectedMovement = 'Entrada';
  List<InventoryMovement> inventoryMovementList = [];
  String lastBatch = '';

  @override
  void initState() {
    descriptionController.text = '.';
    super.initState();
  }

  void _saveForm(InventoryMovement inventoryMovement) async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
          if (await dbConnection.addInventoryMovement(
              onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
              context: context, userId: appData.getUserData().id, inventoryMovement: inventoryMovement)) {
            CustomSnackBar().show(
                context: widget.ctx,
                msg: 'Registro agregado con éxito!',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xff22d88d)
            );
          }else{
            CustomSnackBar().show(
                context: widget.ctx,
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
      productCodeController.text = '';
      productTaxesController.text = '';
      productBarCodeController.text = '';
      passwordController.text = '';
      descriptionController.text = '.';
      productNameController.text = '';
    });
  }

  setLastBatch() async{
    final query = await dbConnection.getData(
        onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
        context: context,
        fields: 'MAX(batch) AS \'batch\'',
        table: 'batch',
        where: 'quantity>0',
        order: 'DESC LIMIT 1',
        orderBy: 'batch',
        groupBy: 'batch'
    );
    lastBatch = query.isNotEmpty?query.first['batch']:'0';

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    dbConnection = BDConnection(context: context);

    return Builder(
        builder: (context) {
          if(lastBatch == ''){
            setLastBatch();
            return const Center(child: CircularProgressIndicator(),);
          }else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                newMovement(),
              ],
            );
          }
        }
    );
  }

  Widget newMovement(){

    return Scrollbar(
      thumbVisibility: true, // Mostrar la barra de desplazamiento siempre
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: responsiveApp.setWidth(1100),
          child: Row(
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
                    child: Padding(
                      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets,
                              child: texto(text: 'Tipo de movimiento', size: responsiveApp.setSP(12)),
                            ),
                            customDropDown(context: context, searchController: searchController,hintText: 'Tipo de movimiento',value: selectedMovement, items: movementItems, onChanged: (v){selectedMovement=v; limpiar();}, searchInnerWidgetHeight: responsiveApp.setHeight(150)),
                            Padding(
                              padding: responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets,
                              child: texto(text: 'Concepto', size: responsiveApp.setSP(12)),
                            ),
                            customDropDown(context: context, searchController: searchController,hintText: 'Concepto',value: selectedConcept, items: conceptItems, onChanged: (v){setState(() => selectedConcept=v);}, searchInnerWidgetHeight: responsiveApp.setHeight(150)),
                            field(context: context, controller: descriptionController, label: 'Descripción', hint: 'Ej: Compra de productos varios', keyboardType: TextInputType.streetAddress),
                            CustomTable(initialData: inventoryMovementList,origin: 'inventory' ,movementType: selectedMovement=='Entrada'?'entrada':'salida', context: context, lastBatchSequenceNumber: lastBatch!='0'?lastBatch.split('-')[1]=='${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}'?int.parse(lastBatch.split('-')[2]):0:0,
                              onUpdate: (movementData){
                              inventoryMovementList.clear();
                              for(var movement in movementData){
                                inventoryMovementList.add(
                                    InventoryMovement(
                                      product: movement.product,
                                      cost: movement.cost,
                                      batch: movement.batch,
                                      concept: selectedConcept=='Compra'?'compra':selectedConcept=='Venta'?'venta':selectedConcept=='Devolución'?'devolucion':selectedConcept=='Decomiso'?'decomiso':'diferencia de inventario',
                                      description: descriptionController.text,
                                      expiration_date: '9999-12-31',
                                      movement: selectedMovement=='Entrada'?'entrada':'salida',
                                      quantity: movement.quantity,
                                    )
                                );
                              }
                            },),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: (){
                                    bool success = false;
                                    for(var movement in inventoryMovementList){
                                      if(movement.batch!=null&&(selectedMovement=='Entrada'?true : movement.batch!.id!=null)){
                                        if(movement.quantity !=null && movement.quantity!>0) {
                                          if(selectedMovement=='Entrada'?true : movement.quantity! <= double.parse(movement.batch!.quantity??'0')) {
                                            _saveForm(movement);
                                            success = true;
                                          }else{
                                            warningMsg(context: context, mainMsg: "Atención", msg: "Revise la cantidad para producto ${movement.product!.id}\n\nCantidad actual para el lote  ${movement.batch!.batch} = ${movement.batch!.quantity}",
                                                okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context); success = false;});
                                          }
                                        }else{
                                          warningMsg(context: context, mainMsg: "Atención", msg: "Revise la cantidad para producto ${movement.product!.id}",
                                              okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context); success = false;});
                                        }
                                      }else{
                                        warningMsg(context: context, mainMsg: "Atención", msg: "No se ha selecionado lote para el producto ${movement.product!.id}",
                                            okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context); success = false;});
                                      }

                                    }
                                    if(success) {
                                      limpiar();
                                      widget.onFinish();
                                    }
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
                                          size: responsiveApp.setSP(14),
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
                                  onTap: widget.onCancel,
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
                                          size: responsiveApp.setSP(14),
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
          ),
        ),
      ),
    );
  }
}
