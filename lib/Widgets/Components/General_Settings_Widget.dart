//import 'dart:html';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class GeneralSettingsWidget extends StatefulWidget {
  const GeneralSettingsWidget({Key? key}) : super(key: key);

  @override
  State<GeneralSettingsWidget> createState() => _GeneralSettingsWidgetState();
}

class _GeneralSettingsWidgetState extends State<GeneralSettingsWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  final GlobalKey<FormState> _formKey = GlobalKey();
  double containerWidth = 5;
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyEmailController = TextEditingController();
  final TextEditingController _companyPhoneController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();
  final TextEditingController _companyWebController = TextEditingController();
  final TextEditingController _companyHostController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  int idCategory = 0;
  String imageName = '';
  String imagePath = 'null';
  Company company = Company();
  bool status= true;
  bool firstTime= true;
  var file;
  int imageLength=0;
  late DropzoneViewController controller1;
  String message1 = 'Drop something here';
  bool highlighted1 = false;
  Uint8List? uploadedImage;

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
          if (await bdConnection.updateCompany(
              context: context,
            companyData: Company(
              id: company.id,
              company_email: _companyEmailController.text,
              company_name: _companyNameController.text,
              company_phone: _companyPhoneController.text,
              address: _companyAddressController.text,
              website: _companyWebController.text,
              currency_id: company.currency_id,
              date_format: company.date_format,
              latitude: company.latitude,
              locale: company.locale,
              longitude: company.longitude,
              purchase_code: company.purchase_code,
              supported_until: company.supported_until,
              time_format: company.time_format,
              timezone: company.timezone,
            ),
          file: file, imageLength: imageLength, imageName: imageName)) {
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
      uploadedImage=null;
      _companyNameController.text = '';
      _companyEmailController.text = '';
      _companyWebController.text = '';
      _companyAddressController.text = '';
      _companyPhoneController.text = '';
      company=Company();
      file = null;
      imageName = '';
      imagePath = '';
    });
  }

  getCompanyData()async{
    var data = await bdConnection.getCompanyData(context);
    setState((){
       company = data;
       _companyPhoneController.text=data.company_phone.toString();
       _companyAddressController.text = data.address.toString();
       _companyWebController.text = data.website.toString();
       _companyNameController.text = data.company_name.toString();
       _companyEmailController.text = data.company_email.toString();
       imagePath = data.logo!.path!.toString();
       uploadedImage = data.logo!.bytes!;
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
    if(firstTime) {
      getCompanyData();
      firstTime=false;
    }
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            if(isMobile(context))
            PreferredSize(
              preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
              child: Container(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                //color: Colors.blueGrey,
                child: Row(
                  children: [
                    if(isMobileAndTablet(context))
                    IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded,)),
                    const Expanded(
                      child: Text("Empresa",
                        style: TextStyle(
                         // color: Colors.white,
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
                //color: Colors.blueGrey,
                onRefresh: () {
                  return Future.delayed(
                    const Duration(seconds: 1),
                        () {
                      /// adding elements in list after [1 seconds] delay
                      /// to mimic network call
                      ///
                      /// Remember: [setState] is necessary so that
                      /// build method will run again otherwise
                      /// list will not show all elements
                      setState((){
                      });

                      // showing snackbar

                    },
                  );
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: isMobile(context)
                      ? mobileBody()
                      : newCategory(),
                ),
              ),
            ),
          ],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: field(
                        context: context,
                        controller: _companyNameController,
                        label: 'Nombre de la empresa*', hint: 'Ej.: Empresa S.A.',
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(20),),
                    Expanded(
                      child: field(
                        context: context,
                        controller: _companyEmailController,
                        label: 'E-Mail de la empresa*', hint: 'Ej.: example@empresa.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(20),),
                    Expanded(
                      child: field(
                        context: context,
                        controller: _companyPhoneController,
                        label: 'Teléfono de la empresa*', hint: '0123456789',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: responsiveApp.setHeight(250),
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
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
                                radius: const Radius.circular(10),
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
                                                      uploadedImage!, fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)
                                                  ):uploadedImage!=null?Image.memory(uploadedImage!,fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)):Image.asset('assets/images/logo.png',fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)),
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
                                                    uploadedImage = r;
                                                    imageLength = uploadedImage!.length;
                                                    file = Stream.value(uploadedImage!.toList());
                                                    //imageProvider = MemoryImage(bytes);
                                                  });
                                                }
                                              });
                                              /*StartFilePicker().startFilePicker((v){
                                                if(v!='error') {
                                                  setState(() {
                                                    uploadedImage = v['bytes'];
                                                    imageLength = uploadedImage!.length;
                                                    file = Stream.value(uploadedImage!.toList());
                                                  });
                                                }
                                              });

                                               */
                                            }, child: const Icon(Icons.image_search_rounded)),
                                          ),
                                        ),
                                      ),
                                     // if(bytes.isEmpty)Center(child: Text(message1)),
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
                    ),
                    SizedBox(width: responsiveApp.setWidth(20),),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: field(
                                  context: context,
                                  controller: _companyAddressController,
                                  label: 'Dirección de la empresa*', hint: 'Ej.: Av. Duarte No. x',
                                  keyboardType: TextInputType.streetAddress,
                                ),
                              ),
                            ]
                          ),
                          SizedBox(height: responsiveApp.setHeight(15),),
                          Row(
                              children: [
                                Expanded(
                                  child: field(
                                    context: context,
                                    controller: _companyWebController,
                                    label: 'Página Web de la empresa*', hint: 'Ej.: www.empresa.com',
                                    keyboardType: TextInputType.url,
                                  ),
                                ),
                              ]
                          ),
                          SizedBox(height: responsiveApp.setHeight(15),),
                          Row(
                              children: [
                                Expanded(
                                  child: field(
                                    context: context,
                                    controller: _companyHostController,
                                    label: 'Dirección host del servidor', hint: 'Ej.: http://localhost',
                                    keyboardType: TextInputType.url,
                                  ),
                                ),
                              ]
                          ),
                        ],
                      ),
                    )
                  ],
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
                      child: field(
                        context: context,
                        controller: _companyNameController,
                        label: 'Nombre de la empresa*', hint: 'Ej.: Empresa S.A.',
                        keyboardType: TextInputType.name,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: field(
                        context: context,
                        controller: _companyEmailController,
                        label: 'E-Mail de la empresa*', hint: 'Ej.: example@empresa.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: field(
                        context: context,
                        controller: _companyPhoneController,
                        label: 'Teléfono de la empresa*', hint: 'Ej.: 1112223333',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: field(
                        context: context,
                        controller: _companyAddressController,
                        label: 'Dirección de la empresa*', hint: 'Ej.: Av. Duarte No. x',
                        keyboardType: TextInputType.streetAddress,
                      ),
                    ),
                  ],
                ),
                Row(
                    children: [
                      Expanded(
                        child: field(
                          context: context,
                          controller: _companyWebController,
                          label: 'Página Web de la empresa*', hint: 'Ej.: www.empresa.com',
                          keyboardType: TextInputType.url,
                        ),
                      ),
                    ]
                ),

                Row(
                    children: [
                      Expanded(
                        child: field(
                          context: context,
                          controller: _companyHostController,
                          label: 'Dirección host del servidor*', hint: 'Ej.: http://localhost',
                          keyboardType: TextInputType.url,
                        ),
                      ),
                    ]
                ),
                SizedBox(height: responsiveApp.setHeight(15),),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: displayHeight(context)*0.3,
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
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
                                radius: const Radius.circular(10),
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
                                                  child: imagePath !='null'? Image.memory(
                                                      uploadedImage!, fit: BoxFit.scaleDown, height: responsiveApp.setHeight(150)
                                                  ):uploadedImage!=null?Image.memory(uploadedImage!,fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)):Image.asset('assets/images/logo.png',fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)),
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
                                                    uploadedImage = r;
                                                    imageLength = uploadedImage!.length;
                                                    file = Stream.value(uploadedImage!.toList());
                                                    //imageProvider = MemoryImage(bytes);
                                                  });
                                                }
                                              });
                                              /*
                                              StartFilePicker().startFilePicker((v){
                                                if(v!='error') {
                                                  setState(() {
                                                    uploadedImage = v['bytes'];
                                                    imageLength = uploadedImage!.length;
                                                    file = Stream.value(uploadedImage!.toList());
                                                  });
                                                }
                                              });

                                               */
                                            }, child: const Icon(Icons.image_search_rounded)),
                                          ),
                                        ),
                                      ),
                                      // if(bytes.isEmpty)Center(child: Text(message1)),
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
                    ),
                  ]
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
        file = controller1.getFileStream(ev);
        uploadedImage = await controller1.getFileData(ev);
        imageLength = uploadedImage!.length;
        setState(() {
          message1 = '$ev dropped';
          highlighted1 = false;
        });
      },
      onDropMultiple: (ev) async {
        print('Zone 1 drop multiple: $ev');
      },
    ),
  );
}
