import 'package:flutter/material.dart';
import '../../../../util/Util.dart';
import '../../../../values/ResponsiveApp.dart';

class BottomColumn extends StatelessWidget {
  final String heading,s1,s2,s3;

  BottomColumn({super.key, 
    required this.heading,
    required this.s1,
    required this.s2,
    required this.s3
  });

  late ResponsiveApp responsiveApp;

  @override
  Widget build(BuildContext context) {
    responsiveApp  = ResponsiveApp(context);
    return Padding(
      padding: responsiveApp.edgeInsetsApp.onlyLargeBottomEdgeInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
          ),
          createS(s1,context),
          createS(s2,context),
          createS(s3,context),
        ],
      ),
    );
  }

  createS(String s, context) {
    return Padding(
      padding: responsiveApp.edgeInsetsApp.onlySmallTopEdgeInsets,
      child: texto(
        text: s,
        size: responsiveApp.setSP(12),
        color: Colors.white
      ),
    );
  }
}
