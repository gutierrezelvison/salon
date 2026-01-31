import 'package:flutter/material.dart';

bool isMobile(BuildContext context){
  return MediaQuery.of(context).size.width < tabletSmall;
}

bool isTablet(BuildContext context){
  return MediaQuery.of(context).size.width >= tabletSmall &&
      MediaQuery.of(context).size.width <= tabletExtraLarge;
}

bool isDesktop(BuildContext context){
  return MediaQuery.of(context).size.width < desktopSmall;
}

bool isMobileAndTablet(BuildContext context){
  return MediaQuery.of(context).size.width <= tabletExtraLarge;
}


bool isPortrait(BuildContext context){
  return MediaQuery.of(context).orientation == Orientation.portrait;
}

bool isLandscape(BuildContext context){
  return MediaQuery.of(context).orientation == Orientation.landscape;
}

//Mobile Size
double get mobileSmall=>320;
double get mobileNormal=>375;
double get mobileLarge=>414;
double get mobileExtraLarge=>480;
//Tablet Size
double get tabletSmall=>600;
double get tabletNormal=>768;
double get tabletLarge=>850;
double get tabletExtraLarge=>1280;
//Desktop Size
double get desktopSmall=>950;
double get desktopNormal=>1920;
double get desktopLarge=>3840;
double get desktopExtraLarge=>4096;
