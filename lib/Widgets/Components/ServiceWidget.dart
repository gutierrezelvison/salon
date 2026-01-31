//import 'dart:html' as html;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:salon/Widgets/WebComponents/Header/header_search_bar.dart';
import '../../Widgets/Components/CategoryWidget.dart';
import '../../Widgets/Components/SucursalesWidget.dart';
import '../../util/db_connection.dart';
import '../../values/ResponsiveApp.dart';
import '../../util/Keys.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class ServiceWidget extends StatefulWidget {
  const ServiceWidget({Key? key}) : super(key: key);

  @override
  State<ServiceWidget> createState() => _ServiceWidgetState();
}

class _ServiceWidgetState extends State<ServiceWidget> {
  late ResponsiveApp responsiveApp;
  AppData appData = AppData();
  late BDConnection bdConnection = BDConnection();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _localNameController = TextEditingController();
  final TextEditingController _localNameLinkController = TextEditingController();
  final TextEditingController _localDescripcionController = TextEditingController();
  final TextEditingController _localPriceController = TextEditingController();
  final TextEditingController _localCommissionController = TextEditingController();
  final TextEditingController _localDiscountController = TextEditingController();
  final TextEditingController _localTimeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _localQuantityController = TextEditingController();
  final discountItems = ['Porcentaje','Fijo'];
  List<String> sucursalItems = [];
  final topItemsId = [0];
  List<String> catItems = [];
  List<String> taxItems = [];
  final timeItems = ['Minutos','Horas','Días'];
  final typeItems = ['Servicio','Producto'];
  String selectedDiscount = 'Porcentaje';
  String selectedTime = 'Minutos';
  String selectedType = 'Servicio';
  Taxes? selectedTax;
  String? selectedSucursal;
  String? selectedCategory;
  int pageIndex = 0;
  bool edit = false;
  bool applyTaxes = false;
  int idService = 0;
  double discountPrice = 0;
  String imageName = '';
  String imagePath = '';
  List<Service>? serviceList;
  List<Sucursal> sucList = [];
  List<Categorie> catList = [];
  List<Taxes> taxList = [];

