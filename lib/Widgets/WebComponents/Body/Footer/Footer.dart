
import 'package:flutter/material.dart';
import '../../../../../util/Util.dart';
import '../../../../values/ResponsiveApp.dart';
import '../../../../values/StringApp.dart';
import 'BottomColumn.dart';
import 'InfoText.dart';

class Footer extends StatelessWidget {
  late ResponsiveApp responsiveApp;

  Footer({super.key});

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Container(
      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
      color: Colors.black,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottomColumn(
                heading: aboutUsStr,
                s1: contactUsStr,
                s2: aboutUsStr,
                s3: knowUsUsStr
              ),
              BottomColumn(
                  heading: helpStr,
                  s1: paymentStr,
                  s2: cancellationStr,
                  s3: fAQStr
              ),
              BottomColumn(
                  heading: socialStr,
                  s1: twitterStr,
                  s2: facebookStr,
                  s3: instagramStr
              ),
              Container(
                color: Colors.white,
                width: responsiveApp.dividerVtlWidth,
                height: responsiveApp.dividerVtlHeight,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
                    child: InfoText(
                      type: emailStr,
                      text: AppData().getCompanyData().company_email??'',
                    ),
                  ),
                  InfoText(
                    type: addressStr,
                    text: AppData().getCompanyData().address??'',
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,
            child: Divider(
              color: Colors.white,
              height: responsiveApp.dividerHznHeight,
            ),
          ),
          texto(
            text: copyrightStr,
            color: Colors.white,
            size: responsiveApp.setSP(12)
          ),
        ],
      ),
    );
  }
}
