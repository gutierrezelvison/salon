import 'package:flutter/material.dart';
import '../../util/states/States.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Util.dart';
import '../db_connection.dart';

class LoginState with ChangeNotifier{
  late SharedPreferences _prefs;

  bool _loggedIn = false;
  bool _loading = true;
  bool _gotoHome = true;
  bool autoLoggedIn = false;

  User user = User();

  LoginState({
    required SharedPreferences preferences,
  }) {
    _prefs = preferences;
    loginState();
  }

  bool isLoggedIn() => _loggedIn;
  bool isGoToHome() => _gotoHome;

  bool isLoading() => _loading;
  bool isAutoLoggedIn() => autoLoggedIn;

  User currentUser() => user;

  Future<void> login(User credentials, BuildContext context,bool stayLoggedIn, String? reason) async {
    final db = Provider.of<BDConnection>(context, listen: false);
    AppData appData = AppData();
    CartState cartState = CartState();
    List<BookingItem> listItem = [];
      for(int i=0;i<cartState.getCartData().length;i++){
        listItem.add(BookingItem(
          business_service_id: cartState.getCartData()[i]['id'],
          quantity: cartState.getCartData()[i]['quantity'],
          chair_id: appData.getChairSelected(),
          unit_price: cartState.getCartData()[i]['price'],
          amount: cartState.getCartData()[i]['quantity'] * cartState.getCartData()[i]['price'],
        ));
      }
    _loading = true;
    notifyListeners();
    final query = await db.login(context,credentials.email!, credentials.password!);
    if(query.isNotEmpty && query[0]!='connection_error' && query[0]!='wrong_pass'){
      if(stayLoggedIn) {
        _prefs.setBool('isLoggedIn', _loggedIn);
        _prefs.setString('userEmail', credentials.email!);
        _prefs.setString('userPass', credentials.password!);
        _prefs.setString('userName', appData.getUserData().name!);
        _prefs.setInt('userRole', appData.getUserData().rol_id!);
      }
      user.name = appData.getUserData().name!;
      //loginState.setLogginStatus(true);

      if(reason == 'booking'){
        appData.setPaymentMethod(await db.getPaymentMethods(context));
        if((await db.setBooking(
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
        ))['success']
        ) {
          appData.setTotalPagar(appData.getTotal());
          cartState.cleanCart(context);
          Navigator.pop(context);
          Navigator.of(context).pushNamed("/pago");
        }
      }else{
        Navigator.pop(context);
      }
      _loading = false;
      _loggedIn = true;
      notifyListeners();
    }else if(query.isNotEmpty && query[0]=='wrong_pass'){
      CustomSnackBar().show(context: context,
          msg:
          'Usuario o contraseña incorrecta, intentelo de nuevo',
          icon: Icons.error,
          color: const Color(0xffFF525C)
      );
      _loading  = false;
      _loggedIn = false;
      notifyListeners();
    }else{
      CustomSnackBar().show(context:context, msg: "No hubo respuesta del servidor, por favor revise su conexión de internet.", icon: Icons.error_rounded, color: Colors.red);
      _loading  = false;
      _loggedIn = false;
      notifyListeners();
    }
  }

  void logout() {
    _prefs.clear();
    _loggedIn = false;
    notifyListeners();
  }

  void gotoHome(bool v){
    _gotoHome = v;
    autoLoggedIn = v;
    notifyListeners();
  }

  void loginState() async {
    if (_prefs.containsKey('isLoggedIn')) {
      user.email = _prefs.getString('userEmail');
      user.password= _prefs.getString('userPass');
      user.name= _prefs.getString('userName');
      user.rol_id= _prefs.getInt('userRole');
      AppData().setUserData(User(rol_id: _prefs.getInt('userRole')));
      _loggedIn = true;
      _loading = false;
      autoLoggedIn = true;
      notifyListeners();
    } else {
      _loading = false;
      notifyListeners();
    }
  }
}