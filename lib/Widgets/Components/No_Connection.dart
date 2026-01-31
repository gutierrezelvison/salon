import 'package:flutter/material.dart';
import '../../util/Util.dart';

class NoConnectionWidget extends StatelessWidget {
  const NoConnectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.report,color: Colors.grey.withOpacity(0.5),size: 100,),
        const SizedBox(height: 10,),
        Flexible(child: texto(text: 'No se obtuvo respuesta del servidor.', size: 16,)),
      ]
    );
  }
}
