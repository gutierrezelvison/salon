//import 'dart:html' as html;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../Widgets/Components/GroupsWidget.dart';
import '../../Widgets/Components/RolesWidget.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class EmployeeWidget extends StatefulWidget {
  EmployeeWidget({Key? key, this.origin,this.roleId}) : super(key: key);
  String? origin;
  int? roleId;

  @override
  State<EmployeeWidget> createState() => _EmployeeWidgetState();
}

class _EmployeeWidgetState extends State<EmployeeWidget> {
  late ResponsiveApp responsiveApp;
  BDConnection bdConnection = BDConnection();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _localNameController = TextEditingController();
  final TextEditingController _localEmailController = TextEditingController();
  final TextEditingController _localPasswordController = TextEditingController();
  final TextEditingController _localMobileController = TextEditingController();
  final TextEditingController _localCommissionController = TextEditingController();
  final TextEditingController _localEmployeeGroupController = TextEditingController();
  final TextEditingController _localRoleController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  int idCategory = 0;
  String imageName = '';
  String imagePath = '';
  final topItems = ['+1 Dominican Republic'];
  dynamic rolItems = ['Seleccionar'];
  dynamic groupItems = ['Seleccionar'];
  String selectedTop = '+1 Dominican Republic';
  String selectedRol = 'Seleccionar';
  String selectedGroup = 'Seleccionar';
  int userId=0;
  bool status= true;
  bool firstTime= true;
  Uint8List bytes = Uint8List(0);
  var file;
  int imageLength=0;
  late DropzoneViewController controller1;
  String message1 = 'Drop something here';
  bool highlighted1 = false;
  List<Roles> rolesList=[];
  List<EmployeeGroups> groupList =[];

