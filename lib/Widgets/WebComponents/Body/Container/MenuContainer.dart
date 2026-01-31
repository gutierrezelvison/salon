
import 'package:flutter/material.dart';

import '../../../../util/Util.dart';
import '../../../../util/db_connection.dart';
import '../../../../values/ResponsiveApp.dart';

class MenuContainer extends StatefulWidget {
  const MenuContainer({Key? key, required this.index,required this.data, this.onPress}) : super(key: key);

  final Categorie data;
  final int index;
  final onPress;
  @override
  _MenuContainerState createState() => _MenuContainerState();
}

class _MenuContainerState extends State<MenuContainer> {
  late ResponsiveApp responsiveApp;
  BDConnection bdConnection = BDConnection();
  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Padding(padding: responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets,
      child: InkWell(
        onTap: () => widget.onPress(),
        child: Container(
          width: responsiveApp.menuContainerWidth,
          height: responsiveApp.menuContainerHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(Radius.circular(responsiveApp.carrouselRadiusWidth)),
              shape: BoxShape.rectangle,
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(responsiveApp.carrouselRadiusWidth)),
                        child: widget.data.image !=null && widget.data.image!=''
                            ? widget.data.image!.name !='blanco.jpeg'?Image.memory(widget.data.image!.bytes!,
                              fit: BoxFit.fill,width: responsiveApp.menuContainerWidth,
                          height: responsiveApp.menuContainerHeight,
                            ):Image.asset('assets/images/blanco.jpeg',fit: BoxFit.fill,width: responsiveApp.menuContainerWidth,
                          height: responsiveApp.menuContainerHeight,): Image.asset('assets/images/No_image.jpg',fit: BoxFit.fill,width: responsiveApp.menuContainerWidth,
                          height: responsiveApp.menuContainerHeight,)
                    ),
                  ),
                ],
              ),
              Container(
                width: responsiveApp.menuContainerWidth,
                height: responsiveApp.menuContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.80),
                  borderRadius: BorderRadius.all(Radius.circular(responsiveApp.carrouselRadiusWidth)),
                ),
              ),
              Center(
                child: Text(
                  widget.data.name!='all'?"${widget.data.name}":'Todos',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }
}
