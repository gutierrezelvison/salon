
import 'package:flutter/material.dart';
import '../../../../util/Util.dart';

class InfoText extends StatelessWidget {
  final String type, text;

  const InfoText({super.key, required this.text,required this.type});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        texto(
          text: type,
          color: Colors.white,
          size: 14,
        ),
        texto(
          text: text,
          color: Colors.white,
          size: 12,
        ),
      ],
    );
  }
}
