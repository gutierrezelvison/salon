import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../util/Util.dart';


class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({super.key, required this.values,
    required this.labels, required this.width, required this.height});
  final List<double> values;
  final List<String> labels;
  final double width;
  final double height;

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  static int touchedIndex = -1;
  late Color randomColor;
  List<Color> colors = [
    const Color(0xff22d88d),
    const Color(0xffff914d),
    const Color(0xff4c4cff),
    const Color(0xfffd4f4f),
    const Color(0xff5c6bc0),
    const Color(0xff2196f3),
    const Color(0xffe91e63),
    const Color(0xff8bc34a),
    const Color(0xfffbc02d),
    const Color(0xff9e9e9e),
    const Color(0xff673ab7),
    const Color(0xff00bcd4),
    const Color(0xffcddc39),
    const Color(0xffc62828),
    const Color(0xff2196f3),
    const Color(0xff009688),
    const Color(0xff4caf50),
    const Color(0xff9c27b0),
    const Color(0xff8bc34a),
    const Color(0xfff44336),
    const Color(0xff673ab7),
    const Color(0xffe91e63),
    const Color(0xff009688),
    const Color(0xff795548),
    const Color(0xff4caf50),
    const Color(0xffcddc39),
    const Color(0xff9e9e9e),
    const Color(0xff2196f3),
    const Color(0xffc62828),
    const Color(0xff00bcd4),
    const Color(0xff8d6e63),
    const Color(0xff8bc34a),
    const Color(0xff673ab7),
    const Color(0xffe91e63),
    const Color(0xff4caf50),
    const Color(0xff9c27b0),
    const Color(0xff009688),
    const Color(0xffcddc39),
    const Color(0xff2196f3),
    const Color(0xfff44336),
    const Color(0xff673ab7),
    const Color(0xff00bcd4),
    const Color(0xff8d6e63),
    const Color(0xffc62828),
    const Color(0xff9e9e9e),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Row(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio:1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {

                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 60,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    Random random = Random();

    return List.generate(widget.values.length, (i) {
      randomColor = colors[random.nextInt(colors.length)];
      final isTouched = i == touchedIndex;
      var res = 0.0;
      final total = widget.values.fold(res, (a, b) => res = a+b);
      final fontSize = isTouched ? 18.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
            return PieChartSectionData(
            color: colors[i % colors.length],
            value: widget.values[i],
            title: '',
            badgeWidget: isTouched?Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    //color: const Color(0xff6C9BD2).withOpacity(0.3),
                    spreadRadius: -5,
                    blurRadius: 8,
                    offset:
                    Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  texto(text:'${(widget.values[i]*100)~/total}%',size: 12,fontWeight: FontWeight.bold),
                  Text(widget.labels[i]),
                ],
              ),
            ):null,
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              //color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );

    });
  }
}