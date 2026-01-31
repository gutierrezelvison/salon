
import 'package:flutter/material.dart';
import '../../../util/Util.dart';
import '../../../values/ResponsiveApp.dart';
import '../../Components/ProductListView.dart';
import 'Container/SectionContainer.dart';

class ProductSection extends StatefulWidget {
  final Categorie? data;
  final Function() onUpdate;

  const ProductSection({super.key, this.data, required this.onUpdate});

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  late ResponsiveApp responsiveApp;

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: responsiveApp.edgeInsetsApp.onlyLargeBottomEdgeInsets,
          child: SectionContainer(
            title: 'Servicios',
            subtitle: 'SERVICIOS',
            color: Colors.red,
          ),
        ),
        ProductListView(widget.data!, onUpdate:(){
          widget.onUpdate();}),
      ],
    );
  }
}
