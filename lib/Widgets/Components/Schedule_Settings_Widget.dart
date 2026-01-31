import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class ScheduleSettingsWidget extends StatefulWidget {
  const ScheduleSettingsWidget({Key? key}) : super(key: key);

  @override
  State<ScheduleSettingsWidget> createState() => _ScheduleSettingsWidgetState();
}

class _ScheduleSettingsWidgetState extends State<ScheduleSettingsWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  final GlobalKey<FormState> _formKey = GlobalKey();
  double containerWidth = 5;
  final TextEditingController _aperturaController = TextEditingController();
  final TextEditingController _cierreController = TextEditingController();
  final TextEditingController _slotsController = TextEditingController();
  final TextEditingController _permitidasController = TextEditingController();
  int pageIndex = 0;
  bool edit = false;
  int idCategory = 0;
  String imageName = '';
  String imagePath = 'null';
  Company company = Company();
  bool status= true;
  bool firstTime= true;
  Uint8List bytes = Uint8List(0);
  var file;
  int imageLength=0;
  late DropzoneViewController controller1;
  String message1 = 'Drop something here';
  bool highlighted1 = false;
  final repetidosItems = ['Si','No'];
  String selectedRepetidos = 'No';
  final estadoItems = ['Activo','Inactivo'];
  String selectedEstado = 'Activo';
  List<bool> allowBooking = [true,true,true,true,true,true,true];
  Map<String,String> weekDaysList = {
    'monday':'Lunes',
    'tuesday':'Martes',
    'wednesday':'Miercoles',
    'thursday':'Jueves',
    'friday':'Viernes',
    'saturday':'Sabado',
    'sunday':'Domingo',
  };

  updateDayStatus(BookingTime day)async{
    if (await bdConnection.updateBookingTimes(context,day)) {
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

  void _saveForm(BookingTime day) async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
          if (await bdConnection.updateBookingTimes(context, day)) {
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
      _aperturaController.text = '';
      _cierreController.text = '';
      _permitidasController.text = '';
      _slotsController.text = '';
      company=Company();
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
          mainAxisSize: MainAxisSize.min,
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
                      child: Text("Horarios",
                        style: TextStyle(
                          //color: Colors.white,
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
          mobileBody(),
          ],
        ),
      ),
    );
  }

  Widget mobileBody(){
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          const Duration(seconds: 1),
              () {
            setState((){
              firstTime=true;
            });

            // showing snackbar

          },
        );
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FutureBuilder(
          future: bdConnection.getBookingTimes(context,''),
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if(snapshot.data==null){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }else {
              return Padding(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            responsiveApp.setWidth(5)),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            spreadRadius: -6,
                            blurRadius: 8,
                            offset: Offset(0, 0),
                          )
                        ]
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if(!isMobileAndTablet(context))
                                texto(text: "#", size: responsiveApp.setSP(12)),
                              texto(text: "Dia".padRight(11,' '), size: responsiveApp.setSP(12)),
                              texto(text: "Apertura", size: responsiveApp.setSP(
                                  12)),
                              texto(text: "cierre", size: responsiveApp.setSP(12)),
                              texto(text: "reserva", size: responsiveApp.setSP(12)),
                              texto(text: "Acciones", size: responsiveApp.setSP(
                                  12)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Container(height: responsiveApp.setHeight(1),
                                  color: Colors.grey,)),
                          ],
                        ),
                        Column(
                          children: List.generate(snapshot.data.length,
                                  (index) {
                                    allowBooking[index]=snapshot.data[index].status=='enabled'?true:false;
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(
                                          responsiveApp.setWidth(5)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          if(!isMobileAndTablet(context))
                                            texto(text: "${snapshot.data[index].id}",
                                                size: responsiveApp.setSP(12)),
                                          texto(text: weekDaysList[snapshot.data[index].day]!.padRight(10,' '),
                                              size: responsiveApp.setSP(12)),
                                          texto(text: "${snapshot.data[index].start_time}",
                                              size: responsiveApp.setSP(12)),
                                          texto(text: "${snapshot.data[index].end_time}",
                                              size: responsiveApp.setSP(12)),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () {
                                              setState((){
                                                allowBooking[index]= !allowBooking[index];
                                              });
                                              updateDayStatus(
                                                  BookingTime(
                                                    id: snapshot.data[index].id,
                                                    day: snapshot.data[index].day,
                                                    end_time: snapshot.data[index].end_time,
                                                    start_time: snapshot.data[index].start_time,
                                                    slot_duration: snapshot.data[index].slot_duration,
                                                    status: allowBooking[index]?'enabled':'disabled',
                                                    max_booking: snapshot.data[index].max_booking,
                                                    multiple_booking: snapshot.data[index].multiple_booking,
                                                  )
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.decelerate,
                                              width: responsiveApp.setWidth(35),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(
                                                    50.0),
                                                color: allowBooking[index] ? const Color(
                                                    0xff22d88d) : Colors.grey
                                                    .withOpacity(0.6),
                                              ),
                                              child: AnimatedAlign(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                alignment: allowBooking[index]
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                                curve: Curves.decelerate,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      3.0),
                                                  child: Container(
                                                    width: responsiveApp.setWidth(
                                                        15),
                                                    height: responsiveApp.setHeight(
                                                        15),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xffFFFFFF),
                                                      borderRadius: BorderRadius
                                                          .circular(100.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: (){
                                              _aperturaController.text=snapshot.data[index].start_time.toString();
                                              _cierreController.text=snapshot.data[index].end_time.toString();
                                              _slotsController.text=snapshot.data[index].slot_duration.toString();
                                              _permitidasController.text=snapshot.data[index].max_booking.toString();
                                              selectedRepetidos=snapshot.data[index].multiple_booking=='yes'?'Si':'No';
                                              selectedEstado = snapshot.data[index].status=='enabled'?'Activo':'Inactivo';
                                              scheduleActions(snapshot.data[index]);
                                              },
                                            child: Container(
                                                padding: responsiveApp.edgeInsetsApp
                                                    .allSmallEdgeInsets,
                                                decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius
                                                        .circular(
                                                        responsiveApp.setWidth(8))
                                                ),
                                                child: const Icon(
                                                  Icons.edit_note_rounded,
                                                  color: Colors.white,)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                          ),
                        ),
                      ],
                    )
                ),
              );
            }
          }
        ),
      ),
    );
  }

  Future<dynamic> scheduleActions(BookingTime dia){
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          actions: [
            Row(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                    _saveForm(
                      BookingTime(
                        id: dia.id,
                        day: dia.day,
                        end_time: _cierreController.text,
                        start_time: _aperturaController.text,
                        slot_duration: _slotsController.text,
                        status: selectedEstado=='Activo'?'enabled':'disabled',
                        max_booking: _permitidasController.text,
                        multiple_booking: selectedRepetidos,
                      )
                    );
                  },
                  child: Container(
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.save,color: Colors.white,),
                        SizedBox(width: responsiveApp.setWidth(2),),
                        texto(text: 'Guardar', size: responsiveApp.setSP(12),color: Colors.white),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: responsiveApp.setWidth(10),),
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel,color: Colors.white,),
                        SizedBox(width: responsiveApp.setWidth(2),),
                        texto(text: 'Cancelar', size: responsiveApp.setSP(12),color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
          content: SizedBox(
            height: displayHeight(context)*0.7,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          texto(text: 'Editar Horarios', size: responsiveApp.setSP(20)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(height: responsiveApp.setHeight(1),color: Colors.grey,),
                          ),
                        ],
                      ),
                      SizedBox(height: responsiveApp.setHeight(10),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          texto(text: weekDaysList[dia.day]!, size: responsiveApp.setSP(20),fontWeight: FontWeight.w500),
                        ],
                      ),
                      SizedBox(height: responsiveApp.setHeight(10),),
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
                                //enabled: false,
                                readOnly: true,
                                cursorColor: Colors.black,
                                controller: _aperturaController,
                                decoration: const InputDecoration(
                                    labelText: 'Horario de apertura*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    hintText: 'Ej.: 09:00 AM',
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
                                onTap: ()async{
                                  var time = await showTimePicker(
                                      context: ctx,
                                      initialTime: TimeOfDay(
                                          hour: int.parse(_aperturaController.text.split(':')[0]),
                                          minute: int.parse(_aperturaController.text.split(':')[1])));
                                      if (time != null) {
                                    setState(() {
                                      _aperturaController.text = "${time.hour}:${time.minute.toString().padLeft(2,'0')}";
                                    });
                                  }
                                },
                              ),
                            ),
                          ]
                      ),
                      SizedBox(height: responsiveApp.setHeight(10),),
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
                                readOnly: true,
                                cursorColor: Colors.black,
                                controller: _cierreController,
                                decoration: const InputDecoration(
                                    labelText: 'Horario de cierre*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    hintText: 'Ej.: 5:00 PM',
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
                                onTap: ()async{
                                  var time = await showTimePicker(
                                      context: ctx,
                                      initialTime: TimeOfDay(
                                          hour: int.parse(_cierreController.text.split(':')[0]),
                                          minute: int.parse(_cierreController.text.split(':')[1])));
                                  if (time != null) {
                                    setState(() {
                                      _cierreController.text = "${time.hour}:${time.minute.toString().padLeft(2,'0')}";
                                    });
                                  }
                                },
                              ),
                            ),
                          ]
                      ),
                      SizedBox(height: responsiveApp.setHeight(10),),
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
                                controller: _slotsController,
                                decoration: const InputDecoration(
                                    labelText: 'Duración de los slots*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    hintText: 'Ej.: 30 AM',
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
                            SizedBox(width: responsiveApp.setWidth(10),),
                            texto(text: 'Minutos', size: responsiveApp.setSP(12)),
                          ]
                      ),
                      SizedBox(height: responsiveApp.setHeight(10),),
                      texto(text: '¿Permitir varias reservas para la misma fecha y hora?', size: responsiveApp.setSP(12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            border: const Border.fromBorderSide(BorderSide(color: Colors.grey,)),
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(2))),

                        // dropdown below..
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedRepetidos,
                          onChanged: (newValue) {
                            setState((){
                              selectedRepetidos = newValue.toString();
                            });
                          },
                          items: repetidosItems
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
                      SizedBox(height: responsiveApp.setHeight(10),),
                      const Text.rich(
                        TextSpan(
                          text: 'Número máximo de reservas permitidas ',
                          children: [
                            TextSpan(text:'( Poner 0 para un número ilimitado de reservas )',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            )
                          ]
                        )
                      ),
                      SizedBox(height: responsiveApp.setHeight(5),),
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
                                controller: _permitidasController,
                                decoration: const InputDecoration(
                                    labelText: 'Reservas permitidas*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    hintText: 'Ej.: 1,2,3,4...',
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
                      SizedBox(height: responsiveApp.setHeight(10),),
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
                      SizedBox(height: responsiveApp.setHeight(10),),
                    ],
                  )
              ),
            ),
          ),
        )
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
