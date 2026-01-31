
import 'package:flutter/material.dart';

import '../../modelo/Menu.dart';
import '../../values/ResponsiveApp.dart';
class MenuTap extends StatefulWidget {
  const MenuTap({super.key});


  @override
  _MenuTapState createState() => _MenuTapState();
}

class _MenuTapState extends State<MenuTap> with TickerProviderStateMixin {
  late TabController _controller;
  late ResponsiveApp responsiveApp;
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    _controller = TabController(length: menu.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return SizedBox(
      height: responsiveApp.menuTabContainerheight,
      child: Padding(
        padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
        child: Column(
          children: <Widget> [
            TabBar(
              onTap: (index){
                setState(() {
                  _selectedIndex = index;
                });
              },
              controller: _controller,
              tabs: List.generate(
                menu.length,
                  (index) => createTab(
                    index,
                    menu[index].title,
                    menu[index].image,
                    context,
                  ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: const <Widget> [
                  /*
                  ProductListView(coffeeList),
                  ProductListView(drinkList),
                  ProductListView(cakeList),
                  ProductListView(sandwichesList),

                   */
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  createTab(int index, String text, String image, BuildContext context){
    return Tab(
      text: text,
      icon: Image.asset(
        image,
        color: _selectedIndex==index? Theme.of(context).iconTheme.color: Theme.of(context).unselectedWidgetColor,
        fit: BoxFit.fill,
        height: responsiveApp.tabImageHeight,
      ),
    );
  }
}
