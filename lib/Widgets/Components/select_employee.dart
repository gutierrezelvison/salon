import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:salon/util/Util.dart';
import 'package:salon/util/db_connection.dart';
import 'package:salon/values/ResponsiveApp.dart';

import '../../util/SizingInfo.dart';
import '../WebComponents/Body/Container/SectionContainer.dart';

class SelectEmployee extends StatelessWidget {

  SelectEmployee({super.key,required this.onSelect});
  final Function(Chairs) onSelect;

  late ResponsiveApp responsiveApp;
  BDConnection bdConnection = BDConnection();
  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Scaffold(
      body: Padding(
        padding: responsiveApp.edgeInsetsApp.hrzExtraLargeEdgeInsets,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
              child: SectionContainer(
                title: 'Elija la silla',
                subtitle: '',
                color: Colors.black,
              ),
            ),
            FutureBuilder(
              future: bdConnection.getData(onError: (String ) {  },
                fields: ''' 
              users.group_id, users.name, 
    users.image, users.id,
    roles.display_name AS 'rol_name', employee_groups.name AS 'group_name', roles.id AS 'rol_id',
    chairs.id AS chair_id, chairs.chair_name AS chair_name, chairs.color AS chair_color
              ''',
                order: 'ASC',
                orderBy: 'users.id' ,
                groupBy: ' users.id ',
                where: '''
     role_user.role_id<>3 AND users.deleted=0
              ''',
                table: ''' 
              users 
    INNER JOIN role_user ON users.id = role_user.user_id 
    INNER JOIN roles ON role_user.role_id = roles.id 
    INNER JOIN employee_groups ON users.group_id = employee_groups.id 
    INNER JOIN chairs ON users.id = chairs.employee_id 
              ''',
                context: context,

              ),
              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.data.isEmpty) {
                  return texto(
                    text: '¡No hay sillas disponibles en este horario!',
                    size: responsiveApp.setSP(14),
                  );
                } else {
                  return Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(responsiveApp.setWidth(10)),
                        child: Wrap(
                          children: List.generate(snapshot.data.length, (index){
                            return buildChairTile(snapshot.data[index],index);
                          })
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget buildChairTile(data, int index) {
    return InkWell(
      onTap: () => onSelect(
        Chairs(
          chair_id: int.parse(data['chair_id']),
          color: data['chair_color'],
          chair_name: data['chair_name'],
          employee_id: int.parse(data['id']),
          employee_name: data['name']
        )
      ),
      child: Container(
        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
        decoration: BoxDecoration(
          //: _chairSelected[index] ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(responsiveApp.carrouselRadiusWidth),
       /*   boxShadow: const [
            BoxShadow(
              spreadRadius: -10,
              blurRadius: 8,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],

        */
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: responsiveApp.setWidth(100),
              height: responsiveApp.setHeight(110),
              decoration: BoxDecoration(
               // color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.all(Radius.circular(responsiveApp.carrouselRadiusWidth)),
              ),
              child: Stack(
                fit: StackFit.loose,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(responsiveApp.carrouselRadiusWidth)),
                            child: ColorFiltered(colorFilter: ColorFilter.mode(Color(int.parse(data['chair_color'])), BlendMode.modulate),
                              child: Image.asset('assets/images/silla.png'),)
                        ),
                      ),
                    ],
                  ),
                  /*
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

                   */
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(responsiveApp.carrouselRadiusWidth), topRight: Radius.circular(responsiveApp.carrouselRadiusWidth)),
                            //shape: BoxShape.circle,
                            //color: Colors.black54
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //Icon(Icons.chair_rounded, size: responsiveApp.setWidth(15),color: Colors.white.withOpacity(0.8),),
                            //SizedBox(width: responsiveApp.setWidth(5),),
                            Expanded(
                              child: texto(
                                alignment: TextAlign.center,
                                text: "${data['chair_name']!}",
                                size: responsiveApp.setSP(12),
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  /*
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(responsiveApp.carrouselRadiusWidth), bottomRight: Radius.circular(responsiveApp.carrouselRadiusWidth)),
                            //shape: BoxShape.circle,
                            color: Colors.black54
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //Icon(Icons.chair_rounded, size: responsiveApp.setWidth(15),color: Colors.white.withOpacity(0.8),),
                            //SizedBox(width: responsiveApp.setWidth(5),),
                            Expanded(
                              child: texto(
                                alignment: TextAlign.center,
                                text: "${data['name']!}",
                                size: responsiveApp.setSP(12),
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                   */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
