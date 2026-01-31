import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({required this.onSelect, this.daySelected});
  final Function(DateTime) onSelect;
  final DateTime? daySelected;
  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime today = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,0,0,0);
  DateTime displayedMonth = DateTime.now();
  DateTime _daySelected = DateTime.now();
  int currentYear = DateTime.now().year;

  @override
  void initState() {
    // TODO: implement initState
    _daySelected = widget.daySelected??DateTime.now();
    super.initState();
  }
  final List<String> daysOfWeek = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];

  void _changeMonth(int change) {
    setState(() {
      DateTime newMonth = DateTime(displayedMonth.year, displayedMonth.month + change, 1);
      if (newMonth.isAfter(today) || newMonth.month == today.month) {
        displayedMonth = newMonth;
      }
    });
  }

  void _changeYear(int newYear) {
    if (newYear >= currentYear) {
      setState(() {
        displayedMonth = DateTime(newYear, displayedMonth.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> availableDays = List.generate(
      DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day, // Obtiene la cantidad de días del mes
          (index) => DateTime(displayedMonth.year, displayedMonth.month, index + 1),
    );

    return Container(
      width: 500,
      height: 420,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(spreadRadius: -6, blurRadius: 8, offset: Offset(0, 1))],
      ),
      child: Column(
        children: [
          // 📌 Navegación entre Meses y Años
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded),
                      onPressed: displayedMonth.month > today.month || displayedMonth.year > today.year
                          ? () => _changeMonth(-1)
                          : null, // Deshabilita si el mes anterior es menor que el actual
                    ),

                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                Text(
                  "${DateFormat('MMMM yyyy').format(displayedMonth)}", // Muestra el mes y año actual
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // 📌 Selector de Año
                DropdownButton<int>(
                  value: displayedMonth.year,
                  onChanged: (y)=>_changeYear(y!),
                  items: List.generate(10, (index) => currentYear + index) // 10 años disponibles
                      .map((year) => DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
          // 📌 Fila de Días de la Semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek.map((day) => Text(day,)).toList(),
          ),

          // 📌 Sección de Días en Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 columnas para los días de la semana
                childAspectRatio: 1.5, // Ajusta proporción de cada celda
              ),
              itemCount: availableDays.length,
              itemBuilder: (context, index) {
                DateTime date = availableDays[index];
                bool isToday = date.day == today.day && date.month == today.month && date.year == today.year;
                bool isSelected = _daySelected.day == date.day && _daySelected.month == date.month && _daySelected.year == date.year;
                bool isPast = date.isBefore(today);

                return InkWell(
                  onTap: isPast ? null : () {
                    widget.onSelect(date);
                    /*
                    setState(() {
                      _daySelected = date;
                    });
                     */
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat('d').format(date),
                      style: TextStyle(
                        fontSize: 14,
                        color: isPast ? Colors.grey : isSelected ? Colors.white : Colors.black, // Día pasado en gris
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
