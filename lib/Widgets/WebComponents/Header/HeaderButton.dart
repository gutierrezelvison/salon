import 'package:flutter/material.dart';
import '../../../values/ResponsiveApp.dart';

class HeaderButton extends StatefulWidget {
  String title;
  int index;
  int colorTone;
  bool lineIsVisible;
  VoidCallback ontap;

  HeaderButton(this.colorTone,this.index, this.title,this.ontap,{super.key, this.lineIsVisible = true});

  @override
  State<HeaderButton> createState() => _HeaderButtonState(index);
}

class _HeaderButtonState extends State<HeaderButton> {
  late int index;
  final List _isHovering = [
    false,
    false,
    false
  ];

  late ResponsiveApp responsiveApp;
  _HeaderButtonState(this.index);
  double _width=0;

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return InkWell(
      onHover: (value) {

        setState(() {
          value
              ?_width = responsiveApp.lineHznButtonWidth
              :_width = 0;
          value
              ? _isHovering[index] = true
              : _isHovering[index] = false;
        });
      },
      onTap: widget.ontap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title,
            style: TextStyle(
              fontWeight: _isHovering[index]
                  ? FontWeight.bold
                  : FontWeight.w400,
              color: Colors.blueGrey[widget.colorTone],
            ),
          ),
          const SizedBox(height: 5,),
          Visibility(
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
            visible: widget.lineIsVisible
                ? _isHovering[index]
                : widget.lineIsVisible,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: responsiveApp.lineHznButtonHeight,
              width: _width,
              color: Colors.blueGrey[widget.colorTone]
            ),
          ),
        ],
      ),
    );
  }
}
