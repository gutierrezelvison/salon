//import 'dart:html' as html;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({Key? key}) : super(key: key);

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _localNameController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  bool firstTime = true;
  int idSucursal = 0;
  Uint8List bytes = Uint8List(0);
  var file;
  int imageLength=0;
  late DropzoneViewController controller1;
  String message1 = 'Drop something here';
  bool highlighted1 = false;
  String imageName = '';
  String imagePath = '';

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
          if (await bdConnection.addCarousel(context: context,imageName: _localNameController.text,
          imageLength: imageLength,file: file)) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Imagen agregada con éxito!',
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
      _localNameController.text = '';
      edit=false;
      idSucursal=0;
      bytes = Uint8List(0);
      file =null;
    });
  }

  deleteItem(int id)async{
    if(await bdConnection.deleteCarousel(context, id)){
      setState(() {

      });
      CustomSnackBar().show(
          context: context,
          msg: 'Imagen eliminado con éxito!',
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
          child: Container(
            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
           // color: Colors.blueGrey,
            child: Row(
              children: [
                if(isMobileAndTablet(context))
                  IconButton(onPressed: ()=> pageIndex==1?limpiar():Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded,)),
                if(!isMobileAndTablet(context)&&pageIndex==1)
                  IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded,)),
                Expanded(
                  child: Text(pageIndex==0?"Carrousel":edit?"Modificar Carousel":"Añadir image",
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

        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(pageIndex==0)
              Expanded(child: imageList()),
            if(pageIndex==1)
              newLocalization(),
          ],
        ),
      ),
    );
  }

  Widget sucursales(){
    return FutureBuilder(
        future: bdConnection.getCarrousel(context),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
                child: CircularProgressIndicator());
          } else {
            return RefreshIndicator(
              onRefresh: () {
                return Future.delayed(
                  const Duration(seconds: 1),
                      () {
                    setState((){
                    });
                  },
                );
              },
              child: GridView.builder(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return index.isEven
                      ? _buildStaggeredTile(snapshot.data[index], 2, 1)
                      : _buildStaggeredTile(snapshot.data[index], 1, 1);
                },),
            );
          }
        }
    );
  }

  Widget _buildStaggeredTile(CarrouselImages item, int columnSpan, int rowSpan) {
    return Container(
      margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            spreadRadius: -6,
            blurRadius: 8,
            offset: Offset(0, 1)
          )
        ]
      ),
      child: GridTile(
        footer: GridTileBar(
          trailing: InkWell(
            onTap: (){
              warningMsg(
                  context: context,
                  mainMsg: '¿Está seguro?',
                  msg: '¡No podrá recuperar el registro borrado!',
                  okBtnText: 'Si, borrar',
                  cancelBtnText: 'No, cancelar',
                  okBtn: (){
                    deleteItem(item.id!);
                    Navigator.pop(context);
                  },
                  cancelBtn: (){
                    Navigator.pop(context);
                  }
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                    color: Colors.red,
                    boxShadow: const [
                      BoxShadow(
                        spreadRadius: -6,
                        blurRadius: 8,
                        offset: Offset(0,2),
                      )
                    ]
                ),
                child: const Icon(Icons.delete_forever_rounded,color: Colors.white,),
              ),
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(responsiveApp.carrouselRadiusWidth),
          child: Image.memory(
            item.file_name!.bytes!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget imageList(){
    return FutureBuilder(
        future: bdConnection.getCarrousel(context),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if(snapshot.data ==null){
            return const Center(child:CircularProgressIndicator());
          }else{
            return RefreshIndicator(
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
                child: StaggeredGrid.count(
                  axisDirection: AxisDirection.down,
                  crossAxisCount: 3,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  children:  List.generate(
                    snapshot.data.length,
                        (index) {

                          return StaggeredGridTile.count(
                            mainAxisCellCount: 1,
                            crossAxisCellCount: index%4==0?3:index>4&&index%2==0?2:1,
                            child: Container(
                              margin: responsiveApp.edgeInsetsApp
                                  .allSmallEdgeInsets,
                              decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: -6,
                                        blurRadius: 8,
                                        offset: Offset(0, 1)
                                    )
                                  ]
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    responsiveApp.carrouselRadiusWidth),
                                child: Image.memory(
                                  snapshot.data[index].file_name.bytes!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }
                  ),
                ),
              ),
            );
          }
        }
    );
  }

  Widget newLocalization(){
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
                const Text('Imagen*'),
                SizedBox(
                  height: responsiveApp.setHeight(250),
                  child: Column(
                    children: [
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
                                            child: imagePath !='null' && imagePath !=''? Image.network(
                                                imagePath, fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)
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
      },
      onDropMultiple: (ev) async {
        print('Zone 1 drop multiple: $ev');
      },
    ),
  );
}
