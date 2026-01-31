
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../WebComponents/Body/Container/SectionContainer.dart';

class ChairSelectionWidget extends StatefulWidget {
  const ChairSelectionWidget({Key? key, required this.date}) : super(key: key);
  final String date;

  @override
  State<ChairSelectionWidget> createState() => _ChairSelectionWidgetState();
}

class _ChairSelectionWidgetState extends State<ChairSelectionWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection bdConnection;
  late List<bool> _chairSelected;
  int idChair = 0;

  @override
  void initState() {
    super.initState();
    _chairSelected = [];
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    bdConnection = BDConnection();

    return Padding(
      padding: responsiveApp.edgeInsetsApp.hrzExtraLargeEdgeInsets,
      child: Column(
        children: [
          Padding(
            padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
            child: SectionContainer(
              title: 'Elija la silla',
              subtitle: '',
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: !isMobileAndTablet(context)? displayWidth(context)*0.8:displayWidth(context),
            child: FutureBuilder(
              future: bdConnection.getFreeChair(context: context, date: widget.date),
              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.data.isEmpty) {
                  return texto(
                    text: '¡No hay sillas disponibles en este horario!',
                    size: responsiveApp.setSP(14),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.all(responsiveApp.setWidth(10)),
                    child: AlignedGridView.count(
                      itemCount: snapshot.data.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
                      crossAxisCount: isMobileAndTablet(context)?displayWidth(context) ~/ responsiveApp.setWidth(300): displayWidth(context) ~/ responsiveApp.setWidth(200),
                      mainAxisSpacing: responsiveApp.setWidth(20),
                      crossAxisSpacing: responsiveApp.setWidth(20),
                      itemBuilder: (context, index) {
                        _chairSelected.add(false);
                        return buildChairTile(snapshot.data[index],index);
                      },
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(height: responsiveApp.setHeight(80),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (){
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(5))
                  ),
                  child: Padding(
                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_rounded, size: responsiveApp.setWidth(8),color: Colors.white,),
                        SizedBox(width: responsiveApp.setWidth(8),),
                        Text(
                          "Volver",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  AppData appData = AppData();
                  if(idChair>0) {
                    appData.setChairSelected(idChair);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed("/cartPage");
                  }
                },
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                      color: idChair>0 ? Colors.black.withOpacity(0.8) : Colors.grey,
                      borderRadius: BorderRadius.circular(responsiveApp.setWidth(5))
                  ),
                  child: Padding(
                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                    child: Row(
                      children: [
                        Text(
                          "Siguiente",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                        ),
                        SizedBox(width: responsiveApp.setWidth(8),),
                        Icon(Icons.arrow_forward_ios_rounded, size: responsiveApp.setWidth(8),color: Colors.white,),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsiveApp.setHeight(40),),
        ],
      ),
    );
  }

  Widget buildChairTile(data, int index) {
    return GridTile(
      child: InkWell(
        onTap: () => onTapChair(index, data.chair_id),
        child: Container(
          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
          decoration: BoxDecoration(
            color: _chairSelected[index] ? Colors.blue.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(responsiveApp.carrouselRadiusWidth),
            boxShadow: const [
              BoxShadow(
                spreadRadius: -10,
                blurRadius: 8,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: responsiveApp.setWidth(200),
                height: responsiveApp.productContainerHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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
                              child: data.employee_image !=null && data.employee_image!!=''
                                  ? Image.network(data.employee_image!,
                                fit: BoxFit.cover,
                                height: responsiveApp.productContainerHeight,
                              ): Image.asset('assets/images/default-avatar-user.png',fit: BoxFit.cover,height: responsiveApp.productContainerHeight,)
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
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          child: Container(
                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(responsiveApp.setWidth(20)),
                                //shape: BoxShape.circle,
                                color: Colors.black54
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chair_rounded, size: responsiveApp.setWidth(15),color: Colors.white.withOpacity(0.8),),
                                SizedBox(width: responsiveApp.setWidth(5),),
                                texto(
                                  text: "${data.chair_name!}",
                                  size: responsiveApp.setSP(12),
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                                  text: "${data.employee_name!}",
                                  size: responsiveApp.setSP(12),
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTapChair(int index, int chairId) {
    setState(() {
      if (_chairSelected[index]) {
        _chairSelected[index] = false;
        idChair = 0;
      } else {
        for (int i = 0; i < _chairSelected.length; i++) {
          _chairSelected[i] = (i == index);
        }
        idChair = chairId;
      }
    });
  }
}

