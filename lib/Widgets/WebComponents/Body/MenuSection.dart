
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../util/SizingInfo.dart';
import '../../../util/Util.dart';
import '../../../values/ResponsiveApp.dart';
import '../../../values/StringApp.dart';
import 'Container/MenuContainer.dart';
import 'Container/SectionContainer.dart';

class MenuSection extends StatefulWidget {

  AutoScrollController scrollController;
  List<Categorie> data;
  MenuSection(this.scrollController,this.data, {super.key});

  @override
  State<MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  late ResponsiveApp responsiveApp;
  late Categorie category;
  late AppData appData;

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    appData = AppData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionContainer(
          title: sectionMenuTitleStr,
          subtitle: sectionMenuSubTitleStr,
          color: Colors.black,
        ),
        Padding(
          padding: responsiveApp.edgeInsetsApp.onlyExtraLargeTopEdgeInsets,
          child:
          AlignedGridView.count(
          itemCount: widget.data.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
          crossAxisCount: isMobileAndTablet(context)? (displayWidth(context) * 0.6) ~/ 138.5 :(displayWidth(context) * 0.6) ~/ 138.5,
          mainAxisSpacing: responsiveApp.setWidth(20),
          crossAxisSpacing: responsiveApp.setWidth(20),
          itemBuilder: (context, index) {
            return MenuContainer(
              index: index,
              data: widget.data[index],
              onPress: () {
                widget.data[index].name != 'all'?
                appData.setView('only'):
                appData.setView('all');
                if(widget.data[index].name != 'all') {
                  appData.setCat(widget.data[index].id!);
                }
                scrollIndex(1);
              },
            );
          }
          ),

        ),
      ],
    );
  }

  scrollIndex(index){
    widget.scrollController.scrollToIndex(index);
  }
}
