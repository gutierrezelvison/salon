import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:salon/Widgets/Components/custom_calendar.dart';
import '../../util/db_connection.dart';

import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../values/ResponsiveApp.dart';
import '../WebComponents/Body/Container/SectionContainer.dart';

class TimeSelectionWidget extends StatefulWidget {
  const TimeSelectionWidget({Key? key, this.origin,this.onDateTimeSelected}) : super(key: key);

  final String? origin;
  final Function(DateTime)? onDateTimeSelected;

  @override
  State<TimeSelectionWidget> createState() => _TimeSelectionWidgetState();
}

class _TimeSelectionWidgetState extends State<TimeSelectionWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  DateTime _daySelected = DateTime.now();
  String dateTimeSelected = '';
  Alignment _alignment = Alignment.topCenter;
  List<bool> hourSelected = [];
  List daySelectedData = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    responsiveApp =ResponsiveApp(context);
    bdConnection = BDConnection();
    return Column(
      children: [
        Padding(
          padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
          child: SectionContainer(
            title: 'Elija la hora',
            subtitle: '',
            color: Colors.black,
          ),
        ),
        Stack(
          fit: StackFit.loose,
          children: [
            Positioned.fill(
                child: AnimatedAlign(
                  alignment: _alignment,
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: responsiveApp.edgeInsetsApp.onlyLargeBottomEdgeInsets,
                    child: Padding(
                      padding: EdgeInsets.all(responsiveApp.setWidth(15)),
                      child: Container(
                        height: responsiveApp.setHeight(245),
                        width: responsiveApp.setWidth(450),
                        padding: responsiveApp.edgeInsetsApp.onlyLargeTopEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(4)),
                          color: Theme.of(context).cardColor,
                            boxShadow: const[
                              BoxShadow(
                                spreadRadius: -6,
                                blurRadius: 8,
                                offset: Offset(0,1),
                              )
                            ]
                        ),
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.onlyMediumTopEdgeInsets,
                          child: FutureBuilder(
                            future: bdConnection.getBookingTimes(context, _daySelected.weekday.toString()),
                            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                              if (isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if(daySelectedData.isNotEmpty){

                                return Padding(
                                  padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                                  child: AlignedGridView.count(
                                    itemCount: hourSelected.length,
                                    crossAxisCount: 5,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    itemBuilder: (context, index) {
                                      return tiles(
                                          datos: daySelectedData[index], index: index
                                      );
                                    },
                                  ),
                                );
                              }else {
                                return Padding(
                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: responsiveApp.setWidth(250),
                                        child: texto(
                                          alignment: TextAlign.center,
                                          text: '¡No disponible para citas, por favor seleccione otro día!',
                                          size: responsiveApp.setSP(14),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ),
            SizedBox(
                height: isMobileAndTablet(context)? responsiveApp.setHeight(245)*3.2:responsiveApp.setHeight(245)*2.2,
                width: isMobileAndTablet(context)?double.infinity:responsiveApp.setWidth(500),
                child: _buildDateTimePicker()
            ),
          ],
        ),
        SizedBox(height: responsiveApp.setHeight(80),),

        Padding(
          padding: isMobileAndTablet(context)?responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets :responsiveApp.edgeInsetsApp.hrzExtraLargeEdgeInsets,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(widget.origin==null)
              InkWell(
                onTap: (){
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(5))
                  ),
                  child: Padding(
                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_rounded, size: responsiveApp.setWidth(8),color: Colors.white,),
                        SizedBox(width: responsiveApp.setWidth(8),),
                        Text(
                          "Volver",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if(widget.origin!=null)
              InkWell(
                onTap: (){
                  widget.onDateTimeSelected!(DateTime.parse(dateTimeSelected));
                },
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(5))
                  ),
                  child: Padding(
                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                    child: Row(
                      children: [
                        Text(
                          "Finalizar",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if(widget.origin==null)
              InkWell(
                onTap: (){
                  AppData appData = AppData();
                  if(dateTimeSelected!='') {
                    appData.setDatetimeSelected(
                        DateTime.parse(dateTimeSelected));
                    Navigator.of(context).pushNamed("/chair_selection",arguments: dateTimeSelected);
                  }
                },
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                      color: dateTimeSelected!='' ? Colors.black.withOpacity(0.8) : Colors.grey,
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(5))
                  ),
                  child: Padding(
                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                    child: Row(
                      children: [
                        Text(
                          "Siguiente",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                        ),
                        SizedBox(width: responsiveApp.setWidth(8),),
                        Icon(Icons.arrow_forward_ios_rounded, size: responsiveApp.setWidth(8),color: Colors.white,),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsiveApp.setHeight(40),),
      ],
    );
  }

  void _handleDateChanged(DateTime selectedDate) {
    setState(() {
      _alignment = isMobileAndTablet(context) ? Alignment.center : Alignment.bottomCenter;
      _daySelected = selectedDate;
      isLoading = true;
      daySelectedData.clear();
      hourSelected.clear();
      _initializeHourSelectedList();
    });
  }

  void _initializeHourSelectedList() async {
    final query = await bdConnection.getBookingTimes(context, _daySelected.weekday.toString());

    if(query.isNotEmpty) {
      var slotDuration = int.parse(await query.first.slot_duration) / 60;
      var start = (int.parse(query.first.start_time.toString().substring(0, 2)))
          .toDouble();
      var end = (int.parse(query.first.end_time.toString().substring(0, 2)));
      DateTime data;
      while (start < end) {
        data = DateTime(_daySelected.year, _daySelected.month, _daySelected.day,
            start.toInt(), (60 * (start - start.toInt())).toInt());
        daySelectedData.add(data);
        //list.add(TimeOfDay(hour: start.toInt(), minute: (60*(start-start.toInt())).toInt()));
        start = start + slotDuration;
        hourSelected.add(false);
      }
      isLoading = false;
    }else{
      isLoading= false;
    }
  }

  List<dynamic> _horariosDisponibles = [];

  Widget _buildDateTimePicker() {
    return Column(
      children: [
        FutureBuilder(
          future: bdConnection.getBookingTimes(context, _daySelected.weekday.toString()),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Muestra carga mientras se obtiene el horario
            }
            if (!snapshot.hasData || snapshot.data.isEmpty) {
              return const Text("No hay horarios disponibles"); // Evita errores si no hay datos
            }

            _horariosDisponibles = snapshot.data; // Guardamos los horarios disponibles

            return Column(children: [
              Container(
                width: responsiveApp.setWidth(500),
                height: responsiveApp.setHeight(280),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(4)),
                  boxShadow: const [BoxShadow(spreadRadius: -6, blurRadius: 8, offset: Offset(0, 1))],
                ),
                child: CustomCalendar(
                  daySelected: _daySelected,
                  onSelect: (d){
                    _daySelected = d;
                    _handleDateChanged(d);
                  },
                )
              ),
            ]);
          },
        ),
      ],
    );
  }






  Widget tiles({required DateTime datos, required int index}) {
    var outputFormat = DateFormat('dd-MMM-yyyy hh:mm a');
    DateTime now = DateTime.now();

    if (_horariosDisponibles.isEmpty) {
      return const SizedBox(); // No mostrar opciones si no hay horarios configurados
    }

    var horario = _horariosDisponibles.first;
    DateTime horarioInicio = DateTime(datos.year, datos.month, datos.day, int.parse(horario.start_time.substring(0, 2)));
    DateTime horarioFin = DateTime(datos.year, datos.month, datos.day, int.parse(horario.end_time.substring(0, 2)));

    bool dentroDeHorario = datos.isAfter(horarioInicio) && datos.isBefore(horarioFin);
    bool esHoraFutura = datos.isAfter(now) || datos.day != now.day;

    return GridTile(
      child: FutureBuilder(
        future: bdConnection.getFreeChair(context: context, date: datos.toString()),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          bool isAvailable = snapshot.data != null; // Permitir selección incluso si `getFreeChair` devuelve vacío

          return InkWell(
            onTap: () {
              if (isAvailable && dentroDeHorario && esHoraFutura) {
                setState(() {
                  for (int i = 0; i < hourSelected.length; i++) {
                    hourSelected[i] = (i == index);
                  }
                  dateTimeSelected = datos.toString();
                });
              }
            },
            child: Container(
              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: hourSelected[index] ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    outputFormat.format(datos).substring(12, 20),
                    style: TextStyle(
                      fontSize: responsiveApp.setSP(10.5),
                      color: isAvailable && dentroDeHorario && esHoraFutura
                          ? (hourSelected[index] ? Colors.white : Colors.black)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }



}
