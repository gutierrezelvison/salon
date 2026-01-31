import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:salon/Widgets/Components/printers_widget.dart';
import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../util/db_connection.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../values/ResponsiveApp.dart';
import '../WebComponents/Header/header_search_bar.dart';
import 'batch_widget.dart';
import 'inventory_movement_widget.dart';

class InventoryWidget extends StatefulWidget {
  const InventoryWidget({Key? key, this.origin,this.roleId}) : super(key: key);
  final String? origin;
  final int? roleId;

  @override
  State<InventoryWidget> createState() => _InventoryWidgetState();
}

class _InventoryWidgetState extends State<InventoryWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection dbConnection;
  AppData appData = AppData();
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController productCodeController = TextEditingController();
  TextEditingController productTaxesController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController availableQuantityController = TextEditingController();
  TextEditingController blockedQuantityController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController productBarCodeController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController subcategoryController = TextEditingController();
  TextEditingController unitMeasureController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  String order = 'ASC';
  String orderBy = 'product.`id`';
  String imageName = '';
  String imagePath = '';
  List<String> subCatItems = [];
  List<String> catItems = [];
  List<String> unitItems = [];
  String? selectedSubCat;
  String? selectedCat;
  String? selectedUnit;
  int productId=0;
  bool status= true;
  bool firstTime= true;
  Uint8List bytes = Uint8List(0);
  dynamic file;
  int imageLength=0;
  late DropzoneViewController controller1;
  String message1 = 'Drop something here';
  bool highlighted1 = false;
  bool isDragging = false;
  dynamic inventoryList;
  List<Categorie> catList=[];
  NumberFormat numberFormat = NumberFormat('#,###.##', 'en_Us');
  var dateFormat = DateFormat('dd-MMM-yyyy hh:mm a');
  late final dynamic logo;
  String logoStatus = 'empty';

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {

          if (await dbConnection.updateInventoryLocation(
              onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
              context: context,productId: productId, location: locationController.text
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
      productCodeController.text = '';
      productTaxesController.text = '';
      productBarCodeController.text = '';
      passwordController.text = '';
      productPriceController.text = '';
      productNameController.text = '';
      imagePath = '';
      inventoryList=null;
      bytes = Uint8List(0);
      edit = false;

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
/*
  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }
// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      if (kDebugMode) {
        print(barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      pageIndex==0?searchController.text = barcodeScanRes : productBarCodeController.text = barcodeScanRes;
    });
  }


 */

  getInventoryList() async {
    var query = await dbConnection.getData(
      onError: (e) {
        warningMsg(
          context: context,
          mainMsg: '¡Error!',
          msg: e,
          okBtnText: 'Aceptar',
          okBtn: () {
            Navigator.pop(context);
          },
        );
      },
      context: context,
      fields: 'product.*, '
          'categories.`id` AS \'category_id\', categories.`name` AS \'category_name\', '
          'inventory.location, inventory.quantity, inventory.`cost`, inventory.reserved, inventory.blocked, inventory.available ',
      table: 'inventory LEFT JOIN business_services product ON inventory.product_id = product.id '
          'INNER JOIN categories ON product.category_id = categories.id ',
      where: '(product.`id` LIKE \'%${searchController.text}%\' OR product.`name` LIKE \'%${searchController.text}%\' '
          'AND product.status=\'active\' AND product.type = \'product\')',
      order: order,
      orderBy: orderBy,
      groupBy: 'product.`id`',
    );

    // Inicializar lista para almacenar los datos adaptados
    List<Map<String, dynamic>> finalQuery = [];

    for (var item in query) {
      // Modificamos la propiedad 'image' solo si tiene contenido válido
      item['image'] = item['image'] != null && item['image'] != ''
          ? await dbConnection.setImages("services", item['image'])
          : null;

      finalQuery.add(item); // Agregamos el item adaptado
    }

    // Actualizamos el estado con los datos procesados
    setState(() {
      inventoryList = finalQuery;
    });
  }


  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    dbConnection = BDConnection();

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
                      onPressed: ()=> pageIndex>0
                          ? limpiar()
                          : homeScaffoldKey.currentState!.openDrawer(),
                      icon: Icon(pageIndex>0
                          ? Icons.arrow_back_rounded
                          : Icons.menu_rounded,)),
                if(!isMobileAndTablet(context)&&pageIndex>0)
                  IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded,)),
                Expanded(
                  child: Text(pageIndex==0?"Inventario":edit?"Modificar Inventario":"Añadir Inventario",
                    style: const TextStyle(
                      //color: Colors.white,
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                if(pageIndex==0)
                  Padding(
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HeaderSearchBar(
                          width: responsiveApp.setWidth(250),
                          controller: searchController,
                          onChange: (v){
                            setState((){
                              searchController.text=v;
                            });
                          },
                          onSearchPressed: (){
                            setState(() {});
                          },
                          suffix: InkWell(
                            onTap: (){
                              setState(() {
                                searchController.text = '';
                              });
                            },
                            child: searchController.text != ''? Icon(Icons.cancel, color: Colors.grey.withOpacity(0.5),):const SizedBox(),
                          ),
                        ),
                        if(isMobileAndTablet(context))
                          const SizedBox(width: 10,),
                        if(isMobileAndTablet(context))
                          InkWell(
                            canRequestFocus: false,
                            onTap: (){
                              //scanBarcodeNormal();
                            },
                            child: Container(
                              width: 30,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).primaryColor.withOpacity(0.85),
                                boxShadow: const [
                                  BoxShadow(
                                    //color: Theme.of(context).primaryColor.withOpacity(0.3),
                                    spreadRadius: -5,
                                    blurRadius: 8,
                                    offset: Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.document_scanner_outlined,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if(pageIndex==0 && isLandscape(context))
                  InkWell(
                    onTap: (){
                     //viewWidget(context, const CheckPriceWidget(), () {Navigator.pop(context);});
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
                            Icons.manage_search_outlined,
                            color: Colors.white,
                            size: responsiveApp.setWidth(20),
                          ),
                          texto(
                            size: responsiveApp.setSP(12),
                            text: 'Ver precio',
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(width: responsiveApp.setWidth(10),),
                if(pageIndex==0 && !isMobile(context) && isLandscape(context))
                  InkWell(
                    onTap: (){
                      if(logoStatus=='empty'||logoStatus=='error') {
                        setState(() {
                          logoStatus = 'loading';
                        });
                        loadImage();
                      }else{
                        sendDoc();
                      }
                    },
                    child: Container(
                      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(50)),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Row(
                        children: [
                          logoStatus=='loading'? SizedBox(width: responsiveApp.setWidth(20),height: responsiveApp.setWidth(20),child: const CircularProgressIndicator(color: Colors.white))
                              :Icon(
                            Icons.print_rounded,
                            color: Colors.white,
                            size: responsiveApp.setWidth(20),
                          ),
                          texto(
                            size: responsiveApp.setSP(12),
                            text: logoStatus=='loading'?' Espere...':' Imprimir',
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(width: responsiveApp.setWidth(10),),
              if(pageIndex==0 && isLandscape(context) && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('create_inventory'))==1)
                InkWell(
                  onTap: (){
                    setState(() {
                      pageIndex = 2;
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
                          size: responsiveApp.setWidth(20),
                        ),
                        texto(
                          size: responsiveApp.setSP(12),
                          text: 'Nuevo',
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),
                if(pageIndex==0 && isMobileAndTablet(context) && isPortrait(context))
                PopupMenuButton(
                position: PopupMenuPosition.under,
                  splashRadius: 5,
                  itemBuilder: (ctx){
                    return [
                      PopupMenuItem(
                        onTap: (){
                          //viewWidget(context, const CheckPriceWidget(), () {Navigator.pop(context);});
                        },
                        child: Container(
                          // margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                            boxShadow: const [
                              BoxShadow(
                                //color: Theme.of(context).primaryColor.withOpacity(0.3),
                                spreadRadius: -5,
                                blurRadius: 8,
                                offset: Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              const Icon(Icons.manage_search_outlined, color: Colors.grey,),
                              SizedBox(width: responsiveApp.setWidth(3),),
                              texto(text: "Ver precio", size: responsiveApp.setSP(12)),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        onTap: (){
                          if(logoStatus=='empty'||logoStatus=='error') {
                            setState(() {
                              logoStatus = 'loading';
                            });
                            loadImage();
                          }else{
                            sendDoc();
                          }
                        },
                        child: Container(
                          // margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                            boxShadow: const [
                              BoxShadow(
                                //color: Theme.of(context).primaryColor.withOpacity(0.3),
                                spreadRadius: -5,
                                blurRadius: 8,
                                offset: Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              const Icon(Icons.print_rounded, color: Colors.grey,),
                              SizedBox(width: responsiveApp.setWidth(3),),
                              texto(text: "Imprimir", size: responsiveApp.setSP(12)),
                            ],
                          ),
                        ),
                      ),
                      if(pageIndex==0 && appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('create_inventory'))==1)
                        PopupMenuItem(
                        onTap: (){
                          setState(() {
                            pageIndex = 2;
                          });
                        },
                        child: Container(
                          // margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                            boxShadow: const [
                              BoxShadow(
                                //color: Theme.of(context).primaryColor.withOpacity(0.3),
                                spreadRadius: -5,
                                blurRadius: 8,
                                offset: Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              const Icon(Icons.add, color: Colors.grey,),
                              SizedBox(width: responsiveApp.setWidth(3),),
                              texto(text: "Nuevo", size: responsiveApp.setSP(12)),
                            ],
                          ),
                        ),
                      ),
                    ];
                  }
                ),
                SizedBox(width: responsiveApp.setWidth(10),),
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
                      inventory(),
                    if(pageIndex == 1)
                      newUser(),
                    if(pageIndex == 2)
                      InventoryMovementWidget(
                        ctx: context,
                        onFinish: (){
                          limpiar();
                        },
                        onCancel: (){
                          setState(() {
                            warningMsg(
                                context: context,
                                mainMsg: '¿Seguro que desea cancelar?', msg: 'Se perderan los datos no guardados.',
                                okBtnText: 'Si, Cancelar', okBtn:() {limpiar();Navigator.pop(context);},
                                cancelBtnText: 'No, Abortar', cancelBtn:() {Navigator.pop(context);});
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget inventory(){
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
                        SizedBox(
                          width: responsiveApp.setWidth(80),
                          child: texto(
                            text: 'Imagen',
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
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                orderBy = 'product.`name`';
                                order= order == 'ASC'?'DESC':'ASC';
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: texto(
                                  text: 'Nombre',
                                  size: 14,
                          ),
                                ),
                                Icon(orderBy=='product.`name`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                              ],
                            ),
                          ),
                        ),
                        if(!isMobileAndTablet(context))
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),

                        if(!isMobileAndTablet(context))
                        InkWell(
                          onTap: (){
                            setState(() {
                              orderBy = 'inventory.`location`';
                              order= order == 'ASC'?'DESC':'ASC';
                            });
                          },
                          child: SizedBox(width: responsiveApp.setWidth(100),
                            child: Row(
                              children: [
                                Expanded(
                                  child: texto(
                                    text: 'Unicación',
                                    size: 14,
                                  ),
                                ),
                                Icon(orderBy=='inventory.`location`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                              ],
                            ),
                          ),
                        ),
                        if(!isMobileAndTablet(context))
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),
                        //if(!isMobileAndTablet(context) && widget.origin!="permissions")
                          InkWell(
                            onTap: (){
                              setState(() {
                                orderBy = 'inventory.`quantity`';
                                order= order == 'ASC'?'DESC':'ASC';
                              });
                            },
                            child: SizedBox(width: responsiveApp.setWidth(100),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: texto(
                                      text: 'Cantidad',
                                      size: 14,
                                    ),
                                  ),
                                  Icon(orderBy=='inventory.`quantity`' && order == 'ASC'?Icons.arrow_drop_up_rounded:Icons.arrow_drop_down_rounded,),
                                ],
                              ),
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
                        child: Builder(
                            builder: (BuildContext ctx) {

                              if (inventoryList == null) {
                                getInventoryList();
                                return const Center(
                                  child: LinearProgressIndicator(backgroundColor: Colors.transparent,),
                                );
                              }else {
                                return inventoryList.isNotEmpty? Column(
                                  children: List.generate(
                                      inventoryList.length,
                                          (index){
                                        return Column(
                                          children: [
                                            list(index),
                                            if(index<inventoryList.length-1)
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
                                        Icon(Icons.production_quantity_limits_rounded, size: responsiveApp.setWidth(30),color: Colors.grey,),
                                        texto(text: 'No hay productos que mostrar', size: responsiveApp.setSP(14), color: Colors.grey),
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

  Widget list(int index){
    return ListTile (
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
              SizedBox(width: responsiveApp.setWidth(90),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    inventoryList[index]['image']!=null
                        ? userImage(
                        width: responsiveApp.setWidth(80),
                        height: responsiveApp.setWidth(80),
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(2)),
                        shadowColor: Theme.of(context).shadowColor,
                        image: Image.memory(inventoryList[index]['image'].bytes))
                        : userImage(
                        width: responsiveApp.setWidth(80),
                        height: responsiveApp.setWidth(80),
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(2)),
                        shadowColor: Theme.of(context).shadowColor,
                        image: Image.asset('assets/images/No_image.jpg')),
                  ],
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
                    size: responsiveApp.setSP(12),
                    text: inventoryList[index]['name'],
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500
                ),
              ),
              if(!isMobileAndTablet(context))
              Padding(
                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                child: SizedBox(height: responsiveApp.setHeight(20),
                  width: responsiveApp.setWidth(1),
                ),
              ),
              if(!isMobileAndTablet(context))
              SizedBox(width: responsiveApp.setWidth(100),
                child: texto(
                    size: responsiveApp.setSP(12),
                    text: inventoryList[index]['location']??'???',
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
                child: Center(
                  child: texto(
                      size: responsiveApp.setSP(12),
                      text: numberFormat.format(double.parse(inventoryList[index]['quantity'].toString())),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),

            ],
          ),
        ),
      onTap: (){
        setState(() {
          pageIndex = 1;
          edit = false;
          productId = int.parse(inventoryList[index]['id']);
          productNameController.text=inventoryList[index]['name'];
          productPriceController.text='\$${inventoryList[index]['price']}';
          productTaxesController.text=inventoryList[index]['taxes'].toString();
          quantityController.text=inventoryList[index]['quantity'];
          availableQuantityController.text=inventoryList[index]['available'];
          blockedQuantityController.text=inventoryList[index]['blocked'];
          locationController.text=inventoryList[index]['location'].toString();
          categoryController.text=inventoryList[index]['category_name'];
          bytes = inventoryList[index]['image']!=null?inventoryList[index]['image'].bytes:Uint8List(0);
          //imagePath = inventoryList[index]['image']!=null&&inventoryList[index]['image']!='null'&&inventoryList[index]['image']!=''?"${dbConnection.getHost()}/uploads/products/${inventoryList[index]['image']}":'';
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          imagePath!=''
                              ? userImage(
                              width: responsiveApp.setWidth(150),
                              height: responsiveApp.setWidth(150),
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(2)),
                              shadowColor: Theme.of(context).shadowColor,
                              image: Image.memory(bytes))
                              : userImage(
                              width: responsiveApp.setWidth(150),
                              height: responsiveApp.setWidth(150),
                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(2)),
                              shadowColor: Theme.of(context).shadowColor,
                              image: Image.asset('assets/images/No_image.jpg')),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      field(enabled: true,readOnly: true,context: context, controller: productNameController, label: 'Nombre de producto', hint: 'Ej: Arroz, Azucar, Huevo, etc.', keyboardType: TextInputType.text),
                      field(enabled: true,readOnly: true,context: context, controller: productPriceController, label: 'Precio',  keyboardType: TextInputType.streetAddress),
                      field(enabled: true,readOnly: true,suffix: const Icon(Icons.arrow_forward_ios_rounded),context: context, controller: quantityController, label: 'Cantidad total', hint: 'Ej: 18,50.10, 12', keyboardType: TextInputType.emailAddress,
                      onTap: ()=>viewBatch(BatchWidget(productId: productId,))),
                      field(enabled: true,readOnly: true,suffix: const Icon(Icons.arrow_forward_ios_rounded),context: context, controller: availableQuantityController, label: 'Cantidad disponible', hint: 'Ej: 18,50.10, 12', keyboardType: TextInputType.emailAddress,
                          onTap: ()=>viewBatch(BatchWidget(productId: productId,status: 'available'))),
                      field(enabled: true,readOnly: true,suffix: const Icon(Icons.arrow_forward_ios_rounded),context: context, controller: blockedQuantityController, label: 'Cantidad bloqueada', hint: 'Ej: 18,50.10, 12', keyboardType: TextInputType.emailAddress,
                          onTap: ()=>viewBatch(BatchWidget(productId: productId,status: 'blocked',))),
                      field(enabled: true,readOnly: !edit,context: context, controller: locationController, label: 'Ubicación', hint: 'Ej: E-18, P-12', keyboardType: TextInputType.text,
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(edit)
                            InkWell(
                              onTap: (){
                                _saveForm();
                              },
                              child: Container(
                                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Icon(
                                  Icons.save_rounded,
                                  color: Colors.white,
                                  size: responsiveApp.setWidth(15),
                                ),
                              ),
                            ),
                          SizedBox(
                            width: responsiveApp.setWidth(5),
                          ),
                          InkWell(
                            onTap: (){
                              if(edit) {
                                warningMsg(
                                    context: context,
                                    mainMsg: '¿Seguro que desea cancelar?', msg: 'Se perderan los datos no guardados.',
                                    okBtnText: 'Si, Cancelar', okBtn:() {setState(()=>edit=false);Navigator.pop(context);},
                                    cancelBtnText: 'No, Abortar', cancelBtn:() {Navigator.pop(context);});
                              }else{
                                setState(()=>edit=true);
                              }
                            },
                            child: Container(
                              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                                color: edit? const Color(0xffFF525C):const Color(0xffffc44e),
                              ),
                              child: Icon(
                                edit?Icons.cancel_rounded:Icons.edit,
                                color: Colors.white,
                                size: responsiveApp.setWidth(15),
                              ),
                            ),
                          ),
                        ],
                      ),),
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

void viewBatch(Widget widget){
  if(isMobileAndTablet(context)) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }else{
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: SizedBox(
              width: displayWidth(context)*0.4,
              child: widget),
          actions: [
            InkWell(
              autofocus: true,
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                width: 110,
                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Theme.of(context).primaryColor,
                ),
                child: const Center(child: Text('Finalizar', style: TextStyle(color: Colors.white))),
              ),
            ),
          ],
        )
    );
  }
}

sendDoc(){
  List<pw.Widget> pages = [];
  for (var i = 0; i < inventoryList.length; i += 10) {
    final endIndex = i + 10;
    if (endIndex > inventoryList.length) {
      pages.add(prueba_vis_fact(i, inventoryList.length));
    } else {
      pages.add(prueba_vis_fact(i, endIndex));
    }
  }
  //viewBatch(PrinterWidget(fact: pages));
}

  Future loadImage() async{
    try {
      logo = appData.getCompanyData().logo!='null'?await flutterImageProvider(NetworkImage(
          "${appData.getCompanyData().logo}")):await flutterImageProvider(const AssetImage('assets/images/vendo_logo.png'));
      setState(() {
        logoStatus = 'loaded';
      });
      sendDoc();

      print("****OK****");
    } catch (e) {
      setState(() {
        logoStatus = 'error';
      });
      print("****ERROR: $e****");
      return;
    }
  }
  pw.Widget prueba_vis_fact(int i, int f) {
    return  pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Row(
            children: [
              pw.Image(
                logo,
                width: responsiveApp.setWidth(100),
                height: responsiveApp.setHeight(100),
              ),
              pw.Column(
                children: [
                  pw.Text("${appData.getCompanyData().name}"),
                  pw.Text("(${appData.getCompanyData().phone.substring(0,3)})"
                      " ${appData.getCompanyData().phone.substring(3,6)}"
                      "-${appData.getCompanyData().phone.substring(6,10)}"),
                  pw.Text("${appData.getCompanyData().address}"),
                  if(appData.getCompanyData().rnc!=null) pw.Text("RNC: ${appData.getCompanyData().rnc}"),
                ]
              ),
            ]
          ),
          pw.SizedBox(height: responsiveApp.setHeight(10)),
          pw.Row(
            mainAxisAlignment:  pw.MainAxisAlignment.spaceBetween,
            children:[
              pw.Text('Fecha:'),
              pw.Text(dateFormat.format(DateTime.now())),
            ]
          ),
          pw.Row(
            mainAxisAlignment:  pw.MainAxisAlignment.spaceBetween,
            children:[
              pw.Text('Usuario:'),
              pw.Text(appData.getUserData().username),
            ]
          ),

          pw.Divider(),

          pw.Row(
              mainAxisAlignment:  pw.MainAxisAlignment.spaceBetween,
              children:[
                //pw.SizedBox(width: 30,child: pw.Text('#'),),
                pw.SizedBox(width: 60,child: pw.Text('CÓDIGO'),),
                pw.Expanded(child: pw.Text('NOMBRE'),),
                pw.SizedBox(width: 75,child: pw.Text('UBICACIÓN'),),
                pw.SizedBox(width: 35,child: pw.Text('UMB'),),
                pw.SizedBox(width: 70,child: pw.Text('CANTIDAD'),),
              ]),
          pw.Divider(),
          pw.ListView(
            children: List<pw.Widget>.from(inventoryList.sublist(i,f).map((data) {
              return  pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment:  pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.SizedBox(width: 60,
                          child:  pw.Text('${data['code']}',style: const pw.TextStyle(fontSize: 12))),
                      pw.Expanded(
                          child:  pw.Text('${data['name']}',style: const pw.TextStyle(fontSize: 12))),
                      pw.SizedBox(width: 75,
                          child:  pw.Text(data['location']??'???',style: const pw.TextStyle(fontSize: 12))),
                      pw.SizedBox(width: 35,
                          child:  pw.Text('${data['unit']}',style: const pw.TextStyle(fontSize: 12))),
                      pw.SizedBox(width: 70,
                          child:  pw.Text('${data['quantity']}',style: const pw.TextStyle(fontSize: 12))),
                    ],
                  ),
                  pw.Divider(),
                ]
              );
            }).toList()),
          ),
        ]
    );
  }
}
