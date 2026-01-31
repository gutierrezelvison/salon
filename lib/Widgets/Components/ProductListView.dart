
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../Widgets/WebComponents/Body/Container/ProductContainer.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../util/db_connection.dart';
import '../../util/states/States.dart';
import '../../values/ResponsiveApp.dart';

class ProductListView extends StatefulWidget {
  final Categorie category;
  final Function() onUpdate;
  const ProductListView(this.category, {super.key, required this.onUpdate});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  BDConnection bdConnection=BDConnection();

  AppData appData = AppData();

  late ResponsiveApp responsiveApp;

  late CartState cartState;

  List<bool> isHovering=[];

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    cartState = CartState();
    return FutureBuilder(
      future: bdConnection.getServices(context: context,searchBy: 'category_id',id: appData.getCat()),
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return SizedBox(
            width: displayWidth(context)*0.9,
            height: displayHeight(context)*0.7,
            child: Stack(
              children: [
                AlignedGridView.count(
                  itemCount: snapshot.data.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
                  crossAxisCount: isMobileAndTablet(context)? (displayWidth(context) * 0.6) ~/ 138.5 :(displayWidth(context) * 0.6) ~/ 138.5,
                  mainAxisSpacing: responsiveApp.setWidth(20),
                  crossAxisSpacing: responsiveApp.setWidth(20),
                  itemBuilder: (context, index) {
                    isHovering.add(false);
                    return ProductContainer(
                      snapshot.data[index],
                      onHoverAdd: (v){
                          isHovering[index]=v;
                      },
                      addColor: isHovering[index]?Theme.of(context).primaryColor.withOpacity(0.85):Theme.of(context).primaryColor,
                      onAddPress: (){
                        setState(() {
                          Provider.of<CartState>(context,listen: false).setPrefs(context,snapshot.data[index].id,snapshot.data[index].name, 1,double.parse(snapshot.data[index].price!));

                        });
                        widget.onUpdate();
                      },
                    );
                  },
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: (){
                        Navigator.of(context).pushNamed("/selectTime");
                      },
                      child: Container(
                        width: responsiveApp.setWidth(100),
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5))
                        ),
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Elija la hora",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: responsiveApp.dividerVtlWidth,),
                              Icon(Icons.arrow_forward_ios_rounded, size: responsiveApp.setWidth(8),color: Colors.white,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
