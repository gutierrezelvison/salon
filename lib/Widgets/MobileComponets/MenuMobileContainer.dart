
import 'package:flutter/material.dart';
import '../../Widgets/WebComponents/Body/Container/ProductContainer.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../util/Util.dart';
import '../../../../util/db_connection.dart';
import '../../../../values/ResponsiveApp.dart';
import '../../util/states/States.dart';

class MenuMobileContainer extends StatefulWidget {
   MenuMobileContainer({Key? key, required this.autoScrollController, required this.onUpdate}): super(key: key);
  late AutoScrollController autoScrollController;
   final Function() onUpdate;

  @override
  _MenuMobileContainerState createState() => _MenuMobileContainerState();
}

class _MenuMobileContainerState extends State<MenuMobileContainer> {
  late ResponsiveApp responsiveApp;
  BDConnection bdConnection = BDConnection();
  AppData appData = AppData();
  CartState cartstate = CartState();
  List<bool> isHovering=[];
  double containerHeight = 300;
  bool firstTime = true;

  setContainerHeigh() async{
    List list= await bdConnection.getCategory(context);
    setState(() {
      containerHeight = double.parse(list.length.toString()) * responsiveApp.setHeight(260);
    });
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    if(firstTime){
      setContainerHeigh();
      firstTime=false;
    }
    return Padding(padding: responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets,
      child: FutureBuilder(
          future: bdConnection.getCategory(context),
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }else {
              return Column(
                children: List.generate(
                    snapshot.data.length,
                        (index){
                      return addScroll(section(snapshot,index),index+1);
                    }
                ),
              );
            }
          }
      ),
    );
  }

  Widget section(AsyncSnapshot catSnapshot,int index){
    catSnapshot.data[index].name!='all'?appData.setView('only'):appData.setView('all');
    return Padding(
      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
      child: SizedBox(
        width: displayWidth(context),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                 catSnapshot.data[index].name!='all'?"${catSnapshot.data[index].name}":'Todos',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(
              width: displayWidth(context),
              //height: responsiveApp.productSubContainerHeight +responsiveApp.setHeight(95),
              child: FutureBuilder(
                  future: bdConnection.getServices(context: context,searchBy: 'category_id',id: catSnapshot.data[index].id),
                  builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return const Center(
                        child: LinearProgressIndicator(),
                      );
                    }else {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                              snapshot.data.length,
                                  (index){
                                isHovering.add(false);
                                return Padding(
                                  padding: EdgeInsets.all(responsiveApp.setWidth(8)),
                                  child: ProductContainer(
                                    snapshot.data[index],
                                    onHoverAdd: (v){
                                      isHovering[index]=v;
                                    },
                                    showCategory: false,
                                    addColor: isHovering[index]?Theme.of(context).primaryColor.withOpacity(0.85):Theme.of(context).primaryColor,
                                    onAddPress: (){
                                      Provider.of<CartState>(context,listen: false).setPrefs(context,snapshot.data[index].id,snapshot.data[index].name, 1,double.parse(snapshot.data[index].price!));
                                      widget.onUpdate();
                                      },
                                  ),
                                );
                              },
                          ),
                        ),
                      );
                    }
                  }
              ),
            )
          ],
        ),
      ),
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
