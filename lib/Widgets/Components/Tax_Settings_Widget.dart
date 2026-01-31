import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class TaxesSettingsWidget extends StatefulWidget {
  const TaxesSettingsWidget({Key? key}) : super(key: key);

  @override
  State<TaxesSettingsWidget> createState() => _TaxesSettingsWidgetState();
}

class _TaxesSettingsWidgetState extends State<TaxesSettingsWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  final GlobalKey<FormState> _formKey = GlobalKey();
  double containerWidth = 5;
  final TextEditingController _taxNameController = TextEditingController();
  final TextEditingController _taxPercentController = TextEditingController();
  final TextEditingController _companyPhoneController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();
  final TextEditingController _companyWebController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  int idCategory = 0;
  String imageName = '';
  String imagePath = 'null';
  Taxes taxData = Taxes();
  bool status= true;
  bool firstTime= true;
  Uint8List bytes = Uint8List(0);
  var file;
  int imageLength=0;
  late DropzoneViewController controller1;
  String message1 = 'Drop something here';
  bool highlighted1 = false;
  final estadoItems = ['Activo','Inactivo'];
  String selectedEstado = 'Activo';

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
          if (await bdConnection.updateTaxes(
              context: context,
            taxData: Taxes(
              id: taxData.id,
              percent: double.parse(_taxPercentController.text),
              tax_name: _taxNameController.text,
              status: selectedEstado=='Activo'?'active':'deactive'
            ))) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Cambios guardados con éxito!',
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

  limpiar(){
    setState(() {
      firstTime=true;
      bytes=Uint8List(0);
      _taxNameController.text = '';
      _taxPercentController.text = '';
      _companyWebController.text = '';
      _companyAddressController.text = '';
      _companyPhoneController.text = '';
      taxData=Taxes();
      file = null;
      imageName = '';
      imagePath = '';
    });
  }

  deleteItem(int id)async{
    if(await bdConnection.deleteCategory(context: context,id: id)){
      CustomSnackBar().show(
          context: context,
          msg: 'Categoría eliminado con éxito!',
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
        body: Column(
          children: [
            //if(isMobile(context))
            PreferredSize(
              preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
              child: Container(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                //color: Colors.blueGrey,
                child: Row(
                  children: [
                    if(isMobileAndTablet(context))
                    IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
                    const Expanded(
                      child: Text("Impuestos",
                        style: TextStyle(
                        //  color: Colors.white,
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
            Expanded(
              child: RefreshIndicator(
              // color: Colors.blueGrey,
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
                  child: FutureBuilder(
                    future: bdConnection.getTaxData(context),
                      builder: (BuildContext cxt, AsyncSnapshot snapshot) {
                        if(snapshot.data ==null){
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }else {
                          taxData =snapshot.data;
                        }
                          taxData = snapshot.data;
                          _taxNameController.text = snapshot.data.tax_name.toString();
                          _taxPercentController.text = snapshot.data.percent.toString();
                          selectedEstado = snapshot.data.status.toString()=='active'?'Activo':'Inactivo';
                          return mobileBody();
                    }
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget mobileBody(){
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
                        controller: _taxNameController,
                        decoration: const InputDecoration(
                            labelText: 'Nombre del impuesto*',
                            labelStyle: TextStyle(color: Colors.grey),
                            hintText: 'Ej.: ITBIS, TAX, IVA...',
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
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null) {
                            return 'This field requires a minimum of 3 characters';
                          }

                          return null;
                        },
                        cursorColor: Colors.black,
                        controller: _taxPercentController,
                        decoration: const InputDecoration(
                            labelText: 'Porcentaje*',
                            labelStyle: TextStyle(color: Colors.grey),
                            hintText: 'Ej.: 18',
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
                    Text("Estado",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsiveApp.setHeight(5),),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      border: const Border.fromBorderSide(BorderSide(color: Colors.grey,)),
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(2))),

                  // dropdown below..
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedEstado,
                    onChanged: (newValue) {
                      setState((){
                        selectedEstado = newValue.toString();
                      });
                    },
                    items: estadoItems
                        .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                        .toList(),

                    // add extra sugar..
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    iconSize: 42,
                    underline: const SizedBox(),
                  ),
                ),
                SizedBox(height: responsiveApp.setHeight(20),),
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

  Widget buildZone1(BuildContext context) => Builder(
    builder: (context) => DropzoneView(
      operation: DragOperation.link,
      cursor: CursorType.grab,
      onCreated: (ctrl) => controller1 = ctrl,
      onLoaded: () => print('Zone 1 loaded'),
      onError: (ev) => print('Zone 1 error: $ev'),
      onHover: () {
        setState(() => highlighted1 = true);
        print('Zone 1 hovered');
      },
      onLeave: () {
        setState(() => highlighted1 = false);
        print('Zone 1 left');
      },
      onDrop: (ev) async {
        print('Zone 1 drop: ${ev.name}');
        file = controller1.getFileStream(ev);
        bytes = await controller1.getFileData(ev);
        imageLength = bytes.length;
        setState(() {
          message1 = '$ev dropped';
          highlighted1 = false;
        });

        print(bytes.sublist(0, 20));
      },
      onDropMultiple: (ev) async {
        print('Zone 1 drop multiple: $ev');
      },
    ),
  );


}
