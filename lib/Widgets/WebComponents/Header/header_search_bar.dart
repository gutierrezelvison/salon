
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../values/ResponsiveApp.dart';

class HeaderSearchBar extends StatefulWidget {
  const HeaderSearchBar({Key? key, this.width , this.keyboardType, this.controller,this.onEditingComplete,this.buttonWidget,required this.onSearchPressed, this.hintText, required this.onChange,this.suffix, this.prefixIcon}) : super(key: key);
  final VoidCallback onSearchPressed;
  final Function(String) onChange;
  final Function()? onEditingComplete;
  final Widget? suffix;
  final Widget? buttonWidget;
  final IconData?  prefixIcon;
  final String? hintText;
  final double? width;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  @override
  State<HeaderSearchBar> createState() => _HeaderSearchBarState();
}

class _HeaderSearchBarState extends State<HeaderSearchBar> {
  late ResponsiveApp responsiveApp;
  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Container(
      margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
      width: widget.width??responsiveApp.setWidth(350),
      height: responsiveApp.setHeight(30),
      padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            //color: Theme.of(context).shadowColor.withOpacity(0.2),
            spreadRadius: -5,
            blurRadius: 7,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
            child: Icon(widget.prefixIcon??Icons.search,color: Colors.grey,size: responsiveApp.setWidth(15),),
          ),
          Expanded(
            child: Padding(
              padding: responsiveApp.edgeInsetsApp.onlySmallBottomEdgeInsets,
              child: TextFormField(
                inputFormatters: widget.keyboardType==TextInputType.number?[FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),]:null,
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText??'Buscar aquí',
                ),
                controller: widget.controller,
                onChanged: (v){
                  widget.onChange(v);
                },
                onEditingComplete: widget.onEditingComplete,
              ),
            ),
          ),
          widget.suffix??const SizedBox(),
          InkWell(
            onTap: widget.onSearchPressed,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius:  BorderRadius.circular(100),
              ),
              child: Padding(
                padding: responsiveApp.edgeInsetsApp.hrzLargeEdgeInsets,
                child: widget.buttonWidget??Text(
                  "Buscar",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
