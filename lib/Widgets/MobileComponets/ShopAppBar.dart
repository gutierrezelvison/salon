
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../util/Keys.dart';
import '../../util/Util.dart';
import '../../util/states/States.dart';
import '../../util/states/login_state.dart';
import '../../values/ResponsiveApp.dart';

class ShopAppBar extends StatelessWidget implements PreferredSizeWidget{
  final double opacity;
  String origin;
  ShopAppBar(this.opacity, this.origin, {super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  AppData appData = AppData();
  late ResponsiveApp responsiveApp;
  CartState cartState = CartState();
  String _cartCant = '0';
  late int colorTone;

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    _cartCant = cartState.getCartData().length.toString();
    colorTone = 600 - ((opacity ~/ 0.001) ~/ 100) * 100<100?100:600 - ((opacity ~/ 0.001) ~/ 100) * 100;
    return Consumer<LoginState>(
        builder: (context, loginProvider, child1) {
        return AppBar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(opacity),
          elevation: 0,
          leading: origin!='HomePage'?const SizedBox(): IconButton(
            icon: Icon(Icons.menu_rounded,color:Colors.blueGrey[colorTone]),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: (){
              if(!kIsWeb) {
                loginProvider.isLoggedIn() ? mainScaffoldKey.currentState!.openDrawer()
                    : homeScaffoldKey.currentState!.openDrawer();
              }else{
                homeScaffoldKey.currentState!.openDrawer();
              }
            },
          ),
          centerTitle: true,
          actions: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                if(origin =='HomePage') {
                  Navigator.of(context).pushNamed("/cartPage");
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Badge(
                    label: Text(_cartCant,style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white,fontSize: responsiveApp.setSP(8)),textAlign: TextAlign.center,),
                    isLabelVisible: cartState.getCartData().length>0,
                    child: Container(
                      padding: EdgeInsets.all(responsiveApp.setWidth(8)),
                      decoration: BoxDecoration(
                        color: opacity<=0.6?Theme.of(context).primaryColor:Colors.white,
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(3)),
                      ),
                      child: Icon(Icons.shopping_bag_sharp, color: opacity<=0.6?Colors.white:Theme.of(context).primaryColor,size: responsiveApp.setWidth(13),),
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(width: responsiveApp.sectionWidth,),
          ],
          title: Text(
            AppData().getCompanyData().company_name??'',
            style: TextStyle(
              color: Colors.blueGrey[100],
              fontSize: responsiveApp.headLine6,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
        );
      }
    );
  }


}
