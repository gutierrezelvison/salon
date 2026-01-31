import 'package:flutter/material.dart';
import '../util/states/States.dart';
import '../Widgets/Components/WebCart.dart';
import '../Widgets/MobileComponets/ShopAppBar.dart';
import '../Widgets/MobileComponets/ShopDrawer.dart';
import '../Widgets/WebComponents/Body/Footer/Footer.dart';
import '../Widgets/WebComponents/Header/Header.dart';
import '../util/Keys.dart';
import '../util/SizingInfo.dart';
import '../util/Util.dart';
import '../values/ResponsiveApp.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});


  @override
  State<CartPage> createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  double _scrollPossition = 0;
  double _opacity = 0;
  AppData  appData = AppData();
  late AutoScrollController autoScrollController;
  bool _isVisible = false;
  late ResponsiveApp responsiveApp;

  _scrollListener() {
    setState(() {
      _scrollPossition = autoScrollController.position.pixels;
    });
  }

  @override
  void initState() {

    autoScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0,0,0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical);
    autoScrollController.addListener(_scrollListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    _opacity      = _scrollPossition < responsiveApp.opacityHeight
                    ?_scrollPossition / responsiveApp.opacityHeight : 1;
    _isVisible    = _scrollPossition >= responsiveApp.menuHeight;

    return Scaffold(
      key: cartScaffoldKey,
      floatingActionButton: Visibility(
        visible: _isVisible,
        child: FloatingActionButton(
          onPressed: (){autoScrollController.scrollToIndex(0);},
          child: const Icon(Icons.arrow_upward),
        ),
      ),
      appBar: isMobileAndTablet(context)
          ? ShopAppBar(_opacity,'CartPage') : Header(
          'CartPage',_opacity,autoScrollController, CartState().getCartData().length),
      drawer: const ShopDrawer(),
      body: ListView(
        controller: autoScrollController,
        children: [
          WebCart(onUpdate: (){setState(() {
          });},),
          isMobileAndTablet(context)
              ? const SizedBox.shrink() : Footer(),
        ],
      ),
    );
  }
}