import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../util/db_connection.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../values/ResponsiveApp.dart';
import '../WebComponents/Body/Container/SectionContainer.dart';

class WidgetPago extends StatefulWidget {
  const WidgetPago({Key? key}) : super(key: key);

  @override
  State<WidgetPago> createState() => _WidgetPagoState();
}

class _WidgetPagoState extends State<WidgetPago> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late ResponsiveApp responsiveApp;
  late AppData appData;
  late BDConnection bdConnection;

  void _saveForm() {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
        print('Got a valid input');
      }
      // And do something here

  }

  @override
  Widget build(BuildContext context) {
    var dateFormat = DateFormat('EEEE, MMMM, dd');
    var hourFormat = DateFormat('dd-MMM-yyyy hh:mm a');
    responsiveApp = ResponsiveApp(context);
    bdConnection = BDConnection();
    appData = AppData();
    return FutureBuilder(
      future: bdConnection.getPaymentMethods(context),
      builder: (BuildContext cxt,AsyncSnapshot snapshot) {
        if(snapshot.data == null){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }else{
          //appData.setPaymentMethod(snapshot.data);
          return Column(
            children: [
              Padding(
                padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
                child: SectionContainer(
                  title: 'Pago',
                  subtitle: '',
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: isMobileAndTablet(context) ? displayWidth(context) * 0.9 : displayWidth(context) * 0.5,
                height: displayHeight(context) * 0.7,
                child: Column(
                  children: [
                    Container(
                      width: isMobileAndTablet(context) ? displayWidth(context) * 0.9 : displayWidth(context) * 0.5,
                      padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              responsiveApp.carrouselRadiusWidth),
                          boxShadow: const [
                            BoxShadow(
                                spreadRadius: -6,
                                blurRadius: 8,
                                offset: Offset(0,0)
                            )
                          ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: responsiveApp.setHeight(20),),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Resumen",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: responsiveApp.setHeight(8),),
                              Container(
                                width: responsiveApp.setWidth(40),
                                height: responsiveApp.setHeight(2),
                                color: Colors.black,
                              ),
                              SizedBox(height: responsiveApp.setHeight(20),),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    //width: displayWidth(context) * 0.35,
                                    padding: responsiveApp.edgeInsetsApp
                                        .allSmallEdgeInsets,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(
                                          responsiveApp.setWidth(5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Expanded(child: Text("Fecha")),
                                        Container(
                                          height: responsiveApp.setHeight(23.95),
                                          width: responsiveApp.setWidth(0.5),
                                          color: Colors.grey,
                                        ),
                                        Expanded(
                                          child: Text(
                                            dateFormat.format(
                                                appData.getDateTimeSelected()),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: responsiveApp.setHeight(20),),
                                  Container(
                                    //width: displayWidth(context) * 0.35,
                                    padding: responsiveApp.edgeInsetsApp
                                        .allSmallEdgeInsets,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(
                                          responsiveApp.setWidth(5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Expanded(child: Text("Hora")),
                                        Container(
                                          height: responsiveApp.setHeight(23.95),
                                          width: responsiveApp.setWidth(0.5),
                                          color: Colors.grey,
                                        ),
                                        Expanded(
                                          child: Text(
                                            hourFormat.format(
                                                appData.getDateTimeSelected())
                                                .substring(12, 20),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: responsiveApp.setHeight(20),),
                                  Container(
                                    //width: displayWidth(context) * 0.35,
                                    padding: responsiveApp.edgeInsetsApp
                                        .allSmallEdgeInsets,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(
                                          responsiveApp.setWidth(5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Expanded(child: Text("Pagar")),
                                        Container(
                                          height: responsiveApp.setHeight(23.95),
                                          width: responsiveApp.setWidth(0.5),
                                          color: Colors.grey,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '\$${appData.getTotalPagar()}',
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: responsiveApp.setHeight(20),),
                              const Text(
                                "Método de pago",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: responsiveApp.setHeight(8),),
                              Container(
                                width: responsiveApp.setWidth(40),
                                height: responsiveApp.setHeight(2),
                                color: Colors.black,
                              ),
                              SizedBox(height: responsiveApp.setHeight(20),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if(snapshot.data.razorpay_status !=null && snapshot.data.razorpay_status =='active')
                                    _paymentMethod(method: ' RazorPay', icon: Icons.payment, onTap: (){}),
                                  if(snapshot.data.paypal_status !=null && snapshot.data.paypal_status =='active')
                                    SizedBox(width: responsiveApp.setWidth(20),),
                                  if(snapshot.data.stripe_status !=null && snapshot.data.stripe_status =='active')
                                    _paymentMethod(method: ' Stripe', icon: Icons.currency_bitcoin, onTap: (){}),
                                  if(snapshot.data.paypal_status !=null && snapshot.data.paypal_status =='active')
                                    SizedBox(width: responsiveApp.setWidth(20),),
                                  if(snapshot.data.paypal_status !=null && snapshot.data.paypal_status =='active')
                                    _paymentMethod(method: ' PayPal', icon: Icons.paypal, onTap: (){}),
                                  if(snapshot.data.paypal_status !=null && snapshot.data.paypal_status =='active')
                                    SizedBox(width: responsiveApp.setWidth(20),),
                                    _paymentMethod(method: ' Pagar en tienda', icon: Icons.store_rounded, onTap: (){
                                      Navigator.pop(context);
                                    }),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(
                                responsiveApp.setWidth(5))
                        ),
                        child: Padding(
                          padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
                          child: Row(
                            children: [
                              Icon(Icons.home,
                                size: responsiveApp.setWidth(8),color: Colors.white,),
                              SizedBox(width: responsiveApp.setWidth(8),),
                              Text(
                                "Ir a la cuenta",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.white),
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
          );
        }
      }
    );
  }

  Widget _paymentMethod({required String method, required IconData icon, Function()? onTap}){
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87,),
            Text(method,style: const TextStyle(color: Colors.black87),),
          ],
        ),
      ),
    );
  }

}