//import 'dart:html' as html;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class CustomerWidget extends StatefulWidget {
  const CustomerWidget({Key? key}) : super(key: key);

  @override
  State<CustomerWidget> createState() => _CustomerWidgetState();
}

class _CustomerWidgetState extends State<CustomerWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection = BDConnection();
  final GlobalKey<FormState> _formKey = GlobalKey();
  double containerWidth = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final topItems = ['+1 Dominican Republic'];
  String selectedTop = '+1 Dominican Republic';
  int pageIndex = 0;
  int bookingId = 0;
  bool isNewCustomer = false;
  bool hasData = false;
  bool edit = false;
  bool verDetalle = false;
  int idService = 0;
  double discountPrice = 0;
  String imageName = '';
  String imagePath = '';
  List<Sucursal> sucList = [];
  List<Categorie> catList = [];
  User user = User();
  List<User> userBookingCount = [];
  bool firstTime= true;
  bool status= true;
  Uint8List bytes = Uint8List(0);
  var file;
  int imageLength=0;
  late DropzoneViewController controller1;
  String message1 = 'Drop something here';
  bool highlighted1 = false;
  final List<bool> _onHovering = [
    false,
    false,
    false,
    false,
    false,
  ];

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
        if (edit) {
          if (await bdConnection.updateUser(context: context,user: User(
            id: user.id!,name: _nameController.text, rol_id: 3, new_customer: isNewCustomer?1:0,
            email: _emailController.text,mobile: _phoneController.text.replaceAll(RegExp(r'[^\d]'), ''),mobile_verified: '0',
            calling_code: selectedTop.split(' ')[0], password:_passwordController.text,
          ),
              file: file, imageLength: imageLength, imageName: imageName, onError: (e) { })) {
            setState((){
              user = User(
                id: user.id,
                name: _nameController.text,
                email: _emailController.text,
                new_customer: isNewCustomer?1:0,
                mobile: _phoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
                mobile_verified: '0',
                calling_code: selectedTop.split(' ')[0],
                image: user.image,
              );
            });
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Cliente actualizada con éxito!',
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
          if (await bdConnection.setUser(context: context,name: _nameController.text, role: 3,
              comission: 0, new_customer: isNewCustomer?1:0,
              email: _emailController.text,mobile: _phoneController.text.replaceAll(RegExp(r'[^\d]'), ''),mobile_verified: 0,
              calling_code: selectedTop.split(' ')[0], password:_passwordController.text,
              file: file, imageLength: imageLength,)) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Cliente agregado con éxito!',
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
  resetPass()async{
    if(_passwordController.text!=''){
      if(await bdConnection.changePassword(onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
          context: context, password: _passwordController.text, userId: user.id!, isDefaultPass: 1)){
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
  deleteItem(int id)async{
    if(await bdConnection.deleteService(context: context,id: id)){
      CustomSnackBar().show(
          context: context,
          msg: 'Cliente eliminado con éxito!',
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

  getContainerHeight2()async{
    List list= await bdConnection.getCustomerBookingList(context: context,condition: user.id, field: 'user_Id');
    if(list.isNotEmpty) {
      hasData = true;
    }
  }

  limpiar(){
      if(edit){
        setState((){
          pageIndex =1;
          verDetalle= false;
          firstTime=true;
          bytes=Uint8List(0);
          _nameController.text='';
          _emailController.text='';
          _phoneController.text='';
          _passwordController.text = '';
          imageName='';
          imagePath = '';
          edit=false;
          isNewCustomer = false;
        });
      }else{
        setState((){
          pageIndex=0;
          firstTime=true;
          bytes=Uint8List(0);
          edit=false;
          bookingId =0;
          idService=0;
          user = User();
          _nameController.text='';
          _emailController.text='';
          _phoneController.text='';
          _passwordController.text = '';
          imageName='';
          imagePath = '';
          isNewCustomer= false;
        });
      }
  }
  @override
  void initState() {
    if(AppData().getUserData().rol_id==3){
      user = AppData().getUserData();
      getBookingCount();
      pageIndex =1;
    }
    super.initState();
  }

  getBookingCount()async{
    var query = await bdConnection.getUsersBookingCount(context: context,roleId: user.rol_id!,
        userId: user.id!);
    for (var e in query) {
        user.booking_approved_count=e.booking_approved_count;
        user.booking_canceled_count= e.booking_canceled_count;
        user.booking_in_progress_count= e.booking_in_progress_count;
        user.booking_completed_count= e.booking_completed_count;
        user.booking_pending_count= e.booking_pending_count;
    }
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
        child: Container(
          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
          //color: Colors.blueGrey,
          child: Row(
            children: [
              if(isMobileAndTablet(context))
                IconButton(onPressed: ()=> pageIndex==3?setState((){pageIndex=1;}):pageIndex>0?limpiar():mainScaffoldKey.currentState!.openDrawer(), icon: Icon(pageIndex!=0?Icons.arrow_back_rounded:Icons.menu_rounded,)),
              if(!isMobileAndTablet(context)&&pageIndex!=0 && AppData().getUserData().rol_id!=3)
                IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded,)),
              Expanded(
                child: Text(pageIndex==0?"Clientes":pageIndex==1?"Detalle cliente":pageIndex==3?'Detalle reserva':edit?"Editar Cliente":"Añadir cliente",
                  style: const TextStyle(
                    //color: Colors.white,
                    fontSize: 18,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if(pageIndex==0 && AppData().getUserData().rol_id!=3&&AppData().getCurrentLevelPermission().map((map)=>map.has_permission).toList().elementAt(AppData().getCurrentLevelPermission().map((map)=>map.permission_name).toList().indexOf('create_customer'))==1)
              InkWell(
                onTap: (){
                  setState(() {
                    edit=false;
                    pageIndex=2;
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

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if(pageIndex==0 && AppData().getUserData().rol_id !=3)
              categories(),
            if(pageIndex==1 || AppData().getUserData().rol_id ==3)
              detalle_cliente(),
            if(pageIndex==2)
              newCategory(),
            if(pageIndex==3)
              reservaDetalle(),
          ],
        ),
      ),
    );
  }

  Widget categories(){
    return Padding(
      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
      child: FutureBuilder(
          future: bdConnection.getUsers(context: context, roleId: 3),
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }else {
              return SizedBox(
                height:  displayHeight(context)*0.87,
                child: MasonryGridView.count(
                    itemCount: snapshot.data.length,
                  crossAxisCount: isMobileAndTablet(context)? (displayWidth(context)) ~/ 250 :(displayWidth(context) * 0.7 ) ~/ 300,
                  mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    itemBuilder: (ctx, index){
                      return list(snapshot,index);
                    },
                ),
              );
            }
          }
      ),
    );
  }

  Widget list(AsyncSnapshot snapshot,int index){

    return Padding(
      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
      child: InkWell(
        onTap: (){
          setState((){
            user = snapshot.data[index];
            getContainerHeight2();
            pageIndex=1;
          });
        },
        child: GridTile(
            child: Container(
              width: responsiveApp.setWidth(200),
              height: responsiveApp.setHeight(150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                  boxShadow: const [
                    BoxShadow(
                      spreadRadius: -6,
                      blurRadius: 8,
                      offset: Offset(0,0),
                    )
                  ],
                gradient: const LinearGradient(
                    begin: Alignment(0,3),
                    end: Alignment(-3,0),
                    colors: [
                      Color(0xff9e7fff),
                      Color(0xff13e9d1),
                    ]
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(responsiveApp.setHeight(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right:responsiveApp.setWidth(3)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: responsiveApp.setWidth(100),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                snapshot.data[index].image!=null
                                    ? userImage(
                                    width: responsiveApp.setWidth(65),
                                    height: responsiveApp.setWidth(65),
                                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(2)),
                                    image: Image.memory(snapshot.data[index].image.bytes!,))
                                    : userImage(
                                    width: responsiveApp.setWidth(65),
                                    height: responsiveApp.setWidth(65),
                                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(2)),
                                    image: Image.asset('assets/images/default-avatar-user.png')),
                              ],
                            ),
                          ),
                          SizedBox(height: responsiveApp.setHeight(5),),
                          texto(
                              size: responsiveApp.setSP(12),
                              text: snapshot.data[index].name,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          texto(
                            text: 'E-mail',
                            size: responsiveApp.setSP(10),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: texto(
                                    size: 14,
                                    text: snapshot.data[index].email,
                                    fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: responsiveApp.setHeight(5),),
                          texto(
                            text: 'Teléfono',
                            size: responsiveApp.setSP(10),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: texto(
                                    size: responsiveApp.setSP(10),
                                    text: '${snapshot.data[index].calling_code} '
                                        '${snapshot.data[index].mobile}',
                                    fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if(!isMobile(context))
                          SizedBox(height: responsiveApp.setHeight(5),),
                          texto(
                            text: 'Cliente desde',
                            size: responsiveApp.setSP(10),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          if(!isMobile(context))
                          Row(
                            children: [
                              Expanded(
                                child: texto(
                                  size: responsiveApp.setSP(10),
                                  text: '${snapshot.data[index].created_at.toString().split(' ')[0]} ',
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: responsiveApp.setHeight(8),),
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              texto(
                                text: 'Reservas',
                                size: responsiveApp.setSP(10),
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: '${snapshot.data[index].booking_completed_count}',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ),
      ),
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
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: customField(
                        context: context,
                        controller: _nameController,
                        labelText: 'Nombre*', hintText: 'Nombre',
                        keyboardType: TextInputType.name,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: customField(
                        context: context,
                        controller: _emailController,
                        labelText: 'E-mail*', hintText: 'someone@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: responsiveApp.edgeInsetsApp.onlySmallRightEdgeInsets,
                  child: Row(
                    children: [
                      Expanded(child: customField(context: context,maxLines: 1, controller: _passwordController, hintText: "Secure password", labelText: 'Contraseña', keyboardType: TextInputType.visiblePassword,obscureText: true,)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: customDropDownButton(
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
                                .toList(),
                        )
                    ),
                    if(!isMobileAndTablet(context))
                    SizedBox(width: responsiveApp.setWidth(10),),
                    if(!isMobileAndTablet(context))
                      Expanded(
                        child: customField(
                          context: context,
                          controller: _phoneController,
                          labelText: 'Teléfono*', hintText: '0123456789',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                  ],
                ),
                if(isMobileAndTablet(context))
                  Row(
                    children: [
                      Expanded(
                        child: customField(
                          context: context,
                          controller: _phoneController,
                          labelText: 'Teléfono*', hintText: '0123456789',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),

                Row(
                  children: [
                    Checkbox(value: isNewCustomer, onChanged: (v){
                      setState(() {
                        isNewCustomer = v!;
                      });
                    }),
                    Text("Cliente nuevo"),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),

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

  Widget detalle_cliente(){
    return Padding(
      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
              color: Theme.of(context).cardColor,
              boxShadow: const [
                BoxShadow(
                  spreadRadius: -6,
                  blurRadius: 8,
                  offset: Offset(0,0),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(responsiveApp.setWidth(5)),topRight: Radius.circular(responsiveApp.setWidth(5))),
                            gradient: LinearGradient(
                              begin: Alignment(0,3),
                              end: Alignment(-3,0),
                              colors: [
                                //Theme.of(context).primaryColor,
                                Color(0xff9e7fff),
                                Color(0xff13e9d1),

                                //const Color(0xff6C9BD2),
                              ],
                            )
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: responsiveApp.setWidth(5), right: responsiveApp.setWidth(15),
                                  top: responsiveApp.setHeight(5), bottom: responsiveApp.setHeight(5)),
                              child: user.image!=null
                                  ? userImage(
                                  width: responsiveApp.setWidth(50),
                                  height: responsiveApp.setWidth(50),
                                  borderRadius: BorderRadius.circular(100),
                                  shadowColor: Theme.of(context).shadowColor,
                                  image: Image.memory(user.image!.bytes!,))
                                  : userImage(
                                  width: responsiveApp.setWidth(50),
                                  height: responsiveApp.setWidth(50),
                                  borderRadius: BorderRadius.circular(100),
                                  shadowColor: Theme.of(context).shadowColor,
                                  shape: BoxShape.circle,
                                  image: Image.asset('assets/images/default-avatar-user.png')),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  texto(
                                      size: responsiveApp.setSP(14),
                                      text: user.name!,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.mail_outline_rounded, color: Colors.white, size: responsiveApp.setWidth(12),),
                                      SizedBox(width: responsiveApp.setWidth(3)),
                                      texto(
                                          size: responsiveApp.setSP(12),
                                          text: user.email!,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.phone_android_rounded, color: Colors.white,size: responsiveApp.setWidth(12),),
                                      SizedBox(width: responsiveApp.setWidth(3)),
                                      texto(
                                          size: responsiveApp.setSP(12),
                                          text: '${user.calling_code} '
                                              '${user.mobile}',
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                            if(AppData().getUserData().rol_id!=3)
                            InkWell(
                              onHover: (v){
                                v?_onHovering[0]=true:_onHovering[0]=false;
                              },
                              onTap:(){
                                setState((){
                                  _nameController.text = user.name.toString();
                                  _phoneController.text = user.mobile.toString();
                                  _emailController.text = user.email.toString();
                                  _passwordController.text = user.password.toString();
                                  imagePath = user.image.toString();
                                  isNewCustomer = user.new_customer==1;
                                  edit=true;
                                  pageIndex=2;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                decoration: BoxDecoration(
                                  color: _onHovering[0]?Colors.white:Colors.transparent,
                                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(3)),
                                  border: Border.all(color: _onHovering[0]?Colors.transparent:Colors.white, width: responsiveApp.setWidth(1)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: _onHovering[0]?Colors.blueGrey:Colors.white),
                                    SizedBox(width: responsiveApp.setWidth(3),),
                                    texto(
                                      text: 'Editar',
                                      size: responsiveApp.setSP(12),
                                      color: _onHovering[0]?Colors.blueGrey:Colors.white,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          texto(
                            size: responsiveApp.setSP(14),
                            text: 'Reservas',
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                                children: [
                                  texto(
                                    text: 'COMPLETA',
                                    size: responsiveApp.setSP(12),
                                  ),
                                  SizedBox(
                                      width: responsiveApp.setWidth(3)),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: user.booking_completed_count.toString(),
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  ),
                                ]
                            ),
                          ),
                          Padding(padding: responsiveApp.edgeInsetsApp
                              .allSmallEdgeInsets,
                            child: Container(
                              color: Colors.grey,
                              width: responsiveApp.setWidth(1),
                              height: responsiveApp.setHeight(30),
                            ),
                          ),
                          Expanded(
                            child: Column(
                                children: [
                                  texto(
                                    text: 'PENDIENTE',
                                    size: responsiveApp.setSP(12),
                                  ),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: user.booking_pending_count.toString(),
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  ),
                                ]
                            ),
                          ),
                          Padding(padding: responsiveApp.edgeInsetsApp
                              .allSmallEdgeInsets,
                            child: Container(
                              color: Colors.grey,
                              width: responsiveApp.setWidth(1),
                              height: responsiveApp.setHeight(30),
                            ),
                          ),
                          Expanded(
                            child: Column(
                                children: [
                                  texto(
                                    text: 'EN CURSO',
                                    size: responsiveApp.setSP(12),
                                  ),

                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: user.booking_in_progress_count.toString(),
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  ),
                                ]
                            ),
                          ),
                          Padding(padding: responsiveApp.edgeInsetsApp
                              .allSmallEdgeInsets,
                            child: Container(
                              color: Colors.grey,
                              width: responsiveApp.setWidth(1),
                              height: responsiveApp.setHeight(30),
                            ),
                          ),
                          Expanded(
                            child: Column(
                                children: [
                                  texto(
                                    text: 'CANCELADO',
                                    size: responsiveApp.setSP(12),
                                  ),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: user.booking_canceled_count.toString(),
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  ),
                                ]
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          SizedBox(height: responsiveApp.setHeight(10),),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              reservas(),
              if(!isMobileAndTablet(context) && verDetalle)
              Expanded(child: reservaDetalle()),
            ],
          ),
          if(hasData)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: displayHeight(context)*0.8,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_copy_outlined,size: responsiveApp.setWidth(80),color: Colors.grey),
                          SizedBox(height: responsiveApp.setHeight(20),),
                          texto(
                            text: 'No hay nada que mostrar',
                            size: responsiveApp.setSP(14),
                            color: Colors.grey,
                            fontFamily: 'Montserrat'
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget reservas(){
    return Row(
      children: [
        Padding(
          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
          child: Container(
            width: !isMobileAndTablet(context)?displayWidth(context)*0.35:displayWidth(context)*0.92,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                color: Colors.white,
                boxShadow: const[
                  BoxShadow(
                    spreadRadius: -1,
                    blurRadius: 2,
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
                      top: responsiveApp.setWidth(8), bottom: responsiveApp.setWidth(8)),
                  child: const Text('Reservas recientes'),
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
                          future: bdConnection.getCustomerBookingList(context: context, condition: user.id, field: 'user_id'),
                          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                            if (snapshot.data == null) {
                              return Container(
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }else {
                              int repetido = 1;
                              return Column(
                                children: List.generate(
                                    snapshot.data.length,
                                        (index){
                                      index>0&&snapshot.data[index].bookings.id==snapshot.data[index-1].bookings.id?repetido++:repetido=1;

                                      return Column(
                                        children: [
                                          index<snapshot.data.length-1&&snapshot.data[index].bookings.id!=snapshot.data[index+1].bookings.id
                                              ? reservar_list(snapshot,index,repetido)
                                              : index==snapshot.data.length-1?reservar_list(snapshot,index,repetido):const SizedBox(),

                                          index<snapshot.data.length-1&&snapshot.data[index].bookings.id!=snapshot.data[index+1].bookings.id
                                          ? Row(
                                          children: [
                                          Expanded(child: Container(height: responsiveApp.setHeight(1),)),
                                          ],
                                          )
                                              : index==snapshot.data.length-1?Row(
                                          children: [
                                          Expanded(child: Container(height: responsiveApp.setHeight(1),)),
                                          ],
                                          ):const SizedBox(),
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
      ],
    );
  }

  Widget reservar_list(AsyncSnapshot snapshot,int index,int repetido){
    var outputFormat = DateFormat('MMM dd, yyyy hh:mm a');
    return ListTile(
      title: Container(
        decoration: BoxDecoration(
          color: const Color(0xff5359ff).withOpacity(0.05),
          borderRadius: BorderRadius.circular(responsiveApp.setWidth(3)),
        ),
        child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                    color: snapshot.data[index].bookings.status=='completed'?const Color(0xff22d88d)
                        :snapshot.data[index].bookings.status=='pending'?const Color(0xffffc44e)
                        :snapshot.data[index].bookings.status=='approved'?const Color(0xff13e9d1)
                        :snapshot.data[index].bookings.status=='in progress'?const Color(0xff5359ff)
                        :const Color(0xffFF525C) ,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(responsiveApp.setWidth(3)),
                    bottomLeft: Radius.circular(responsiveApp.setWidth(3))),
                  ),
                  child: Column(
                    children: [
                      texto(
                        text: outputFormat.format(DateTime.parse(snapshot.data[index].bookings.date_time)).split(',')[0],
                        size: responsiveApp.setSP(14),
                        color: Colors.white,
                      ),
                      Container(
                        padding: EdgeInsets.all(responsiveApp.setWidth(3)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          border: Border.all(width: responsiveApp.setWidth(1),
                              color: Colors.white
                          ),
                        ),
                        child: texto(
                          text: outputFormat.format(DateTime.parse(snapshot.data[index].bookings.date_time)).substring(13,21),
                          size: responsiveApp.setSP(10),
                          color: Colors.white,
                        ),
                      ),
                      texto(
                        text: outputFormat.format(DateTime.parse(snapshot.data[index].bookings.date_time)).substring(7,12),
                        size: responsiveApp.setSP(14),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: responsiveApp.setWidth(5),),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      texto(size: 14, text: '1. ${snapshot.data[index-(repetido-1)].service.name} x '
                          '${snapshot.data[index].bookingItem.quantity}'),
                      if(repetido >= 2)
                        texto(size: 14, text: '2. ${snapshot.data[index-(repetido-2)].service.name} x '
                            '${snapshot.data[index].bookingItem.quantity}'),
                      if(repetido >= 3)
                        texto(size: 14, text: '3. ${snapshot.data[index-(repetido-3)].service.name} x '
                            '${snapshot.data[index].bookingItem.quantity}'),
                      if(repetido >= 4)
                        texto(size: 14, text: '4. ${snapshot.data[index-(repetido-4)].service.name} x '
                            '${snapshot.data[index].bookingItem.quantity}'),
                      if(repetido >= 5)
                        texto(size: 14, text: '5. ${snapshot.data[index-(repetido-5)].service.name} x '
                            '${snapshot.data[index].bookingItem.quantity}'),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          border: Border.all(width: responsiveApp.setWidth(1),
                              color: snapshot.data[index].bookings.status=='completed'?const Color(0xff22d88d)
                                  :snapshot.data[index].bookings.status=='pending'?const Color(0xffffc44e)
                                  :snapshot.data[index].bookings.status=='approved'?const Color(0xff13e9d1)
                                  :snapshot.data[index].bookings.status=='in progress'?const Color(0xff5359ff)
                                  :const Color(0xffFF525C)
                          ),
                        ),
                        child: texto(
                            size: 14,
                            text: snapshot.data[index].bookings.status,
                            color: snapshot.data[index].bookings.status=='completed'?const Color(0xff22d88d)
                                :snapshot.data[index].bookings.status=='pending'?const Color(0xffffc44e)
                                :snapshot.data[index].bookings.status=='approved'?const Color(0xff13e9d1)
                                :snapshot.data[index].bookings.status=='in progress'?const Color(0xff5359ff)
                                :const Color(0xffFF525C)
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                  child: Container(height: responsiveApp.setHeight(53),
                    width: responsiveApp.setWidth(1),
                    color: Colors.black.withOpacity(0.1),),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded,color: Colors.blueGrey),
                  onPressed: (){
                    setState((){
                      if(isMobileAndTablet(context))pageIndex=3;
                      verDetalle=true;
                      bookingId = snapshot.data[index].bookings.id;
                    });
                  },
                )
              ],
            ),
      ),
    );
  }
  
  Widget reservaDetalle(){
    var outputFormat = DateFormat('dd-MMM-yyyy hh:mm a');
    return FutureBuilder(
        future: bdConnection.getCustomerBookingList(context: context, condition: bookingId, field: 'id'),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }else {
            return Padding(
                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          responsiveApp.setWidth(5)),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          spreadRadius: -1,
                          blurRadius: 2,
                          offset: Offset(0, 0),
                        )
                      ]
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: responsiveApp.setWidth(5),
                                  right: responsiveApp.setWidth(15),
                                  top: responsiveApp.setHeight(5),
                                  bottom: responsiveApp.setHeight(5)),
                              child: user.image!=null
                                  ? userImage(
                                  width: responsiveApp.setWidth(50),
                                  height: responsiveApp.setWidth(50),
                                  borderRadius: BorderRadius.circular(100),

                                  shadowColor: Theme.of(context).shadowColor,
                                  image: Image.memory(user.image!.bytes!,))
                                  : userImage(
                                  width: responsiveApp.setWidth(50),
                                  height: responsiveApp.setWidth(50),
                                  shadowColor: Theme.of(context).shadowColor,
                                  borderRadius: BorderRadius.circular(100),
                                  image: Image.asset('assets/images/default-avatar-user.png')),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            texto(
                              size: responsiveApp.setSP(14),
                              text: user.name??'',
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        SizedBox(height: responsiveApp.setHeight(5),),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    texto(
                                      text: 'E-mail',
                                      size: responsiveApp.setSP(12),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.mail_outline_rounded,
                                          size: responsiveApp.setWidth(12),
                                          color: Colors.grey,),
                                        SizedBox(
                                            width: responsiveApp.setWidth(3)),
                                        texto(
                                          size: responsiveApp.setSP(12),
                                          text: user.email??'',
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ]
                              ),
                            ),
                            if(!isMobileAndTablet(context))
                            Padding(padding: responsiveApp.edgeInsetsApp
                                .allSmallEdgeInsets,
                              child: Container(
                                color: Colors.grey,
                                width: responsiveApp.setWidth(1),
                                height: responsiveApp.setHeight(30),
                              ),
                            ),
                            if(!isMobileAndTablet(context))
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    texto(
                                      text: 'Mobile',
                                      size: responsiveApp.setSP(12),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.phone_android_rounded,
                                          size: responsiveApp.setWidth(12),
                                          color: Colors.grey,),
                                        SizedBox(
                                            width: responsiveApp.setWidth(3)),
                                        texto(
                                          size: responsiveApp.setSP(12),
                                          text: '${user.calling_code} '
                                              '${user.mobile}',
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ]
                              ),
                            ),
                          ],
                        ),
                        if(isMobileAndTablet(context))
                          SizedBox(height: responsiveApp.setHeight(2),),
                        if(isMobileAndTablet(context))
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      texto(
                                        text: 'Mobile',
                                        size: responsiveApp.setSP(12),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.phone_android_rounded,
                                            size: responsiveApp.setWidth(12),
                                            color: Colors.grey,),
                                          SizedBox(
                                              width: responsiveApp.setWidth(3)),
                                          texto(
                                            size: responsiveApp.setSP(12),
                                            text: '${user.calling_code} '
                                                '${user.mobile}',
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ]
                                ),
                              ),
                            ],
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    texto(
                                    text: 'Fecha',
                                    size: responsiveApp.setSP(12),
                                    fontWeight: FontWeight.bold,
                                    ),
                                    Row(
                                      children: [
                                            Icon(Icons.calendar_today_outlined,
                                            size: responsiveApp.setWidth(12),color: Colors.grey),
                                            SizedBox(width: responsiveApp.setWidth(3)),
                                            texto(
                                              size: 14, text: snapshot.data[0].bookings.date_time.toString()
                                              .split(' ')
                                              .first,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ]
                                    ),
                                ),
                                Padding(padding: responsiveApp.edgeInsetsApp
                                    .allSmallEdgeInsets,
                                  child: Container(
                                    color: Colors.grey,
                                    width: responsiveApp.setWidth(1),
                                    height: responsiveApp.setHeight(30),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        texto(
                                          text: 'Hora',
                                          size: responsiveApp.setSP(12),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.alarm, size: responsiveApp.setWidth(12),color: Colors.grey),
                                            SizedBox(width: responsiveApp.setWidth(3)),
                                            texto(
                                              size: 14,
                                              text: outputFormat.format(DateTime.parse(snapshot.data[0].bookings.date_time)).toString().substring(12,20),
                                              color: Colors.grey,
                                            ),
                                          ],
                                        )
                                      ]
                                  ),
                                ),
                            Padding(padding: responsiveApp.edgeInsetsApp
                                .allSmallEdgeInsets,
                              child: Container(
                                color: Colors.grey,
                                width: responsiveApp.setWidth(1),
                                height: responsiveApp.setHeight(30),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      texto(
                                        text: 'Estado',
                                        size: responsiveApp.setSP(12),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      Container(
                                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                                          border: Border.all(width: responsiveApp.setWidth(1),
                                              color: snapshot.data[0].bookings.status=='completed'?const Color(0xff22d88d)
                                                  :snapshot.data[0].bookings.status=='pending'?const Color(0xffffc44e)
                                                  :snapshot.data[0].bookings.status=='approved'?const Color(0xff13e9d1)
                                                  :snapshot.data[0].bookings.status=='in progress'?const Color(0xff5359ff)
                                                  :const Color(0xffFF525C)
                                          ),
                                        ),
                                        child: texto(
                                            size: 14,
                                            text: snapshot.data[0].bookings.status,
                                            color: snapshot.data[0].bookings.status=='completed'?const Color(0xff22d88d)
                                                :snapshot.data[0].bookings.status=='pending'?const Color(0xffffc44e)
                                                :snapshot.data[0].bookings.status=='approved'?const Color(0xff13e9d1)
                                                :snapshot.data[0].bookings.status=='in progress'?const Color(0xff5359ff)
                                                :const Color(0xffFF525C)
                                        ),
                                      )
                                    ]
                                  ),
                                ],
                              ),
                            ),
                          ]
                        ),
                        SizedBox(height: responsiveApp.setHeight(2),),
                        if(isMobileAndTablet(context))
                          Row(
                            children: [
                              SizedBox(
                                width: responsiveApp.setWidth(150),
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: 'Método de pago',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    snapshot.data[0].bookings.payment_gateway == 'paypal'
                                        ? Icons.paypal_rounded:Icons.money, color: Colors.black.withOpacity(0.6),
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(2),),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: '${snapshot.data[0].bookings.payment_gateway}',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        SizedBox(height: responsiveApp.setHeight(2),),
                        if(isMobileAndTablet(context))
                          Row(
                            children: [
                              SizedBox(
                                width: responsiveApp.setWidth(150),
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: 'Estado de pago',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    snapshot.data[0].bookings.payment_status == 'pending'
                                        ? Icons.cancel:Icons.check_circle,
                                    color: snapshot.data[0].bookings.payment_status == 'pending'
                                        ? const Color(0xffffc44e): const Color(0xff22d88d),
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(2),),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: '${snapshot.data[0].bookings.payment_status}',
                                    fontWeight: FontWeight.w500,
                                    color: snapshot.data[0].bookings.payment_status == 'pending'
                                        ? const Color(0xffffc44e): const Color(0xff22d88d),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        SizedBox(height: responsiveApp.setHeight(2),),
                        Row(
                          children: [
                            Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  color: Colors.blueGrey,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: responsiveApp.setWidth(40),
                                        child: texto(
                                            size: responsiveApp.setSP(12),
                                            text: '#',
                                          color: Colors.white,
                                        ),
                                      ),
                                      Expanded(
                                        child: texto(
                                            size: responsiveApp.setSP(12),
                                            text: 'Artículo',
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: responsiveApp.setWidth(60),
                                        child: texto(
                                            size: responsiveApp.setSP(12),
                                            text: 'Precio',
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: responsiveApp.setWidth(60),
                                        child: texto(
                                            size: responsiveApp.setSP(12),
                                            text: 'Cantidad',
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: responsiveApp.setWidth(60),
                                        child: texto(
                                            size: responsiveApp.setSP(12),
                                            text: 'Total',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ),
                          ],
                        ),
                        Column(
                          children: List.generate(
                              snapshot.data.length,
                                  (int index){
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Row(
                                        children: [
                                          SizedBox(
                                            width: responsiveApp.setWidth(40),
                                            child: texto(
                                              size: responsiveApp.setSP(12),
                                              text: '${snapshot.data[index].service.id}',
                                            ),
                                          ),
                                          Expanded(
                                            child: texto(
                                              size: responsiveApp.setSP(12),
                                              text: '${snapshot.data[index].service.name}',
                                            ),
                                          ),
                                          SizedBox(
                                            width: responsiveApp.setWidth(60),
                                            child: texto(
                                              size: responsiveApp.setSP(12),
                                              text: '\$${snapshot.data[index].bookingItem.unit_price}',
                                            ),
                                          ),
                                          SizedBox(
                                            width: responsiveApp.setWidth(60),
                                            child: texto(
                                              size: responsiveApp.setSP(12),
                                              text: '${snapshot.data[index].bookingItem.quantity}',
                                            ),
                                          ),
                                          SizedBox(
                                            width: responsiveApp.setWidth(60),
                                            child: texto(
                                              size: responsiveApp.setSP(12),
                                              text: '\$${snapshot.data[index].bookingItem.amount}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if(index<snapshot.data.length -1)
                                    Row(
                                      children: [
                                        Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                                      ],
                                    )
                                  ],
                                );
                              },
                            ),
                        ),
                        SizedBox(height: responsiveApp.setHeight(2),),
                        Row(
                          children: [
                            Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                          ],
                        ),
                        if(!isMobileAndTablet(context))
                        SizedBox(
                          height: responsiveApp.setHeight(30),
                          child: Row(
                            children: [
                              SizedBox(
                                width: responsiveApp.setWidth(150),
                                  child: texto(
                                    size: responsiveApp.setSP(12),
                                    text: 'Método de pago',
                                    fontWeight: FontWeight.w500,
                                  ),
                              ),
                              if(!isMobileAndTablet(context))
                              Row(
                                children: [
                                  Icon(
                                    snapshot.data[0].bookings.payment_gateway == 'paypal'
                                        ? Icons.paypal_rounded:Icons.money, color: Colors.black.withOpacity(0.6),
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(2),),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: '${snapshot.data[0].bookings.payment_gateway}',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              const Expanded(child: SizedBox(),),
                              Row(
                                children: [
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: 'Subtotal',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(30),),
                                  texto(
                                    size: responsiveApp.setSP(12),
                                    text: '${snapshot.data[0].bookings.original_amount}',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(width: responsiveApp.setWidth(40),),
                                ],
                              ),
                            ]
                          ),
                        ),
                        if(!isMobileAndTablet(context))
                        SizedBox(
                          height: responsiveApp.setHeight(30),
                          child: Row(
                              children: [
                                SizedBox(
                                  width: responsiveApp.setWidth(150),
                                  child: texto(
                                    size: responsiveApp.setSP(12),
                                    text: 'Estado de pago',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if(!isMobileAndTablet(context))
                                Row(
                                  children: [
                                    Icon(
                                      snapshot.data[0].bookings.payment_status == 'pending'
                                          ? Icons.cancel:Icons.check_circle,
                                      color: snapshot.data[0].bookings.payment_status == 'pending'
                                        ? const Color(0xffffc44e): const Color(0xff22d88d),
                                    ),
                                    SizedBox(width: responsiveApp.setWidth(2),),
                                    texto(
                                      size: responsiveApp.setSP(12),
                                      text: '${snapshot.data[0].bookings.payment_status}',
                                      fontWeight: FontWeight.w500,
                                      color: snapshot.data[0].bookings.payment_status == 'pending'
                                          ? const Color(0xffffc44e): const Color(0xff22d88d),
                                    ),
                                  ],
                                ),
                                const Expanded(child: SizedBox(),),
                                Row(
                                  children: [
                                    texto(
                                      size: responsiveApp.setSP(12),
                                      text: 'ITBIS (${snapshot.data[0].bookings.tax_percent}%)',
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(width: responsiveApp.setWidth(30),),
                                    texto(
                                      size: responsiveApp.setSP(12),
                                      text: '${snapshot.data[0].bookings.tax_amount}',
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(width: responsiveApp.setWidth(40),),
                                  ],
                                ),
                              ]
                          ),
                        ),

                        SizedBox(
                          height: responsiveApp.setHeight(30),
                          child: Row(
                            children: [
                              const Expanded(child: SizedBox(),),
                              texto(
                                size: responsiveApp.setSP(14),
                                text: 'TOTAL',
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(width: responsiveApp.setWidth(30),),
                              texto(
                                size: responsiveApp.setSP(14),
                                text: '\$${snapshot.data[0].bookings.amount_to_pay}',
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(width: responsiveApp.setWidth(40),),
                            ],
                          ),
                        ),
                      ]
                  ),
                ),
            );
          }
        }
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
