import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../util/SizingInfo.dart';
import '../../util/db_connection.dart';
import '../../util/Util.dart';
import '../../util/states/States.dart';
import '../../util/states/login_state.dart';
import '../../values/ResponsiveApp.dart';
import '../WebComponents/Body/Container/SectionContainer.dart';

class WidgetRegister extends StatefulWidget {
  const WidgetRegister({Key? key}) : super(key: key);

  @override
  State<WidgetRegister> createState() => _WidgetRegisterState();
}

class _WidgetRegisterState extends State<WidgetRegister> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late ResponsiveApp responsiveApp;
  late AppData appData;
  late CartState cartState;
  late BDConnection bdConnection;
  List<BookingItem> listItem = [];
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final topItems = ['+1 Dominican Republic'];
  String selectedTop = '+1 Dominican Republic';
  // This function is triggered when the "Save" button is pressed
  void _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
        if(await bdConnection.setUser(
            context: context,
            role : 3,
            name: _firstNameController.text,
            comission: 0,
            email: _emailController.text,
            calling_code: selectedTop.split(' ')[0],
            mobile: _phoneNumberController.text,
            mobile_verified: 0,
            password: _passwordController.text
        )){
            Provider.of<LoginState>(
                context, listen: false)
                .login(User(
                rol_id : 3,
                name: _firstNameController.text,
                email: _emailController.text,
                comission: 0,
                calling_code: selectedTop.split(' ')[0],
                mobile: _phoneNumberController.text,
                mobile_verified: '0',
                password: _passwordController.text
            ), context,false,'booking');
        }else{
          CustomSnackBar().show(context: context, msg: 'Ha ocurrido un error al crear el usuario', icon: Icons.error, color: Colors.red);
        }
    }else{
      CustomSnackBar().show(context: context, msg: 'Formulario incompleto', icon: Icons.error, color: Colors.red);
    }
  }


  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    bdConnection  = BDConnection();
    appData = AppData();
    cartState = CartState();
    if(listItem.isEmpty){
      for(int i=0;i<cartState.getCartData().length;i++){
        listItem.add(BookingItem(
          business_service_id: cartState.getCartData()[i]['id'],
          quantity: cartState.getCartData()[i]['quantity'],
          unit_price: cartState.getCartData()[i]['price'],
          amount: cartState.getCartData()[i]['quantity'] * cartState.getCartData()[i]['price'],
        ));
      }
    }
    return SizedBox(
      width: isMobileAndTablet(context)?double.infinity:displayWidth(context)*0.8,
      child: Column(
        children: [
          Padding(
            padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
            child: SectionContainer(
              title: 'Verificar',
              subtitle: '',
              color: Colors.black,
            ),
          ),
          Container(
            width: isMobileAndTablet(context)?displayWidth(context)*0.95:displayWidth(context)*0.7,
            padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(responsiveApp.carrouselRadiusWidth),
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
                Row(
                  children: [
                    const Text('Ya tienes cuenta? ',
                      style: TextStyle(
                          color: Colors.grey
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed("/Login",
                        arguments: 'booking');
                      },
                      child: const Text('Acceder Ahora',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),

                      ),
                    )
                  ],
                ),
                SizedBox(height: responsiveApp.setHeight(20),),
                if(isMobileAndTablet(context))
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      form_1(),
                      SizedBox(width: responsiveApp.setWidth(15),),
                      form_2(),
                    ],
                  ),
                if(!isMobileAndTablet(context))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: form_1()),
                      SizedBox(width: responsiveApp.setWidth(50),),
                      Expanded(child: form_2()),
                    ],
                  )
              ],
            ),
          ),
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
                    _saveForm();
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
                          Text(
                            "Continuar con el pago",
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
  
  Widget form_1(){
    var dateFormat = DateFormat('EEEE, MMMM, dd');
    var hourFormat = DateFormat('dd-MMM-yyyy hh:mm a');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Añadir detalles",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: responsiveApp.setHeight(8),),
        Container(
          width: responsiveApp.setWidth(40),
          height: responsiveApp.setHeight(2),
          color: Colors.black,
        ),
        SizedBox(height: responsiveApp.setHeight(20),),

        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nombre*'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (value != null && value.trim().length < 3) {
                          return 'This field requires a minimum of 3 characters';
                        }

                        return null;
                      },
                      cursorColor: Colors.black,
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                          hintText: 'First Name',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red,))),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Text('Contraseña*'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (value != null && value.trim().length < 3) {
                          return 'This field requires a minimum of 3 characters';
                        }

                        return null;
                      },
                      cursorColor: Colors.black,
                      controller: _passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red,))),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Text('E-mail*'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (value != null && value.trim().length < 3) {
                          return 'This field requires a minimum of 3 characters';
                        }

                        return null;
                      },
                      cursorColor: Colors.black,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          hintText: 'E-mail',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red,))),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Text('Phone number*'),
              Row(
                children: [
                  Container(
                    //width: responsiveApp.setWidth(180),
                    padding: const EdgeInsets.only(left: 10, top: 1,bottom: 1),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(responsiveApp.setWidth(3))),

                    // dropdown below..
                    child: DropdownButton<String>(
                      value: selectedTop,
                      onChanged: (newValue) {
                        setState((){
                          selectedTop = newValue.toString();
                        });
                      },
                      items: topItems
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                //fontFamily: "Montserrat",
                              ),),
                          ))
                          .toList(),

                      // add extra sugar..
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      iconSize: 42,
                      underline: const SizedBox(),
                    ),
                  ),
                  if(!isMobileAndTablet(context))
                  SizedBox(width: responsiveApp.setWidth(8),),
                  if(!isMobileAndTablet(context))
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (value != null && value.trim().length < 10) {
                          return 'This field requires a minimum of 10 characters';
                        }

                        return null;
                      },
                      cursorColor: Colors.black,
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          hintText: 'Phone number',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red,))),
                    ),
                  ),
                ],
              ),
              if(isMobileAndTablet(context))
              const SizedBox(
                height: 20,
              ),
              if(isMobileAndTablet(context))
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value != null && value.trim().length < 10) {
                            return 'This field requires a minimum of 10 characters';
                          }

                          return null;
                        },
                        cursorColor: Colors.black,
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            hintText: 'Phone number',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red,))),
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 20,
              ),
              Text("** Su cuenta se creará automáticamente.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ],
    );
  }

  form_2(){
    var dateFormat = DateFormat('EEEE, MMMM, dd');
    var hourFormat = DateFormat('dd-MMM-yyyy hh:mm a');
    return Column(
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
              //width: displayWidth(context)*0.35,
              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
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
                      dateFormat.format(appData.getDateTimeSelected()),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: responsiveApp.setHeight(20),),
            Container(
              //width: displayWidth(context)*0.35,
              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
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
                      hourFormat.format(appData.getDateTimeSelected()).substring(12,20),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: responsiveApp.setHeight(20),),
            Container(
              //width: displayWidth(context)*0.35,
              padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(responsiveApp.setWidth(5)),
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
                      '\$${appData.getTotal()}',
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
          "¿Observaciones?",
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

        Container(
          //width: displayWidth(context)*0.35,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  maxLines: 5,
                  minLines: 1,
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                      hintText: 'Escriba su mensaje aquí...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)
                      ),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red,))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
