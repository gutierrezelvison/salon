
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../util/SizingInfo.dart';
import '../../util/states/States.dart';
import '../../util/Util.dart';
import '../../util/db_connection.dart';
import '../../util/states/login_state.dart';
import '../../values/ResponsiveApp.dart';
import '../WebComponents/Body/Container/SectionContainer.dart';
import 'package:provider/provider.dart';

import 'cart_item.dart';

class WebCart extends StatefulWidget {
  const WebCart({Key? key, required this.onUpdate}) : super(key: key);
  final Function() onUpdate;

  @override
  State<WebCart> createState() => _WebCartState();
}

class _WebCartState extends State<WebCart> {
  late ResponsiveApp responsiveApp;
  late AppData appData =AppData();
  late BDConnection bdConnection = BDConnection();
  double subTotal=0;
  double total=0;
  double itbis=0;
  NumberFormat numberFormat = NumberFormat('#,###.##', 'en_Us');
  List<dynamic> cartData = [];

  updateState(){
      cartData = CartState().getCartData();

      subTotal = cartData.fold(0, (total, cartItem) {
        var quantity = cartItem['quantity'] as int;
        var price = cartItem['price'] as double;
        return total + (quantity * price);
      });

      itbis = subTotal * (double.parse(appData.getTaxData().percent.toString())/100);

      total = subTotal + itbis;

      appData.setSubTotal(subTotal);
      appData.setItbis(itbis);
      appData.setTotal(total);
  }

