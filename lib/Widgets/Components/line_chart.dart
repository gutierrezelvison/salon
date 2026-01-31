import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../util/SizingInfo.dart';
import '../../util/Util.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({
    super.key,
    required this.maxX,
    required this.ventas,
    required this.xTiles,
    required this.maxY,
    required this.period,
  });

  final String period;
  final int maxX;
  final double maxY;
  final List<FlSpot> ventas;
  final List<String> xTiles;

  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    const Color(0xff22d88d),
    const Color(0xff13e9d1),
  ];

  List<Color> gradientColors2 = [];
  bool cargando = true;
  late List<double> ventasReducidas;

  @override
  void initState() {
    super.initState();


    // Simular carga para que la UI no se congele
    Future.delayed(const Duration(milliseconds: 100), () {
      //ventasReducidas = reducirDatos(widget.ventas);
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    });
  }

  List<String> month = [
    '01','02','03','04','05','06','07','08','09','10','11','12',
    '13','14','15','16','17','18','19','20','21','22','23','24',
    '25','26','27','28','29','30','31'
  ];

  // Agrupar los datos en bloques si son demasiados
  List<double> reducirDatos(List<double> ventas) {
    const maxPuntos = 30; // máximo número de puntos a mostrar
    if (ventas.length <= maxPuntos) return ventas;

    final paso = (ventas.length / maxPuntos).ceil();
    List<double> resultado = [];

    for (int i = 0; i < ventas.length; i += paso) {
      final grupo = ventas.sublist(i, (i + paso).clamp(0, ventas.length));
      final promedio = grupo.reduce((a, b) => a + b) / grupo.length;
      resultado.add(promedio);
    }

    return resultado;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,//Color(0xff68737d),
      //fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    if((widget.maxX<=daysInMonth(DateTime.now().month) && (widget.maxX<=5?(value.toInt()>0 && (value.toInt()+1) % 1 == 0):widget.maxX>5&&widget.maxX<=10?(value.toInt()>0 && (value.toInt()+1) % 2 == 0):(value.toInt()>0 && (value.toInt()+1) % 3 == 0)))){
      text= Text(month[value.toInt()],style: style);
    }else{
      text= const SizedBox();
    }

    return SideTitleWidget(
      space: 8.0,
      meta: meta,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,//Color(0xff67727d),
      //fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    int len = widget.maxY.toInt().toString().length;
    String numS = widget.maxY.toInt().toString().substring(0,1).padRight(len,'0');
    double num = widget.maxY>0? double.parse(((widget.maxY.toInt() + (widget.maxY * 0.1))/int.parse(numS)).round().toString().padRight(len,'0')):0;
    String text;
    if(value.toInt() % (isMobileAndTablet(context)?num*0.80:num*0.50) == 0){
      text =  '${value.toDouble().round().toInt()}';
    }else{
      return const SizedBox();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }



  @override
  Widget build(BuildContext context) {
    if (gradientColors2.isEmpty) {
      gradientColors2.add(const Color(0xff22d88d));
      gradientColors2.add(Theme.of(context).cardColor);
    }

    return AspectRatio(
      aspectRatio: 1.8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: cargando
            ? const Center(child: CircularProgressIndicator())
            : LineChart(mainData()),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:  AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles:  AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: 1,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < widget.xTiles.length) {
                return RotatedBox(quarterTurns: 3,child: Text(widget.xTiles[index], style: TextStyle(fontSize: 10)));
              }
              return Text('');
            },
          ),
        ),

      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: widget.xTiles.length.toDouble() - 1,
      minY: 0,
      lineBarsData: [
        LineChartBarData(
          spots: widget.ventas,

          /*ventasReducidas
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value))
              .toList(),
           */
          isCurved: true, // mejora rendimiento
          preventCurveOverShooting: true,
          gradient: LinearGradient(
            colors: gradientColors
                .map((color) => color.withOpacity(0.3))
                .toList(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          barWidth: 3,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: true,
          gradient: LinearGradient(
            colors: gradientColors2
                .map((color) => color.withOpacity(0.3))
                .toList(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          ), // evita sombreado
        ),
      ],
    );
  }
}
