import 'package:flutter/material.dart';
import '../../Widgets/Components/EmploeeWidget.dart';
import '../../Widgets/Components/RolesWidget.dart';
import '../../util/db_connection.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../values/ResponsiveApp.dart';

class PermissionSettingsWidget extends StatefulWidget {
  const PermissionSettingsWidget({Key? key}) : super(key: key);

  @override
  State<PermissionSettingsWidget> createState() => _PermissionSettingsWidgetState();
}

class _PermissionSettingsWidgetState extends State<PermissionSettingsWidget> {
  late ResponsiveApp responsiveApp;
  late BDConnection dbConnection;
  int pageIndex = 0;
  List<bool> selectAll = [];
  List<bool> addList = [];
  List<bool> watchList = [];
  List<bool> editList = [];
  List<bool> deleteList = [];
  List<bool> showPermission = [];
  List<Map<String,List<bool>>> modulePermission =[];

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    dbConnection = BDConnection(context: context);

    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: displayHeight(context),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    PreferredSize(
                      preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                        //color: Colors.blueGrey,
                        child: Row(
                          children: [
                            if(isMobileAndTablet(context))
                              IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded,)),
                            Expanded(
                              child: Text(pageIndex==0?"Permisos":"Editar Permisos",
                                style: const TextStyle(
                                  //   color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if(pageIndex==0)
                              InkWell(
                                onTap: (){
                                  if(isMobileAndTablet(context)) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                        const RolesWidget()));
                                  }else{
                                    showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          content: SizedBox(
                                              width: displayWidth(context)*0.4,
                                              child: const RolesWidget()),
                                          actions: [
                                            InkWell(
                                              autofocus: true,
                                              onTap: (){
                                                setState((){});
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                width: 110,
                                                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                                child: const Center(child: Text('Finalizar', style: TextStyle(color: Colors.white))),
                                              ),
                                            ),
                                          ],
                                        )
                                    );
                                  }
                                },
                                child: Container(
                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(50)),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Padding(
                                    padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.settings_applications,
                                          color: Colors.white,
                                          size: responsiveApp.setWidth(20),
                                        ),
                                        SizedBox(width: responsiveApp.setWidth(5),),
                                        texto(
                                          size: responsiveApp.setSP(12),
                                          text: 'Nivel',
                                          color: Colors.white,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(width: responsiveApp.setWidth(10),),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () {
                          return Future.delayed(
                            const Duration(seconds: 1),
                                () {
                              setState((){
                              });
                            },
                          );
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if(pageIndex==0)
                                roles(),
                              if(pageIndex==1)
                                SizedBox(height: displayHeight(context),
                                    child: const RolesWidget()),
                                //newLocalization(),
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

  Widget roles(){
    return FutureBuilder(
      future: dbConnection.getRoles(context),
        builder: (BuildContext ctx, AsyncSnapshot snapshot){
          if(snapshot.data ==null){
            return const Center(child: CircularProgressIndicator(),);
          }else{
            for(var i=0;i<snapshot.data.length;i++){
              showPermission.add(false);
              selectAll.add(false);
              Map<String,List<bool>> map = {};
              modulePermission.add(map);
            }
            return Padding(
              padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
              child: Column(
                children: List.generate(
                  snapshot.data.length,
                    (index){
                    return index>0? Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                              color: Theme.of(context).cardColor,
                              boxShadow: const [
                                BoxShadow(
                                  spreadRadius: -6,
                                  blurRadius: 8,
                                  offset: Offset(0,0),
                                )
                              ]
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,//Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(responsiveApp.setWidth(5)),
                                      topLeft: Radius.circular(responsiveApp.setWidth(5)),
                                      bottomRight: showPermission[index]?Radius.circular(responsiveApp.setWidth(0)):Radius.circular(responsiveApp.setWidth(5)),
                                      bottomLeft: showPermission[index]?Radius.circular(responsiveApp.setWidth(0)):Radius.circular(responsiveApp.setWidth(5))),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    texto(
                                      text: snapshot.data[index].name.padRight(20,' '),
                                      size: responsiveApp.setSP(14),
                                      fontWeight: FontWeight.w500,
                                      //color: Colors.white,
                                    ),
                                    InkWell(
                                      onTap: (){
                                        if(isMobileAndTablet(context)) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>
                                                  EmployeeWidget(origin: 'permissions',roleId: snapshot.data[index].id,)));
                                        }else{
                                          showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                content: SizedBox(
                                                  width: displayWidth(context)*0.4,
                                                    child: EmployeeWidget(origin: 'permissions',roleId: snapshot.data[index].id,)),
                                                actions: [
                                                  InkWell(
                                                    autofocus: true,
                                                    onTap: (){
                                                      setState((){});
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      width: responsiveApp.setWidth(120),
                                                      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                      child: const Center(child: Text('Finalizar', style: TextStyle(color: Colors.white))),
                                                    ),
                                                  ),
                                                ],
                                          )
                                              );
                                        }
                                      },
                                      child: Container(
                                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(50)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.group, color: Colors.white,),
                                            SizedBox(width: responsiveApp.setWidth(5),),
                                            texto(
                                              text: '${snapshot.data[index].member_count}',
                                              size: responsiveApp.setSP(12),
                                                color: Colors.white
                                            ),
                                            SizedBox(width: responsiveApp.setWidth(5),),
                                            if(!isMobile(context))
                                            texto(
                                              text: 'Miembros',
                                              size: responsiveApp.setSP(12),
                                              color: Colors.white
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          showPermission[index]= !showPermission[index];
                                        });
                                      },
                                      child: Container(
                                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(50)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.vpn_key_rounded,),
                                            SizedBox(width: responsiveApp.setWidth(5),),
                                            if(!isMobile(context))
                                            texto(
                                                text: 'Permisos',
                                                size: responsiveApp.setSP(12),
                                                //color: Colors.white
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if(showPermission[index])
                                permission(index,snapshot.data[index].id)
                            ],
                          ),
                        ),
                        if(index<snapshot.data.length)SizedBox(height: responsiveApp.setHeight(10),),
                      ],
                    ):const SizedBox();
                    }
                )
              ),
            );
          }
        }
    );
  }

  Widget permission(int i,levelId){
    return FutureBuilder(
          future: dbConnection.getPermission(context, levelId),
          builder: (BuildContext ctx, AsyncSnapshot snapshot){
            if(snapshot.data==null){
              return const Center(child: LinearProgressIndicator(backgroundColor: Colors.transparent,),);
            }else{
              List<String> keys = [];
              if(modulePermission[i-1].isEmpty) {
                for (var j = 0; j < snapshot.data.length; j++) {
                  print(snapshot.data[j].permission_name);
                    if (!modulePermission[i - 1].containsKey(
                        snapshot.data[j].module_name)) {
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1].putIfAbsent(
                          snapshot.data[j].module_name, () => [true])
                          : modulePermission[i - 1].putIfAbsent(
                          snapshot.data[j].module_name, () => [false]);
                    } else if(snapshot.data[j].module_name!='pos'
                        && snapshot.data[j].module_name!='settings'
                        && modulePermission[i - 1][snapshot.data[j].module_name]!.length < 2){
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]!.add(true)
                          : modulePermission[i - 1][snapshot.data[j].module_name]!.add(false);
                    }else if(snapshot.data[j].module_name!='pos'
                        && snapshot.data[j].module_name!='settings'
                        && snapshot.data[j].module_name!='dgii'
                        && modulePermission[i - 1][snapshot.data[j].module_name]!.length < 4){
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]!.add(true)
                          : modulePermission[i - 1][snapshot.data[j].module_name]!.add(false);
                    }else{
                      switch(snapshot.data[j].permission_name.split('_')[1]){
                        case 'read':
                          snapshot.data[j].has_permission==1
                              ? modulePermission[i - 1][snapshot.data[j].module_name]![0]=true
                              : modulePermission[i - 1][snapshot.data[j].module_name]![0]=false;
                          break;
                        case 'manage':
                          snapshot.data[j].has_permission==1
                              ? modulePermission[i - 1][snapshot.data[j].module_name]![0]=true
                              : modulePermission[i - 1][snapshot.data[j].module_name]![0]=false;
                          break;
                        case 'access':
                          snapshot.data[j].has_permission==1
                              ? modulePermission[i - 1][snapshot.data[j].module_name]![0]=true
                              : modulePermission[i - 1][snapshot.data[j].module_name]![0]=false;
                          break;
                        case 'generate_reports':
                          snapshot.data[j].has_permission==1
                              ? modulePermission[i - 1][snapshot.data[j].module_name]![1]=true
                              : modulePermission[i - 1][snapshot.data[j].module_name]![1]=false;
                          break;
                        case 'record_payment':
                          snapshot.data[j].has_permission==1
                              ? modulePermission[i - 1][snapshot.data[j].module_name]![1]=true
                              : modulePermission[i - 1][snapshot.data[j].module_name]![1]=false;
                          break;
                        case 'add':
                          snapshot.data[j].has_permission==1
                              ? modulePermission[i - 1][snapshot.data[j].module_name]![1]=true
                              : modulePermission[i - 1][snapshot.data[j].module_name]![1]=false;

                          break;
                        case 'create':
                          snapshot.data[j].has_permission==1
                              ? modulePermission[i - 1][snapshot.data[j].module_name]![1]=true
                              : modulePermission[i - 1][snapshot.data[j].module_name]![1]=false;

                          break;
                        case 'update':
                          snapshot.data[j].has_permission==1
                              ? modulePermission[i - 1][snapshot.data[j].module_name]![2]=true
                              : modulePermission[i - 1][snapshot.data[j].module_name]![2]=false;
                          break;
                        case 'delete':
                          snapshot.data[j].has_permission==1
                              ? modulePermission[i - 1][snapshot.data[j].module_name]![3]=true
                              : modulePermission[i - 1][snapshot.data[j].module_name]![3]=false;
                          break;
                      }
                    }
                }
              }else{
                for (var j = 0; j < snapshot.data.length; j++) {
                  switch(snapshot.data[j].permission_name.split('_')[1]){
                    case 'read':
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]![0]=true
                          : modulePermission[i - 1][snapshot.data[j].module_name]![0]=false;
                      break;
                    case 'manage':
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]![0]=true
                          : modulePermission[i - 1][snapshot.data[j].module_name]![0]=false;
                      break;
                    case 'access':
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]![0]=true
                          : modulePermission[i - 1][snapshot.data[j].module_name]![0]=false;
                      break;
                    case 'generate_reports':
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]![1]=true
                          : modulePermission[i - 1][snapshot.data[j].module_name]![1]=false;
                      break;
                    case 'record_payment':
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]![1]=true
                          : modulePermission[i - 1][snapshot.data[j].module_name]![1]=false;
                      break;
                    case 'add':
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]![1]=true
                          : modulePermission[i - 1][snapshot.data[j].module_name]![1]=false;

                      break;
                    case 'create':
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]![1]=true
                          : modulePermission[i - 1][snapshot.data[j].module_name]![1]=false;

                      break;
                    case 'update':
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]![2]=true
                          : modulePermission[i - 1][snapshot.data[j].module_name]![2]=false;
                      break;
                    case 'delete':
                      snapshot.data[j].has_permission==1
                          ? modulePermission[i - 1][snapshot.data[j].module_name]![3]=true
                          : modulePermission[i - 1][snapshot.data[j].module_name]![3]=false;
                      break;
                  }
                }
              }

              return Padding(
                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: (){
                            selectAll[i-1]
                                ? dbConnection.revokeAllPermissions(
                                (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context,levelId)
                                : dbConnection.addAllPermissions((e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context,levelId);

                            setState(() {
                              selectAll[i-1] = !selectAll[i-1];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.decelerate,
                            width: responsiveApp.setWidth(35),
                            decoration:BoxDecoration(
                              borderRadius:BorderRadius.circular(50.0),
                              color: selectAll[i-1] ? const Color(0xff6C9BD2) : Colors.grey.withOpacity(0.6),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              alignment: selectAll[i-1] ? Alignment.centerRight : Alignment.centerLeft,
                              curve: Curves.decelerate,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  width: responsiveApp.setWidth(15),
                                  height: responsiveApp.setHeight(15),
                                  decoration:BoxDecoration(
                                    color: const Color (0xffFFFFFF),
                                    borderRadius:BorderRadius.circular(100.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: responsiveApp.setWidth(10),),
                        const Text("Seleccionar todo",
                        ),
                      ],
                    ),
                    SizedBox(height: responsiveApp.setHeight(10),),
                    Row(
                      children: [
                        Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: responsiveApp.setHeight(10),),
                                Padding(
                                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: isMobileAndTablet(context)?responsiveApp.setWidth(140):responsiveApp.setWidth(195),),
                                      SizedBox(
                                        width: isMobileAndTablet(context)?responsiveApp.setWidth(70):responsiveApp.setWidth(100),
                                        child: Center(
                                          child: texto(
                                              text: 'Gestionar',
                                              size: responsiveApp.setSP(12),
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isMobileAndTablet(context)?responsiveApp.setWidth(70):responsiveApp.setWidth(100),
                                        child: Center(
                                          child: texto(
                                              text: 'Agregar',
                                              size: responsiveApp.setSP(12),
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isMobileAndTablet(context)?responsiveApp.setWidth(70):responsiveApp.setWidth(100),
                                        child: Center(
                                          child: texto(
                                              text: 'Modificar',
                                              size: responsiveApp.setSP(12),
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isMobileAndTablet(context)?responsiveApp.setWidth(70):responsiveApp.setWidth(100),
                                        child: Center(
                                          child: texto(
                                              text: 'Borrar',
                                              size: responsiveApp.setSP(12),
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: responsiveApp.setHeight(5),),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      snapshot.data.length, (index) {
                                    Widget widget = !keys.contains(snapshot.data[index].module_name)
                                        ? Padding(
                                      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: isMobileAndTablet(context)?responsiveApp.setWidth(140):responsiveApp.setWidth(200),
                                            child: texto(
                                                text: snapshot.data[index].module_display_name.padRight(20,' '),
                                                size: responsiveApp.setSP(12),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          SizedBox(
                                            width: isMobileAndTablet(context)?responsiveApp.setWidth(70):responsiveApp.setWidth(100),
                                            child: Center(
                                              child: customSwitch(
                                                    (){
                                                  setState(() {
                                                    //bdConnection.addPermission(snapshot.data[index].permission_id, roleId);
                                                    modulePermission[i-1][snapshot.data[index].module_name]![0]
                                                        ? dbConnection.revokePermission((e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context,snapshot.data[index].permission_id, levelId)
                                                        : dbConnection.addPermission((e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context,snapshot.data[index].permission_id, levelId);
                                                    //modulePermission[i-1][snapshot.data[index].module_name]![0] = !modulePermission[i-1][snapshot.data[index].module_name]![0];
                                                    //watchList[index] = !watchList[index];
                                                  });
                                                },
                                                modulePermission[i-1][snapshot.data[index].module_name]![0] ? const Color(0xff6C9BD2) : Colors.grey.withOpacity(0.6),
                                                modulePermission[i-1][snapshot.data[index].module_name]![0] ? Alignment.centerRight : Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                          if(modulePermission[i-1][snapshot.data[index].module_name]!.length>=2)
                                            SizedBox(
                                              width: isMobileAndTablet(context)?responsiveApp.setWidth(70):responsiveApp.setWidth(100),
                                              child: Center(
                                                child: customSwitch(
                                                      (){
                                                    setState(() {
                                                      //bdConnection.addPermission(snapshot.data[index].permission_id, roleId);
                                                      modulePermission[i-1][snapshot.data[index].module_name]![1]
                                                          ? dbConnection.revokePermission((e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context,snapshot.data[index].permission_id + 1, levelId)
                                                          : dbConnection.addPermission((e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context,snapshot.data[index].permission_id + 1, levelId);
                                                      //modulePermission[i-1][snapshot.data[index].module_name]![0] = !modulePermission[i-1][snapshot.data[index].module_name]![0];
                                                      //watchList[index] = !watchList[index];
                                                    });
                                                  },
                                                  modulePermission[i-1][snapshot.data[index].module_name]![1] ? const Color(0xff6C9BD2) : Colors.grey.withOpacity(0.6),
                                                  modulePermission[i-1][snapshot.data[index].module_name]![1] ? Alignment.centerRight : Alignment.centerLeft,
                                                ),
                                              ),
                                            ),
                                          if(modulePermission[i-1][snapshot.data[index].module_name]!.length>=3)
                                            SizedBox(
                                              width: isMobileAndTablet(context)?responsiveApp.setWidth(70):responsiveApp.setWidth(100),
                                              child: Center(
                                                child: customSwitch(
                                                      (){
                                                    setState(() {
                                                      //bdConnection.addPermission(snapshot.data[index].permission_id, roleId);
                                                      modulePermission[i-1][snapshot.data[index].module_name]![2]
                                                          ? dbConnection.revokePermission((e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context,snapshot.data[index].permission_id + 2, levelId)
                                                          : dbConnection.addPermission((e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context,snapshot.data[index].permission_id + 2, levelId);
                                                      //modulePermission[i-1][snapshot.data[index].module_name]![0] = !modulePermission[i-1][snapshot.data[index].module_name]![0];
                                                      //watchList[index] = !watchList[index];
                                                    });
                                                  },
                                                  modulePermission[i-1][snapshot.data[index].module_name]![2] ? const Color(0xff6C9BD2) : Colors.grey.withOpacity(0.6),
                                                  modulePermission[i-1][snapshot.data[index].module_name]![2] ? Alignment.centerRight : Alignment.centerLeft,
                                                ),
                                              ),
                                            ),
                                          if(modulePermission[i-1][snapshot.data[index].module_name]!.length>=4)
                                            SizedBox(
                                              width: isMobileAndTablet(context)?responsiveApp.setWidth(70):responsiveApp.setWidth(100),
                                              child: Center(
                                                child: customSwitch(
                                                      (){
                                                    setState(() {
                                                      //bdConnection.addPermission(snapshot.data[index].permission_id, roleId);
                                                      modulePermission[i-1][snapshot.data[index].module_name]![3]
                                                          ? dbConnection.revokePermission((e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context,snapshot.data[index].permission_id + 3, levelId)
                                                          : dbConnection.addPermission((e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},context,snapshot.data[index].permission_id + 3, levelId);
                                                      //modulePermission[i-1][snapshot.data[index].module_name]![0] = !modulePermission[i-1][snapshot.data[index].module_name]![0];
                                                      //watchList[index] = !watchList[index];
                                                    });
                                                  },
                                                  modulePermission[i-1][snapshot.data[index].module_name]![3] ? const Color(0xff6C9BD2) : Colors.grey.withOpacity(0.6),
                                                  modulePermission[i-1][snapshot.data[index].module_name]![3] ? Alignment.centerRight : Alignment.centerLeft,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ) :const SizedBox();

                                    if(!keys.contains(snapshot.data[index].module_name)) {
                                      keys.add(snapshot.data[index].module_name);
                                    }

                                    return widget;

                                  }
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            }
          }
      );
  }

  Widget customSwitch(VoidCallback onTap, Color color, Alignment alignment,){
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
        width: responsiveApp.setWidth(35),
        decoration:BoxDecoration(
          borderRadius:BorderRadius.circular(50.0),
          color: color,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: alignment,
          curve: Curves.decelerate,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              width: responsiveApp.setWidth(15),
              height: responsiveApp.setHeight(15),
              decoration:BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:BorderRadius.circular(100.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