  setBooking()async{
    BDConnection dbConnection = BDConnection();

    List<BookingItem> listItem = [];
    for(int i=0;i<cartData.length;i++){
      listItem.add(BookingItem(
        business_service_id: cartData[i]['id'],
        quantity: cartData[i]['quantity'],
        chair_id: appData.getChairSelected(),
        unit_price: cartData[i]['price'],
        amount: cartData[i]['quantity'] * cartData[i]['price'],
      ));
    }

    if((await dbConnection.setBooking(
    context             : context,
    user_id             : appData.getUserData().id,
    //chairId             : appData.getChairSelected(),
    date_time           : appData.getDateTimeSelected(),
    status              : 'pending',
    payment_gateway     : 'cash',
    original_amount     : appData.getSubTotal(),
    discount            : 0,
    discount_percent    : 0,
    tax_name            : appData.getTaxData().tax_name,
    tax_percent         : appData.getTaxData().percent,
    tax_amount          : appData.getItbis(),
    amount_to_pay       : appData.getTotal(),
    payment_status      : 'pending',
    source              : 'online',
    itemList            : listItem,
    ))["success"]
    ) {
    appData.setTotalPagar(appData.getTotal());
    CartState().cleanCart(context);
    Navigator.pop(context);
    Navigator.of(context).pushNamed("/pago");
    }
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    updateState();
    return SizedBox(
      width: displayWidth(context)*0.8,
      height: isMobileAndTablet(context)?null: displayHeight(context)*0.75,
      child: Column(
        children: [
          Padding(
            padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
            child: SectionContainer(
              title: 'Detalles de la Reserva',
              subtitle: '',
              color: Colors.black,
            ),
          ),
          if (!isMobileAndTablet(context))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCart(),
                _buildSummary(),
              ],
            ),
          if (isMobileAndTablet(context))
            Column(
              children: [
                _buildCart(),
                SizedBox(height: responsiveApp.setHeight(40),),
                _buildSummary(),
              ],
            ),
          //const Expanded(child: SizedBox()),
          SizedBox(height: responsiveApp.setHeight(80),),
          Padding(
            padding: isMobileAndTablet(context)?responsiveApp.edgeInsetsApp.hrzMediumEdgeInsets :responsiveApp.edgeInsetsApp.hrzExtraLargeEdgeInsets,
            child: Row(
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
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    if(CartState().getCartData().isNotEmpty) {
                      if (appData.getDateTimeSelected() != null &&
                          appData.getChairSelected() != null) {
                        if (Provider.of<LoginState>(context, listen: false).isLoggedIn()) {
                          appData.setTotalPagar(appData.getTotal());
                          setBooking();
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed("/pago");
                        } else {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(
                              "/register");
                        }
                      } else
                      if (appData.getDateTimeSelected() == null) {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(
                            "/selectTime");
                      } else if (appData.getChairSelected() == null) {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(
                            "/chair_selection",
                            arguments: appData.getDateTimeSelected());
                      }
                    }
                  },
                  child: Container(
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    decoration: BoxDecoration(
                        color: CartState().getCartData().isNotEmpty?Colors.black.withOpacity(0.8):Colors.grey,
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(5))
                    ),
                    child: Padding(
                      padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                      child: Row(
                        children: [
                          Text(
                            appData.getDateTimeSelected()==null?"Elija la hora":appData.getChairSelected()==null?"Elija la Silla":"Proceder a la compra",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
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
          ),
          SizedBox(height: responsiveApp.setHeight(40),),
        ],
      ),
    );
  }

  Widget _buildCart() {
    return Padding(
      padding: EdgeInsets.all(responsiveApp.setWidth(8)),
      child: Column(
        children: [
          Container(
            height: responsiveApp.setHeight(5),
            width: responsiveApp.setWidth(590),
            color: Colors.black,
          ),
          Container(
            width: responsiveApp.setWidth(590),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(responsiveApp.setWidth(5)),bottomLeft: Radius.circular(responsiveApp.setWidth(5))),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0,0),
                  )
                ]
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        //color: Colors.blueGrey,
                        child: Row(
                          children: [
                            Expanded(
                              child: texto(
                                size: responsiveApp.setSP(12),
                                text: 'Artículo',
                                //color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(60),
                              child: Center(
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: 'Precio',
                                  //color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(70),
                              child: Center(
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: 'Cantidad',
                                  //color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(60),
                              child: Center(
                                child: texto(
                                  size: responsiveApp.setSP(12),
                                  text: 'Total',
                                  //color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: responsiveApp.setWidth(25),
                              child: texto(
                                size: responsiveApp.setSP(12),
                                text: '',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Container(height: responsiveApp.setHeight(1),color: Colors.grey,)),
                  ],
                ),
                if(cartData.isNotEmpty)
                  Column(
                    children:
                    List.generate(
                      cartData.length,
                          (int index){
                        return Column(
                          children: [
                            CartItemWidget(
                              itemData: cartData[index],
                              onUpdate: () {
                                setState(() {
                                  updateState();
                                });
                                widget.onUpdate();
                              },
                            ),
                            if (index < cartData.length - 1)
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: responsiveApp.setHeight(1),
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(responsiveApp.setWidth(10)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              if(cartData.isEmpty)
                                Icon(Icons.remove_shopping_cart_outlined,color:  Colors.grey, size: responsiveApp.setWidth(20),),
                              if(cartData.isEmpty)
                                texto(text: "Ningun articulo seleccionado", size: responsiveApp.setSP(12),color: Colors.grey),
                              if(cartData.isEmpty)
                                SizedBox(height: responsiveApp.setHeight(10)),
                            ],
                          ),
                        ),
                      ]
                  ),
                ),
                Container(
                  height: responsiveApp.setHeight(1),
                  width: responsiveApp.setWidth(590),
                  color: Colors.grey.withOpacity(0.3),
                ),
                Padding(
                  padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap:(){
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                          ),
                          child: const Text("Continuar Reservando"),
                        ),
                      ),
                      if(cartData.isNotEmpty)
                        SizedBox(width: responsiveApp.setWidth(20),),
                      if(cartData.isNotEmpty)
                        InkWell(
                          onTap:(){
                            setState((){

                              Provider.of<CartState>(context, listen: false).cleanCart(context);
                            });
                          },
                          child: Container(
                            padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                            ),
                            child: const Text("Vaciar Carrito"),
                          ),
                        ),
                      SizedBox(width: responsiveApp.setWidth(20),),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        Container(
          width: isMobileAndTablet(context)?  displayWidth(context)*0.9 : responsiveApp.setWidth(250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsiveApp.setWidth(3)),
            color: Colors.black.withOpacity(0.8),
          ),
          child: Column(
            children: [
              Padding(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                child: Container(
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.9)),
                    borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Total de Articulos",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold,color: Colors.white.withOpacity(0.9)),),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sub Total',style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withOpacity(0.9)),),
                    Text('RD\$ ${numberFormat.format(appData.getSubTotal())}',style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withOpacity(0.9)),),
                  ],
                ),
              ),
              Padding(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ITBIS (${appData.getTaxData().percent}%)',style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withOpacity(0.9)),),
                    Text('RD\$ ${numberFormat.format(appData.getItbis())}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withOpacity(0.9)),),
                  ],
                ),
              ),
              Container(
                width: responsiveApp.setWidth(240),
                height: responsiveApp.setHeight(0.5),
                color: Colors.grey.withOpacity(0.3),
              ),
              Padding(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:',style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withOpacity(0.9)),),
                    Text('RD\$ ${numberFormat.format(appData.getTotal())}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withOpacity(0.9)),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
