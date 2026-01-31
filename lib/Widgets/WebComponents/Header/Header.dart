
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon/util/db_connection.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../../../util/states/States.dart';
import '../../../util/Util.dart';
import '../../../util/states/login_state.dart';
import '../../../values/ResponsiveApp.dart';
import '../../../values/StringApp.dart';
import 'HeaderButton.dart';
class ImageFiles{
  String? path;
  String? mimeType;
  String? name;
  int? length;
  Uint8List? bytes;
  DateTime? lastModified;
  Uint8List? extraAppleBookmark;

  ImageFiles({this.path,   this.mimeType,   this.name,   this.length,   this.bytes,   this.lastModified,   this.extraAppleBookmark, });
}
class Header extends StatefulWidget implements PreferredSizeWidget {
  final double opacity;
  String origin;
  final int cartCan;

  Header (this.origin,this.opacity,this.scrollController,this.cartCan, {super.key});
  AutoScrollController scrollController;

  @override
  _HeaderState createState() => _HeaderState();

  @override
  Size get preferredSize  => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  late ResponsiveApp responsiveApp;
  AppData appData = AppData();
  late int colorTone;
  ImageFiles? imageFiles;

  Color invertColor(Color color) => Color.fromARGB(color.alpha, 255 - color.red, 255 - color.green, 255 - color.blue);


  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);

    colorTone = 600 - ((widget.opacity ~/ 0.001) ~/ 100) * 100<100?100:600 - ((widget.opacity ~/ 0.001) ~/ 100) * 100;
    return Consumer<LoginState>(
        builder: (BuildContext context, LoginState value, Widget? child){
        return Consumer<CartState>(
            builder: (BuildContext context, CartState cartState, Widget? child1){
            return Container(
              color: Theme.of(context).primaryColor.withOpacity(widget.opacity),
              height: responsiveApp.setHeight(80),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: (){
                        if(widget.origin!='HomePage'){
                          Navigator.of(context).pop();
                        }
                      },
                      child: ClipPath(
                        clipper: MyClipper(),
                        child: Container(
                          height: responsiveApp.setHeight(80),
                          color: Theme.of(context).primaryColor,
                          padding: responsiveApp.edgeInsetsApp.hrzLargeEdgeInsets,
                          child: Padding(
                            padding: responsiveApp.edgeInsetsApp.onlyLargeRightEdgeInsets,
                            child: Padding(
                              padding: responsiveApp.edgeInsetsApp.onlyLargeLeftEdgeInsets,
                              child: Padding(
                                padding: responsiveApp.edgeInsetsApp.onlyMediumRightEdgeInsets,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [

                                    /*
                                    appData.getCompanyData().logo!='null' && appData.getCompanyData().logo!=null && appData.getCompanyData().logo!=''
                                        ? CachedNetworkImage(
                                       imageUrl:appData.getCompanyData().logo,
                                      height: responsiveApp.setHeight(80),
                                      width: responsiveApp.setWidth(100),
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    )
                                        :Image.asset(
                                      'assets/images/logo.png',
                                      height: responsiveApp.setHeight(80),
                                      width: responsiveApp.setWidth(100),
                                    ),
                                     */

                                  appData.getCompanyData().logo!='null' && appData.getCompanyData().logo!=null && appData.getCompanyData().logo!=''
                                        ? Image.memory(
                                      appData.getCompanyData().logo.bytes,
                                      height: responsiveApp.setHeight(80),
                                      width: responsiveApp.setWidth(100),
                                    )
                                        :Image.asset(
                                      'assets/images/logo.png',
                                      height: responsiveApp.setHeight(80),
                                      width: responsiveApp.setWidth(100),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          /*
                          SizedBox(width: responsiveApp.barSpace1Width,),
                          HeaderButton(colorTone,0, aboutUsStr),
                          SizedBox(width: responsiveApp.barSpace1Width,),
                          HeaderButton(colorTone,1, locationStr),

                           */
                        ],
                      ),
                    ),
                  /*
                  SizedBox(
                    width: responsiveApp.setWidth(350),
                    height: responsiveApp.setHeight(40),
                    child: Navigator(
                      onGenerateRoute: (_) => MaterialPageRoute(
                        builder: (ctx) => HeaderSearchBar(onSearchPressed: () {  }, onChange: (String ) {  },),
                      ),
                    ),
                  ),
                  */
                    SizedBox(width: responsiveApp.sectionWidth,),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        if(widget.origin =='HomePage') {
                          Navigator.of(context).pushNamed("/cartPage");
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Badge(
                            label: Text(widget.cartCan.toString(),style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white,fontSize: responsiveApp.setSP(8)),textAlign: TextAlign.center,),
                            isLabelVisible: widget.cartCan>0,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                                padding: EdgeInsets.all(responsiveApp.setWidth(8)),
                                decoration: BoxDecoration(
                                  color: widget.opacity<=0.6?Theme.of(context).primaryColor:Colors.white,
                                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(3)),
                                ),
                                child: Icon(Icons.shopping_bag_sharp, color: widget.opacity<=0.6?Colors.white:Theme.of(context).primaryColor,size: responsiveApp.setWidth(13),),
                            ),
                          ),

                        ],
                      ),
                    ),
                    SizedBox(width: responsiveApp.sectionWidth,),
                    HeaderButton(colorTone,2,
                      value.isLoggedIn()? '${value.currentUser().name}': loginStr,
                      (){
                        if(value.isLoggedIn()){
                          Provider.of<LoginState>(context,listen: false).gotoHome(false);
                        }else{
                          Navigator.of(context).pushNamed("/Login");
                        }
                      },
                      lineIsVisible: false,
                    ),

                    SizedBox(width: responsiveApp.sectionWidth,),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }
}

