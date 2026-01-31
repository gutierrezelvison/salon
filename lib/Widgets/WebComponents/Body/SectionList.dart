
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../../../values/ResponsiveApp.dart';
import 'MenuSection.dart';
import 'ProductoSection.dart';
import '../../../util/db_connection.dart';

class SectionListView extends StatefulWidget {
  final AutoScrollController autoScrollController;
  final Function() onUpdate;
  const SectionListView({super.key, required this.onUpdate,required this.autoScrollController});

  @override
  State<SectionListView> createState() => _SectionListViewState();
}

class _SectionListViewState extends State<SectionListView> {
  late ResponsiveApp responsiveApp;

  BDConnection bdConnection = BDConnection();

  @override
  Widget build(BuildContext context) {

    responsiveApp = ResponsiveApp(context);
    return FutureBuilder(
      future: bdConnection.getCategory(context),
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              2,
              (index) {
                return (index == 0)
                    ? Padding(
                  padding: responsiveApp.edgeInsetsApp.allExtraLargeEdgeInsets,
                  child: addScroll(MenuSection(widget.autoScrollController,snapshot.data),0),
                )
                    :Padding(
                  padding: responsiveApp.edgeInsetsApp.allExtraLargeEdgeInsets,
                  child: addScroll(ProductSection(data: snapshot.data[0], onUpdate: () {
                    widget.onUpdate();}),index),
                );
              },
            ),
          );
        }
      },
    );
  }

  addScroll(Widget child,index){
    return AutoScrollTag(
      key: ValueKey(index),
      index: index,
      controller: widget.autoScrollController,
      child: child,

    );
  }
}
