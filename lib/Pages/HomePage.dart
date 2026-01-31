import 'package:flutter/material.dart';
import '../Widgets/Components/No_Connection.dart';
import '../util/db_connection.dart';
import 'package:provider/provider.dart';
import '../Widgets/MobileComponets/MenuMobileContainer.dart';
import '../util/Util.dart';
import '../Widgets/Components/Carousel.dart';
import '../Widgets/MobileComponets/ShopAppBar.dart';
import '../Widgets/MobileComponets/ShopDrawer.dart';
import '../Widgets/WebComponents/Body/Footer/Footer.dart';
import '../Widgets/WebComponents/Body/SectionList.dart';
import '../Widgets/WebComponents/Header/Header.dart';
import '../util/Keys.dart';
import '../util/SizingInfo.dart';
import '../util/states/States.dart';
import '../values/ResponsiveApp.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double _scrollPossition = 0;
  double _opacity = 0;
  late AutoScrollController autoScrollController;
  bool _isVisible = false;
  late ResponsiveApp responsiveApp;
  BDConnection bdConnection = BDConnection();
  bool isLoading = true;

  _scrollListener() {
    setState(() {
      _scrollPossition = autoScrollController.position.pixels;
    });
  }
  int cartCan = 0;

  @override
  void initState() {
    Provider.of<BDConnection>(context, listen: false);
    autoScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0,0,0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical);
    autoScrollController.addListener(_scrollListener);
    getCompanyData();
    super.initState();
  }

  getCompanyData()async{
    var query = await bdConnection.getCompanyData(context);
    AppData().setCompanyData(query);

    if(AppData().getCompanyData()!=null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    _opacity      = _scrollPossition < responsiveApp.opacityHeight
                    ?_scrollPossition / responsiveApp.opacityHeight : 1;
    _isVisible    = _scrollPossition >= responsiveApp.menuHeight;
    cartCan = CartState().getCartData().length;
    return Builder(
      builder: (context) {
        if(AppData().getCompanyData()==null){
          if(isLoading){
            return const Center(child: CircularProgressIndicator(),);
          }else {
            return Scaffold(

              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width: isMobileAndTablet(context)?displayWidth(context)*0.7:displayWidth(context)*0.3,
                        height: 300,
                        child: const NoConnectionWidget()),
                    InkWell(
                      onTap: (){
                        setState(() {
                          getCompanyData();
                        });
                      },
                      child: Text("Reintentar"),
                    )
                  ],
                ),
              ),
            );
          }
        }else{
          return SafeArea(
            child: Scaffold(
              key: homeScaffoldKey,
              floatingActionButton: Visibility(
                visible: _isVisible,
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: (){autoScrollController.scrollToIndex(0);},
                  child: const Icon(Icons.arrow_upward, color: Colors.white,),
                ),
              ),
              appBar: isMobileAndTablet(context)
                  ? ShopAppBar(_opacity,'HomePage') : Header('HomePage',_opacity,autoScrollController,cartCan),
              drawer: const ShopDrawer(),
              body: ListView(
                controller: autoScrollController,
                children: [
                  SizedBox(height: responsiveApp.setHeight(10),),
                  const Carousel(),
                  if(isMobileAndTablet(context))SizedBox(height: responsiveApp.setHeight(5),),
                  isMobileAndTablet(context)
                      ? MenuMobileContainer(autoScrollController: autoScrollController,onUpdate:(){
                    setState(() {
                      cartCan = CartState().getCartData().length;
                    });}) : SectionListView(onUpdate:(){
                    setState(() {
                      cartCan = CartState().getCartData().length;
                    });},autoScrollController: autoScrollController),
                  isMobileAndTablet(context)
                      ? const SizedBox.shrink() : Footer(),
                ],
              )
            ),
          );
        }
      }
    );
  }
}