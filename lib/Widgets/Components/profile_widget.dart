//import 'dart:html' as html;
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import '../../util/Keys.dart';
import '../../util/db_connection.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../values/ResponsiveApp.dart';
import '../change_password_widget.dart';
import '../security_questions_widget.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection dbConnection;
  AppData appData = AppData();
  static User user = User();
  int pageIndex = 0;
  bool enabled = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController levelController = TextEditingController();
  TextEditingController idCardController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  Uint8List bytes = Uint8List(0);
  var file;
  int imageLength=0;
  String imageName = '';
  String imagePath = '';
  bool isDragging = false;
  bool verPerfil = false;
  bool editProfile = false;
  String profileUrl = '';
  dynamic imageProvider;
  late DropzoneViewController controller1;
  String message1 = 'Drop something here';
  bool highlighted1 = false;

  @override
  void initState() {
    nameController.text = appData.getUserData().name;
    emailController.text = appData.getUserData().email;
    passwordController.text = appData.getUserData().password;
    phoneController.text = appData.getUserData().mobile;
    user = appData.getUserData();
    super.initState();
  }

  resetFields(){
    setState(() {
      nameController.text = appData.getUserData().name;
      emailController.text = appData.getUserData().email;
      passwordController.text = appData.getUserData().password;
      phoneController.text = appData.getUserData().mobile;
    });
  }

  void _saveForm() async {
    if(pageIndex==2) {
      user.name = appData.getUserData().name;
      user.email = appData.getUserData().email;
      user.mobile = appData.getUserData().mobile;
      user.security_questions = appData
          .getUserData()
          .security_questions;
      if (await dbConnection.updateUser(
          onError: (e) {
            warningMsg(context: context,
                mainMsg: '¡Error!',
                msg: e,
                okBtnText: 'Aceptar',
                okBtn: () {
                  Navigator.pop(context);
                });
          },
          context: context,
          user: user,
          file: file,
          imageLength: file != null ? imageLength : 0,
          imageName: imageName)) {
        setState(() {

          imageName = '';
          imageLength = 0;
          editProfile = false;
          bytes = Uint8List(0);
          file = null;
        });
        Provider.of<BDConnection>(context, listen: false);
        CustomSnackBar().show(
            context: context,
            msg: 'Acción realizada con éxito!',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xff22d88d)
        );
      } else {
        CustomSnackBar().show(
            context: context,
            msg: 'No se pudo completar la operación!',
            icon: Icons.error_outline_outlined,
            color: const Color(0xffFF525C)
        );
      }
    }else{
      final bool isValid = _formKey.currentState!.validate();
      if (isValid) {
        user.name = nameController.text;
        user.email = emailController.text;
        user.mobile = phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
        user.security_questions = appData
            .getUserData()
            .security_questions;
        if (await dbConnection.updateUser(
            onError: (e) {
              warningMsg(context: context,
                  mainMsg: '¡Error!',
                  msg: e,
                  okBtnText: 'Aceptar',
                  okBtn: () {
                    Navigator.pop(context);
                  });
            },
            context: context,
            user: user,
            file: file != null ? file.openRead() : null,
            imageLength: file != null ? imageLength : 0,
            imageName: imageName)) {
          setState(() {
            imageName = '';
            imageLength = 0;
            editProfile = false;
          });
          Provider.of<BDConnection>(context, listen: false);
          CustomSnackBar().show(
              context: context,
              msg: 'Acción realizada con éxito!',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xff22d88d)
          );
        } else {
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

  // Función para actualizar la imagen
  void updateImage(ImageProvider newImageProvider) {
    setState(() {
      imageProvider = newImageProvider;
    });
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    dbConnection = BDConnection(context: context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: pageIndex==2?Colors.black:Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            SizedBox(
              height: displayHeight(context),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        PreferredSize(
                          preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
                          child: Container(
                            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                            //color: Colors.blueGrey,
                            child: Row(
                              children: [
                                if(isMobileAndTablet(context))
                                  IconButton(onPressed: ()=> pageIndex==0?mainScaffoldKey.currentState!.openDrawer():setState((){pageIndex=0;}), icon: pageIndex==0?const Icon(Icons.menu,): Icon(Icons.arrow_back_ios_new_rounded,color: pageIndex==2?Colors.white:Theme.of(context).iconTheme.color,)),
                                if(!isMobileAndTablet(context) && pageIndex>0)
                                  IconButton(onPressed: ()=> setState((){pageIndex=0;}), icon: Icon(Icons.arrow_back_ios_new_rounded,color: pageIndex==2?Colors.white:Theme.of(context).iconTheme.color,)),
                                Expanded(
                                  child: Text(pageIndex==0?"Perfil":pageIndex==1? "Preguntas de seguridad": "Foto de perfil",
                                    style: TextStyle(
                                      color: pageIndex==2? Colors.white:Theme.of(context).textTheme.headlineSmall!.color,
                                      fontSize: 18,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if(pageIndex==2)
                                  actionButton(
                                      name: "Cambiar",
                                      color: const Color(0xffffdc65),
                                      icon: Icons.change_circle_rounded,
                                      onTap: (){
                                        if(editProfile) file= null;

                                            if(isMobileAndTablet(context)){
                                              FileManager().abreArchivo((r) {
                                                if(r!='error') {
                                                  setState(() {
                                                    bytes = r;
                                                    imageLength = bytes.length;
                                                    file = Stream.value(bytes.toList());
                                                    imageProvider = MemoryImage(bytes);
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
                                            }else{
                                              setState(() {
                                                verPerfil = true;
                                                editProfile = true;
                                              });
                                            }

                                      }
                                  ),
                                if(pageIndex==2 && file!=null)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if(file !=null)
                                          actionButton(
                                              name: 'Guardar',
                                              color: const Color(0xff6C9BD2),
                                              icon: Icons.save,
                                              onTap: (){
                                                imageName = appData.getUserData().image != null &&
                                                    appData.getUserData().image != ''
                                                    ? appData.getUserData().image.toString().split('/').last.split('.').first
                                                    : 'default-avatar-user';
                                                _saveForm();
                                                setState(() {
                                                  editProfile = !editProfile;
                                                });
                                              }
                                          ),
                                        const SizedBox(width: 10,),

                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
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
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  if(pageIndex==0)
                                    body(),
                                  if(pageIndex==1)
                                    SecurityQuestionsWidget(hasSecurityQuestions: user.security_questions==1),
                                  if(pageIndex == 2)
                                    SizedBox(
                                      height: displayHeight(context)*0.95,
                                      child: viewPhoto(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if(verPerfil)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: desktopChangeImage(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget body(){
    return Padding(
      padding: responsiveApp.edgeInsetsApp.onlySmallLeftEdgeInsets,
      child: Padding(
        padding: responsiveApp.edgeInsetsApp.onlyMediumRightEdgeInsets,
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(10)),
                  boxShadow: const [
                    BoxShadow(
                      spreadRadius: -6,
                      blurRadius: 8,
                      offset: Offset(0, 0),
                    ),
                  ]
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: responsiveApp.setHeight(20),),
                      InkWell(
                        onTap: (){
                          setState(() {
                            if(file != null){
                              imageProvider = MemoryImage(bytes);
                            }else if(appData.getUserData().image != null && appData.getUserData().image != ''){
                              imageProvider = NetworkImage(appData.getUserData().image);
                            }else{
                              imageProvider = const AssetImage('assets/images/default-avatar-user.png');
                            }
                            pageIndex = 2;
                            //verPerfil=true;
                          });
                        },
                        child: Container(
                          width: responsiveApp.setWidth(100),
                          height: responsiveApp.setWidth(100),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(100)),
                          ),
                          child: bytes.isNotEmpty?userImage(
                              width: responsiveApp.setWidth(100),
                              height: responsiveApp.setWidth(100),
                              color: Colors.white,
                              shadowColor: Theme.of(context).shadowColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(100)),
                              image: Image.memory(
                                bytes,
                                fit: BoxFit.fill,
                              )):appData.getUserData().image != null &&
                              appData.getUserData().image != ''
                              ? userImage(
                              width: responsiveApp.setWidth(100),
                              height: responsiveApp.setWidth(100),
                              color: Colors.white,
                              shadowColor: Theme.of(context).shadowColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(100)),
                              image: Image.memory(
                                appData.getUserData().image.bytes!,
                                fit: BoxFit.fill,
                              ))
                              : userImage(
                              width: responsiveApp.setWidth(100),
                              height: responsiveApp.setWidth(100),
                              color: Colors.white,
                              shadowColor: Theme.of(context).shadowColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(100)),
                              image: Image.asset(
                                'assets/images/default-avatar-user.png',
                                fit: BoxFit.fill,
                              )
                          ),
                        ),
                      ),
                      SizedBox(height: responsiveApp.setHeight(10),),
                      Padding(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            actionButton(
                              name: 'Preguntas',
                                color: const Color(0xffA2CDB8),
                                icon: Icons.security_rounded,
                              onTap: (){
                                setState(() {
                                  pageIndex = 1;
                                });
                              }
                            ),
                            SizedBox(width: responsiveApp.setWidth(10),),
                            actionButton(
                                name: enabled?'Cancelar':'Editar Perfil',
                                color: enabled?const Color(0xffff4567):const Color(0xffffdc65),
                                icon: enabled? Icons.cancel :Icons.edit,
                                onTap: (){
                                  if(enabled) {
                                    warningMsg(
                                        context: context,
                                        mainMsg: 'Seguro que desea cancelar?',
                                        msg: 'Se perderan los datos no guardados.',
                                        okBtnText: 'Si, Cancelar',
                                        cancelBtnText: 'No, abortar',
                                        okBtn: (){
                                          setState(() {
                                            enabled=false;
                                          });
                                          resetFields();
                                          Navigator.pop(context);
                                        },
                                        cancelBtn: (){Navigator.pop(context);}
                                    );
                                  }else{
                                    setState(() {
                                      enabled = true;
                                    });
                                  }
                                }
                            ),
                            SizedBox(width: responsiveApp.setWidth(10),),
                            actionButton(
                              name: 'Guardar',
                              color: const Color(0xff6C9BD2),
                              icon: Icons.save,
                              onTap: (){
                                imageName = appData.getUserData().image != null &&
                                    appData.getUserData().image != ''
                                    ? appData.getUserData().image.toString().split('/').last.split('.').first
                                    : 'default-avatar-user';
                                _saveForm();
                                setState(() {
                                  enabled = false;
                                });
                              }
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsiveApp.setHeight(5),),
                      field(context: context, controller: nameController, label: 'Nombre', keyboardType: TextInputType.name, enabled: enabled),
                      field(context: context, controller: phoneController, label: 'Teléfono', keyboardType: TextInputType.phone, enabled: enabled),
                      field(context: context, controller: emailController, label: 'Correo', keyboardType: TextInputType.emailAddress, enabled: enabled),
                      Padding(
                        padding: responsiveApp.edgeInsetsApp.onlySmallRightEdgeInsets,
                        child: Row(
                          children: [
                            Expanded(child: field(context: context, maxLines: 1,controller: passwordController, label: 'Contraseña', keyboardType: TextInputType.visiblePassword,obscureText: true,enabled: false)),
                            actionButton(
                                name: '',
                                color: const Color(0xffA2CDB8),
                                icon: Icons.change_circle_rounded,
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          ChangePasswordWidget(reason: 'user_change',userId: appData.getUserData().id,)));
                                }
                            ),
                          ],
                        ),
                      ),
                      //if(appData.getUserData().security_questions==1)
                      SizedBox(height: responsiveApp.setHeight(20),),
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
  Widget viewPhoto(){

    return Row(
      children: [
        Expanded(
          child: PhotoView(
            imageProvider: imageProvider,
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
  Widget desktopChangeImage(){
    return Container(
      width: responsiveApp.setWidth(500),
      height: responsiveApp.setHeight(500),
      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(responsiveApp.setWidth(8)),
          boxShadow: const [
            BoxShadow(
             // color: Colors.grey.withOpacity(0.4),
              spreadRadius: -8,
              blurRadius: 15,
              offset: Offset(0,0), // changes position of shadow
            ),
          ]
      ),
      child: Column(
        children: [
          if(!editProfile)
            Expanded(
                child: appData.getUserData().image != null &&
                    appData.getUserData().image != ''
                    ? userImage(
                    width: responsiveApp.setWidth(450),
                    height: responsiveApp.setHeight(400),
                    color: Colors.white,
                    shadowColor: Theme.of(context).shadowColor,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(0)),
                    image: Image.network(
                      appData.getUserData().image,
                      fit: BoxFit.fill,
                    ))
                    : userImage(
                    width: responsiveApp.setWidth(450),
                    height: responsiveApp.setHeight(400),
                    color: Colors.white,
                    shadowColor: Theme.of(context).shadowColor,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(0)),
                    image: Image.asset(
                      'assets/images/default-avatar-user.png',
                      fit: BoxFit.fill,
                    )
                ),
            ),
          if(editProfile)
            Expanded(
              child: Stack(
                children: [
                  if(kIsWeb)
                    SizedBox(
                      height: responsiveApp.setHeight(400),
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(responsiveApp.setWidth(20)),
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
                                          child: imagePath !='null' && imagePath !=''? Image.network(
                                              imagePath, fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)
                                          ):file!=null?Image.memory(bytes,fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)):Image.asset('assets/images/logo.png',fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)),
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
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                actionButton(
                    name: "Cancelar",
                    color: const Color(0xffff4567),
                    icon: Icons.cancel_rounded,
                    onTap: (){
                      setState(() {
                        if(editProfile) file=null;
                        verPerfil = false;
                      });
                    }
                ),
                const SizedBox(width: 10,),
                actionButton(
                    name: "Aceptar",
                    color: const Color(0xffA2CDB8),
                    icon: Icons.check_circle_rounded,
                    onTap: (){
                      setState(() {
                        verPerfil=false;
                        editProfile = false;
                        imageProvider = MemoryImage(bytes);
                      });
                    }
                ),
              ],
            ),
          ),
        ],
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
      },
      onLeave: () {
        setState(() => highlighted1 = false);
      },
      onDrop: (ev) async {
        setState(() {
          highlighted1 = false;
        });
        file = controller1.getFileStream(ev);
        bytes = await controller1.getFileData(ev);
        imageLength = bytes.length;
      },
      onDropMultiple: (ev) async {
        print('Zone 1 drop multiple: $ev');
      },
    ),
  );
/*
  _startFilePicker() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files!.length == 1) {
        final file = files[0];
        html.FileReader reader =  html.FileReader();

        reader.onLoadEnd.listen((e) {
          setState(() {

            bytes = reader.result as Uint8List;
            imageLength = bytes.length;
            this.file = Stream.value(bytes.toList());
          });
        });

        reader.onError.listen((fileEvent) {
          print("Some Error occured while reading the file");
          setState(() {
            //option1Text = "Some Error occured while reading the file";
          });
        });

        reader.readAsArrayBuffer(file);
      }
    });
  }

 */
}