  @override
  void initState() {
    setRolesList();
    setGroupList();
    super.initState();
  }

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
        if (edit) {
          if (await bdConnection.updateUser(context: context, user: User(
            id: userId,name: _localNameController.text,
            rol_id: rolesList.elementAt(rolItems.indexOf(selectedRol)-1).id!,
            group_id: groupList.elementAt(groupItems.indexOf(selectedGroup)-1).id!,
            comission: double.parse(_localCommissionController.text),
            email: _localEmailController.text,mobile: _localMobileController.text.replaceAll(RegExp(r'[^\d]'), ''),mobile_verified: '0',
            calling_code: selectedTop.split(' ')[0],
          ),
              file: file, imageLength: imageLength, imageName: imageName, onError: (e) {  })) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Empleado actualizada con éxito!',
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
          if (await bdConnection.setUser(context: context,name: _localNameController.text,
            role: rolesList.elementAt(rolItems.indexOf(selectedRol)-1).id!,
            group_id: groupList.elementAt(groupItems.indexOf(selectedGroup)-1).id!,
            comission: double.parse(_localCommissionController.text),
            email: _localEmailController.text,mobile: _localMobileController.text.replaceAll(RegExp(r'[^\d]'), ''),mobile_verified: 0,
            calling_code: selectedTop.split(' ')[0], password:_localPasswordController.text,
            file: file, imageLength: imageLength,)) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Empleado agregada con éxito!',
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

  resetPass()async{
    if(_localPasswordController.text!=''){
      if(await bdConnection.changePassword(onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
          context: context, password: _localPasswordController.text, userId: userId, isDefaultPass: 1)){
        CustomSnackBar().show(
            context: context,
            msg: 'Empleado agregada con éxito!',
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
    }else{
      CustomSnackBar().show(
          context: context,
          msg: 'El campo contraseña no debe estar vacio!',
          icon: Icons.error_outline_outlined,
          color: const Color(0xffFF525C)
      );
    }
  }

  limpiar(){
    setState(() {
      edit = false;
      userId = 0;
      pageIndex = 0;
      idCategory=0;
      firstTime=true;
      bytes=Uint8List(0);
      _localNameController.text = '';
      _localEmailController.text = '';
      _localEmployeeGroupController.text = '';
      _localMobileController.text = '';
      _localPasswordController.text = '';
      _localRoleController.text = '';
      _localCommissionController.text = '';
      file = null;
      imageName = '';
      imagePath = '';

      selectedTop = '+1 Dominican Republic';
      selectedRol = 'Seleccionar';
      selectedGroup = 'Seleccionar';
    });
  }

  setRolesList() async{
    for (var element in await bdConnection.getRoles(context)){
      rolesList.add(element);
      rolItems.add(element.display_name);
    }
  }

  setGroupList()async{
    for (var element in await bdConnection.getGroups(context)){
      groupList.add(element);
      groupItems.add(element.name);setState(() {
      });
    }
  }

  deleteItem(int id)async{

    if(await bdConnection.deleteUser(context: context,id: id,)){
      CustomSnackBar().show(
          context: context,
          msg: 'Empleado eliminado con éxito!',
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
                  IconButton(
                      onPressed: ()=> pageIndex==1
                          ? limpiar()
                          : widget.origin=='permissions'
                          ? Navigator.pop(context)
                          : mainScaffoldKey.currentState!.openDrawer(),
                      icon: Icon(pageIndex==1 || widget.origin=='permissions'
                          ? Icons.arrow_back_rounded
                          : Icons.menu_rounded,
                       )),
                if(!isMobileAndTablet(context)&&pageIndex==1)
                  IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded,)),
                Expanded(
                  child: Text(pageIndex==0?"Empleados":edit?"Modificar empleado":"Añadir empleado",
                    style: const TextStyle(
                      //color: Colors.white,
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
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if(pageIndex==0)
                      categories(),
                    if(pageIndex==1)
                      newCategory(),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                  boxShadow: const  [
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
                        if(!isMobileAndTablet(context) && widget.origin!="permissions")
                        SizedBox(width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Grupo de empleados',
                            size: 14,
                          ),
                        ),
                        if(!isMobileAndTablet(context) && widget.origin!="permissions")
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),
                        if(!isMobileAndTablet(context) && widget.origin!="permissions")
                        SizedBox(width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Rol',
                            size: 14,
                          ),
                        ),
                        if(!isMobileAndTablet(context) && widget.origin!="permissions")
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
                            future: widget.origin=='permissions'? bdConnection.getRoleUsers(context: context,roleId: widget.roleId!) : bdConnection.getUsers(context: context,roleId: 2),
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
                                  )
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

              SizedBox(width: responsiveApp.setWidth(80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    snapshot.data[index].image!=null&&snapshot.data[index].image!=''
                        ? userImage(
                        width: responsiveApp.setWidth(50),
                        height: responsiveApp.setWidth(50),
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(2)),
                        shadowColor: Theme.of(context).shadowColor,
                        image: Image.memory(snapshot.data[index].image.bytes!,fit: BoxFit.cover,))
                        : userImage(
                        width: responsiveApp.setWidth(50),
                        height: responsiveApp.setWidth(50),
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(2)),
                        shadowColor: Theme.of(context).shadowColor,
                        image: Image.asset('assets/images/default-avatar-user.png',fit: BoxFit.cover,)),
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
                    text: snapshot.data[index].name,
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
              if(!isMobileAndTablet(context) && widget.origin!="permissions")
              SizedBox(width: responsiveApp.setWidth(100),
                child: texto(
                    size: responsiveApp.setSP(10),
                    text: snapshot.data[index].group_name,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500
                ),
              ),
              if(!isMobileAndTablet(context) && widget.origin!="permissions")
              Padding(
                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                child: SizedBox(height: responsiveApp.setHeight(20),
                  width: responsiveApp.setWidth(1),
                ),
              ),
              if(!isMobileAndTablet(context) && widget.origin!="permissions")
              SizedBox(width: responsiveApp.setWidth(100),
                child: texto(
                    size: responsiveApp.setSP(10),
                    text: snapshot.data[index].rol_name,
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
                                  pageIndex =1;
                                  bytes=(snapshot.data[index].image?.bytes!)??Uint8List(0);
                                  edit=true;
                                  userId=snapshot.data[index].id;
                                  _localCommissionController.text=snapshot.data[index].comission.toString();
                                  _localNameController.text=snapshot.data[index].name;
                                  _localMobileController.text=snapshot.data[index].mobile;
                                  _localEmailController.text=snapshot.data[index].email;
                                  _localPasswordController.text=snapshot.data[index].password;
                                  imageName = (snapshot.data[index].image?.name.toString().split('.').first)??'';
                                  imagePath = (snapshot.data[index].image?.path!)??'';
                                  selectedRol = snapshot.data[index].rol_name;
                                  selectedGroup = snapshot.data[index].group_name;
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

  Widget newCategory(){
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15),
                  child: Text('Nombre* ', style: Theme
                      .of(context)
                      .textTheme
                      .labelSmall,),
                ),
                customField(
                    //readOnly: appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.modify'))==0 || appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.add'))==0,
                    context: context, controller: _localNameController,hintText: "Ej: Pedro Hernandez...", keyboardType: TextInputType.name),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15),
                  child: Text('E-mail* ', style: Theme
                      .of(context)
                      .textTheme
                      .labelSmall,),
                ),
                customField(
                    //readOnly: appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.modify'))==0 || appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.add'))==0,
                    context: context, controller: _localEmailController,hintText: "Ej: someone@example.com", keyboardType: TextInputType.emailAddress),

                const SizedBox(height: 8,),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15),
                  child: Text('Contraseña* ', style: Theme
                      .of(context)
                      .textTheme
                      .labelSmall,),
                ),
                Padding(
                  padding: responsiveApp.edgeInsetsApp.onlySmallRightEdgeInsets,
                  child: Row(
                    children: [
                      Expanded(
                        child: customField(
                          //readOnly: appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.modify'))==0 || appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.add'))==0,
                            context: context, controller: _localPasswordController,hintText: "Secure password", keyboardType: TextInputType.visiblePassword,obscureText: true),
                      ),
                      actionButton(
                          name: '',
                          color: Colors.green,
                          icon: Icons.change_circle_rounded,
                          onTap: (){
                            resetPass();
                          }
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,

                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15),
                            child: Text('Area* ', style: Theme
                                .of(context)
                                .textTheme
                                .labelSmall,),
                          ),
                          customDropDownButton(
                              value: selectedTop,
                              onChanged: (newValue) {
                                setState((){
                                  selectedTop = newValue.toString();
                                });
                              },
                              items: topItems
                                  .map<DropdownMenuItem<String>>(
                                      (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                                  .toList()
                          ),
                        ],
                      ),
                    ),
                    if(!isMobileAndTablet(context))
                    SizedBox(width: responsiveApp.setWidth(5),),
                    if(!isMobileAndTablet(context))
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15),
                              child: Text('Teléfono* ', style: Theme
                                  .of(context)
                                  .textTheme
                                  .labelSmall,),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: customField(
                                    //readOnly: appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.modify'))==0 || appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.add'))==0,
                                      context: context, controller: _localMobileController,hintText: "Ej: 0123456789", keyboardType: TextInputType.phone),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if(!isMobileAndTablet(context))
                      SizedBox(width: responsiveApp.setWidth(5),),
                      if(!isMobileAndTablet(context))
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15),
                                child: Text('% Comisión* ', style: Theme
                                    .of(context)
                                    .textTheme
                                    .labelSmall,),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: customField(
                                      //readOnly: appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.modify'))==0 || appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.add'))==0,
                                        context: context, controller: _localCommissionController,hintText: "Ej: 10,20,30...", keyboardType: TextInputType.number),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                  ],
                ),

                if(isMobileAndTablet(context))
                  const SizedBox(height: 8,),
                if(isMobileAndTablet(context))
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15),
                    child: Text('Teléfono* ', style: Theme
                        .of(context)
                        .textTheme
                        .labelSmall,),
                  ),
                if(isMobileAndTablet(context))
                Row(
                  children: [
                    Expanded(
                      child: customField(
                        //readOnly: appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.modify'))==0 || appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.add'))==0,
                          context: context, controller: _localMobileController,hintText: "Ej: 0123456789", keyboardType: TextInputType.phone),
                    ),
                  ],
                ),
                if(isMobileAndTablet(context))
                  const SizedBox(height: 8,),
                if(isMobileAndTablet(context))
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15),
                    child: Text('% Comisión* ', style: Theme
                        .of(context)
                        .textTheme
                        .labelSmall,),
                  ),
                if(isMobileAndTablet(context))
                Row(
                  children: [
                    Expanded(
                      child: customField(
                        //readOnly: appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.modify'))==0 || appData.getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(appData.getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('products.add'))==0,
                          context: context, controller: _localCommissionController,hintText: "Ej: 10,20,30...", keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 8,),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15),
                  child: Text('Grupo de empleado* ', style: Theme
                      .of(context)
                      .textTheme
                      .labelSmall,),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: customDropDownButton(
                          value: selectedGroup,
                          onChanged: (newValue) {
                            setState((){
                              selectedGroup = newValue.toString();
                            });
                          },
                          items: groupItems
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                              .toList()
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(5),),
                    InkWell(
                      onTap: (){
                        if(isMobileAndTablet(context)) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  const GroupsWidget()));
                        }else {
                          viewWidget(context, const GroupsWidget(), () {
                            Navigator.pop(context);
                            groupItems = ['Seleccionar'];
                            selectedGroup = 'Seleccionar';
                            setGroupList();
                            setState(() {});
                          });
                        }
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          color: Colors.green
                        ),
                        child: const Icon(Icons.settings_applications,color: Colors.white,),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8,),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15),
                  child: Text('Rol* ', style: Theme
                      .of(context)
                      .textTheme
                      .labelSmall,),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                      customDropDownButton(
                          value: selectedRol,
                          onChanged: (newValue) {
                            setState((){
                              selectedRol = newValue.toString();
                            });
                          },
                          items: rolItems
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                              .toList(),
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(5),),
                    InkWell(
                      onTap: (){
                        if(isMobileAndTablet(context)) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  const RolesWidget()));
                        }else {
                          viewWidget(context, const RolesWidget(), () {
                            Navigator.pop(context);
                            rolItems = ['Seleccionar'];
                            selectedRol = 'Seleccionar';
                            setRolesList();
                            setState(() {});

                          });
                        }
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                            color: Colors.green
                        ),
                        child: const Icon(Icons.settings_applications,color: Colors.white,),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8,),
                SizedBox(
                  height: responsiveApp.setHeight(250),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          texto(size: 12, text: 'Imagen'),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(20),
                          dashPattern: const [10, 10],
                          color: Colors.grey,
                          strokeWidth: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: highlighted1 ?Colors.grey.withOpacity(0.2): Colors.transparent,
                            ),
                            child: Stack(
                              children: [
                                if(kIsWeb)
                                buildZone1(context),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                            child: imagePath !='null' && imagePath !=''? Image.memory(
                                                bytes, fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)
                                            ):bytes.isNotEmpty?Image.memory(bytes,fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)):Image.asset('assets/images/logo.png',fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                                      child: ElevatedButton(onPressed: (){
                                        FileManager().abreArchivo((r) {
                                          if(r!='error') {
                                            setState(() {
                                              bytes = r;
                                              imageLength = bytes.length;
                                              file = Stream.value(bytes.toList());
                                              //imageProvider = MemoryImage(bytes);
                                            });
                                          }
                                        });
                                        /*
                                              StartFilePicker().startFilePicker((v){
                                                if(v!='error') {
                                                  setState(() {
                                                    bytes = v['bytes'];
                                                    imageLength = bytes.length;
                                                    file = Stream.value(bytes.toList());
                                                  });
                                                }
                                              });

                                               */
                                      }, child: const Icon(Icons.image_search_rounded)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      /*
                      ElevatedButton(
                        onPressed: () async {
                          print(await controller1.pickFiles(mime: ['image/jpeg', 'image/png']));
                        },
                        child: const Text('Pick file'),
                      ),

                       */
                    ],
                  ),
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
        setState(() {

          message1 = '$ev dropped';
          highlighted1 = false;
        });
        file = controller1.getFileStream(ev);
        bytes = await controller1.getFileData(ev);
        imageLength = bytes.length;
        print(bytes.sublist(0, 20));
      },
      onDropMultiple: (ev) async {
        print('Zone 1 drop multiple: $ev');
      },
    ),
  );

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
