import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../util/SizingInfo.dart';
import '../../util/Util.dart';
import '../../util/states/login_state.dart';
import '../../values/ResponsiveApp.dart';
import '../answer_questions_widget.dart';

class WidgetLogin extends StatefulWidget {
  const WidgetLogin({Key? key,required this.reason}) : super(key: key);
  final String reason;

  @override
  State<WidgetLogin> createState() => _WidgetLoginState();
}

class _WidgetLoginState extends State<WidgetLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late ResponsiveApp responsiveApp;
  late User     user;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<bool> _isHovering=[
    false,
    false,
    false,
    false,
  ];

  final topItems = ['+1 Dominican Republic'];
  String selectedTop = '+1 Dominican Republic';
  bool rememberMe = false;
  bool verPass = false;
  // This function is triggered when the "Save" button is pressed
  void _saveForm() {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {

      user.email = _emailController.text;
      user.password = _passwordController.text;
      Provider.of<LoginState>(
          context, listen: false)
          .login(user, context,rememberMe,widget.reason );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    user = User();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: responsiveApp.setHeight(35),left: responsiveApp.setWidth(16),right: responsiveApp.setWidth(16),),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        //height: 40.0,
                        width: isMobileAndTablet(context)? displayWidth(context) * 0.8 :  350.0,
                        padding: const EdgeInsets.only(top: 4,left: 16,right: 16,bottom: 4),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular((50))),
                          color: Colors.transparent,
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if (value != null && value.trim().length < 3) {
                              return 'This field requires a minimum of 3 characters';
                            }
                            return null;
                          },
                          enableIMEPersonalizedLearning: true,
                          autofocus: false,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          //autovalidateMode: AutovalidateMode.onUserInteraction,
                          enableInteractiveSelection: true,
                          enableSuggestions: true,
                          scribbleEnabled: true,
                          //style: TextStyle(color: Colors.white.withOpacity(0.9)),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.person,
                              color: Colors.black.withOpacity(0.7),
                            ),
                            hintText: 'Usuario',
                            border: InputBorder.none,
                          ),
                          autofillHints: const [AutofillHints.username],
                          /* onTap: (){
                            setState(() {
                              focusColorfield1=Colors.orange;
                              focusColorfield2=Colors.transparent;
                            });
                          },

                          */
                        ),
                      ),
                      Container(height: 1.0,width: isMobileAndTablet(context)? displayWidth(context) * 0.8 :  350.0,
                        color: Colors.black.withOpacity(0.9),),
                      const Padding(padding: EdgeInsets.all(8.0)),

                      Container(
                        //height: 40.0,
                        width: isMobileAndTablet(context)? displayWidth(context) * 0.8 :  350.0,
                        padding: const EdgeInsets.only(top: 4,left: 16,right: 16,bottom: 4),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular((50))),
                          color: Colors.transparent,
                          //border: Border.all(color: focusColorfield2,),
                          /*boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                              )
                            ]

                             */
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if (value != null && value.trim().length < 3) {
                              return 'This field requires a minimum of 3 characters';
                            }
                            return null;
                          },
                          obscureText: verPass?false:true,
                          controller: _passwordController,
                          //style: TextStyle(color: Colors.black.withOpacity(0.9),),
                          decoration: InputDecoration(
                            suffix: InkWell(
                              onTap: (){
                                setState((){
                                  verPass = !verPass;
                                });
                              },
                              child: Icon(
                                  verPass? Icons.disabled_visible: Icons.remove_red_eye,
                                  color: Colors.black.withOpacity(0.7)
                              ),
                            ),
                            icon: Icon(
                              Icons.vpn_key,
                              color: Colors.black.withOpacity(0.7),
                            ),
                            hintText: 'Contraseña',
                            border: InputBorder.none,

                          ),
                          onEditingComplete: () => _saveForm(),
                          /* onTap: (){
                            setState(() {
                              focusColorfield1=Colors.transparent;
                              focusColorfield2=Colors.orange;
                            });
                          },

                          */
                        ),
                      ),
                      Container(height: 1.0,width: isMobileAndTablet(context)? displayWidth(context) * 0.8 :  350.0,
                          color: Colors.black.withOpacity(0.9))
                    ],
                  ),
                ),
                SizedBox(height: responsiveApp.setHeight(30),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onHover: (v){
                        setState(() {
                          _isHovering[2]=v;
                        });
                      },
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                            const  AnswerQuestionsWidget()));
                      },
                      child: Text("Olvidé mi contraseña!",
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: responsiveApp.setSP(12),
                          color: _isHovering[2]?Colors.red:Theme.of(context).textTheme.bodySmall! .color,//Colors.black.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsiveApp.setHeight(30),),

                Consumer<LoginState>(
                  builder: (BuildContext context, LoginState value, Widget? child){
                    if(value.isLoading()){
                      return Center(
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              backgroundColor: Colors.transparent,
                              color: const Color(0xff6C9BD2).withOpacity(0.9),
                            ),

                          ],
                        ),
                      );
                    }else{
                      return child!;
                    }
                  },
                  child: InkWell(
                    onHover: (v){
                      setState(() {
                        _isHovering[0]=v;
                      });
                    },
                    onTap: (){
                      _saveForm();
                    },
                    child: Padding(
                      padding: isMobileAndTablet(context) ? EdgeInsets.zero : responsiveApp.edgeInsetsApp.hrzLargeEdgeInsets,
                      child: Container(
                        height: responsiveApp.setHeight(50),
                        //width: isMobileAndTablet(context)? displayWidth(context) * 0.8 :  350.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(25)),
                          color: _isHovering[0]?const Color(0xff6C9BD2).withOpacity(0.8):const Color(0xff6C9BD2),
                        ),
                        child: Center(
                          child: Text("INICIAR SESION",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile(context)? responsiveApp.setSP(12) : responsiveApp.setSP(14),
                                fontFamily: "Montserrat",
                                letterSpacing: 3
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // _submit(),
                const Padding(padding: EdgeInsets.all(10.0)),
                Padding(
                  padding: responsiveApp.edgeInsetsApp.allLargeEdgeInsets,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text("Mantenerme conectado",
                          style: TextStyle(fontSize: 15.0,//color: Colors.black.withOpacity(0.9)
                          ),
                        ),
                      ),
                      //SizedBox(width: responsiveApp.setWidth(10),),
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onHover: (v){
                          setState(() {
                            _isHovering[3]=v;
                          });
                        },
                        onTap: (){
                          setState(() {
                            rememberMe = !rememberMe;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.decelerate,
                          width: responsiveApp.setWidth(35),
                          decoration:BoxDecoration(
                            borderRadius:BorderRadius.circular(50.0),
                            color: rememberMe ? const Color(0xff6C9BD2) : Colors.grey.withOpacity(0.6),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            alignment: rememberMe ? Alignment.centerRight : Alignment.centerLeft,
                            curve: Curves.decelerate,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.decelerate,
                                width: _isHovering[3]? responsiveApp.setWidth(18): responsiveApp.setWidth(15),
                                height: responsiveApp.setHeight(15),
                                decoration:BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius:BorderRadius.circular(100.0),
                                ),
                              ),
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
      ],
    );
  }
}
