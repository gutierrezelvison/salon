import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:salon/util/db_connection.dart';

import '../../util/Util.dart';
import '../../values/ResponsiveApp.dart';

class CustomTable extends StatefulWidget {
  final int lastBatchSequenceNumber;
  final BuildContext context;
  final String movementType;
  final String origin;
  final List<InventoryMovement>? initialData;
  final Function(List<InventoryMovement>) onUpdate;

  const CustomTable({super.key, required this.movementType,required this.context,required this.lastBatchSequenceNumber, required this.onUpdate, required this.origin, this.initialData});

  @override
  _CustomTableState createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  List<InventoryMovement> rows = [];
  late ResponsiveApp responsiveApp;
  late BDConnection dbConnection;
  List<String> prodCodeItems = [];
  List<String> prodNameItems = [];
  List<Batch> batchList=[];
  String? selectedProductCode;
  String? selectedProductName;
  List<Service> prodList =[];

  void addNewRow(InventoryMovement newRow) {
    setState(() {
      rows.add(newRow);
    });
  }

  List<List<String>> _parseClipboardData(String clipboardData) {
    List<List<String>> tableData = [];
    List<String> rowsData = clipboardData.split('\n');
    for (var row in rowsData) {

      tableData.add(row.split('\t'));

    }
    return tableData;
  }

  Future<void> pasteDataFromClipboard() async {
    String clipboardData = await Clipboard.getData('text/plain').then((value) => value?.text ?? '');
    List<List<String>> tableData = _parseClipboardData(clipboardData);
    tableData.removeLast();
    for (var rowData in tableData) {
// Agregar un nuevo elemento a la lista
      InventoryMovement newDataRow = InventoryMovement(
        product : Service(
          id  : int.parse(rowData[0]),
          name  : rowData[1],
        ),
        quantity          : double.parse(rowData[2]),
        cost             : double.parse(rowData[4]),
        batch             : Batch(batch: 'P-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}-${(widget.lastBatchSequenceNumber+(rows.length+1)).toString().padLeft(3,'0')}'),
        //expiration_date   : rowData[7],
      );
      setState(() {
        addNewRow(newDataRow);
      });
      widget.onUpdate(rows);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    rows = List.from(widget.initialData??[]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp =ResponsiveApp(context);
    dbConnection = BDConnection(context: context);
    //if(rows.isEmpty)addNewRow(InventoryMovement());
    return Container(
            margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(responsiveApp.setWidth(8)),
                boxShadow: const [
                  BoxShadow(
                      spreadRadius: -7,
                      blurRadius: 8,
                      offset: Offset(0, 1)
                  )
                ]
            ),
            child: Column(
              children: [
                Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  margin: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(8)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: responsiveApp.setWidth(100),
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                          child: texto(text: 'Producto',color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                          child: texto(text: 'Nombre del producto', color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: responsiveApp.setWidth(100),
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                          child: texto(text: 'Cantidad',color: Colors.white),
                        ),
                      ),
                      if(widget.movementType=='entrada')
                      SizedBox(
                        width: responsiveApp.setWidth(100),
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                          child: texto(text: widget.origin=='inventory'? 'Costo':'ITBIS',color: Colors.white),
                        ),
                      ),
                      if(widget.movementType=='entrada')
                      SizedBox(
                        width: responsiveApp.setWidth(100),
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                          child: texto(text: widget.origin=='inventory'? 'Moneda':'Monto',color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: responsiveApp.setWidth(140),
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                          child: texto(text: 'Lote',color: Colors.white),
                        ),
                      ),
                    /*  if(widget.movementType=='entrada')
                        SizedBox(
                          width: responsiveApp.setWidth(140),
                          child: Padding(
                            padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                            child: texto(text: 'Fecha Caducidad', size: responsiveApp.setSP(14),color: Colors.white),
                          ),
                        ),

                     */
                    ],
                  ),
                ),
                for (var index = 0; index < rows.length; index++)
                  ItemRow(
                    origin: widget.origin,
                    movement: widget.movementType,
                    context: widget.context,
                    rowData: rows[index],
                    products: prodList,
                    batchList: batchList,
                    prodCodeItems: prodCodeItems,
                    prodNameItems: prodNameItems,
                    onSearch: (campo,data){
                    },
                    onUpdate: (updatedRow) {
                      if(widget.origin=='inventory') getBatchList(updatedRow.product!.id!);
                      setState(() {
                        rows[index] = updatedRow;
                      });
                      widget.onUpdate(rows);
                    },
                    onDelete: () {
                      setState(() {
                        rows.removeAt(index);
                      });
                      widget.onUpdate(rows);
                    },
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          rows.add(widget.movementType=='entrada'? InventoryMovement(batch: Batch(batch:'P-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}-${(widget.lastBatchSequenceNumber+(rows.length+1)).toString().padLeft(3,'0')}')):InventoryMovement());
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                    SizedBox(width: responsiveApp.sectionWidth,),
                    ElevatedButton(
                      onPressed: () {
                        //setState(() {
                        pasteDataFromClipboard();
                        //});
                      },
                      child: const Icon(Icons.content_paste_rounded),
                    ),
                  ],
                )
              ],
            ),
          );
    }


  getBatchList(int productId)async{
    batchList.clear();
    for (var element in await dbConnection.getData(
        onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
        context: context,
        fields: '*',
        table: 'batch',
        where: 'product_id = $productId AND status = \'available\' AND quantity > 0',
        order: 'DESC',
        orderBy: 'batch',
        groupBy: 'id')){
      setState(() {
        batchList.add(
            Batch(
                id: int.parse(element['id']),
                product_id: int.parse(element['product_id']),
                batch: element['batch'],
                cost: element['cost'],
                expiration_date: element['expiration_date'],
                quantity: element['quantity'],
                status: element['status'],
                description: element['description']
            )
        );
      });
    }
  }
}

