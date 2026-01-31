import 'package:flutter/material.dart';
import '../../values/ResponsiveApp.dart';
import 'package:provider/provider.dart';

import '../../util/Util.dart';
import '../../util/states/States.dart';

class CartItemWidget extends StatefulWidget {
  final dynamic itemData;
  final Function() onUpdate;

  const CartItemWidget({super.key, 
    required this.itemData,
    required this.onUpdate,
  });

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late ResponsiveApp responsiveApp;
  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: texto(
                  size: responsiveApp.setSP(12),
                  text: '${widget.itemData['name']}',
                ),
              ),
              SizedBox(
                width: responsiveApp.setWidth(60),
                child: Center(
                  child: texto(
                    size: responsiveApp.setSP(12),
                    text: '\$${widget.itemData['price']}',
                  ),
                ),
              ),
              Container(
                width: responsiveApp.setWidth(70),
                //height: 52,
                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                alignment: Alignment.center,
                child: Container(
                  width: responsiveApp.setWidth(70),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(3)),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.itemData['quantity'] > 1) {
                            setState(() {
                              Provider.of<CartState>(context, listen: false).setPrefs(
                                context,
                                widget.itemData['id'],
                                widget.itemData['name'],
                                -1,
                                widget.itemData['price'],
                              );
                            });
                            widget.onUpdate();
                          }
                        },
                        child: Container(
                          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.10),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(responsiveApp.setWidth(3)),bottomLeft: Radius.circular(responsiveApp.setWidth(3)))
                          ),
                          child: const Text("-"),
                        ),
                      ),
                      Container(
                        height: responsiveApp.setHeight(23.9),
                        width: responsiveApp.setWidth(0.5),
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: responsiveApp.setHeight(23.9),
                          child: Center(
                              child: texto(
                                text: widget.itemData['quantity'].toString(),
                                size: responsiveApp.setSP(12),
                              )
                          ),
                        ),
                      ),
                      Container(
                        height: responsiveApp.setHeight(23.95),
                        width: responsiveApp.setWidth(0.5),
                        color: Colors.grey,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            Provider.of<CartState>(context, listen: false).setPrefs(
                              context,
                              widget.itemData['id'],
                              widget.itemData['name'],
                              1,
                              widget.itemData['price'],
                            );
                          });
                          widget.onUpdate();
                        },
                        child: Container(
                          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.10),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(responsiveApp.setWidth(3)),bottomRight: Radius.circular(responsiveApp.setWidth(3)))
                          ),
                          child: const Text("+"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: responsiveApp.setWidth(60),
                child: Center(
                  child: texto(
                    size: responsiveApp.setSP(12),
                    text: '\$${(widget.itemData['quantity'] * widget.itemData['price']).toString()}',
                  ),
                ),
              ),
              InkWell(
                  onTap: (){
                    setState(() {
                      Provider.of<CartState>(context, listen: false).removeItemFromCart(context, widget.itemData['id']);
                    });
                    widget.onUpdate();
                  },
                  child: const Icon(Icons.cancel_rounded,color: Colors.black,)),
            ],
          ),
        ),
      ],
    );
  }
}