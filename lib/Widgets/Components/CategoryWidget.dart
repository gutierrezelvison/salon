//import 'dart:html' as html;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({Key? key}) : super(key: key);

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _localNameController = TextEditingController();
  final TextEditingController _localNameLinkController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  int idCategory = 0;
  String imageName = '';
  String imagePath = '';
  bool status= true;
  bool firstTime= true;
  Uint8List bytes = Uint8List(0);
  var file;
  int imageLength=0;
  late DropzoneViewController controller1;
  String message1 = 'Drop something here';
  bool highlighted1 = false;

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
        if (edit) {
          if (await bdConnection.updateCategory(context: context,id: idCategory,name: _localNameController.text, slug: _localNameLinkController.text,
              status: status?'active':'deactive', file: file, imageLength: imageLength, imageName: imageName)) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Categoría actualizada con éxito!',
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
          if (await bdConnection.addCategory(context: context,name: _localNameController.text, slug: _localNameLinkController.text,
                status: status?'active':'deactive', file: file, imageLength: imageLength)) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Categoría agregada con éxito!',
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

  limpiar(){
    setState(() {
      pageIndex = 0;
      idCategory=0;
      firstTime=true;
      bytes=Uint8List(0);
      _localNameController.text = '';
      _localNameLinkController.text = '';
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
        child: Container(
          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
          //color: Colors.blueGrey,
          child: Row(
            children: [
              if(isMobileAndTablet(context))
                IconButton(onPressed: ()=> pageIndex==1?limpiar(): mainScaffoldKey.currentState!.openDrawer(), icon: Icon(pageIndex==1?Icons.arrow_back_rounded:Icons.menu_rounded)),
              if(!isMobileAndTablet(context)&&pageIndex==1)
                IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded)),
              Expanded(
                child: Text(pageIndex==0?"Categorías":edit?"Modificar categoría":"Añadir categoría",
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
                        SizedBox(width: responsiveApp.setWidth(30),
                          child: texto(
                            text: '#',
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
                        if(!isMobile(context))
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),
                        if(!isMobile(context))
                        SizedBox(width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Estado',
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
                            future: bdConnection.getCategory(context),
                            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                              if (snapshot.data == null) {
                                return Container(
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }else {
                                return Column(
                                  children: List.generate(
                                      snapshot.data.length,
                                      (index){
                                        return Column(
                                          children: [
                                            index>0?list(snapshot,index):const SizedBox(),
                                            if(index>0&&index<snapshot.data.length-1)
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
              SizedBox(width: responsiveApp.setWidth(30),
                  child: texto(
                    text: snapshot.data[index].id.toString(),
                    size: responsiveApp.setSP(10),
                  ),
              ),

              Padding(
                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                child: SizedBox(height: responsiveApp.setHeight(20),
                  width: responsiveApp.setWidth(1),
                ),
              ),
              SizedBox(width: responsiveApp.setWidth(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    snapshot.data[index].image!=null
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
                        image: Image.asset('assets/images/No_image.jpg',fit: BoxFit.cover,)),
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
                    size: responsiveApp.setSP(10),
                    text: snapshot.data[index].name,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500
                ),
              ),
              if(!isMobile(context))
              Padding(
                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                child: SizedBox(height: responsiveApp.setHeight(20),
                  width: responsiveApp.setWidth(1),
                ),
              ),
              if(!isMobile(context))
              SizedBox(width: responsiveApp.setWidth(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                        color: snapshot.data[index].status=='active'? const Color(0xff22d88d): const Color(0xffFF525C),
                      ),
                      child: texto(
                        size: responsiveApp.setSP(10),
                        text: snapshot.data[index].status=='active'?'Activo':'Inactivo',
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
                                  bytes=(snapshot.data[index].image?.bytes)??Uint8List(0);
                                  edit=true;
                                  idCategory=snapshot.data[index].id;
                                  _localNameController.text=snapshot.data[index].name;
                                  _localNameLinkController.text=snapshot.data[index].slug;
                                  imageName = (snapshot.data[index].image?.name.toString().split('.').first)??'';
                                  imagePath = (snapshot.data[index].image?.path!)??'';
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
                Row(
                  children: [
                    Expanded(
                      child: field(
                        context: context,
                        controller: _localNameController,
                        label: 'Nombre de la categoría*', hint: 'Nombre',
                        keyboardType: TextInputType.name,
                        onChanged: (value){
                          setState((){
                            _localNameLinkController.text=value.replaceAll(' ', '-');
                          });
                        },
                      ),
                    ),
                    if(!isMobileAndTablet(context))
                    SizedBox(width: responsiveApp.setWidth(40),),
                    if(!isMobileAndTablet(context))
                      Expanded(
                        child: field(
                          context: context,
                          controller: _localNameLinkController,
                          label: 'Enlace de la categoría*', hint: 'enlace-categoria',
                          keyboardType: TextInputType.text,
                        ),
                      ),
                  ],
                ),
                if(isMobileAndTablet(context))
                  Row(
                  children: [
                    Expanded(
                        child: field(
                          context: context,
                          controller: _localNameLinkController,
                          label: 'Enlace de la categoría*', hint: 'enlace-categoria',
                          keyboardType: TextInputType.text,
                        ),
                      ),
                  ],
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
                                            child: imagePath !='null'&&imagePath !=''? Image.memory(
                                                bytes, fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)
                                            ):bytes.isNotEmpty?Image.memory(bytes,fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)):Image.asset('assets/images/No_image.jpg',fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)),
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
                                             // imageProvider = MemoryImage(bytes);
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
}
