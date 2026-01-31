import 'package:flutter/material.dart';
import '../../../../util/Util.dart';
import '../../../../util/states/States.dart' show CartState;
import '../../../../values/ResponsiveApp.dart';

class ProductContainer extends StatelessWidget {
  late Service product;
  final onHoverAdd;
  final onPress;
  final onAddPress;
  Color addColor;
  bool? showCategory;
  bool? showQuantity;
  late CartState cartState;
  ProductContainer(this.product, {super.key, this.showQuantity,this.showCategory ,this.onPress,this.onAddPress,this.onHoverAdd,required this.addColor});

  late ResponsiveApp responsiveApp;
  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    cartState = CartState();
    return GridTile(
      child: Container(
        width: responsiveApp.setWidth(138),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(responsiveApp.carrouselRadiusWidth),
          boxShadow: const [
            BoxShadow(
              spreadRadius: -7,
              blurRadius: 8,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: responsiveApp.setWidth(150),
              height: responsiveApp.productSubContainerHeight,
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(responsiveApp.carrouselRadiusWidth)),
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(responsiveApp.carrouselRadiusWidth)),
                            child: product.image !=null && product.image!!=''
                                ? Image.memory(product.image!.bytes!,
                                  fit: BoxFit.fill,
                              height: responsiveApp.productSubContainerHeight,
                                ): Image.asset('assets/images/No_image.jpg',fit: BoxFit.fill,height: responsiveApp.productSubContainerHeight,)
                        ),
                      ),
                    ],
                  ),
                  Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(responsiveApp.carrouselRadiusWidth)),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          )
                        ),
                      )
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        child: Container(
                          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(20)),
                            //shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.5)
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer_outlined, size: responsiveApp.setWidth(15),color: Colors.black87,),
                              SizedBox(width: responsiveApp.setWidth(5),),
                              texto(
                                text: "${product.time!.split('.')[0]} ${product.time_type!.substring(0,1)}",
                                size: responsiveApp.setSP(11),
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if(showCategory??true)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        child: Container(
                          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5))
                          ),
                          child: Padding(
                            padding: responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets,
                            child: Text(
                              "${product.category_name}",
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight:  FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: responsiveApp.edgeInsetsApp.onlySmallLeftEdgeInsets,
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: responsiveApp.edgeInsetsApp.onlyMediumTopEdgeInsets,
                      child: Text(
                        product.name!,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.black.withValues(alpha: 0.9)),
                      ),
                    ),
                  ),
                if(showQuantity??false)
                Padding(
                    padding: responsiveApp.edgeInsetsApp.onlyMediumTopEdgeInsets,
                    child: Padding(
                        padding: responsiveApp.edgeInsetsApp.onlyMediumRightEdgeInsets,
                      child: Text.rich(
                        TextSpan(text:product.quantity.toString(),
                          style: Theme.of(context).textTheme.labelLarge!,
                          children: <TextSpan>[
                            TextSpan(text:" Uni",
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.black.withValues(alpha: 0.9)),),
                          ]
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: responsiveApp.edgeInsetsApp.onlySmallRightEdgeInsets,
              child: Padding(
                padding: responsiveApp.edgeInsetsApp.onlySmallLeftEdgeInsets,
                child: Padding(
                  padding: responsiveApp.edgeInsetsApp.onlyMediumTopEdgeInsets,
                  child: Padding(
                    padding: responsiveApp.edgeInsetsApp.onlySmallBottomEdgeInsets,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                              text: 'RD\$',
                              style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: responsiveApp.setSP(12),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: ' ${product.discount_type=='percent'? double.parse(product.price!)-(double.parse(product.price!)*(double.parse(product.discount!)/100)):double.parse(product.price!)-double.parse(product.discount!)}',
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black,fontSize: responsiveApp.setSP(14)),
                                ),
                              ],
                            ),
                            ),
                            if(double.parse(product.discount!)> 0)
                            Text.rich(
                              TextSpan(
                                text: ' ${double.parse(product.price!)}',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(decoration: TextDecoration.lineThrough, decorationColor: Colors.red ,color: Colors.red,fontSize: responsiveApp.setSP(10)),
                              ),
                            )
                          ],
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onHover: onHoverAdd,
                          onTap: onAddPress,
                          child: Container(
                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            decoration: BoxDecoration(
                                color: addColor,
                                //borderRadius: BorderRadius.circular(100),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  spreadRadius: -7,
                                  blurRadius: 6,
                                  offset: Offset(0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                              child: const Icon(Icons.add,color: Colors.white,),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