  bool status= true;
  bool firstTime= true;
  Uint8List bytes = Uint8List(0);
  var file;
  int imageLength=0;
  late DropzoneViewController controller1;
  String message1 = 'Drop something here';
  bool highlighted1 = false;
  List<Service> filteredServices =[];
  Map<String, bool> filterOptions = {};

  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
        if (edit) {
          if (await bdConnection.updateService(context: context, id: idService,name: _localNameController.text, slug: _localNameLinkController.text,
              category_id: catList.elementAt(catItems.indexOf(selectedCategory!)).id!,
              description: _localDescripcionController.text,discount: double.parse(_localDiscountController.text==''?'0':_localDiscountController.text),
              discount_type: selectedDiscount=='Porcentaje'?'percent':'fixed',
              location_id: sucList.elementAt(sucursalItems.indexOf(selectedSucursal!)).id,
              type: selectedType=="Servicio"?"service":"product",
              apply_taxes: applyTaxes?1:0,
              tax_id: selectedTax?.id??0,
              quantity: _localQuantityController.text!=""?int.parse(_localQuantityController.text):0,
              price: double.parse(_localPriceController.text),time: double.parse(_localTimeController.text==''?'0':_localTimeController.text),
              commission: selectedType=="Servicio"?double.parse(_localCommissionController.text):0,
              time_type: selectedTime=='Minutos'?'minutes':selectedTime=='Horas'?'hours':'days',
              status: status?'active':'deactive', file: file, imageLength: imageLength,
              imageName: imageName!=''?imageName:hashPassword("${idService.toString()} ${DateTime.now().toString()}"))) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Servicio actualizado con éxito!',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xff22d88d)
            );
          }else{
            CustomSnackBar().show(
                context: context,
                msg: 'No se pudo completar la operación!',
                icon: Icons.error_outline_outlined,
                color: const Color(0xffFF525C)
            );
          }
        } else {
          if (await bdConnection.addService(context: context,name: _localNameController.text, slug: _localNameLinkController.text,
              category_id: catList.elementAt(catItems.indexOf(selectedCategory!)).id!,
              description: _localDescripcionController.text,discount: double.parse(_localDiscountController.text==''?'0':_localDiscountController.text),
              discount_type: selectedDiscount=='Porcentaje'?'percent':'fixed',
              location_id: sucList.elementAt(sucursalItems.indexOf(selectedSucursal!)).id,
              type: selectedType=="Servicio"?"service":"product",
              apply_taxes: applyTaxes?1:0,
              tax_id: selectedTax?.id??0,
              quantity: _localQuantityController.text!=""?int.parse(_localQuantityController.text):0,
              price: double.parse(_localPriceController.text),time: double.parse(_localTimeController.text==''?'0':_localTimeController.text),
              commission: selectedType=="Servicio"?double.parse(_localCommissionController.text):0,
              time_type: selectedTime=='Minutos'?'minutes':selectedTime=='Horas'?'hours':'days',
              status: status?'active':'deactive', file: file, imageLength: imageLength, imageName: imageName)) {
            limpiar();
            CustomSnackBar().show(
                context: context,
                msg: 'Servicio agregado con éxito!',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xff22d88d)
            );
          }else{
            CustomSnackBar().show(
                context: context,
                msg: 'No se pudo completar la operación!',
                icon: Icons.error_outline_outlined,
                color: const Color(0xffFF525C)
            );
          }
      }
    }
  }

  deleteItem(int id)async{
    if(await bdConnection.deleteService(context: context,id: id)){
      CustomSnackBar().show(
          context: context,
          msg: 'Servicio eliminado con éxito!',
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xff22d88d)
      );
    }else{
      CustomSnackBar().show(
          context: context,
          msg: 'No se pudo completar la operación!',
          icon: Icons.error_outline_outlined,
          color: const Color(0xffFF525C)
      );
    }
  }

  setSucursal() async{
    for (var element in await bdConnection.getSucursales(context)){
      sucList.add(element);
      sucursalItems.add(element.name);
    }
  }

  getTaxes() async{
    var query = await bdConnection.getTaxData(context);
    for (var element in query){
      taxList.add(element);
      taxItems.add("${element.percent!.toString()}%");

    }
    selectedTax =query[0];
  }

  setCategory()async{
    List list = await bdConnection.getCategory(context);
    for (var i=0;i<list.length;i++){
      if(i>0)catList.add(list[i]);
      if(i>0)catItems.add(list[i].name);
    }
  }

  getServices()async{
    var query = await bdConnection.getServices(context: context,searchBy: 'id',type: '');
    serviceList= List.from(query);
    if(query!=[]&& filterOptions.isEmpty) {
      extractFilterOptions(serviceList!, filterOptions);
    }else {
      onFilter();
    }
  }

  void onFilter() {
    String searchText = _searchController.text.trim().toLowerCase();
    bool hasSearch = searchText.isNotEmpty;

    bool anyFilterSelected = filterOptions.containsValue(true);

    filteredServices = serviceList!.where((service) {
      // Primero aplicar los filtros
      bool matchesType = filterOptions[service.type] ?? false;
      bool matchesCategory = filterOptions[service.category_name] ?? false;
      bool matchesDiscountType = filterOptions[service.discount_type] ?? false;

      // Si hay filtros activos, el servicio debe cumplir al menos uno de los criterios activos
      bool passesFilters = !anyFilterSelected ||
          matchesType || matchesCategory || matchesDiscountType;

      // Luego aplicar búsqueda solo si pasa los filtros
      bool matchesSearch = !hasSearch || (service.name?.toLowerCase().contains(searchText) ?? false);

      return passesFilters && matchesSearch;
    }).toList();

    setState(() {});
  }





  void extractFilterOptions(List<Service> services, Map<String, bool> filterOptions) {
    // Agregar opción "Todo"
    //filterOptions["Todo"] = true;

    // Extraer categorías únicas
    Set<String> categories = services.map((s) => s.category_name ?? "").toSet();
    for (var category in categories) {
      if (category.isNotEmpty) {
        filterOptions[category] = false; // Por defecto, no filtrar
      }
    }

    // Extraer tipos de registro únicos
    Set<String> types = services.map((s) => s.type ?? "").toSet();
    for (var type in types) {
      if (type.isNotEmpty) {
        filterOptions[type] = false;
      }
    }

    // Extraer tipos de descuento únicos
    Set<String> discountTypes = services.map((s) => s.discount_type ?? "").toSet();
    for (var discountType in discountTypes) {
      if (discountType.isNotEmpty) {
        filterOptions[discountType] = false;
      }
    }
    onFilter();
  }


  limpiar(){
    setState(() {
      pageIndex =0;
      firstTime=true;
      bytes=Uint8List(0);
      edit=false;
      idService=0;
      discountPrice = 0;
      _localNameController.text='';
      _localNameLinkController.text='';
      _localDescripcionController.text='';
      _localDiscountController.text='';
      _localTimeController.text = '';
      _localPriceController.text = '';
      selectedSucursal = null;
      selectedCategory = null;
      imageName='';
      imagePath = '';
      selectedTax=null;
      selectedType= 'Servicio';
      taxList.clear();
      taxItems.clear();
      serviceList=null;
      file = null;
      filteredServices.clear();
      filterOptions.clear();
    });
  }
  int countNonEmptyLists(Map<String, bool> map) {
    int count = 0;
    map.forEach((key, value) {
      if (value) {
        count++;
      }
    });
    return count;
  }

  @override
  void initState() {
    setCategory();
    setSucursal();

    //getServices();
    appData.setView('all');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsiveApp.setHeight(80)), // here the desired height
        child: Container(
          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
          //color: Colors.blueGrey,
          child: Row(
            children: [
              if(isMobileAndTablet(context))
                IconButton(onPressed: ()=> pageIndex==1?limpiar():mainScaffoldKey.currentState!.openDrawer(), icon: Icon(pageIndex==1?Icons.arrow_back_rounded:Icons.menu_rounded,)),
              if(!isMobileAndTablet(context)&&pageIndex==1)
                IconButton(onPressed: ()=> limpiar(), icon: const Icon(Icons.arrow_back_rounded,)),
              Expanded(
                child: Text(pageIndex==0?"Servicios":edit?"Modificar servicios":"Añadir servicios",
                  style: const TextStyle(
                   // color: Colors.white,
                    fontSize: 18,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if(pageIndex==0)
                HeaderSearchBar(onSearchPressed: (){
                  onFilter();
                },
                    onChange: (v){
                  onFilter();
                    },
                    controller: _searchController,
                ),
              if(pageIndex==0)
              InkWell(
                onTap: (){
                  setState(() {
                    pageIndex=1;
                    _searchController.text = '';
                  });
                },
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(50)),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: responsiveApp.setWidth(10),
                      ),
                      texto(
                        size: responsiveApp.setSP(10),
                        text: 'Nuevo',
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: responsiveApp.setWidth(10),),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          if(pageIndex==0)
          Row(
            children: [
              InkWell(
                  onTap: () async {

                  },
                  child: Container(
                      margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                      padding: responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                  padding: responsiveApp.edgeInsetsApp.vrtSmallEdgeInsets,child: Icon(Icons.tune_rounded, color: Theme.of(context).primaryColor))),
                          if(countNonEmptyLists(filterOptions)>0)
                            Container(
                              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Text(countNonEmptyLists(filterOptions).toString(), style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white,)),
                              ),
                            ),
                        ],
                      ))
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(filterOptions.keys.length, (index){
                      var keys = filterOptions.keys.toList();
                      return InkWell(
                        onTap: ()async{
                            filterOptions[keys[index]]=!(filterOptions[keys[index]])!;
                            onFilter();
                        },
                        child: Container(
                          margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                          decoration: BoxDecoration(
                            color: !filterOptions[keys[index]]!?Colors.transparent:Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Text(keys[index],
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: !filterOptions[keys[index]]!?Theme.of(context).textTheme.labelMedium!.color:Colors.white,),),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                return Future.delayed(
                  const Duration(seconds: 1),
                      () {
                    setState((){});
                  },
                );
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if(pageIndex==0)
                      categories(),
                    if(pageIndex==1)
                      isMobileAndTablet(context)?newServiceMobile():newService(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categories(){
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      spreadRadius: -6,
                      blurRadius: 8,
                      offset: Offset(0,0),
                    )
                  ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: responsiveApp.setWidth(10),
                        top: responsiveApp.setWidth(2), bottom: responsiveApp.setWidth(2)),
                    child: Row(
                      children: [
                        SizedBox(width: responsiveApp.setWidth(30),
                          child: texto(
                            text: '#',
                            size: 14,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),
                        SizedBox(
                          width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Imagen',
                            size: 14,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),
                        Expanded(
                          child: texto(
                          text: 'Nombre',
                          size: 14,
                        ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),
                        if(!isMobileAndTablet(context))
                        SizedBox(width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Categoría',
                            size: 14,
                          ),
                        ),
                        if(!isMobileAndTablet(context))
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),
                        if(!isMobileAndTablet(context))
                        SizedBox(width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Precio',
                            size: 14,
                          ),
                        ),
                        if(!isMobileAndTablet(context))
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),
                        if(!isMobileAndTablet(context))
                        SizedBox(width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Estado',
                            size: 14,
                          ),
                        ),
                        if(!isMobileAndTablet(context))
                        Padding(
                          padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                          child: Container(height: responsiveApp.setHeight(20),
                            width: responsiveApp.setWidth(1),
                            color: Colors.grey.withOpacity(0.3),),
                        ),
                        SizedBox(width: responsiveApp.setWidth(100),
                          child: texto(
                            text: 'Acciones',
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Builder(
                            builder: (BuildContext ctx) {
                              if (serviceList == null) {
                                getServices();
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }else {

                                return Column(
                                  children: List.generate(
                                    filteredServices.length,
                                        (index){
                                      return Column(
                                        children: [
                                          list(index),
                                          if(index<filteredServices.length-1)
                                            Row(
                                              children: [
                                                Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey.withOpacity(0.3),)),
                                              ],
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              }
                            }
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget list(int index){

    return ListTile(
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: responsiveApp.setHeight(3)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: responsiveApp.setWidth(30),
                  child: texto(
                    text: filteredServices[index].id.toString(),
                    size: responsiveApp.setSP(10),
                  ),
              ),

              Padding(
                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                child: SizedBox(height: responsiveApp.setHeight(20),
                  width: responsiveApp.setWidth(1),
                ),
              ),
              SizedBox(width: responsiveApp.setWidth(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    filteredServices[index].image!=null
                        ? userImage(
                        width: responsiveApp.setWidth(50),
                        height: responsiveApp.setWidth(50),
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(2)),
                        shadowColor: Theme.of(context).shadowColor,
                        image: Image.memory(filteredServices[index].image!.bytes!,fit: BoxFit.cover,))
                        : userImage(
                        width: responsiveApp.setWidth(50),
                        height: responsiveApp.setWidth(50),
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(2)),
                        shadowColor: Theme.of(context).shadowColor,
                        image: Image.asset('assets/images/No_image.jpg',fit: BoxFit.cover,)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                child: SizedBox(height: responsiveApp.setHeight(20),
                  width: responsiveApp.setWidth(1),
                ),
              ),
              Expanded(
                child: texto(
                    size: responsiveApp.setSP(10),
                    text: filteredServices[index].name!,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500
                ),
              ),
              Padding(
                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                child: SizedBox(height: responsiveApp.setHeight(20),
                  width: responsiveApp.setWidth(1),
                ),
              ),
              if(!isMobileAndTablet(context))
              SizedBox(width: responsiveApp.setWidth(100),
                child: texto(
                    size: responsiveApp.setSP(10),
                    text: filteredServices[index].category_name!,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500
                ),
              ),
              if(!isMobileAndTablet(context))
              Padding(
                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                child: SizedBox(height: responsiveApp.setHeight(20),
                  width: responsiveApp.setWidth(1),
                ),
              ),
              if(!isMobileAndTablet(context))
              SizedBox(width: responsiveApp.setWidth(100),
                child: texto(
                    size: responsiveApp.setSP(10),
                    text: filteredServices[index].price!,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500
                ),
              ),
              if(!isMobileAndTablet(context))
              Padding(
                padding: EdgeInsets.all(responsiveApp.setWidth(5)),
                child: SizedBox(height: responsiveApp.setHeight(20),
                  width: responsiveApp.setWidth(1),
                ),
              ),
              if(!isMobileAndTablet(context))
              SizedBox(width: responsiveApp.setWidth(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                        color: filteredServices[index].status=='active'? const Color(0xff22d88d): const Color(0xffFF525C),
                      ),
                      child: texto(
                        size: responsiveApp.setSP(10),
                        text: filteredServices[index].status=='active'?'Activo':'Inactivo',
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: responsiveApp.setWidth(100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(width: responsiveApp.setWidth(40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async{
                                _searchController.text = '';
                                if(filteredServices[index].apply_taxes==1) await getTaxes();
                                setState(() {
                                  bytes=(filteredServices[index].image?.bytes)??Uint8List(0);
                                  edit=true;
                                  idService=filteredServices[index].id!;
                                  _localNameController.text=filteredServices[index].name!;
                                  _localNameLinkController.text=filteredServices[index].slug!;
                                  _localDescripcionController.text=filteredServices[index].description!;
                                  _localDiscountController.text=filteredServices[index].discount!;
                                  _localTimeController.text = filteredServices[index].time!;
                                  _localPriceController.text = filteredServices[index].price!;
                                  _localCommissionController.text = filteredServices[index].commission!;
                                  _localQuantityController.text = filteredServices[index].quantity!.toString();
                                  selectedType = filteredServices[index].type=="product"?"Producto":"Servicio";
                                  applyTaxes = filteredServices[index].apply_taxes==1;
                                  applyTaxes = filteredServices[index].apply_taxes==1;
                                  selectedSucursal = filteredServices[index].location_name;
                                  selectedCategory = filteredServices[index].category_name;
                                  if(filteredServices[index].apply_taxes==1)selectedTax = taxList.firstWhere((e)=>e.id==filteredServices[index].tax_id);
                                  selectedDiscount = filteredServices[index].discount_type=='percent'?'Porcentaje':'Fijo';
                                  discountPrice = discountPrice = filteredServices[index].discount_type=='percent'
                                      ? double.parse(filteredServices[index].price.toString())-(double.parse(filteredServices[index].price.toString())*(double.parse(filteredServices[index].discount.toString())/100))
                                      : double.parse(filteredServices[index].price.toString())-double.parse(filteredServices[index].discount.toString());
                                  imageName = (filteredServices[index].image?.name.toString().split('.').first)??'';
                                  imagePath = (filteredServices[index].image?.path!)??'';

                                  pageIndex =1;
                                });
                              },
                              child: Container(
                                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                                  color: const Color(0xffffc44e),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: responsiveApp.setWidth(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: responsiveApp.setWidth(40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: (){
                                warningMsg(
                                    context: context,
                                    mainMsg: '¿Está seguro?',
                                    msg: '¡No podrá recuperar el registro borrado!',
                                    okBtnText: 'Si, borrar',
                                    cancelBtnText: 'No, cancelar',
                                    okBtn: (){
                                      deleteItem(filteredServices[index].id!);
                                      Navigator.pop(context);
                                    },
                                    cancelBtn: (){
                                      Navigator.pop(context);
                                    }
                                );
                              },
                              child: Container(
                                padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                                  color: const Color(0xffFF525C),
                                ),
                                child: Icon(
                                  Icons.delete_forever_rounded,
                                  color: Colors.white,
                                  size: responsiveApp.setWidth(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      onTap: (){
        setState(() {

        });
      },
    );
  }
  
  Widget newService(){
    return Padding(
      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                spreadRadius: -6,
                blurRadius: 8,
                offset: Offset(0,0),
              )
            ]
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: customField(
                      context: context,
                      controller: _localNameController,
                      labelText: 'Nombre del servicio*', hintText: 'Nombre',
                      keyboardType: TextInputType.name,
                      onChanged: (value){
                        setState((){
                          _localNameLinkController.text=value.replaceAll(' ', '-');
                        });
                    },),
                  ),
                  //  SizedBox(width: responsiveApp.setWidth(40),),
                  Expanded(
                    child: customField(
                      context: context,
                      controller: _localNameLinkController,
                      labelText: 'Enlace de servicio*',
                      hintText: 'enlace-servicio',
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      child: customField
                        (context: context,
                        useValidator: false,
                        controller: _localDescripcionController,
                        maxLines: 5,
                        minLines: 1,
                        maxLength: 250,
                        labelText: 'Descripción',
                        hintText: 'Descripcion',
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
                //const SizedBox(height: 8,),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: customField(
                          context: context,
                          controller:
                          _localPriceController,
                          labelText: 'Precio*',
                          hintText: 'Ej: 250',
                          keyboardType: TextInputType.number
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: customField(
                          context: context,
                          controller:
                          _localDiscountController,
                          labelText: 'Descuento',
                          hintText: 'Ej: 10',
                          keyboardType: TextInputType.number,
                        useValidator: false,
                        onChanged: (value){
                          setState((){
                            discountPrice = selectedDiscount=='Porcentaje'
                                ? double.parse(_localPriceController.text!=''?_localPriceController.text:'0')-(double.parse(_localPriceController.text!=''?_localPriceController.text:'0')*(double.parse(value)/100))
                                : double.parse(_localPriceController.text!=''?_localPriceController.text:'0')-double.parse(value);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: customDropDownButton(
                          value: selectedDiscount,
                          onChanged: (newValue) {
                            setState((){
                              selectedDiscount = newValue.toString();
                              setState((){
                                discountPrice = selectedDiscount=='Porcentaje'
                                    ? double.parse(_localPriceController.text!=''?_localPriceController.text:'0')-(double.parse(_localPriceController.text!=''?_localPriceController.text:'0')*(double.parse(_localDiscountController.text!=''?_localDiscountController.text:'0')/100))
                                    : double.parse(_localPriceController.text!=''?_localPriceController.text:'0')-double.parse(_localDiscountController.text!=''?_localDiscountController.text:'0');
                              });
                            });
                          },
                          items: discountItems
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                              .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
                      ),
                        child: const Icon(Icons.map_rounded, color: Colors.white)
                    ),
                    Expanded(
                      child: customDropDown(
                          searchController: _searchController,
                          items: sucursalItems,
                          hintText: 'Seleccione una Sucursal',
                          value: selectedSucursal,
                          onChanged: (value) {
                            setState(() {
                              selectedSucursal = value as String;
                              _searchController.text='';
                            });
                          },
                        context: context,
                       // hintIcon: Icons.local_offer,
                        searchInnerWidgetHeight: responsiveApp.setHeight(120),
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(5),),
                    InkWell(
                      onTap: (){
                        if(isMobileAndTablet(context)) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                              const SucursalWidget()));
                        }else {
                          viewWidget(context, const SucursalWidget(), () async{
                            Navigator.pop(context);
                            //sucList.clear();
                            sucursalItems.clear();
                            selectedSucursal = null;
                            await setSucursal();

                            setState(() {});
                          });
                        }
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                            color: Colors.green
                        ),
                        child: const Icon(Icons.settings_applications,color: Colors.white,),
                      ),
                    ),

                    SizedBox(width: responsiveApp.setWidth(10),),
                    Container(
                        padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
                        ),
                        child: const Icon(Icons.local_offer, color: Colors.white)
                    ),
                    Expanded(
                      child: customDropDown(
                          hintText: 'Seleccione una categoría',
                          value: selectedCategory,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value as String;
                              _searchController.text='';
                            });
                          },
                        context: context,
                        items: catItems,
                        searchController: _searchController,
                        searchInnerWidgetHeight: responsiveApp.setHeight(120),
                      ),
                    ),SizedBox(width: responsiveApp.setWidth(5),),
                    InkWell(
                      onTap: (){
                        if(isMobileAndTablet(context)) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                              const CategoryWidget()));
                        }else {
                          viewWidget(context, const CategoryWidget(), ()async {
                            Navigator.pop(context);
                            //catList.clear();
                            catItems.clear();
                            selectedCategory = null;
                            await setCategory();

                            setState(() {});
                          });
                        }
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                            color: Colors.green
                        ),
                        child: const Icon(Icons.settings_applications,color: Colors.white,),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              texto(
                                  size: responsiveApp.setSP(9),
                                  text: 'Precio de descuento',
                                color: Colors.grey
                              ),
                              texto(
                                size: responsiveApp.setSP(14),
                                text: '\$$discountPrice',
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    if(selectedType == "Servicio")
                    Expanded(
                      flex: 3,
                      child: customField(
                        useValidator: false,
                        context: context,
                        controller:
                        _localCommissionController,
                        labelText: 'Comisión',
                        hintText: 'Ej: 30',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: customField(
                        useValidator: false,
                        context: context,
                        controller:
                        _localTimeController,
                        labelText: 'Tiempo o duración',
                        hintText: 'Ej: 45',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: customDropDownButton(
                        value: selectedTime,
                        onChanged: (newValue) {
                          setState((){
                            selectedTime = newValue.toString();
                          });
                        },
                        items: timeItems
                            .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: customDropDownButton(
                        value: selectedType,
                        onChanged: (newValue) {
                          setState((){
                            selectedType = newValue.toString();
                          });
                        },
                        items: typeItems
                            .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                            .toList(),
                      ),
                    ),
                    Visibility(
                      visible: selectedType == "Producto",
                      child: Expanded(
                        flex: 2,
                        child: customField(
                          readOnly: edit && appData.getModuleListData().any((map) => map['name'] == 'inventory' && map['status'] == 'active')?true:(edit && appData.getUserData().rol_id!=1),
                          useValidator: false,
                          context: context,
                          controller:
                          _localQuantityController,
                          labelText: 'Cantidad en existencia',
                          hintText: 'Ej: 45',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                        child: Row(
                          children: [
                            Checkbox(
                                value: applyTaxes,
                                onChanged: (v)async {
                                  //loadingDialog(context);
                                  if(taxList.isEmpty) await getTaxes();
                                 // Navigator.pop(context);
                                  setState(() {
                                    applyTaxes = v!;
                                  });
                                }
                            ),
                            Text("Aplicar ${appData.getTaxData().tax_name}"),
                          ],
                        ),
                    ),
                    if(applyTaxes)
                    Expanded(
                      flex: 2,
                      child: customDropDownButton(
                        value: selectedTax!.tax_name!,
                        onChanged: (newValue) {
                          setState((){
                            selectedTax = taxList.firstWhere((element)=>element.tax_name! == newValue);
                          });
                        },
                        items: taxList.map((e)=>e.tax_name!).toList()
                            .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                            .toList(),
                      ),
                    ),

                  ],
                ),

                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: responsiveApp.setHeight(250),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          texto(size: 12, text: 'Imagen'),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(20),
                          dashPattern: const [10, 10],
                          color: Colors.grey,
                          strokeWidth: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: highlighted1 ?Colors.grey.withOpacity(0.2): Colors.transparent,
                            ),
                            child: Stack(
                              children: [
                                if(kIsWeb)
                                buildZone1(context),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                            child: imagePath !='null'&&imagePath !=''? Image.memory(
                                                bytes, fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)
                                            ):bytes.isNotEmpty?Image.memory(bytes,fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)):Image.asset('assets/images/logo.png',fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                                      child: ElevatedButton(onPressed: (){
                                        FileManager().abreArchivo((r) {
                                          if(r!='error') {
                                            setState(() {
                                              bytes = r;
                                              imageLength = bytes.length;
                                              file = Stream.value(bytes.toList());
                                              //imageProvider = MemoryImage(bytes);
                                            });
                                          }
                                        });
                                        /*
                                              StartFilePicker().startFilePicker((v){
                                                if(v!='error') {
                                                  setState(() {
                                                    bytes = v['bytes'];
                                                    imageLength = bytes.length;
                                                    file = Stream.value(bytes.toList());
                                                  });
                                                }
                                              });

                                               */
                                      }, child: const Icon(Icons.image_search_rounded)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      /*
                      ElevatedButton(
                        onPressed: () async {
                          print(await controller1.pickFiles(mime: ['image/jpeg', 'image/png']));
                        },
                        child: const Text('Pick file'),
                      ),

                       */
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text("Estado",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(10),),
                    InkWell(
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: (){
                        setState(() {
                          status = !status;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.decelerate,
                        width: responsiveApp.setWidth(35),
                        decoration:BoxDecoration(
                          borderRadius:BorderRadius.circular(50.0),
                          color: status ? const Color(0xff22d88d) : Colors.grey.withOpacity(0.6),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: status ? Alignment.centerRight : Alignment.centerLeft,
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
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: (){
                        selectedCategory!=null && selectedSucursal!=null
                            ? _saveForm()
                            : warningMsg(
                            context: context,
                            mainMsg: 'Formulario incompleto',
                            msg: '¡Debe seleccionar categorría y sucursal!',
                            okBtnText: 'Ok',
                            okBtn: (){
                              Navigator.pop(context);
                            },

                        );
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          color: Colors.blueGrey,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.save_rounded,
                              color: Colors.white,
                              size: responsiveApp.setWidth(10),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(2),
                            ),
                            texto(
                              size: responsiveApp.setSP(10),
                              text: 'Guardar',
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: responsiveApp.setWidth(15),
                    ),
                    InkWell(
                      onTap: (){
                        limpiar();
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          color: const Color(0xffFF525C),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              color: Colors.white,
                              size: responsiveApp.setWidth(10),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(2),
                            ),
                            texto(
                              size: responsiveApp.setSP(10),
                              text: 'Cancelar',
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget newServiceMobile(){
    return Padding(
      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                spreadRadius: -6,
                blurRadius: 8,
                offset: Offset(0,0),
              )
            ]
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children:[
                  Expanded(
                    child: field(
                      context: context,
                      controller: _localNameController,
                      label: 'Nombre del servicio*', hint: 'Nombre',
                      keyboardType: TextInputType.name,
                      onChanged: (value){
                        setState((){
                          _localNameLinkController.text=value.replaceAll(' ', '-');
                        });
                      },),
                  ),
                  //  SizedBox
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: field(
                        context: context,
                        controller: _localNameLinkController,
                        label: 'Enlace de servicio*',
                        hint: 'enlace-servicio',
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: field
                        (context: context,
                        controller: _localDescripcionController,
                        maxLines: 5,
                        minLines: 1,
                        maxLength: 250,
                        label: 'Descripción*',
                        hint: 'Descripcion',
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: field(
                          context: context,
                          controller:
                          _localPriceController,
                          label: 'Precio*',
                          hint: 'Ej: 250',
                          keyboardType: TextInputType.number
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: field(
                        context: context,
                        controller:
                        _localDiscountController,
                        label: 'Descuento*',
                        hint: 'Ej: 10',
                        keyboardType: TextInputType.number,
                        onChanged: (value){
                          setState((){
                            discountPrice = selectedDiscount=='Porcentaje'
                                ? double.parse(_localPriceController.text!=''?_localPriceController.text:'0')-(double.parse(_localPriceController.text!=''?_localPriceController.text:'0')*(double.parse(value)/100))
                                : double.parse(_localPriceController.text!=''?_localPriceController.text:'0')-double.parse(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            border: const Border.fromBorderSide(BorderSide(color: Colors.grey,)),
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(2))),

                        // dropdown below..
                        child: DropdownButton<String>(
                          value: selectedDiscount,
                          onChanged: (newValue) {
                            setState((){
                              selectedDiscount = newValue.toString();
                              setState((){
                                discountPrice = selectedDiscount=='Porcentaje'
                                    ? double.parse(_localPriceController.text!=''?_localPriceController.text:'0')-(double.parse(_localPriceController.text!=''?_localPriceController.text:'0')*(double.parse(_localDiscountController.text!=''?_localDiscountController.text:'0')/100))
                                    : double.parse(_localPriceController.text!=''?_localPriceController.text:'0')-double.parse(_localDiscountController.text!=''?_localDiscountController.text:'0');
                              });
                            });
                          },
                          items: discountItems
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                              .toList(),

                          // add extra sugar..
                          icon: const Icon(Icons.arrow_drop_down_rounded),
                          iconSize: 42,
                          underline: const SizedBox(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              texto(
                                  size: responsiveApp.setSP(9),
                                  text: 'Precio de descuento',
                                  color: Colors.grey
                              ),
                              texto(
                                size: responsiveApp.setSP(14),
                                text: '\$$discountPrice',
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))
                        ),
                        child: const Icon(Icons.map_rounded, color: Colors.white)
                    ),
                    Expanded(
                      child: customDropDown(
                        searchController: _searchController,
                        items: sucursalItems,
                        hintText: 'Seleccione una Sucursal',
                        value: selectedSucursal,
                        onChanged: (value) {
                          setState(() {
                            selectedSucursal = value as String;
                            _searchController.text='';
                          });
                        },
                        context: context,
                        // hintIcon: Icons.local_offer,
                        searchInnerWidgetHeight: responsiveApp.setHeight(120),
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(5),),
                    InkWell(
                      onTap: (){
                        if(isMobileAndTablet(context)) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                              const SucursalWidget()));
                        }else {
                          viewWidget(context, const SucursalWidget(), () {
                            Navigator.pop(context);
                            //sucList.clear();
                            sucursalItems.clear();
                            selectedSucursal = null;
                            setSucursal();

                            setState(() {});
                          });
                        }
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                            color: Colors.green
                        ),
                        child: const Icon(Icons.settings_applications,color: Colors.white,),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))
                        ),
                        child: const Icon(Icons.local_offer, color: Colors.white)
                    ),
                    Expanded(
                      child: customDropDown(
                          searchController: _searchController,
                          items: catItems,
                          hintText: 'Seleccione una categoría',
                          value: selectedCategory,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value as String;
                              _searchController.text='';
                            });
                          },
                        context: context,
                        hintIcon: Icons.local_offer,
                        searchInnerWidgetHeight: responsiveApp.setHeight(120),
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(5),),
                    InkWell(
                      onTap: (){
                        if(isMobileAndTablet(context)) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                              const CategoryWidget()));
                        }else {
                          viewWidget(context, const CategoryWidget(), () {
                            Navigator.pop(context);
                            //sucList.clear();
                            catItems.clear();
                            selectedCategory = null;
                            setSucursal();

                            setState(() {});
                          });
                        }
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                            color: Colors.green
                        ),
                        child: const Icon(Icons.settings_applications,color: Colors.white,),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: field(
                        context: context,
                        controller:
                        _localTimeController,
                        label: 'Tiempo o duración*',
                        hint: 'Ej: 45',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          border: const Border.fromBorderSide(BorderSide(color: Colors.grey,)),
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(2))),

                      // dropdown below..
                      child: DropdownButton<String>(
                        value: selectedTime,
                        onChanged: (newValue) {
                          setState((){
                            selectedTime = newValue.toString();
                          });
                        },
                        items: timeItems
                            .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                            .toList(),

                        // add extra sugar..
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        iconSize: 42,
                        underline: const SizedBox(),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: responsiveApp.setHeight(250),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          texto(size: 12, text: 'Imagen'),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(20),
                          dashPattern: const [10, 10],
                          color: Colors.grey,
                          strokeWidth: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: highlighted1 ?Colors.grey.withOpacity(0.2): Colors.transparent,
                            ),
                            child: Stack(
                              children: [
                                if(kIsWeb)
                                buildZone1(context),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                                            child: imagePath !='null'&&imagePath !=''? Image.memory(
                                                bytes, fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)
                                            ):bytes.isNotEmpty?Image.memory(bytes,fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)):Image.asset('assets/images/logo.png',fit: BoxFit.scaleDown, height: responsiveApp.setHeight(200)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                                      child: ElevatedButton(onPressed: (){
                                        FileManager().abreArchivo((r) {
                                          if(r!='error') {
                                            setState(() {
                                              bytes = r;
                                              imageLength = bytes.length;
                                              file = Stream.value(bytes.toList());
                                              //imageProvider = MemoryImage(bytes);
                                            });
                                          }
                                        });
                                        /*
                                              StartFilePicker().startFilePicker((v){
                                                if(v!='error') {
                                                  setState(() {
                                                    bytes = v['bytes'];
                                                    imageLength = bytes.length;
                                                    file = Stream.value(bytes.toList());
                                                  });
                                                }
                                              });

                                               */
                                      }, child: const Icon(Icons.image_search_rounded)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      /*
                      ElevatedButton(
                        onPressed: () async {
                          print(await controller1.pickFiles(mime: ['image/jpeg', 'image/png']));
                        },
                        child: const Text('Pick file'),
                      ),

                       */
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text("Estado",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(width: responsiveApp.setWidth(10),),
                    InkWell(
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: (){
                        setState(() {
                          status = !status;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.decelerate,
                        width: responsiveApp.setWidth(35),
                        decoration:BoxDecoration(
                          borderRadius:BorderRadius.circular(50.0),
                          color: status ? const Color(0xff22d88d) : Colors.grey.withOpacity(0.6),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: status ? Alignment.centerRight : Alignment.centerLeft,
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
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: (){
                        selectedCategory!=null && selectedSucursal!=null
                            ? _saveForm()
                            : warningMsg(
                          context: context,
                          mainMsg: 'Formulario incompleto',
                          msg: '¡Debe seleccionar categorría y sucursal!',
                          okBtnText: 'Ok',
                          okBtn: (){
                            Navigator.pop(context);
                          },

                        );
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          color: Colors.blueGrey,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.save_rounded,
                              color: Colors.white,
                              size: responsiveApp.setWidth(10),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(2),
                            ),
                            texto(
                              size: responsiveApp.setSP(10),
                              text: 'Guardar',
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: responsiveApp.setWidth(15),
                    ),
                    InkWell(
                      onTap: (){
                        limpiar();
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          color: const Color(0xffFF525C),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              color: Colors.white,
                              size: responsiveApp.setWidth(10),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(2),
                            ),
                            texto(
                              size: responsiveApp.setSP(10),
                              text: 'Cancelar',
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildZone1(BuildContext context) => Builder(
    builder: (context) => DropzoneView(
      operation: DragOperation.link,
      cursor: CursorType.grab,
      onCreated: (ctrl) => controller1 = ctrl,
      onLoaded: () => print('Zone 1 loaded'),
      onError: (ev) => print('Zone 1 error: $ev'),
      onHover: () {
        setState(() => highlighted1 = true);
        print('Zone 1 hovered');
      },
      onLeave: () {
        setState(() => highlighted1 = false);
        print('Zone 1 left');
      },
      onDrop: (ev) async {
        print('Zone 1 drop: ${ev.name}');
        setState(() {

          message1 = '$ev dropped';
          highlighted1 = false;
        });
        file = controller1.getFileStream(ev);
        bytes = await controller1.getFileData(ev);
        imageLength = bytes.length;
        print(bytes.sublist(0, 20));
      },
      onDropMultiple: (ev) async {
        print('Zone 1 drop multiple: $ev');
      },
    ),
  );
}