class ItemRow extends StatefulWidget {
  final BuildContext context;
  final InventoryMovement rowData;
  final void Function(InventoryMovement) onUpdate;
  final void Function(String, String) onSearch;
  final VoidCallback  onDelete;
  final List<Service> products;
  final List<String>  prodCodeItems;
  final List<String>  prodNameItems;
  final List<Batch>?  batchList;
  final String        movement;
  final String        origin;


  const ItemRow({super.key,
    required this.context,
    required this.rowData,
    required this.products,
    required this.onUpdate,
    required this.onDelete,
    this.batchList,
    required this.movement,
    required this.prodCodeItems,
    required this.prodNameItems,
    required this.onSearch, required this.origin,
  });

  @override
  State<ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<ItemRow> {
  late ResponsiveApp responsiveApp;
  NumberFormat numberFormat = NumberFormat('#,###.##', 'en_Us');

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: responsiveApp.setWidth(110),
                child:customTypeAhead(controller: widget.rowData.product!=null?TextEditingController(text: widget.rowData.product!.id.toString()):TextEditingController(),
                    margin: EdgeInsets.zero,
                    icon: const SizedBox(),
                    onSelect: (suggestion) {
                      widget.onUpdate(InventoryMovement(
                        product : Service(
                          id    : int.parse(suggestion['id'].toString()),
                          name  : suggestion['name'].toString(),

                        ),
                        quantity          : widget.rowData.quantity,
                        cost             : widget.rowData.cost,
                        batch             : widget.rowData.batch,
                        tax             : widget.rowData.tax,
                        total:  widget.rowData.total,
                        expiration_date   : widget.rowData.expiration_date,
                      ));
                    },
                    suggestionsCallBack: (pattern) {
                      return (BDConnection(context: context).getData(
                          onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
                          context: context,
                          fields: 'product.`id`, product.`name`',
                          table: 'business_services product ',
                          where: '(product.`name` LIKE \'%$pattern%\') AND product.`type` <>\'service\'',
                          order: 'ASC',
                          orderBy: 'product.`id`',
                          groupBy: 'product.`id`'
                      ));
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Row(
                          children: [
                            Text(suggestion['id']!.toString(),
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,),
                            const SizedBox(width: 10,),
                            Expanded(child: Text(
                              suggestion['name']!.toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,)),
                          ],
                        ),
                      );
                    }
                ),),
            Expanded(child: customTypeAhead(controller: widget.rowData.product!=null?TextEditingController(text: widget.rowData.product!.name):TextEditingController(),
                margin: EdgeInsets.zero,
                icon: const SizedBox(),
                onSelect: (suggestion) {
                  widget.onUpdate(InventoryMovement(
                    product : Service(
                      id    : int.parse(suggestion['id'].toString()),
                      name  : suggestion['name'].toString(),

                    ),
                    quantity          : widget.rowData.quantity,
                    cost             : widget.rowData.cost,
                    batch             : widget.rowData.batch,
                    tax             : widget.rowData.tax,
                    total:  widget.rowData.total,
                    expiration_date   : widget.rowData.expiration_date,
                  ));
                },
                suggestionsCallBack: (pattern) {
                  return (BDConnection(context: context).getData(
                      onError: (e){warningMsg(context: context, mainMsg: '¡Error!', msg: e, okBtnText: 'Aceptar', okBtn: (){Navigator.pop(context);});},
                      context: context,
                      fields: 'product.`id`, product.`name`',
                      table: 'business_services product ',
                      where: '(product.`name` LIKE \'%$pattern%\') AND product.`type` <>\'service\'',
                      order: 'ASC',
                      orderBy: 'product.`id`',
                      groupBy: 'product.`id`'
                  ));
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Row(
                      children: [
                        Text(suggestion['id']!.toString(),
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,),
                        const SizedBox(width: 10,),
                        Expanded(child: Text(
                          suggestion['name']!.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,)),
                      ],
                    ),
                  );
                }
            ),),
            SizedBox(width: responsiveApp.setWidth(100),
              child: customField(context: context, margin: const EdgeInsets.only(left: 5),
                  initialValue: numberFormat.format(widget.rowData.quantity??0.0),
                  hintText: 'Ej: 1, 1.5, 2...', keyboardType: TextInputType.number,
                  onChanged: (v){
              widget.onUpdate(InventoryMovement(
                product: widget.rowData.product,
                quantity          : v!=''?double.parse(v):0.0,
                cost             : widget.rowData.cost,
                tax             : widget.rowData.tax,
                batch             : widget.rowData.batch,
                total:  ((v!=''?double.parse(v):0.0) * ((widget.rowData.tax??0)+(widget.rowData.cost??0))),
                expiration_date   : widget.rowData.expiration_date,
              ));

            }),),

           if(widget.movement=='entrada')
            SizedBox(width: responsiveApp.setWidth(100),
                child: customField(context: context, margin: const EdgeInsets.only(left: 5), initialValue: widget.origin=='inventory'?numberFormat.format(widget.rowData.cost??0.0):numberFormat.format(widget.rowData.tax??0.0), hintText: 'Ej: 9.99', keyboardType: TextInputType.number,onChanged: (v){
                  widget.onUpdate(InventoryMovement(
                product: widget.rowData.product,
                quantity          : widget.rowData.quantity,
                cost             : widget.origin=='inventory'? v!=''?double.parse(v):0.0:widget.rowData.cost,
                batch             : widget.rowData.batch,
                tax             : widget.origin=='inventory'?widget.rowData.tax: v!=''?double.parse(v):0.0,
                total:  ((widget.rowData.quantity??0) * ((v!=''?double.parse(v):0.0)+(widget.rowData.cost??0))),
                expiration_date   : widget.rowData.expiration_date,
              ));
            })),
            if(widget.movement=='entrada')
            SizedBox(width: responsiveApp.setWidth(100), child:
            customField(context: context, margin: const EdgeInsets.only(left: 5), controller: TextEditingController(text: widget.origin=='inventory'? 'DOP':numberFormat.format(widget.rowData.total??0.0)), hintText: widget.origin=='inventory'? 'Ej: DOP':'Ej: 1.0', keyboardType: widget.origin=='inventory'?TextInputType.text:TextInputType.number,
            onChanged: (v){
              if(widget.origin!='inventory'){
                widget.onUpdate(InventoryMovement(
                  product: widget.rowData.product,
                  quantity          : widget.rowData.quantity,
                  cost             : widget.rowData.cost,
                  batch             : widget.rowData.batch,
                  tax: widget.rowData.tax,
                  total:  v!=''?double.parse(v):0.0,
                  expiration_date   : widget.rowData.expiration_date,
                ));
              }
            }
            )),
            if(widget.movement == 'entrada')
            SizedBox(width: responsiveApp.setWidth(120),
                child: customField(context: context, margin: const EdgeInsets.only(left: 5), initialValue: (widget.rowData.batch?.batch)??'', hintText: 'Ej: P-231231-01', keyboardType: TextInputType.text,onChanged: (v){
              widget.onUpdate(InventoryMovement(
                product: widget.rowData.product,
                quantity          : widget.rowData.quantity,
                cost             : widget.rowData.cost,
                batch             : Batch(batch: v),
                tax             : widget.rowData.tax,
                total:  widget.rowData.total,
                expiration_date   : widget.rowData.expiration_date,
              ));
            })),
            if(widget.movement == 'salida')
              SizedBox(width: responsiveApp.setWidth(120), child: customDropDownField(context: context,initialValue: null, options: widget.batchList!.map((map) => map.batch.toString()).toList(), label: 'Lote', onSelected: (v){
                widget.onUpdate(InventoryMovement(
                  product : Service(
                    id    : widget.rowData.product!.id,
                    name  : widget.rowData.product!.name,

                  ),
                  quantity          : widget.rowData.quantity,
                  cost             : widget.rowData.cost,
                  tax             : widget.rowData.tax,
                  total:  widget.rowData.total,
                  batch             : Batch(id: widget.batchList!.firstWhere((item)=>item.batch==v).id,batch: v,quantity: widget.batchList!.firstWhere((item)=>item.batch==v).quantity),
                  expiration_date   : widget.rowData.expiration_date,
                ));
                if (kDebugMode) {
                  print(v);
                }
              },)),
            /*
            if(widget.movement=='entrada')
            SizedBox(width: responsiveApp.setWidth(120), child: field(context: context, initialValue: widget.rowData.expiration_date ?? '', label: 'Fercha de caducidad', hint: 'Ej: 2023-12-31', keyboardType: TextInputType.text,onChanged: (v){
              widget.onUpdate(InventoryMovement(
                product: widget.rowData.product,
                quantity: widget.rowData.quantity,
                cost: widget.rowData.cost,
                batch: widget.rowData.batch,
                expiration_date: v,
              ));
            })),

             */
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: widget.onDelete,
              color: Colors.red,
            ),
          ],
        ),


        // Agrega más filas para el resto de los campos (date, month, status, etc.)
        const Divider(color: Colors.transparent, height: 5,),
      ],
    );
  }
}
