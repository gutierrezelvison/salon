
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../util/db_connection.dart';
import '../../modelo/Carousel.dart';
import '../../util/SizingInfo.dart';
import '../../values/ResponsiveApp.dart';

class Carousel extends StatefulWidget {
  const Carousel({super.key});


  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final _controller = CarouselSliderController();
  int _current = 0;
  late ResponsiveApp responsiveApp;
  BDConnection bdConnection = BDConnection();

  List <Widget> generateImageTiles () {
    return carousel.map(
      (element) => ClipRRect(
        borderRadius: BorderRadius.circular(responsiveApp.carrouselRadiusWidth),
        child: Image.asset(
          element.image,
          fit: BoxFit.cover,
          height: responsiveApp.carouselContainerHeight,
        ),
      )
    ).toList();
  }

  List <Widget> generateImageTilesFromServer (List list) {
    return list.map(
            (element) => ClipRRect(
          borderRadius: BorderRadius.circular(responsiveApp.carrouselRadiusWidth),
          child: Image.memory(
            element.file_name.bytes,
            fit: BoxFit.cover,
            width: responsiveApp.setWidth(1920),
            height: responsiveApp.carouselContainerHeight,
          ),
        )
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return FutureBuilder(
        future: bdConnection.getCarrousel(context),
        builder: (BuildContext ctx, AsyncSnapshot snapshot){
          if(snapshot.data == null){
            return const Center(child: CircularProgressIndicator(),);
          }else{
            //var imagesFromServer=generateImageTilesFromServer(snapshot.data);
            return Stack(
              children: [
                CarouselSlider(
                  items: snapshot.data.isEmpty ? generateImageTiles() : generateImageTilesFromServer(snapshot.data),
                  options: CarouselOptions(
                    scrollPhysics: isMobileAndTablet(context)
                        ? const PageScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(milliseconds: 10000),
                    autoPlayAnimationDuration: const Duration(milliseconds: 2000),
                    autoPlayCurve: Curves.bounceOut,
                    aspectRatio: 16/8,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                        for(int i = 0; i < carousel.length; i++){
                          carousel[i].isSelected = (i == index) ? true : false;
                        }
                      });
                    },
                  ),
                  carouselController: _controller,
                ),

                isMobileAndTablet(context)
                    ? Container()
                    : Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: responsiveApp.carouselContainerWidth,
                      height: responsiveApp.carouselContainerHeight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          carousel.length,
                              (index) => InkWell(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              _controller.animateToPage(index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: carousel[index].isSelected
                                  ? 35
                                  : responsiveApp.carouselLineContainerWidth,
                              height: responsiveApp.carousellineContainerheight,
                              margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                              decoration: BoxDecoration(
                                  color: carousel[index].isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                  shape: BoxShape.rectangle
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                isMobileAndTablet(context)
                    ? Container()
                    : Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: responsiveApp.carouselContainerWidth,
                      width: responsiveApp.carouselContainerHeight,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: (){
                                setState(() {

                                  _controller.animateToPage(_current>0?_current-1:carousel.length-1);
                                });

                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(5),
                                    boxShadow: const [
                                      BoxShadow(
                                        spreadRadius: -6,
                                        blurRadius: 8,
                                        offset: Offset(0,0),
                                      )
                                    ]
                                ),
                                child: Icon(Icons.arrow_back_ios_rounded, size: 15,color: Theme.of(context).primaryColor,),
                              ),
                            ),
                            const SizedBox(width: 5,),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  _controller.animateToPage(_current<carousel.length-1?_current+1:0);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(5),
                                    boxShadow: const [
                                      BoxShadow(
                                        spreadRadius: -6,
                                        blurRadius: 8,
                                        offset: Offset(0,0),
                                      )
                                    ]
                                ),
                                child: Icon(Icons.arrow_forward_ios_rounded, size: 15,color: Theme.of(context).primaryColor,),
                              ),
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }
    );
  }
}
