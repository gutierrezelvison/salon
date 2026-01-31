import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../Pages/chairSelectionPage.dart';
import 'package:provider/provider.dart';
import 'Pages/CartPage.dart';
import 'Pages/HomePage.dart';
import 'Pages/LoginPage.dart';
import 'Pages/MainPage.dart';
import 'Pages/RegisterPage.dart';
import 'Pages/TimeSelectionPage.dart';
import 'Pages/payment_page.dart';
import 'util/Util.dart';
import 'util/check_for_updates.dart';
import 'util/db_connection.dart';
import 'pages/local_auth.dart';
import 'util/di.dart' as di;
import 'util/states/States.dart';
import 'util/states/local_auth_state.dart';
import 'util/states/login_state.dart';
import 'util/states/theme_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  checkForUpdate();
  Timer.periodic(Duration(minutes: 5), (timer) => checkForUpdate()); // Verifica cada 5 min
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child){
        return MultiProvider(
          providers: [
            //se declaran los proveedores de estado para obtener datos de ellos en tiempo de ejecucion
            ChangeNotifierProvider<ThemeState>(
              create: (_) => ThemeState(),
            ),
            ChangeNotifierProvider<CartState>(
              create: (_) => CartState(),
            ),
            ChangeNotifierProvider<LocalAuthState>(
              create: (BuildContext context) => GetIt.instance(),
            ),
            ChangeNotifierProvider<LoginState>(
              create: (BuildContext context) => GetIt.instance(),
            ),
            //configuramos un proxyprovider para obtener el estado de inicio de sesion
            ProxyProvider<LoginState, BDConnection>(
              update: (ctx, LoginState value, __) {
                if (value.isLoggedIn()) {
                  return BDConnection(
                    context: ctx,
                    origin:'main',
                    email: value.currentUser().email,
                    pass: value.currentUser().password,
                  );
                }
                return BDConnection();
              },
            ),
          ],
          child: Consumer<ThemeState>(
              builder: (context, state, child) {
                return Consumer<LocalAuthState>(
                    builder: (context, biometricState, child4) {
                      return Consumer<LoginState>(
                          builder: (context, loginProvider, child1) {
                            return MaterialApp(
                              debugShowCheckedModeBanner: false,
                              //title: 'Flutter Demo',
                              theme: state.currentTheme,
                              //Declaramos las rutas de las pantallas a las que vamos a acceder
                              onGenerateRoute: (settings) {
                                if (settings.name == '/cartPage') {

                                  return MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return const CartPage();
                                      });
                                }
                                if (settings.name == '/selectTime') {

                                  return MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return const TimeSelectionPage();
                                      });
                                }
                                if (settings.name == '/register') {

                                  return MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return const RegisterPage();
                                      });
                                }
                                if (settings.name == '/pago') {

                                  return MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return const PaymentPage();
                                      });
                                }
                                if (settings.name == '/Login') {
                                  Object? reason = settings.arguments;
                                  return MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return LoginPage(
                                            reason: reason.toString()
                                        );
                                      });
                                }
                                if (settings.name == '/MainPage') {

                                  return MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return const MainPage();
                                      });
                                }
                                if (settings.name == '/HomePage') {

                                  return MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return const HomePage();
                                      });
                                }
                                if (settings.name == '/chair_selection') {
                                  return MaterialPageRoute(

                                      builder: (BuildContext context) {
                                        Object? args = settings.arguments;
                                        return ChairSelectionPage(
                                          date: args.toString(),
                                        );
                                      });
                                }
                                /*
                                    else if (settings.name == '/edit_reg') {
                                      EditPageParams document = settings
                                          .arguments;
                                      return MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return EditPage(
                                              params: document,
                                            );
                                          });
                                    }
                                    */
                                return null;
                              },
                              //segun el estado decidimos cual pantalla mostrar
                              routes: {
                                '/': (BuildContext context) {
                                  if(!state.isLoading()) {
                                    if (!kIsWeb) {//si estamos en la web hara lo siguiente
                                      if (loginProvider.isLoggedIn()) {
                                        if (biometricState
                                            .isBiometricEnabled() &&
                                            !biometricState
                                                .isBiometricAuthorized()) {
                                          return const MyLocalAuth();//bloqueo con biometricos
                                        } else {
                                          Provider.of<BDConnection>(
                                              context, listen: false);
                                          return const MainPage();//pagina principal del sistema
                                        }
                                      } else {
                                        Provider.of<BDConnection>(
                                            context, listen: false);
                                        return const HomePage();//home page pagina web
                                      }
                                    } else {//si es movil u otra plataforma hara lo siguiente
                                      if (loginProvider.isLoggedIn()) {
                                        if (loginProvider.isAutoLoggedIn() && loginProvider.isGoToHome()) {
                                          Provider.of<BDConnection>(
                                              context, listen: false);
                                          return const HomePage();
                                        } else {
                                          Provider.of<BDConnection>(
                                              context, listen: false);
                                          return const MainPage();
                                        }
                                      } else {
                                        Provider.of<BDConnection>(
                                            context, listen: false);
                                        return const HomePage();
                                      }
                                    }
                                  }else{
                                    return const Center(child: CircularProgressIndicator(),);
                                  }
                                },
                              },
                            );
                          }
                      );
                    }
                );
              }),
        );
      },
    );
  }
}
