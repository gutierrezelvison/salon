import 'package:flutter/material.dart';
import '../util/SizingInfo.dart';
import '../values/EdgeInsetsApp.dart';

class ResponsiveApp{
  final BuildContext _context;
  late MediaQueryData _mediaQueryData;
  late double _textScaleFactor;
  late double _scaleFactor;
  late EdgeInsetsApp edgeInsetsApp;

  ResponsiveApp(this._context) {
    _mediaQueryData = MediaQuery.of(_context);
    _textScaleFactor = _mediaQueryData.textScaleFactor;
    _scaleFactor = isMobile(_context)?1:isTablet(_context)?1.1:1.3;
    edgeInsetsApp = EdgeInsetsApp(this);
  }


  //Container
  get menuContainerHeight => setHeight(90);
  get menuContainerWidth => setWidth(130);
  get productContainerWidth => setWidth(20);
  get productSubContainerHeight => setHeight(120);
  get productContainerHeight => setHeight(250);
  get carouselContainerHeight => setHeight(300);
  get carouselContainerWidth => setWidth(60);
  get carouselLineContainerWidth => setWidth(20);
  get carousellineContainerheight => setHeight(1.5);
  get menuTabContainerheight => setHeight(400);
  get SectionHeight => setHeight(50);
  get sectionWidth => setWidth(8);

  //Rdius
  get menuRadiusWidth => setWidth(30);
  get carrouselRadiusWidth => setWidth(10);

  //Images
  get menuImageHeight => setHeight(60);
  get menuImageWidth => setWidth(50);
  get tabImageHeight => setWidth(30);

  get menuHeight => setHeight(850);
  get opacityHeight => setHeight(252);
  get drawerWidth => setWidth(252);

  //Divider and line
  get dividerVtlHeight => setHeight(100);
  get dividerVtlWidth => setWidth(2);
  get dividerHznHeight => setHeight(1);
  get lineHznButtonHeight => setHeight(2);
  get lineHznButtonWidth => setWidth(20);

  //Spaces
  get barSpace1Width => setWidth(60);
  get barSpace2Width => setWidth(80);

  //Text Size
  get boddyText1 => setSP(12);
  get headLine6 => setSP(15);
  get headLine3 => setSP(30);
  get headLine2 => setSP(40);

  //Spacing
  get letterSpacingCarouselWidth => setWidth(10);
  get letterSpacingHeaderWidth => setWidth(3);

  setWidth(double width) => width * _scaleWidth;
  setHeight(double height) => height * _scaleHeight;

  setSP(double fontSize) => setWidth(fontSize) * _textScaleFactor;

  get _scaleWidth => (width * _scaleFactor) / width;
  get _scaleHeight => (height * _scaleFactor) / height;

  get width => _mediaQueryData.size.width;
  get height => _mediaQueryData.size.height;


}