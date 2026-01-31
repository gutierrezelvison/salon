import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';

class ChairsWidget extends StatefulWidget {
  const ChairsWidget({Key? key}) : super(key: key);

  @override
  State<ChairsWidget> createState() => _ChairsWidgetState();
}

class _ChairsWidgetState extends State<ChairsWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _localNameController = TextEditingController();
  final TextEditingController _localNameLinkController = TextEditingController();
  final TextEditingController _localDescripcionController = TextEditingController();
  final TextEditingController _localPriceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _localTimeController = TextEditingController();
  List<String> itemsEmployee = [];
  String? selectedEmployee;
  int pageIndex = 0;
  bool edit = false;
  int idChair = 0;
  List<User> employeeList = [];
  bool status= true;
  bool firstTime= true;
  late Color dialogPickerColor; // Color for picker in dialog using onChanged
  late Color dialogSelectColor; // Color for picker using color select dialog.

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
        if (edit) {
          if (await bdConnection.updateChair(context: context, chair: Chairs(
            chair_id: idChair,
            color: dialogSelectColor.value.toString(),
            employee_id: selectedEmployee!=null?employeeList.elementAt(itemsEmployee.indexOf(selectedEmployee!)).id:1,
            chair_name: _localNameController.text,
            status: status?'active':'deactive',
          ))) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Servicio actualizada con éxito!',
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
        } else {
          if (await bdConnection.addChair(context: context, chair: Chairs(
            employee_id: selectedEmployee!=null?employeeList.elementAt(itemsEmployee.indexOf(selectedEmployee!)).id:1,
            chair_name: _localNameController.text,
            color: dialogSelectColor.value.toString(),
            status: status?'active':'deactive',
          ))) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Servicio agregado con éxito!',
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

  deleteItem(int id)async{
    if(await bdConnection.deleteChair(context: context,chairId: id)){
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

  setlists() async{
    for (var element in await bdConnection.getGroupUsers(context, 1)){
      employeeList.add(element);
      itemsEmployee.add(element.name);
    }
  }

  limpiar(){
    setState(() {
      pageIndex =0;
      edit=false;
      idChair=0;
      _localNameController.text='';
      _localNameLinkController.text='';
      _localDescripcionController.text='';
      _searchController.text='';
      _localTimeController.text = '';
      _localPriceController.text = '';
      selectedEmployee = null;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    dialogPickerColor = Colors.red;
    dialogSelectColor = const Color(0xFFA239CA);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    bdConnection = BDConnection();
    if(firstTime){
      setlists();
      firstTime=false;
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
        child: Container(
          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
         // color: Colors.blueGrey,
          child: Row(
            children: [
              if(isMobileAndTablet(context))
                IconButton(onPressed: ()=> pageIndex==1?limpiar():mainScaffoldKey.currentState!.openDrawer(), icon: Icon(pageIndex==1?Icons.arrow_back_rounded:Icons.menu_rounded,)),
              if(!isMobileAndTablet(context)&&pageIndex==1)
                IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded,)),
              Expanded(
                child: Text(pageIndex==0?"Sillas":edit?"Modificar Silla":"Añadir Silla",
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
                    setState((){});
                  },
                );
              },
              child: SingleChildScrollView(
                dragStartBehavior: DragStartBehavior.down,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if(pageIndex==0)
                      categories(),
                    if(pageIndex==1)
                      newService(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categories(){
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
                        SizedBox(
                          width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Asignada a',
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
                            text: 'Acciones',
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
                            future: bdConnection.getChairs(context: context),
                            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                              if (snapshot.data == null) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }else {
                                return Column(
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
            SizedBox(width: responsiveApp.setWidth(50),
              child: userImage(height: responsiveApp.setHeight(50),
                  image: ColorFiltered(colorFilter: ColorFilter.mode(Color(int.parse(snapshot.data[index].color)), BlendMode.modulate),
                    child: Image.asset('assets/images/silla.png'),))
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
                  text: snapshot.data[index].chair_name,
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
              SizedBox(width: responsiveApp.setWidth(80),
                child: texto(
                    size: responsiveApp.setSP(12),
                    text: snapshot.data[index].employee_name,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500
                ),
              ),

            SizedBox(width: responsiveApp.setWidth(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: responsiveApp.setWidth(40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                edit=true;
                                dialogSelectColor = Color(int.parse(snapshot.data[index].color));
                                dialogPickerColor = Color(int.parse(snapshot.data[index].color));
                                idChair=snapshot.data[index].chair_id;
                                _localNameController.text=snapshot.data[index].chair_name;
                                selectedEmployee = snapshot.data[index].employee_id > 1?snapshot.data[index].employee_name:null;
                                status = snapshot.data[index].status=='active'?true:false;
                                pageIndex = 1;
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
                                    deleteItem(snapshot.data[index].chair_id);
                                    Navigator.pop(context);
                                    limpiar();
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
                )
            ),
          ],
        ),
      ),
      onTap: (){
        setState(() {

        });
      },
    );
  }

  Widget newService(){
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
                Padding(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  child: Row(
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
                              labelText: 'Nombre de la silla*',
                              labelStyle: TextStyle(color: Colors.grey),
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
                    ]
                  ),
                ),
                Padding(
                  padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: customDropDown(
                            searchController: _searchController,
                            items: itemsEmployee,
                            value: selectedEmployee,
                            onChanged: (value) {
                              setState(() {
                                selectedEmployee = value as String;
                                _searchController.text='';
                              });
                            },
                          context: context,
                          hintIcon: Icons.local_offer,
                          searchInnerWidgetHeight: responsiveApp.setHeight(120),
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                      child: Stack(
                        children: [
                          userImage(shape: BoxShape.rectangle,width: responsiveApp.setWidth(300),height: responsiveApp.setHeight(200),
                              image: ColorFiltered(
                                  colorFilter: ColorFilter.mode(dialogSelectColor, BlendMode.modulate),
                                  child:  Image.asset('assets/images/silla.png',))),
                          Positioned.fill(child: Align(
                            alignment: Alignment.bottomRight,
                            child: ColorIndicator(
                              width: 40,
                              height: 40,
                              borderRadius: 0,
                              color: dialogSelectColor,
                              elevation: 1,
                              onSelectFocus: false,
                              onSelect: ()async{
                                final Color newColor = await showColorPickerDialog(
                                  // The dialog needs a context, we pass it in.
                                  context,
                                  // We use the dialogSelectColor, as its starting color.
                                  dialogSelectColor,
                                  title: Text('ColorPicker',
                                      style: Theme.of(context).textTheme.titleLarge),
                                  width: 40,
                                  height: 40,
                                  spacing: 0,
                                  runSpacing: 0,
                                  borderRadius: 0,
                                  wheelDiameter: 165,
                                  enableOpacity: true,
                                  showColorCode: true,
                                  colorCodeHasColor: true,
                                  pickersEnabled: <ColorPickerType, bool>{
                                    ColorPickerType.wheel: true,
                                  },
                                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                                    copyButton: false,
                                    pasteButton: false,
                                    longPressMenu: true,
                                  ),
                                  actionButtons: const ColorPickerActionButtons(
                                    okButton: true,
                                    closeButton: true,
                                    dialogActionButtons: false,
                                  ),
                                  transitionBuilder: (BuildContext context,
                                      Animation<double> a1,
                                      Animation<double> a2,
                                      Widget widget) {
                                    final double curvedValue =
                                        Curves.easeInOutBack.transform(a1.value) - 1.0;
                                    return Transform(
                                      transform: Matrix4.translationValues(
                                          0.0, curvedValue * 200, 0.0),
                                      child: Opacity(
                                        opacity: a1.value,
                                        child: widget,
                                      ),
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 400),
                                  constraints: const BoxConstraints(
                                      minHeight: 480, minWidth: 320, maxWidth: 320),
                                );
                                // We update the dialogSelectColor, to the returned result
                                // color. If the dialog was dismissed it actually returns
                                // the color we started with. The extra update for that
                                // below does not really matter, but if you want you can
                                // check if they are equal and skip the update below.
                                setState(() {
                                  dialogSelectColor = newColor;
                                });
                              },
                            ),
                          )),
                        ],
                      ),
                    )
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
                    SizedBox(width: responsiveApp.setWidth(10),),
                    InkWell(
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: (){
                        setState(() {
                          status = !status;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.decelerate,
                        width: responsiveApp.setWidth(35),
                        decoration:BoxDecoration(
                          borderRadius:BorderRadius.circular(50.0),
                          color: status ? const Color(0xff22d88d) : Colors.grey.withOpacity(0.6),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: status ? Alignment.centerRight : Alignment.centerLeft,
                          curve: Curves.decelerate,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              width: responsiveApp.setWidth(15),
                              height: responsiveApp.setHeight(15),
                              decoration:BoxDecoration(
                                color: const Color (0xffFFFFFF),
                                borderRadius:BorderRadius.circular(100.0),
                              ),
                            ),
                          ),
                        ),
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
