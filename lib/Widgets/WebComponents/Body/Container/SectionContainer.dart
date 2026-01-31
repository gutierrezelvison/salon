
import 'package:flutter/material.dart';

import '../../../../values/ResponsiveApp.dart';

class SectionContainer extends StatelessWidget {
  SectionContainer({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.color, Widget? child,
  }) : super(key: key);

  final String title,subtitle;
  final Color color;
  Widget? child;
  late ResponsiveApp responsiveApp;

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);

    return SizedBox(
      width: responsiveApp.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey,fontWeight: FontWeight.w400),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500,color: Colors.black.withOpacity(0.8))
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: responsiveApp.setWidth(40),
                    height: responsiveApp.setHeight(1),
                    color: Colors.blueGrey,
                  ),
                  Icon(Icons.location_on,color: Colors.blueGrey,size: responsiveApp.setWidth(15),),
                  Container(
                    width: responsiveApp.setWidth(40),
                    height: responsiveApp.setHeight(1),
                    color: Colors.blueGrey,
                  )
                ],
              ),
              child??const SizedBox(),
            ],
          )
        ],
      ),
    );
  }
}
