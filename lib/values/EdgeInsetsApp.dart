
import 'package:flutter/material.dart';

import 'ResponsiveApp.dart';

class EdgeInsetsApp{
  //Todo
  late EdgeInsets allSmallEdgeInsets;
  late EdgeInsets allMediumEdgeInsets;
  late EdgeInsets allLargeEdgeInsets;
  late EdgeInsets allExtraLargeEdgeInsets;
  //Vertical
  late EdgeInsets vrtSmallEdgeInsets;
  late EdgeInsets vrtMediumEdgeInsets;
  late EdgeInsets vrtLargeEdgeInsets;
  late EdgeInsets vrtExtraLargeEdgeInsets;
  //Horizontal
  late EdgeInsets hrzSmallEdgeInsets;
  late EdgeInsets hrzMediumEdgeInsets;
  late EdgeInsets hrzLargeEdgeInsets;
  late EdgeInsets hrzExtraLargeEdgeInsets;
  //Solo derecha, Izquierda, Arriba y abajo Small
  late EdgeInsets onlySmallTopEdgeInsets;
  late EdgeInsets onlySmallBottomEdgeInsets;
  late EdgeInsets onlySmallRightEdgeInsets;
  late EdgeInsets onlySmallLeftEdgeInsets;
  //Solo derecha, Izquierda, Arriba y abajo Medium
  late EdgeInsets onlyMediumTopEdgeInsets;
  late EdgeInsets onlyMediumBottomEdgeInsets;
  late EdgeInsets onlyMediumRightEdgeInsets;
  late EdgeInsets onlyMediumLeftEdgeInsets;
  //Solo derecha, Izquierda, Arriba y abajo Large
  late EdgeInsets onlyLargeTopEdgeInsets;
  late EdgeInsets onlyLargeBottomEdgeInsets;
  late EdgeInsets onlyLargeRightEdgeInsets;
  late EdgeInsets onlyLargeLeftEdgeInsets;

  //Solo arriba y abajo extralare
  late EdgeInsets onlyExtraLargeTopEdgeInsets;
  late EdgeInsets onlyExtraLargeBottomEdgeInsets;
  late EdgeInsets onlyExtraLargeRightEdgeInsets;
  late EdgeInsets onlyExtraLargeLeftEdgeInsets;

  late final ResponsiveApp _responsiveApp;

  EdgeInsetsApp(this._responsiveApp){
    //Padding
    double smallHeightEdgeInsets = _responsiveApp.setHeight(5);
    double smallWidthEdgeInsets = _responsiveApp.setWidth(5);

    double mediumHeightEdgeInsets = _responsiveApp.setHeight(10);
    double mediumWidthEdgeInsets = _responsiveApp.setWidth(10);

    double largeHeightEdgeInsets = _responsiveApp.setHeight(20);
    double largeWidthEdgeInsets = _responsiveApp.setWidth(20);

    double extraLargeHeightEdgeInsets = _responsiveApp.setHeight(100);
    double extraLargeWidthEdgeInsets = _responsiveApp.setWidth(100);

    //Todo
    allSmallEdgeInsets = EdgeInsets.symmetric(horizontal: smallWidthEdgeInsets ,vertical: smallHeightEdgeInsets);
    allMediumEdgeInsets = EdgeInsets.symmetric(horizontal: mediumWidthEdgeInsets ,vertical: mediumHeightEdgeInsets);
    allLargeEdgeInsets = EdgeInsets.symmetric(horizontal: largeWidthEdgeInsets ,vertical: largeHeightEdgeInsets);
    allExtraLargeEdgeInsets = EdgeInsets.symmetric(horizontal: extraLargeWidthEdgeInsets ,vertical: extraLargeHeightEdgeInsets);
    //Vertical
    vrtSmallEdgeInsets = EdgeInsets.symmetric(vertical: smallHeightEdgeInsets);
    vrtMediumEdgeInsets = EdgeInsets.symmetric(vertical: mediumHeightEdgeInsets);
    vrtLargeEdgeInsets = EdgeInsets.symmetric(vertical: largeHeightEdgeInsets);
    vrtExtraLargeEdgeInsets = EdgeInsets.symmetric(vertical: extraLargeHeightEdgeInsets);
    //Horiizontal
    hrzSmallEdgeInsets = EdgeInsets.symmetric(horizontal: smallWidthEdgeInsets);
    hrzMediumEdgeInsets = EdgeInsets.symmetric(horizontal: mediumWidthEdgeInsets);
    hrzLargeEdgeInsets = EdgeInsets.symmetric(horizontal: largeWidthEdgeInsets);
    hrzExtraLargeEdgeInsets = EdgeInsets.symmetric(horizontal: extraLargeWidthEdgeInsets);
    //Solo derecha, Izquierda, Arriba y abajo Small
    onlySmallTopEdgeInsets = EdgeInsets.only(top: smallHeightEdgeInsets);
    onlySmallBottomEdgeInsets = EdgeInsets.only(bottom: smallHeightEdgeInsets);
    onlySmallLeftEdgeInsets = EdgeInsets.only(left: smallWidthEdgeInsets);
    onlySmallRightEdgeInsets = EdgeInsets.only(right: smallWidthEdgeInsets);
    //Solo derecha, Izquierda, Arriba y abajo Medium
    onlyMediumTopEdgeInsets = EdgeInsets.only(top: mediumHeightEdgeInsets);
    onlyMediumBottomEdgeInsets = EdgeInsets.only(bottom: mediumHeightEdgeInsets);
    onlyMediumLeftEdgeInsets = EdgeInsets.only(left: mediumWidthEdgeInsets);
    onlyMediumRightEdgeInsets = EdgeInsets.only(right: mediumWidthEdgeInsets);
    //Solo derecha, Izquierda, Arriba y abajo Large
    onlyLargeTopEdgeInsets = EdgeInsets.only(top: largeHeightEdgeInsets);
    onlyLargeBottomEdgeInsets = EdgeInsets.only(bottom: largeHeightEdgeInsets);
    onlyLargeLeftEdgeInsets = EdgeInsets.only(left: largeWidthEdgeInsets);
    onlyLargeRightEdgeInsets = EdgeInsets.only(right: largeWidthEdgeInsets);
    //Solo derecha, Izquierda, Arriba y abajo Large
    onlyExtraLargeTopEdgeInsets = EdgeInsets.only(top: extraLargeHeightEdgeInsets);
    onlyExtraLargeBottomEdgeInsets = EdgeInsets.only(bottom: extraLargeHeightEdgeInsets);
    onlyExtraLargeRightEdgeInsets = EdgeInsets.only(right: extraLargeWidthEdgeInsets);
    onlyExtraLargeLeftEdgeInsets = EdgeInsets.only(left: extraLargeWidthEdgeInsets);
  }
}