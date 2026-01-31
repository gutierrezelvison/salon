import 'package:flutter/material.dart';
import 'package:salon/Widgets/Components/admin_cash_validator_widget.dart';
import '../../util/db_connection.dart';

import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../values/ResponsiveApp.dart';
import '../WebComponents/Header/header_search_bar.dart';

class CashRegisterWidget extends StatefulWidget {
  const CashRegisterWidget({super.key});

  @override
  State<CashRegisterWidget> createState() => _CashRegisterWidgetState();
}

class _CashRegisterWidgetState extends State<CashRegisterWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection dbConnection;
  AppData appData = AppData();
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController customerCodeController = TextEditingController();
  TextEditingController customerRncController = TextEditingController();
  TextEditingController cashNumberController = TextEditingController();
  TextEditingController customerEmailController = TextEditingController();
  TextEditingController customerPhoneController = TextEditingController();
  TextEditingController cashNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  String order = 'ASC';
  int cashId=0;
  bool status= true;
  bool firstTime= true;
  String? selectedUser;
  List<String> userItems=[];
  List<User> users=[];

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      if (edit) {
        if (await dbConnection.updateCashRegister(
            onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
            context: context,
            cashRegister: CashRegister(
                id: cashId,
                name: cashNameController.text,
                user_id: users.elementAt(userItems.indexOf(selectedUser!)).id,
                number: int.parse(cashNumberController.text),
            ))) {
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
      } else {
        if (await dbConnection.addCashRegister(
            onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
            context: context,
            cashRegister: CashRegister(
              name: cashNameController.text,
              user_id: users.elementAt(userItems.indexOf(selectedUser!)).id,
              number: int.parse(cashNumberController.text),
            ))) {
          limpiar();
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
    }
  }

  limpiar(){
    setState(() {
      pageIndex = 0;
      customerCodeController.text = '';
      customerRncController.text = '';
      customerEmailController.text = '';
      cashNumberController.text = '';
      customerPhoneController.text = '';
      cashNameController.text = '';
      selectedUser = null;
    });
  }

  setProdList() async{
    users.clear();
    userItems.clear();
    for (var element in await dbConnection.getData(
        onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
        context: context,
        fields: 'users.group_id, users.name, users.email, users.calling_code, users.mobile, users.mobile_verified, users.password, '
        'users.image, users.remember_token, users.created_at, users.id,'
        'roles.display_name AS \'rol_name\', employee_groups.name AS \'group_name\', roles.id AS \'rol_id\'',
        table: 'users '
        'INNER JOIN role_user ON users.id = role_user.user_id '
        'INNER JOIN roles ON role_user.role_id = roles.id '
        'INNER JOIN employee_groups ON users.group_id = employee_groups.id ',
        where: 'role_user.role_id<>3 AND users.deleted=0',
        order: 'ASC',
        orderBy: 'users.id',
        groupBy: 'users.id'
    )){
      users.add(
          User(
              id: int.parse(element['id']),
              name: element['name'],
              email: element['email'],
          )
      );
    }
    userItems = users.map((map) => map.name.toString()).toList();
    setState(() {

    });
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
                          : Navigator.pop(context),
                      icon: Icon(pageIndex==1
                          ? Icons.arrow_back_rounded
                          : Icons.menu_rounded,)),
                if(!isMobileAndTablet(context)&&pageIndex==1)
                  IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded,)),
                Expanded(
                  child: Text(pageIndex==0?"Caja":edit?"Modificar Caja":"Añadir Caja",
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
                      viewWidget(context, AdminCashValidatorWidget()
                          , ()=>Navigator.pop(context));
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
                            Icons.key,
                            color: Colors.white,
                            size: responsiveApp.setWidth(20),
                          ),
                          texto(
                            size: responsiveApp.setSP(12),
                            text: 'Password',
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(width: responsiveApp.setWidth(10),),

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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(pageIndex == 0)
                      _body(),
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

  Widget _body(){
    return Builder(
      builder: (context) {
        if(users.isEmpty){
          setProdList();
          return const Center(child: CircularProgressIndicator(),);
        }else {
          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            responsiveApp.setWidth(5)),
                        color: Theme
                            .of(context)
                            .cardColor,
                        boxShadow: const [
                          BoxShadow(
                            spreadRadius: -6,
                            blurRadius: 8,
                            offset: Offset(0, 0),
                          )
                        ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Padding(
                          padding: EdgeInsets.only(
                              left: responsiveApp.setWidth(10),
                              top: responsiveApp.setWidth(2),
                              bottom: responsiveApp.setWidth(2)),
                          child: Row(
                            children: [
                              if(!isMobileAndTablet(context))
                                SizedBox(width: responsiveApp.setWidth(100),
                                  child: texto(
                                    text: 'Numero',
                                    size: responsiveApp.setSP(12),
                                  ),
                                ),
                              if(!isMobileAndTablet(context))
                              Padding(
                                padding: EdgeInsets.all(
                                    responsiveApp.setWidth(5)),
                                child: Container(
                                  height: responsiveApp.setHeight(20),
                                  width: responsiveApp.setWidth(1),
                                  color: Colors.grey.withOpacity(0.3),),
                              ),
                              Expanded(
                                child: texto(
                                  text: 'Nombre',
                                  size: responsiveApp.setSP(12),
                                ),
                              ),
                              if(!isMobileAndTablet(context))
                                Padding(
                                  padding: EdgeInsets.all(
                                      responsiveApp.setWidth(5)),
                                  child: Container(
                                    height: responsiveApp.setHeight(20),
                                    width: responsiveApp.setWidth(1),
                                    color: Colors.grey.withOpacity(0.3),),
                                ),
                              if(!isMobileAndTablet(context))
                                SizedBox(width: responsiveApp.setWidth(100),
                                  child: texto(
                                    text: 'Usuario',
                                    size: responsiveApp.setSP(12),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.all(
                                    responsiveApp.setWidth(5)),
                                child: Container(
                                  height: responsiveApp.setHeight(20),
                                  width: responsiveApp.setWidth(1),
                                  color: Colors.grey.withOpacity(0.3),),
                              ),
                              SizedBox(width: responsiveApp.setWidth(100),
                                child: texto(
                                  text: 'Acciones',
                                  size: responsiveApp.setSP(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(child: Container(
                              height: responsiveApp.setHeight(1),
                              color: Colors.grey.withOpacity(0.3),)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: FutureBuilder(
                                  future: dbConnection.getData(
                                      onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
                                      context: context,
                                      fields: 'cash_register.`id`,cash_register.`name`,cash_register.`number`,'
                                          'users.`id` AS \'user_id\', users.`name` AS \'user_name\'',
                                      table: 'cash_register INNER JOIN users ON cash_register.`user_id` = users.`id`',
                                      where: 'cash_register.`number` LIKE \'%${searchController.text}%\' OR cash_register.`name` LIKE \'%${searchController.text}%\'',
                                      order: '$order limit 50',
                                      orderBy: 'cash_register.`id`',
                                      groupBy: 'cash_register.`id`'),
                                  builder: (BuildContext ctx,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.data == null) {
                                      return const Center(
                                        child: LinearProgressIndicator(
                                          backgroundColor: Colors.transparent,),
                                      );
                                    } else {
                                      return snapshot.data.isNotEmpty ? Column(
                                          children: List.generate(
                                            snapshot.data.length,
                                                (index) {
                                              return Column(
                                                children: [
                                                  list(snapshot, index),
                                                  if(index <
                                                      snapshot.data.length - 1)
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            child: Container(
                                                              height: responsiveApp
                                                                  .setHeight(1),
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                  0.3),)),
                                                      ],
                                                    ),
                                                ],
                                              );
                                            },
                                          )
                                      ) : Padding(
                                        padding: responsiveApp.edgeInsetsApp
                                            .allMediumEdgeInsets,
                                        child: Column(
                                            children: [
                                              Icon(Icons.file_copy_outlined,
                                                size: responsiveApp.setWidth(
                                                    30), color: Colors.grey,),
                                              texto(
                                                  text: 'No hay nada que mostrar',
                                                  size: responsiveApp.setSP(14),
                                                  color: Colors.grey),
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
      }
    );
  }

  Widget list(AsyncSnapshot snapshot,int index){

    return ListTile(
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: responsiveApp.setHeight(3)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: responsiveApp.setWidth(100),
              child: texto(
                  size: responsiveApp.setSP(12),
                  text: snapshot.data[index]['number'],
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
                size: responsiveApp.setSP(12),
                text: snapshot.data[index]['name'],
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
                  text: snapshot.data[index]['user_name'],
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
                              edit=true;
                              cashId = int.parse(snapshot.data[index]['id']);
                              cashNameController.text=snapshot.data[index]['name'];
                              cashNumberController.text=snapshot.data[index]['number'];
                              selectedUser = userItems.elementAt(users.map((e) => e.id).toList().indexOf(int.parse(snapshot.data[index]['user_id'])));
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
                              size: responsiveApp.setWidth(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /*
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
                              size: responsiveApp.setWidth(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                   */
                ],
              )
            ),
          ],
        ),
      ),
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
                      field(context: context, controller: cashNameController, label: 'Nombre', hint: 'Ej: Nombre de la caja', keyboardType: TextInputType.name),
                      field(context: context, controller: cashNumberController, label: 'Numero', hint: 'Ej: 1, 2, 3...', keyboardType: TextInputType.name),
                      customDropDownField(context: context, options: userItems,initialValue: selectedUser , onSelected: (v){
                        setState(() {
                          selectedUser=v;
                        });
                      }),
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
